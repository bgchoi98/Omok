package room;

import java.io.IOException;
import java.util.List;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import javax.websocket.Session;
import com.google.gson.Gson;

import game.GameUser;
import game.Observer;
import util.webSocketDTOs.MessageType;
import util.webSocketDTOs.WebSocketMessage;

public class RoomService {

	private static final RoomRepository ROOMREPOSITORY = RoomRepository.getInstance();
	
	private final Gson gson = new Gson();
    private final Set<Session> waitingSessions = ConcurrentHashMap.newKeySet(); // 대기실에 있는 WebSocket 세션 보관소
	
    // 싱글톤 
	private static volatile RoomService instance;

    private RoomService() { }

    public static RoomService getInstance() {
        if (instance == null) {
            synchronized (RoomService.class) {
                if (instance == null) {
                    instance = new RoomService();
                }
            }
        }
        return instance;
    }
    		
    public Room createRoom(LobbyUser lobbyUser) {
    	Room room = ROOMREPOSITORY.save(lobbyUser); 
    	broadcastRoomList();
    	return room;
    }
    
    public void observe(LobbyUser lobbyUser, Room room) {
    	Observer observer = new Observer(lobbyUser);
    	room.getObservers().add(observer);
    }

    
    public void sendRoomListToLobbyUser(Session session, LobbyUser lobbyUser) {
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
    
    public void joinRoom(Room room, LobbyUser lobbyUser) {
        
        if (room == null) {
        	return;
        }

        synchronized (room) {
            if (room.getGameUsers().size() >= 2) {
            	return;
            }
            
            GameUser gameUser = new GameUser(lobbyUser);
            room.getGameUsers().add(gameUser);   

            if (room.getGameUsers().size() == 2) {
                room.setRoomStatus(RoomStatus.PLAYING);
                // 두 명 다 찼으니 플레이어 상태 갱신
            } 
        }
    }

	public void deleteRoom(long seqId) {
		ROOMREPOSITORY.deleteRoom(seqId);
		broadcastRoomList();
	}
	
	public Room findRoom(Long roomId) {
		return ROOMREPOSITORY.findById(roomId);
	}
	
	public void addSession(Session session) {
		waitingSessions.add(session);
	}
	
	public void removeSession(Session session) {
		waitingSessions.remove(session);
	}
}
