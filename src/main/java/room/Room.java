package room;

import java.util.ArrayList;
import java.util.List;

import game.GameUser;
import game.Observer;

public class Room {
	
	private static Long roomSeqGenerator = 1L;
	private Long roomSeq;

	private List<GameUser> gameUsers = new ArrayList<>();
	private List<Observer> observers = new ArrayList<>();
	
	private RoomStatus roomStatus;
	
	// 방장 닉네임 추가
	private String hostNickname;

	/**
	 * Room 생성자
	 * @param roomStatus 방 상태
	 * @param hostNickname 방장 닉네임
	 */
	public Room(RoomStatus roomStatus, String hostNickname) {
		this.roomSeq = roomSeqGenerator++;
		this.roomStatus = roomStatus;
		this.hostNickname = hostNickname;
	}

	public Long getRoomSeq() {  
	    return roomSeq;
	}

	public List<GameUser> getGameUsers() {
		return gameUsers;
	}

	public List<Observer> getObservers() {
		return observers;
	}

	public RoomStatus getRoomStatus() {
		return roomStatus;
	}

	public void setRoomStatus(RoomStatus roomStatus) {
		this.roomStatus = roomStatus;
	}

	public String getHostNickname() {
		return hostNickname;
	}

	/**
	 * 해당 유저가 방장인지 확인
	 * @param nickname 확인할 닉네임
	 * @return 방장 여부
	 */
	public boolean isHost(String nickname) {
		return this.hostNickname != null && this.hostNickname.equals(nickname);
	}

	/**
	 * 방이 가득 찼는지 확인
	 * @return 방이 가득 찼으면 true
	 */
	public boolean isFull() {
		return gameUsers.size() >= 2;
	}

	/**
	 * 방이 비어있는지 확인
	 * @return 방이 비어있으면 true
	 */
	public boolean isEmpty() {
		return gameUsers.isEmpty();
	}

	/**
	 * 방에 참가 가능한지 확인
	 * @return 참가 가능하면 true
	 */
	public boolean canJoin() {
		return roomStatus == RoomStatus.WAITING && !isFull();
	}
}
