package game;

import java.io.IOException;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;
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
import room.RoomStatus;
import user.User;
import util.Constants;
import util.webSocketDTOs.GetHttpSessionConfigurator;
import util.webSocketDTOs.MessageType;
import util.webSocketDTOs.WebSocketMessage;


@ServerEndpoint(
    value = "/game",
    configurator = GetHttpSessionConfigurator.class
)
public class GameWebSocket {
	
	private static final Logger log = LoggerFactory.getLogger(GameWebSocket.class);

	private final Gson gson = new Gson();
	private final GameService gameService = GameService.getInstance();
	private final RoomRepository roomRepository = RoomRepository.getInstance();
	
	
	// 각 방들과 그에 해당하는 웹소켓 세션들: roomSeq -> Set<Session>
	private static Map<Long, Set<Session>> roomSessions = new ConcurrentHashMap<>();
	
	// 세션으로 닉네임 조회, session -> nickname
	private static Map<Session, String> sessionNicknameMap = new ConcurrentHashMap<>();

	// 세션으로 현재 들어가있는 방 조회, session -> roomSeq
	private static Map<Session, Long> sessionRoomMap = new ConcurrentHashMap<>();



	// 게임 방에 들어왔을 때
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
        
        // HTTP 세션 정보로 유저 신원 조회
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
	
	// 게임 방 속 게임 유저, 관전자가 행동을 수행했을 때
	@OnMessage
	public void onMessage(String message, Session session) {
		try {
			User user = (User) session.getUserProperties().get("user");
			if (user == null) {
				log.warn("Message from unauthenticated session");
				return;
			}
			
			// 파싱
			// 프론트에서 받아와야 할 데이터 : roomSeq,
			String nickname = user.getNickname();
			JsonObject json = gson.fromJson(message, JsonObject.class);
			String type = json.get("type").getAsString();
			
			log.debug("Game message received - type: {}, from: {}", type, nickname);
			
			switch (type) {
			
			// 1. 게임 방 참여 (게임 플레이어, 관전)
			case "JOIN_GAME":
				joinGame(session, json, nickname);
				break;
				
			// 2. 돌 착수
			case "MAKE_MOVE":
				makeMove(session, json, nickname);
				break;
			
			// 3. 채팅
			case "CHAT":
				chat(session, json, nickname);
				break;
			
			// 4. 기권/나가기
			case "EXIT":
			    handleExit(session, nickname);
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
	
	// game.jsp -> main.jsp 로 이동 시 (게임 종료 혹은 관전 나가기, 게임 탈주)
//	@OnClose
//	public void onClose(Session session) {
//		
//	    // 맵에서 nickname, roomSeq 가져오기
//	    String nickname = sessionNicknameMap.get(session);
//	    Long roomSeq = sessionRoomMap.get(session);
//
//	    if (nickname != null && roomSeq != null) {
//	        // 방에 해당하는 모든 세션들 조회
//	        Set<Session> sessions = roomSessions.get(roomSeq);
//	        if (sessions != null) {
//	        	// 나간 사람의 웹소켓 세션 삭제
//	            sessions.remove(session);
//	            
//	            // 방에 웹소켓 세션이 하나도 없을 경우 방 삭제
//	            if (sessions.isEmpty()) {
//					roomRepository.deleteRoom(roomSeq);
//					roomSessions.remove(roomSeq);
//	            }
//	        }
//	    }
	@OnClose
	public void onClose(Session session) {

	    String nickname = sessionNicknameMap.get(session);
	    Long roomSeq = sessionRoomMap.get(session);

	    if (nickname != null && roomSeq != null) {

	        // 게임 유저 & 게임 진행 중이면 → 기권 처리
	        if (gameService.isGameUser(roomSeq, nickname)) {
	            GameState gameState = gameService.getGameState(roomSeq);

	            if (gameState != null && !gameState.isGameOver()) {
	                gameState.quit(nickname);

	                String winner = gameState.getWinner();

	                JsonObject msg = new JsonObject();
	                msg.addProperty("type", "GAME_OVER");
	                msg.addProperty("result", "WIN");
	                msg.addProperty("winner", winner);
	                msg.addProperty(
	                    "message",
	                    nickname + "님이 게임을 나가 " + winner + "님이 승리했습니다."
	                );

	                broadcastToRoom(roomSeq, gson.toJson(msg), session);

	                Room room = roomRepository.findById(roomSeq);
	                if (room != null) {
	                    room.setRoomStatus(RoomStatus.END);
	                }
	            }
	        }
	    }
	    // 세션 관련 정보 제거
	    sessionNicknameMap.remove(session);
	    sessionRoomMap.remove(session);
	}

	
	@OnError
	public void onError(Session session, Throwable t) {
		String nickname = (String) session.getUserProperties().get("nickname");
		log.error("Game WebSocket error for user {}: {}", nickname != null ? nickname : "unknown", t.getMessage(), t);
	}
	
	
	/*
	---------------------------------------------------------------------------------------------------
	---------------------------------------------------------------------------------------------------
	---------------------------------------------------------------------------------------------------
	---------------------------------------------------------------------------------------------------
	---------------------------------------------------------------------------------------------------
	---------------------------------------------------------------------------------------------------
	여기까지 onOpen, onMessage, onClose, onError 
	*/
	
	
	// 1. 게임 방 참여 (게임 플레이어, 관전)
	private void joinGame(Session session, JsonObject json, String nickname) {
		
		// 프론트에서 JSON 으로 roomSeq을 받아와야 한다.
		if (!json.has("roomSeq")) {
			sendError(session, "방 번호가 없습니다.");
			return;
		}
		
		Long roomSeq = json.get("roomSeq").getAsLong();
		Room room = roomRepository.findById(roomSeq); // JSON 으로 받아온 roomSeq 을 통해 Room 을 리포지토리에서 조회
		
		if (room == null) {
			sendError(session, "방을 찾을 수 없습니다.");
			return;
		}
		
		// roomSeq를 웹소켓 세션에 저장 -> 이 시점부터 웹 소켓 세션에는 User, userNickName, roomSeq 총 3개의 데이터가 들어있다.
		session.getUserProperties().put("roomSeq", roomSeq);
		
		// 세션 관리 
		Set<Session> sessions = roomSessions.get(roomSeq);
		if (sessions == null) {
		    synchronized (roomSessions) {
		        sessions = roomSessions.get(roomSeq);
		        // 처음 들어온 유저라면
		        if (sessions == null) {
		            sessions = ConcurrentHashMap.newKeySet();
		            roomSessions.put(roomSeq, sessions);
		        }
		    }
		}
		
		// 기존 세션이 있으면 닫기 (재접속 처리) , 나간 사람이 다시 들어올 경우
		Iterator<Session> iterator = sessions.iterator();
		while (iterator.hasNext()) {
		    Session s = iterator.next();
		    String oldNickname = sessionNicknameMap.get(s);
		    if (nickname.equals(oldNickname) && s.isOpen() && !s.equals(session)) {
		        closeSession(s, "Reconnected from another session");
		        iterator.remove();  
		        sessionNicknameMap.remove(s);
		        sessionRoomMap.remove(s);
		        break;
		    }
		}
		

		// 새 세션 등록
		sessions.add(session);
		sessionNicknameMap.put(session, nickname);
		sessionRoomMap.put(session, roomSeq);
		

		// 게임 검증
	    boolean gameStarted = gameService.startGame(roomSeq);
	    
	    if (gameStarted) {
	        log.info("Game started for room {}", roomSeq);
	    } else {
	        log.info("Game not started or already started for room {}", roomSeq);
	    }
	    
	    GameState gameState = gameService.getGameState(roomSeq);
	    
	    boolean isGameUser = gameService.isGameUser(roomSeq, nickname);
	    boolean isObserver = gameService.isObserver(roomSeq, nickname);

	    if (gameState == null) {
	        // 게임이 아직 시작되지 않았을 경우
	        if (isGameUser) {
	            // 대기 중인 플레이어에게 응답
	            JsonObject response = new JsonObject();
	            response.addProperty("type", "WAITING_FOR_PLAYER");
	            response.addProperty("roomSeq", roomSeq);
	            response.addProperty("message", "상대방을 기다리는 중입니다...");
	            
	            session.getAsyncRemote().sendText(gson.toJson(response));
	            log.info("{} is waiting for another player in room {}", nickname, roomSeq);
	            return;
	        } else {
	            // 관전자가 게임 시작 전 방에 들어오려 함 -> 프론트 단에서 잡아두기 때문에 발생 가능성은 거의 없음
	            sendError(session, "아직 게임이 시작되지 않았습니다.");
	            
	            // 등록했던 세션 제거
	            sessions.remove(session);
	            sessionNicknameMap.remove(session);
	            sessionRoomMap.remove(session);
	            return;
	        }
	    }
		// 옵저버 접속의 경우 기존 게임내역 확인을위해 별도 map내역 프론트단 전송 bgchoi
        if (isObserver) {
            // 1. GameState의 board를 그대로 JSON으로 보내기
            JsonObject response = new JsonObject();
            response.addProperty("type", "JOIN_OBSERVER");
            response.addProperty("roomSeq", roomSeq);
            response.addProperty("currentTurn", gameState.getCurrentTurn());
            response.add("board", gson.toJsonTree(gameState.getBoard())); // int[][] 그대로 전송

            session.getAsyncRemote().sendText(gson.toJson(response));
            return; // 관전자 초기화 끝
        }
		
		
		// 프론트에 JSON 객체 전달
	    JsonObject response = new JsonObject();
	    response.addProperty("type", "JOIN_GAME_SUCCESS");
	    response.addProperty("roomSeq", roomSeq);
	    response.addProperty("isPlayer", isGameUser);
	    response.addProperty("isObserver", isObserver);
	    response.addProperty("blackPlayer", gameState.getBlackPlayer());
	    response.addProperty("whitePlayer", gameState.getWhitePlayer());
	    response.addProperty("currentTurn", gameState.getCurrentTurn());
	    response.addProperty("boardSize", GameState.getBoardSize());

	    // ADD: 아바타 정보 전송 (서버 상태에서 가져옴)
	    Integer p1Avatar = room.getP1Avatar();
	    Integer p2Avatar = room.getP2Avatar();
	    if (p1Avatar != null) {
	        response.addProperty("p1Avatar", p1Avatar);
	    }
	    if (p2Avatar != null) {
	        response.addProperty("p2Avatar", p2Avatar);
	    }

	    // 객체 배열은 add
	    response.add("board", gson.toJsonTree(gameState.getBoard()));

	    if (isGameUser) {
	        int stone = gameState.getPlayerStone(nickname);
	        response.addProperty("myStone", stone);
	    }
	    
		
		// 비동기로 클라이언트에 전달 (실시간 전달)
		session.getAsyncRemote().sendText(gson.toJson(response));
		
		log.info("{} joined game room {} as {}", nickname, roomSeq, isGameUser ? "gameUser" : "observer");
		
		// 브로드캐스팅
		broadcastToRoom(roomSeq, createNotification("USER_JOINED", nickname + "님이 " + (isGameUser ? "게임에" : "관전에") + " 참여했습니다."), session);
	}
	

	// 2. 돌 착수 처리
	private void makeMove(Session session, JsonObject json, String nickname) {
		Long roomSeq = (Long) session.getUserProperties().get("roomSeq");
		
		// room 검증
		if (roomSeq == null) {
			sendError(session, "게임 방에 참여하지 않았습니다.");
			return;
		}
		
		//  프론트에서 JSON 으로 row, col 을 받아야 한다.
		if (!json.has("row") || !json.has("col")) {
			sendError(session, "착수 위치가 없습니다.");
			return;
		}
		
		int row = json.get("row").getAsInt();
		int col = json.get("col").getAsInt();
		
		// 게임 유저인지 검증 (관전자는 돌을 둘 수 없으며 프론트단에서 먼저 돌을 못두도록 막아둬야 한다) 
		if (!gameService.isGameUser(roomSeq, nickname)) {
			sendError(session, "플레이어만 착수할 수 있습니다.");
			return;
		}
		
		// 착수 
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
		if (gameService.isGameOver(roomSeq)) {
			gameOver(roomSeq);
		}
	}
	

	// 3. 채팅 (관전자, 게임 유저 모두 가능)
	private void chat(Session session, JsonObject json, String nickname) {
		Long roomSeq = (Long) session.getUserProperties().get("roomSeq");
		
		// roomSeq, JSON 검증
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
		chatMsg.addProperty("timestamp", System.currentTimeMillis()); // 채팅 시 현재 시간 출력
		
		broadcastToRoom(roomSeq, gson.toJson(chatMsg), null);
		
		log.debug("Chat in room {}: {} - {}", roomSeq, nickname, message);
	}
	
	// 4. 기권 처리 
	private void handleExit(Session session, String nickname) {

	    Long roomSeq = sessionRoomMap.get(session);
	    if (roomSeq == null) {
	        return;
	    }

	    // 게임 유저가 아니면 (관전자) → 그냥 나가기
	    if (!gameService.isGameUser(roomSeq, nickname)) {
	        return;
	    }

	    GameState gameState = gameService.getGameState(roomSeq);
	    if (gameState == null || gameState.isGameOver()) {
	        return;
	    }

	    // 기권 처리
	    gameState.quit(nickname);

	    String winner = gameState.getWinner();

	    JsonObject msg = new JsonObject();
	    msg.addProperty("type", "GAME_OVER");
	    msg.addProperty("result", "WIN");
	    msg.addProperty("winner", winner);
	    msg.addProperty(
	        "message",
	        nickname + "님이 기권하여 " + winner + "님이 승리했습니다."
	    );

	    broadcastToRoom(roomSeq, gson.toJson(msg), null);

	    // 방 상태 종료
	    Room room = roomRepository.findById(roomSeq);
	    if (room != null) {
	        room.setRoomStatus(RoomStatus.END);
	    }

	    log.info("Player quit: roomSeq={}, quitter={}, winner={}", roomSeq, nickname, winner);
	}

	/*
	---------------------------------------------------------------------------------------------------
	---------------------------------------------------------------------------------------------------
	---------------------------------------------------------------------------------------------------
	---------------------------------------------------------------------------------------------------
	---------------------------------------------------------------------------------------------------
	---------------------------------------------------------------------------------------------------
	여기까지 onMessage -> joinGame, makeMove, chat
	*/
	
	// makeMove 끝단에서 사용 
	private void gameOver(Long roomSeq) {
		String winner = gameService.getWinner(roomSeq);
		
	    if (winner == null) {
	        log.warn("gameOver: Winner is null, roomSeq={}", roomSeq);
	        return;
	    }
		
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

		// 현재 룸
		Room room = roomRepository.findById(roomSeq);
		if (room != null) {
			room.setRoomStatus(RoomStatus.END);
		}

		log.info("Game over in room {}: winner = {}", roomSeq, winner);
	}
	
	// 브로드캐스트
	private void broadcastToRoom(Long roomSeq, String message, Session except) {

	    Set<Session> sessions = roomSessions.get(roomSeq);
	    
	    if (sessions == null) {
	        return;
	    }
	    // 순회, 메시지 비동기로 전송
	    for (Session s : sessions) {
	        if (s != null && s.isOpen() && !s.equals(except)) {
	            try {
	                s.getAsyncRemote().sendText(message);
	            } catch (Exception e) {
	                log.error("Error broadcasting to session", e);
	            }
	        }
	    }
	}
	

	// 프론트에 전달하는 알림 메시지
	private String createNotification(String notificationType, String message) {
		JsonObject notification = new JsonObject();
		notification.addProperty("type", "NOTIFICATION");
		notification.addProperty("notificationType", notificationType);
		notification.addProperty("message", message);
		return gson.toJson(notification);
	}
	
	// 웹소켓 세션 종료
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
	

	// 프론트에 에러 메시지 전송
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
