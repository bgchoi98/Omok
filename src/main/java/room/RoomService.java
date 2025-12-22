package room;

import java.io.IOException;
import java.util.List;
import java.util.Random;
import java.util.Set;
import javax.websocket.Session;
import com.google.gson.Gson;
import com.google.gson.JsonObject;

import game.GameUser;
import game.Observer;
import util.webSocketDTOs.MessageType;
import util.webSocketDTOs.WebSocketMessage;

public class RoomService {

	private static final RoomRepository ROOM_REPOSITORY = RoomRepository.getInstance();

	private final Gson gson = new Gson();
	private final Random random = new Random(); // ADD: 아바타 랜덤 배정용

	// 싱글톤
	private static volatile RoomService instance;

	private RoomService() {
	}

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

	/**
	 * 방 생성
	 * 
	 * @param lobbyUser 방을 생성하는 유저
	 * @param sessions  전체 세션 목록 (브로드캐스트용)
	 * @return 생성된 Room
	 */
	public Room createRoom(LobbyUser lobbyUser, Set<Session> sessions) {
		Room room = ROOM_REPOSITORY.save(lobbyUser);

		// ADD: P1 아바타 배정 (방 생성 시점 1회만)
		synchronized (room) {
			if (room.getP1Avatar() == null) {
				int avatar = random.nextInt(4) + 1; // 1~4 랜덤
				room.setP1Avatar(avatar);
			}
		}

		broadcastRoomList(sessions);
		return room;
	}

	/**
	 * 방 입장
	 * 
	 * @param room      입장할 방
	 * @param lobbyUser 입장하는 유저
	 * @return 입장 성공 여부
	 */
	public boolean joinRoom(Room room, LobbyUser lobbyUser) {
		if (room == null) {
			return false;
		}

		synchronized (room) {
			// Room의 canJoin() 메서드 활용
			if (!room.canJoin()) {
				return false;
			}

			GameUser gameUser = new GameUser(lobbyUser);
			room.getGameUsers().add(gameUser);

			// 2명이 되면 게임 중 상태로 변경
			if (room.isFull()) {
				System.out.println("2명이상됨");
				room.setRoomStatus(RoomStatus.PLAYING);

				// ADD: P2 아바타 배정 (2명 확정 시점 1회만)
				if (room.getP2Avatar() == null) {
					int p1 = room.getP1Avatar() != null ? room.getP1Avatar() : 1;
					int p2;
					do {
						p2 = random.nextInt(4) + 1; // 1~4 랜덤
					} while (p2 == p1); // P1과 겹치지 않게
					room.setP2Avatar(p2);
				}
			}
			return true;
		}
	}

	/**
	 * 관전자 추가
	 * 
	 * @param lobbyUser 관전하는 유저
	 * @param room      관전할 방
	 * @return 관전 성공 여부
	 */
	public boolean observe(LobbyUser lobbyUser, Room room) {
		if (room == null) {
			return false;
		}

		// 게임 중인 방만 관전 가능
		if (room.getRoomStatus() != RoomStatus.PLAYING) {
			return false;
		}

		Observer observer = new Observer(lobbyUser);
		room.getObservers().add(observer);

		// 관전자 인원수 제한 ?
		// if *(room.getObservers().size > 2 )
		return true;
	}

	/**
	 * 방 삭제
	 * 
	 * @param roomId   삭제할 방 ID
	 * @param nickname 삭제를 요청한 유저 닉네임
	 * @param sessions 전체 세션 목록
	 * @return 삭제 성공 여부
	 */
	public boolean deleteRoom(Long roomId, String nickname, Set<Session> sessions) {
		Room room = ROOM_REPOSITORY.findById(roomId);

		if (room == null) {
			return false;
		}

		// 방장만 삭제 가능
		if (!room.isHost(nickname)) {
			return false;
		}

		// 게임 중인 방은 삭제 불가
		if (room.getRoomStatus() == RoomStatus.PLAYING) {
			return false;
		}

		boolean deleted = ROOM_REPOSITORY.deleteRoom(roomId);
//    	if (deleted) {
//    		broadcastRoomList(sessions);
//    	}
		return deleted;
	}
	
	/**
	 * 방 삭제
	 * 
	 * @param roomId   삭제할 방 ID
	 * @param nickname 삭제를 요청한 유저 닉네임
	 * @param sessions 전체 세션 목록
	 * @return 삭제 성공 여부
	 */
	public boolean deleteRoom_Refresh(Long roomId, String nickname) {
		Room room = ROOM_REPOSITORY.findById(roomId);

		if (room == null) {
			return false;
		}

		// 방장만 삭제 가능
		if (!room.isHost(nickname)) {
			return false;
		}

		// 게임 중인 방은 삭제 불가
		if (room.getRoomStatus() == RoomStatus.PLAYING) {
			return false;
		}

		boolean deleted = ROOM_REPOSITORY.deleteRoom(roomId);
//    	if (deleted) {
//    		broadcastRoomList(sessions);
//    	}
		return deleted;
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
			String json = createRoomListJson();
			session.getBasicRemote().sendText(json);
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	/**
	 * 방 리스트 JSON 생성
	 * 
	 * @return JSON 문자열
	 */
	private String createRoomListJson() {
		List<Room> rooms = ROOM_REPOSITORY.findAll();
		return gson.toJson(new WebSocketMessage(MessageType.ROOMLIST, null, rooms));
	}

	/**
	 * 모든 세션에 방 리스트 브로드캐스트
	 * 
	 * @param sessions 전송할 세션 목록
	 */
//    public void broadcastRoomList(Set<Session> sessions) {
//        String json = createRoomListJson(); 
//        System.out.println("json출력"  + json);
//        for (Session session : sessions) {
//            if (session.isOpen()) {
//                try {
//                    session.getAsyncRemote().sendText(json);
//                } catch (Exception e) {
//                    e.printStackTrace();
//                }
//            }
//        }
//    }
	// 변경
	public void broadcastRoomList(Set<Session> sessions) {
		String json = createRoomListJson();
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

	/**
	 * 방 조회
	 * 
	 * @param roomId 방 ID
	 * @return Room 객체 또는 null
	 */
	public Room findRoom(Long roomId) {
		return ROOM_REPOSITORY.findById(roomId);
	}

	/**
	 * 방 조회
	 * 
	 * @param 방장닉네임
	 * @return Room 객체 또는 null
	 */
	public Room findByHostNickname(String nickname) {
		if (nickname == null)
			return null;
		for (Room room : RoomRepository.getRooms().values()) {
			if (room.isHost(nickname)) {
				return room;
			}
		}
		return null;
	}
}
