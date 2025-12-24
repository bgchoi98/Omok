package room;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import game.GameUser;

public class RoomRepository {

	private static Map<Long, Room> rooms = new ConcurrentHashMap<>();

	// 싱글톤
	private static volatile RoomRepository instance;

	private RoomRepository() {
	}

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

	public Room save(LobbyUser lobbyUser) {

		// 1. 로비 유저가 게임 유저로 변경됨
		GameUser gameUser = new GameUser(lobbyUser);

		// 2. 새로운 방이 생성되며 방의 상태가 대기로 된다.
		Room savedRoom = new Room(RoomStatus.WAITING, lobbyUser.getNickName()); // 방장 닉네임 추가

		// 3. 방 번호 가져오기
		long currentSeq = savedRoom.getRoomSeq();

		// 4. 방 객체 속 게임 유저 리스트에 게임 유저를 추가
		savedRoom.getGameUsers().add(gameUser);

		// 5. 맵에 방 번호, 방을 key - value 로 넣는다
		rooms.put(currentSeq, savedRoom);

		return savedRoom;
	}

	public List<Room> findAll() {
		List<Room> result = new ArrayList<>();
		for (Room room : rooms.values()) {
			if (room.getRoomStatus() != RoomStatus.END) { // 종료중방 빼고
				result.add(room);
			}
		}
		return result;
	}

	public Room findById(Long roomId) {
		return rooms.get(roomId);
	}

	public List<Room> findByStatus(RoomStatus status) {
		List<Room> result = new ArrayList<>();
		for (Room room : rooms.values()) {
			if (room.getRoomStatus() == status) {
				result.add(room);
			}
		}
		return result;
	}

	public boolean deleteRoom(Long roomId) {
		try {
			Room removed = rooms.remove(roomId);
			return removed != null;
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}
	}

	public boolean existsById(Long roomId) {
		return rooms.containsKey(roomId);
	}

	public int count() {
		return rooms.size();
	}

	public void deleteAll() {
		rooms.clear();
	}

	public static Map<Long, Room> getRooms() {
		return rooms;
	}
}
