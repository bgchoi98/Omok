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

    /**
     * 방 생성 및 저장
     * @param lobbyUser 방을 생성하는 로비 유저
     * @return 생성된 Room 객체
     */
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

	/**
	 * 모든 방 조회 (종료된 방 제외)
	 * @return 방 리스트
	 */
	public List<Room> findAll() {
	    List<Room> result = new ArrayList<>();
	    for (Room room : rooms.values()) {
	        if (room.getRoomStatus() != RoomStatus.END) {	// 게임끝난 방은 조회안하도록
	            result.add(room);
	        }
	    }
	    return result;
	}

    /**
     * 방 ID로 방 조회
     * @param roomId 방 ID
     * @return Room 객체 또는 null
     */
	public Room findById(Long roomId) {
		return rooms.get(roomId);
	}

    /**
     * 특정 상태의 방들만 조회
     * @param status 방 상태
     * @return 해당 상태의 방 리스트
     */
	public List<Room> findByStatus(RoomStatus status) {
		List<Room> result = new ArrayList<>();
		for (Room room : rooms.values()) {
			if (room.getRoomStatus() == status) {
				result.add(room);
			}
		}
		return result;
	}

    /**
     * 방 삭제
     * @param roomId 삭제할 방 ID
     * @return 삭제 성공 여부
     */
	public boolean deleteRoom(Long roomId) {
		try {
			Room removed = rooms.remove(roomId);
			return removed != null;
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}
	}

    /**
     * 방이 존재하는지 확인
     * @param roomId 방 ID
     * @return 존재 여부
     */
	public boolean existsById(Long roomId) {
		return rooms.containsKey(roomId);
	}

    /**
     * 전체 방 개수
     * @return 방 개수
     */
	public int count() {
		return rooms.size();
	}

    /**
     * 모든 방 삭제 (테스트용)
     */
	public void deleteAll() {
		rooms.clear();
	}

	public static Map<Long, Room> getRooms() {
		return rooms;
	}
}
