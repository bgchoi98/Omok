package game;

import java.io.IOException;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import javax.servlet.http.HttpSession;
import javax.websocket.CloseReason;
import javax.websocket.EndpointConfig;
import javax.websocket.OnClose;
import javax.websocket.OnError;
import javax.websocket.OnMessage;
import javax.websocket.OnOpen;
import javax.websocket.Session;
import javax.websocket.server.ServerEndpoint;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.google.gson.Gson;
import com.google.gson.JsonObject;

import room.Room;
import room.RoomRepository;
import user.User;
import util.Constants;
import util.webSocketDTOs.GetHttpSessionConfigurator;
import util.webSocketDTOs.MessageType;
import util.webSocketDTOs.WebSocketMessage;

/**
 * 게임 웹소켓 엔드포인트
 */
@ServerEndpoint(
    value = "/game",
    configurator = GetHttpSessionConfigurator.class
)
public class GameWebSocket {
	
	private static final Logger log = LoggerFactory.getLogger(GameWebSocket.class);

	private final Gson gson = new Gson();
	private final GameService gameService = GameService.getInstance();
	private final RoomRepository roomRepository = RoomRepository.getInstance();
	
	// 게임 중인 세션 관리: roomSeq -> (nickname -> Session)
	private static Map<Long, Map<String, Session>> gameRooms = new ConcurrentHashMap<>();

	@OnOpen
	public void onOpen(Session session, EndpointConfig config) {
		// HTTP 세션에서 User 가져오기
        HttpSession httpSession = (HttpSession) config.getUserProperties()
            .get(HttpSession.class.getName());
        
        // 세션 검증
        if (httpSession == null) {
            closeSession(session, "No HTTP session");
            return;
        }
        
        User user = (User) httpSession.getAttribute(Constants.SESSION_KEY);
        
        // 유저 검증
        if (user == null) {
            closeSession(session, "Not authenticated");
            return;
        }
        
        // 세션에 유저 정보 저장
        session.getUserProperties().put("user", user);
        session.getUserProperties().put("nickname", user.getNickname());
        
        log.info("Game WebSocket connected: {}", user.getNickname());
	}
	
	@OnMessage
	public void onMessage(String message, Session session) {
		try {
			User user = (User) session.getUserProperties().get("user");
			if (user == null) {
				log.warn("Message from unauthenticated session");
				return;
			}
			
			String nickname = user.getNickname();
			JsonObject json = gson.fromJson(message, JsonObject.class);
			String type = json.get("type").getAsString();
			
			log.debug("Game message received - type: {}, from: {}", type, nickname);
			
			switch (type) {
			
			case "JOIN_GAME":
				handleJoinGame(session, json, nickname);
				break;
				
			case "MAKE_MOVE":
				handleMakeMove(session, json, nickname);
				break;
				
			case "CHAT":
				handleChat(session, json, nickname);
				break;
				
			default:
				log.warn("Unknown game message type: {}", type);
				sendError(session, "알 수 없는 메시지 타입입니다: " + type);
				break;
			}
			
		} catch (Exception e) {
			log.error("Error processing game message", e);
			sendError(session, "메시지 처리 중 오류가 발생했습니다: " + e.getMessage());
		}
	}
	
	/**
	 * 게임 참여 (플레이어 또는 관전자)
	 */
	private void handleJoinGame(Session session, JsonObject json, String nickname) {
		if (!json.has("roomSeq")) {
			sendError(session, "방 번호가 없습니다.");
			return;
		}
		
		Long roomSeq = json.get("roomSeq").getAsLong();
		Room room = roomRepository.findById(roomSeq);
		
		if (room == null) {
			sendError(session, "방을 찾을 수 없습니다.");
			return;
		}
		
		// roomSeq를 세션에 저장
		session.getUserProperties().put("roomSeq", roomSeq);
		
		// 해당 방의 세션 맵 가져오기 또는 생성
		Map<String, Session> roomSessions = gameRooms.computeIfAbsent(roomSeq, k -> new ConcurrentHashMap<>());
		
		// 기존 세션이 있으면 닫기 (재접속 처리)
		Session oldSession = roomSessions.get(nickname);
		if (oldSession != null && oldSession.isOpen() && !oldSession.equals(session)) {
			log.info("Replacing old session for {} in room {}", nickname, roomSeq);
			closeSession(oldSession, "Reconnected from another session");
		}
		
		// 새 세션 등록
		roomSessions.put(nickname, session);
		
		// 게임 시작 (아직 시작 안했으면)
		boolean gameStarted = gameService.startGame(roomSeq);
		
		// 게임 상태 조회
		GameState gameState = gameService.getGameState(roomSeq);
		
		if (gameState == null) {
			sendError(session, "게임 상태를 불러올 수 없습니다.");
			return;
		}
		
		// 플레이어인지 관전자인지 확인
		boolean isPlayer = gameService.isPlayer(roomSeq, nickname);
		boolean isObserver = gameService.isObserver(roomSeq, nickname);
		
		// 참여 성공 응답
		JsonObject response = new JsonObject();
		response.addProperty("type", "JOIN_GAME_SUCCESS");
		response.addProperty("roomSeq", roomSeq);
		response.addProperty("isPlayer", isPlayer);
		response.addProperty("isObserver", isObserver);
		response.addProperty("blackPlayer", gameState.getBlackPlayer());
		response.addProperty("whitePlayer", gameState.getWhitePlayer());
		response.addProperty("currentTurn", gameState.getCurrentTurn());
		response.addProperty("boardSize", GameState.getBoardSize());
		
		// 보드 상태 전송 (2차원 배열을 JSON으로 변환)
		response.add("board", gson.toJsonTree(gameState.getBoard()));
		
		if (isPlayer) {
			int stone = gameState.getPlayerStone(nickname);
			response.addProperty("myStone", stone);  // 1: 흑돌, 2: 백돌
		}
		
		session.getAsyncRemote().sendText(gson.toJson(response));
		
		log.info("{} joined game room {} as {}", nickname, roomSeq, isPlayer ? "player" : "observer");
		
		// 같은 방의 다른 사람들에게 입장 알림
		broadcastToRoom(roomSeq, createNotification("USER_JOINED", nickname + "님이 " + (isPlayer ? "게임에" : "관전에") + " 참여했습니다."), session);
	}
	
	/**
	 * 착수 처리
	 */
	private void handleMakeMove(Session session, JsonObject json, String nickname) {
		Long roomSeq = (Long) session.getUserProperties().get("roomSeq");
		
		if (roomSeq == null) {
			sendError(session, "게임 방에 참여하지 않았습니다.");
			return;
		}
		
		if (!json.has("row") || !json.has("col")) {
			sendError(session, "착수 위치가 없습니다.");
			return;
		}
		
		int row = json.get("row").getAsInt();
		int col = json.get("col").getAsInt();
		
		// 플레이어인지 확인
		if (!gameService.isPlayer(roomSeq, nickname)) {
			sendError(session, "플레이어만 착수할 수 있습니다.");
			return;
		}
		
		// 착수 시도
		boolean success = gameService.makeMove(roomSeq, row, col, nickname);
		
		if (!success) {
			sendError(session, "착수에 실패했습니다. (차례가 아니거나 이미 돌이 있습니다)");
			return;
		}
		
		// 게임 상태 조회
		GameState gameState = gameService.getGameState(roomSeq);
		
		if (gameState == null) {
			sendError(session, "게임 상태를 찾을 수 없습니다.");
			return;
		}
		
		int stone = gameState.getPlayerStone(nickname);
		
		// 착수 성공 메시지 브로드캐스트
		JsonObject moveMsg = new JsonObject();
		moveMsg.addProperty("type", "MOVE");
		moveMsg.addProperty("row", row);
		moveMsg.addProperty("col", col);
		moveMsg.addProperty("stone", stone);
		moveMsg.addProperty("player", nickname);
		moveMsg.addProperty("currentTurn", gameState.getCurrentTurn());
		
		broadcastToRoom(roomSeq, gson.toJson(moveMsg), null);
		
		log.info("Move made in room {}: ({}, {}) by {}", roomSeq, row, col, nickname);
		
		// 게임 종료 확인
		if (gameState.isGameOver()) {
			handleGameOver(roomSeq, gameState);
		}
	}
	
	/**
	 * 채팅 처리
	 */
	private void handleChat(Session session, JsonObject json, String nickname) {
		Long roomSeq = (Long) session.getUserProperties().get("roomSeq");
		
		if (roomSeq == null) {
			sendError(session, "게임 방에 참여하지 않았습니다.");
			return;
		}
		
		if (!json.has("message")) {
			sendError(session, "메시지가 없습니다.");
			return;
		}
		
		String message = json.get("message").getAsString();
		
		// 채팅 메시지 브로드캐스트
		JsonObject chatMsg = new JsonObject();
		chatMsg.addProperty("type", "CHAT");
		chatMsg.addProperty("sender", nickname);
		chatMsg.addProperty("message", message);
		chatMsg.addProperty("timestamp", System.currentTimeMillis());
		
		broadcastToRoom(roomSeq, gson.toJson(chatMsg), null);
		
		log.debug("Chat in room {}: {} - {}", roomSeq, nickname, message);
	}
	
	/**
	 * 게임 종료 처리
	 */
	private void handleGameOver(Long roomSeq, GameState gameState) {
		String winner = gameState.getWinner();
		
		JsonObject gameOverMsg = new JsonObject();
		gameOverMsg.addProperty("type", "GAME_OVER");
		
		if ("DRAW".equals(winner)) {
			gameOverMsg.addProperty("result", "DRAW");
			gameOverMsg.addProperty("message", "무승부입니다!");
		} else {
			gameOverMsg.addProperty("result", "WIN");
			gameOverMsg.addProperty("winner", winner);
			gameOverMsg.addProperty("message", winner + "님이 승리했습니다!");
		}
		
		broadcastToRoom(roomSeq, gson.toJson(gameOverMsg), null);
		
		log.info("Game over in room {}: winner = {}", roomSeq, winner);
	}
	
	/**
	 * 특정 방의 모든 세션에 메시지 브로드캐스트
	 * @param roomSeq 방 번호
	 * @param message 메시지
	 * @param except 제외할 세션 (null이면 모두에게 전송)
	 */
	private void broadcastToRoom(Long roomSeq, String message, Session except) {
		Map<String, Session> roomSessions = gameRooms.get(roomSeq);
		
		if (roomSessions == null) {
			return;
		}
		
		for (Session s : roomSessions.values()) {
			if (s != null && s.isOpen() && !s.equals(except)) {
				try {
					s.getAsyncRemote().sendText(message);
				} catch (Exception e) {
					log.error("Error broadcasting to session", e);
				}
			}
		}
	}
	
	/**
	 * 알림 메시지 생성
	 */
	private String createNotification(String notificationType, String message) {
		JsonObject notification = new JsonObject();
		notification.addProperty("type", "NOTIFICATION");
		notification.addProperty("notificationType", notificationType);
		notification.addProperty("message", message);
		return gson.toJson(notification);
	}
	
	@OnClose
	public void onClose(Session session) {
		String nickname = (String) session.getUserProperties().get("nickname");
		Long roomSeq = (Long) session.getUserProperties().get("roomSeq");
		
		if (nickname != null && roomSeq != null) {
			Map<String, Session> roomSessions = gameRooms.get(roomSeq);
			if (roomSessions != null) {
				roomSessions.remove(nickname);
				
				// 방이 비었으면 맵에서 제거
				if (roomSessions.isEmpty()) {
					gameRooms.remove(roomSeq);
				}
				
				log.info("{} disconnected from game room {}", nickname, roomSeq);
				
				// 다른 사람들에게 퇴장 알림
				broadcastToRoom(roomSeq, createNotification("USER_LEFT", nickname + "님이 나갔습니다."), null);
			}
		}
	}
	
	@OnError
	public void onError(Session session, Throwable t) {
		String nickname = (String) session.getUserProperties().get("nickname");
		log.error("Game WebSocket error for user {}: {}", nickname != null ? nickname : "unknown", t.getMessage(), t);
	}
	
	/**
	 * 웹소켓 세션 닫기
	 */
	private void closeSession(Session session, String reason) {
		try {
			if (session.isOpen()) {
				session.close(new CloseReason(
					CloseReason.CloseCodes.VIOLATED_POLICY,
					reason
				));
			}
		} catch (IOException e) {
			log.error("Error closing session: {}", e.getMessage());
		}
	}
	
	/**
	 * 에러 메시지 전송
	 */
	private void sendError(Session session, String errorMsg) {
		WebSocketMessage message = new WebSocketMessage(MessageType.ERROR, null, errorMsg);
		try {
			if (session.isOpen()) {
				session.getBasicRemote().sendText(gson.toJson(message));
			}
		} catch (IOException e) {
			log.error("Error sending error message: {}", e.getMessage());
		}
	}
}
