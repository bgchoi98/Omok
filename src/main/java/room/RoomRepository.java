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



	public Room createRoom(LobbyUser lobbyUser) {
		
		GameUser gameUser = new GameUser(lobbyUser);
		
		Room savedRoom = new Room(
				RoomStatus.WAITING
		);
		long currentSeq = savedRoom.getRoomSeq();
		
		savedRoom.getGameUsers().add(gameUser);
		
		rooms.put(currentSeq, savedRoom);
		return savedRoom;
	}





	public List<Room> findAll() {
		return new ArrayList<>(rooms.values());
	}

	public Room findById(Long id) {
		return rooms.get(id);
	}
	



	public void deleteRoom(long seqId) {
		try {
			rooms.remove(seqId);
		} catch (NumberFormatException e) {
			e.printStackTrace();
		}
		
	}


}
