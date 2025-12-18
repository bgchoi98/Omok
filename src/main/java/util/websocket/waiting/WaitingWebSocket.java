package util.websocket.waiting;

import java.io.IOException;

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

import rooms.Room;
import rooms.RoomStatusEnum;
import users.User;
import util.Constants;
import util.websocket.dto.GetHttpSessionConfigurator;
import util.websocket.dto.MessageType;
import util.websocket.dto.WebSocketMessage;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@ServerEndpoint(
	    value = "/roomList",
	    configurator = GetHttpSessionConfigurator.class
	    // HTTP 세션(HttpSession)을 WebSocket으로 넘기기 위해 쓰는 장치
	)

public class WaitingWebSocket {
	
	private static final Logger log = LoggerFactory.getLogger(WaitingWebSocket.class);

	private final Gson gson = new Gson();
    private final WaitingService waitingService = WaitingService.getInstance();
	
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
        
        // 세션에 User 저장, 대기 화면에서 세션은 '사용자' 단위
        session.getUserProperties().put("user", user);

        
        waitingService.addSession(session); // 세션을 RoomList 화면에 추가
        waitingService.sendRoomListToSession(session); // 세션(사용자)에게 룸리스트 전달
        
        
        log.info("WaitingRoom connected userId={}", user.getUserId());
	}
	
	@OnMessage
	public void onMessage(String message, Session session) {
		
		try {
        	// 세션에서 회원 조회
            User user = (User) session.getUserProperties().get("user");
            if (user == null) {
                return;
            }
            
            // 
            JsonObject json = gson.fromJson(message, JsonObject.class);
            String type = json.get("type").getAsString();
           
            switch (type) {
            case "ROOMLIST":
                waitingService.sendRoomListToSession(session);
                log.info("onMessage work : {}", type);
                break;
            case "CREATE_ROOM":
                JsonObject createData = json.getAsJsonObject("data");
                long ownerUserSeq = createData.get("ownerUserSeq").getAsLong();
                Room newRoom = new Room(0, null, ownerUserSeq, null, RoomStatusEnum.WAIT);
                waitingService.createRoom(newRoom);
                break;

            case "DELETE_ROOM":
                JsonObject deleteData = json.getAsJsonObject("data");
                int roomSeq = deleteData.get("roomSeq").getAsInt();
                waitingService.deleteRoom(String.valueOf(roomSeq));
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
        waitingService.removeSession(session);
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
