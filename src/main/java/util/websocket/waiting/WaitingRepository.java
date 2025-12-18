package util.websocket.waiting;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import rooms.Room;
import rooms.RoomStatusEnum;
import util.OmokRepository;

public class WaitingRepository {

	private static Map<Integer, Room> roomMap = new ConcurrentHashMap<>();
	private static int roomSeqId = 1;
	
	private static volatile WaitingRepository instance;

    private WaitingRepository() { }

    public static WaitingRepository getInstance() {
        if (instance == null) {
            synchronized (WaitingRepository.class) {
                if (instance == null) {
                    instance = new WaitingRepository();
                }
            }
        }
        return instance;
    }



	public Room save(Room room) {
		int currentSeq = roomSeqId++;
		Room savedRoom = new Room(
				currentSeq,
				new java.sql.Date(System.currentTimeMillis()),  // 현재 시간
				room.getOwnerUserSeq(),
				room.getGuestUserSeq(),
				RoomStatusEnum.WAIT
		);
		roomMap.put(currentSeq, savedRoom);
		return savedRoom;
	}





	public List<Room> findAll() {
		return new ArrayList<>(roomMap.values());
	}

	public Room findById(int id) {
		return roomMap.get(id);
	}

	public int delete(String id) {
		try {
			int roomSeq = Integer.parseInt(id);
			Room removed = roomMap.remove(roomSeq);
			return removed != null ? 1 : 0;  // 삭제 성공 시 1, 실패 시 0
		} catch (NumberFormatException e) {
			return 0;
		}
	}



}
