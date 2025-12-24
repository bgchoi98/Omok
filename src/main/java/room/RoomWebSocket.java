package room;

import java.io.IOException;
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

import com.google.gson.Gson;
import com.google.gson.JsonObject;

import game.GameUser;
import user.User;
import util.Constants;
import util.webSocketDTOs.GetHttpSessionConfigurator;
import util.webSocketDTOs.MessageType;
import util.webSocketDTOs.WebSocketMessage;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@ServerEndpoint(value = "/lobby", configurator = GetHttpSessionConfigurator.class)
public class RoomWebSocket {

	private static final Logger log = LoggerFactory.getLogger(RoomWebSocket.class);

	private final Gson gson = new Gson();
	private static final RoomService roomService = RoomService.getInstance();

	private static Map<Session, LobbyUser> sessionToUser = new ConcurrentHashMap<>(); // 세션 -> 로비 유저 조회
	private static Map<String, Session> nicknameToSession = new ConcurrentHashMap<>(); // 닉네임 -> 세션 조회

	@OnOpen
	public void onOpen(Session session, EndpointConfig config) {
		// HTTP 세션에서 User 가져오기
		HttpSession httpSession = (HttpSession) config.getUserProperties().get(HttpSession.class.getName());

		// 세션 검증
		if (httpSession == null) {
			closeSession(session, "No HTTP session");
			return;
		}

		// 유저 검증
		User user = (User) httpSession.getAttribute(Constants.SESSION_KEY);
		if (user == null) {
			closeSession(session, "Not authenticated");
			return;
		}

		// 검증 통과 시 닉네임 조회
		String nickname = user.getNickname();

		// 재접속일 경우(이미 접속 중이었을 때) 이전 세션 종료
		Session oldSession = nicknameToSession.get(nickname);
		if (oldSession != null && oldSession.isOpen() && !oldSession.equals(session)) {
			log.info("Duplicated connection for {}", nickname);
			sessionToUser.remove(oldSession);
			closeSession(oldSession, "Duplicate connection");
		}

		LobbyUser lobbyUser = new LobbyUser(nickname);
		// 양방향 맵에 모두 저장
		sessionToUser.put(session, lobbyUser);
		nicknameToSession.put(nickname, session);

		sendRoomListToLobbyUser(session, lobbyUser);
		System.out.println("소켓 세션아이디 확인용 : " + session.getId());
		log.info("LobbyUser connected userId={}", nickname);
	}

	@OnMessage
	public void onMessage(String message, Session session) {

		try {
			LobbyUser currentUser = sessionToUser.get(session);
			// 검증
			if (currentUser == null) {
				log.warn("Message from unknown session");
				return;
			}

			Set<Session> allSessions = sessionToUser.keySet();
			JsonObject json = gson.fromJson(message, JsonObject.class);
			String type = json.get("type").getAsString();

			switch (type) {

			// 게임 종료 후, 또는 랭킹에서 메인 페이지로 돌아올 때 로비 신호
			// OnOpen으로 sendRoomListToLobbyUser 메서드를 한 번 실행하기 때문에 OnMessage로 실행할 필요가 없다.
			/*
			 * case "LOBBY": roomService.sendRoomListToLobbyUser(session, currentUser);
			 * log.info("LOBBY request from: {}", currentUser.getNickName()); break;
			 */

			case "CREATE_ROOM":
				Room room = roomService.createRoom(currentUser, allSessions);
				broadcastRoomList(allSessions);
				log.info("Room created by: {}, roomSeq: {}", currentUser.getNickName(), room.getRoomSeq());

				// 방 생성자에게 성공 응답 전송
				JsonObject response = new JsonObject();
				response.addProperty("type", "ROOM_CREATED");
				response.addProperty("roomSeq", room.getRoomSeq());
				response.addProperty("status", "WAITING");
				response.addProperty("message", "방이 생성되었습니다.");
				session.getAsyncRemote().sendText(gson.toJson(response));
				break;

			case "JOIN_ROOM":
				// 검증
				if (!json.has("roomId")) {
					sendError(session, "방 ID가 없습니다.");
					break;
				}
				System.out.println("확인용" + json.get("roomId"));

				Long joinRoomId = json.get("roomId").getAsLong();
				Room findRoom = roomService.findRoom(joinRoomId);

				if (findRoom == null) {
					sendError(session, "방을 찾을 수 없습니다.");
					break;
				}

				boolean joined = roomService.joinRoom(findRoom, currentUser);
				if (joined) {
					log.info("{} joined room {}", currentUser.getNickName(), joinRoomId);

					// 방 리스트 업데이트 브로드캐스트
					broadcastRoomList(allSessions);

					// 2명이 모두 모였을 때 게임 시작 메시지 전송
					if (findRoom.isFull()) {
						JsonObject startMsg = new JsonObject();
						startMsg.addProperty("type", "START");
						startMsg.addProperty("roomId", findRoom.getRoomSeq());
						String startJson = gson.toJson(startMsg);

						// 닉네임으로 세션 조회
						for (GameUser gameUser : findRoom.getGameUsers()) {
							Session playerSession = nicknameToSession.get(gameUser.getNickName());
							if (playerSession != null && playerSession.isOpen()) {
								playerSession.getAsyncRemote().sendText(startJson);
								log.info("START message sent to: {}", gameUser.getNickName());
							}
						}
					}
				} else {
					sendError(session, "방 입장에 실패했습니다. (방이 가득 찼거나 게임이 시작되었습니다)");
				}
				break;

			case "OBSERVE_ROOM":
				// 검증
				if (!json.has("roomId")) {
					sendError(session, "방 ID가 없습니다.");
					break;
				}

				Long observingRoomId = json.get("roomId").getAsLong();
				Room observeRoom = roomService.findRoom(observingRoomId);

				// 검증
				if (observeRoom == null) {
					sendError(session, "방을 찾을 수 없습니다.");
					break;
				}

				boolean observeSuccess = roomService.observe(currentUser, observeRoom);
				if (observeSuccess) {
					log.info("{} started observing room {}", currentUser.getNickName(), observingRoomId);
					// 방 리스트 업데이트 브로드캐스트
					broadcastRoomList(allSessions);
					// 관전 성공 응답 전송
					JsonObject observeResponse = new JsonObject();
					// 게임유저와 동일하게 게임페이지 가면될거같아서 주석처리해놈 BGHOI
					// observeResponse.addProperty("type", "OBSERVE_SUCCESS");
					observeResponse.addProperty("type", "START");
					observeResponse.addProperty("roomId", observingRoomId);
					observeResponse.addProperty("message", "관전을 시작합니다.");
					session.getAsyncRemote().sendText(gson.toJson(observeResponse));
				} else {
					sendError(session, "게임중이거나 관전인원이 꽉 찼습니다");
				}
				break;

			case "DELETE_ROOM":
				// 검증
				if (!json.has("data") || !json.get("data").isJsonObject()) {
					sendError(session, "data 객체가 없습니다.");
					break;
				}

				JsonObject deleteData = json.getAsJsonObject("data");

				if (!deleteData.has("roomId") || !deleteData.get("roomId").isJsonPrimitive()) {
					sendError(session, "roomId가 유효하지 않습니다.");
					break;
				}

				long roomSeq = deleteData.get("roomId").getAsLong();
				System.out.println("룸삭제 테스트 :" + roomSeq);
				// 방장 확인 및 상태 검증 포함된 삭제
				boolean deleted = roomService.deleteRoom(roomSeq, currentUser.getNickName(), allSessions);

				if (deleted) {
					log.info("Room {} deleted by {}", roomSeq, currentUser.getNickName());

					// 삭제 성공 응답
//                	JsonObject deleteResponse = new JsonObject();
//                	deleteResponse.addProperty("type", "ROOM_DELETED");
//                	deleteResponse.addProperty("roomSeq", roomSeq);
//                	deleteResponse.addProperty("message", "방이 삭제되었습니다.");
//                	session.getBasicRemote().sendText(gson.toJson(deleteResponse));
					broadcastRoomList(allSessions);
				} else {
					sendError(session, "방 삭제에 실패했습니다. (권한이 없거나 게임이 진행 중입니다)");
				}
				break;

			default:
				log.warn("Unknown message type: {}", type);
				sendError(session, "알 수 없는 메시지 타입입니다: " + type);
				break;
			}

		} catch (Exception e) {
			log.error("Error processing message from {}: {}",
					sessionToUser.get(session) != null ? sessionToUser.get(session).getNickName() : "unknown",
					e.getMessage(), e);
			sendError(session, "메시지 처리 중 오류가 발생했습니다: " + e.getMessage());
		}
	}

	@OnClose
	public void onClose(Session session) {
		LobbyUser lobbyUser = sessionToUser.get(session);
		if (lobbyUser != null) {
			log.info("LobbyUser disconnected: {}", lobbyUser.getNickName());

			// 양방향 맵에서 모두 제거
			sessionToUser.remove(session);
			nicknameToSession.remove(lobbyUser.getNickName(), session);
		}

		// 룸매칭중 새로고침시 삭제처리
		// 룸 매칭버튼 클릭 시 해당 소켓이 종료되고 게임소켓으로 열림
		Room room = roomService.findByHostNickname(lobbyUser.getNickName());
		if (room == null)
			return;
		if (room.getRoomStatus() == RoomStatus.WAITING) {
			roomService.deleteRoom_Refresh(room.getRoomSeq(), lobbyUser.getNickName());
			broadcastRoomList(sessionToUser.keySet());
		}

	}

	@OnError
	public void onError(Session session, Throwable t) {
		LobbyUser lobbyUser = sessionToUser.get(session);
		String nickname = lobbyUser != null ? lobbyUser.getNickName() : "unknown";
		log.error("WebSocket error for user {}: {}", nickname, t.getMessage(), t);
	}

	/**
	 * 웹소켓 세션 닫기
	 * 
	 * @param session 닫을 세션
	 * @param reason  닫는 이유
	 */
	private void closeSession(Session session, String reason) {
		try {
			if (session.isOpen()) {
				session.close(new CloseReason(CloseReason.CloseCodes.VIOLATED_POLICY, reason));
			}
		} catch (IOException e) {
			log.error("Error closing session: {}", e.getMessage());
		}
	}

	/**
	 * 에러 메시지 전송
	 * 
	 * @param session  전송할 세션
	 * @param errorMsg 에러 메시지
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

	/**
	 * 특정 유저에게 방 리스트 전송
	 * 
	 * @param session   전송할 세션
	 * @param lobbyUser 유저 정보
	 */
	public void sendRoomListToLobbyUser(Session session, LobbyUser lobbyUser) {
		try {
			if (!session.isOpen()) {
				return;
			}
			String json = roomService.createRoomListJson();
			session.getBasicRemote().sendText(json);
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	// 변경
	public static void broadcastRoomList(Set<Session> sessions) {
		String json = roomService.createRoomListJson();
		for (Session session : sessions) {
			if (!session.isOpen())
				continue;
			synchronized (session) {
				try {
					session.getBasicRemote().sendText(json);
				} catch (IOException e) {

				}
			}
		}
	}

	// 게임 종료 및 이탈 시 로비유저 최신화
	public static void LobbyUserSessionbroadCase() {
//		LobbyUser lobbyUserSession = new LobbyUser(sessionToUser.keySet());
//		broadcastRoomList(lobbyUserSession.getLobbyUserSession());
		broadcastRoomList(sessionToUser.keySet()); // 수정 sh

	}

}
