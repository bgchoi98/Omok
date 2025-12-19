package room;

import java.io.IOException;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

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
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;

import user.User;
import user.UserService;
import util.Constants;
import util.webSocketDTOs.GetHttpSessionConfigurator;
import util.webSocketDTOs.MessageType;
import util.webSocketDTOs.WebSocketMessage;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@ServerEndpoint(
	    value = "/lobby",
	    configurator = GetHttpSessionConfigurator.class
	    // HTTP 세션(HttpSession)을 WebSocket으로 넘기기 위해 쓰는 장치
	)

public class RoomWebSocket {
	
	private static final Logger log = LoggerFactory.getLogger(RoomWebSocket.class);

	private final Gson gson = new Gson();
	
    private final RoomService roomService = RoomService.getInstance();
    private final UserService userService = UserService.getInstance();
    
    private static Map<Session, LobbyUser> map = new HashMap<>();
	
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
        
        // 세션으로 유저 검증
        if (user == null) {
            closeSession(session, "Not authenticated");
            return;
        }
        
        LobbyUser lobbyUser = new LobbyUser(user.getNickname());
        map.put(session, lobbyUser);
        
        //roomService.addSession(session); // 세션 저장
        roomService.sendRoomListToLobbyUser(session, lobbyUser); // 세션(사용자)에게 룸리스트 전달
        
        //session.getUserProperties().put("user", user);
        log.info("LobbyUser connected userId={}", lobbyUser.getNickName());
	}
	
	@OnMessage
	public void onMessage(String message, Session session) {
		
		try {
        	/* 세션에서 회원 조회
            User user = (User) session.getUserProperties().get("user");
            if (user == null) {
                return;
            }
            */
			
			LobbyUser getUser = map.get(session);
			 if (getUser == null) {
	                return;
	         }
			
            // 
            JsonObject json = gson.fromJson(message, JsonObject.class);
            String type = json.get("type").getAsString();
           
            switch (type) {
            case "LOBBY":
            	roomService.sendRoomListToLobbyUser(session, getUser);
                log.info("onMessage work : {}, userNickName : {}", type, getUser.getNickName());
                break;
            case "CREATE_ROOM":
                /*J8sonObject createData = json.getAsJsonObject("data");
                int createUserSeq = createData.get("UserSeq").getAsInt();
                
                User findUser = userService.findById(createUserSeq);
               
            	String lobbyUserNickName = getUser.getNickName();
            	User findUser = userService.findByNickName(lobbyUserNickName);
                
                LobbyUser createRoomLobbyUser = new LobbyUser(findUser.getNickname(), session);
                */
                Room room = roomService.createRoom(getUser);
                
                break;
                
            case "JOIN_ROOM":
            	/*JsonObject joinData = json.getAsJsonObject("data");
                JsonArray joinArr = joinData.get("UserSeq").getAsJsonArray();
                
                int joinUserSeq = joinArr.get(0).getAsInt();
                long roomSeq = joinArr.get(1).getAsLong();
                
                
                User joinUser = userService.findById(joinUserSeq);
                
                LobbyUser joinRoomLobbyUser = new LobbyUser(joinUser.getNickname());
                */
            	JsonObject joinData = json.getAsJsonObject("roomId");
            	Long joinRoomId = joinData.get("roomId").getAsLong();
                Room findRoom = roomService.findRoom(joinRoomId); 
            	
                roomService.joinRoom(findRoom, getUser);
                
                
                for (Session mapSession : map.keySet()) {
                	roomService.sendRoomListToLobbyUser(mapSession, map.get(mapSession)); 
                }
            
                break;

            case "OBSERVE_ROOM":
            	JsonObject observeData = json.getAsJsonObject("roomId");
            	Long observingRoomId = observeData.get("roomId").getAsLong();
            	
            	Room observeRoom = roomService.findRoom(observingRoomId);
            	
            	roomService.observe(getUser, observeRoom);
            	log.info("onMessage work : {}, userNickName : {}", type, getUser.getNickName());
            	break;
            	
            case "DELETE_ROOM":
                JsonObject deleteData = json.getAsJsonObject("data");
                long roomSeq = deleteData.get("roomSeq").getAsLong();
                roomService.deleteRoom(roomSeq);
                break;
            default:
            	log.info("Unkown message type : " + type);
                break;
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            sendError(session, "메시지 처리 중 오류 발생");
        }
		
	}
	
	@OnClose
	public void onClose(Session session) {
		User user = (User) session.getUserProperties().get("user");
        if (user != null) {
        	log.info("WaitingRoom connected userId={}", user.getUserId());
        }
	        
        // RoomService에서 대기실에 연결된 웹소켓 세션만 제거
        roomService.removeSession(session);
	}
	
	@OnError
	public void onerror(Session session, Throwable t) {
		t.printStackTrace();
	}
	
	
	// 웹 소켓 세션 닫기
    private void closeSession(Session session, String reason) {
        try {
            session.close(new CloseReason(
                CloseReason.CloseCodes.VIOLATED_POLICY,
                reason
            ));
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
    
    // 에러 메시지 전송
    private void sendError(Session session, String errorMsg) {
        WebSocketMessage message = new WebSocketMessage(MessageType.ERROR, null, errorMsg);
        try {
            session.getBasicRemote().sendText(gson.toJson(message));
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

}
