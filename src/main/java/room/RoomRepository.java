package room;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import game.GameUser;
import room.Room;
import room.RoomStatus;
import util.OmokRepository;

public class RoomRepository {

	private static Map<Long, Room> rooms = new ConcurrentHashMap<>();
	
	
	public static Map<Long, Room> getRooms() {
		return rooms;
	}

	

	private static volatile RoomRepository instance;

    private RoomRepository() { }

    public static RoomRepository getInstance() {
        if (instance == null) {
            synchronized (RoomRepository.class) {
                if (instance == null) {
                    instance = new RoomRepository();
                }
            }
        }
        return instance;
    }



    // 방 생성
	public Room save(LobbyUser lobbyUser) {
		
		// 1. 로비 유저가 게임 유저로 변경됨 
		GameUser gameUser = new GameUser(lobbyUser);
		
		// 2. 새로운 방이 생성되며 방의 상태가 대기로 된다.
		Room savedRoom = new Room(
				RoomStatus.WAITING
		);
		
		// 3. 방 번호 넣기
		long currentSeq = savedRoom.getRoomSeq();
		
		// 4. 방 객체 속 게임 유저 리스트에 게임 유저를 추가
		savedRoom.getGameUsers().add(gameUser);
		
		// 5. 맵에 방 번호, 방을 key - value 로 넣는다
		rooms.put(currentSeq, savedRoom);
		return savedRoom;
	}





	public List<Room> findAll() {
		return new ArrayList<>(rooms.values());
	}

	public Room findById(Long roomId) {
		return rooms.get(roomId);
	}
	



	public void deleteRoom(long seqId) {
		try {
			rooms.remove(seqId);
		} catch (NumberFormatException e) {
			e.printStackTrace();
		}
		
	}


}
