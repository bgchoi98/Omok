package util.websocket.waiting;

import java.io.IOException;
import java.util.List;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import javax.websocket.Session;
import com.google.gson.Gson;

import rooms.Room;
import util.websocket.dto.MessageType;
import util.websocket.dto.WebSocketMessage;

public class WaitingService {

	private static final WaitingRepository ROOMREPOSITORY = WaitingRepository.getInstance();
	
	private final Gson gson = new Gson();
    private final Set<Session> waitingSessions = ConcurrentHashMap.newKeySet(); // 대기실에 있는 WebSocket 세션 보관소
	
    // 싱글톤 
	private static volatile WaitingService instance;

    private WaitingService() { }

    public static WaitingService getInstance() {
        if (instance == null) {
            synchronized (WaitingService.class) {
                if (instance == null) {
                    instance = new WaitingService();
                }
            }
        }
        return instance;
    }

    
    public void sendRoomListToSession(Session session) {
        try {
            String json = createRoomListJson(); // 룸 리스트들을 클라이언트로 담아 전달 
            session.getBasicRemote().sendText(json);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
    private String createRoomListJson() {
        List<Room> rooms = ROOMREPOSITORY.findAll();
        return gson.toJson(
            new WebSocketMessage(MessageType.ROOMLIST, null, rooms)
        );
    }

    // 방 생성, 삭제 시 모든 세션들에게 자동 반영
    public void broadcastRoomList() {
        String json = createRoomListJson();
        for (Session session : waitingSessions) {
            if (session.isOpen()) {
                session.getAsyncRemote().sendText(json);
            }
        }
    }
    
	public void addSession(Session session) {
	    waitingSessions.add(session);
	}
	public void removeSession(Session session) {
		waitingSessions.remove(session);
	}
	
	 public void createRoom(Room room) {
	        ROOMREPOSITORY.save(room);
	        broadcastRoomList(); // ⭐ 핵심
	    }

    public void deleteRoom(String roomId) {
        ROOMREPOSITORY.delete(roomId);
        broadcastRoomList(); // ⭐ 핵심
    }
}
