package room;

import java.util.ArrayList;
import java.util.List;

import game.GameUser;
import game.Observer;
import game.GameState;

public class Room {

	private static Long roomSeqGenerator = 1L;
	private Long roomSeq;

	private List<GameUser> gameUsers = new ArrayList<>();
	private List<Observer> observers = new ArrayList<>();

	private RoomStatus roomStatus;

	// 방장 닉네임 추가
	private String hostNickname;

	// 게임 상태
	private GameState gameState;

	// ADD: 플레이어 아바타 (1~4)
	private Integer p1Avatar;  // Player 1 아바타 번호 (1~4)
	private Integer p2Avatar;  // Player 2 아바타 번호 (1~4)


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


	// 해당 유저가 방장인지
	public boolean isHost(String nickname) {
		return this.hostNickname != null && this.hostNickname.equals(nickname);
	}


	// 해당 방이 가득찼는지
	public boolean isFull() {
		return gameUsers.size() >= 2;
	}


	// 해당 방이 비어있는지
	public boolean isEmpty() {
		return gameUsers.isEmpty();
	}

	// 해당 방에 참여 가능한지
	public boolean canJoin() {
		return roomStatus == RoomStatus.WAITING && !isFull();
	}


	// 현재 게임 상태 조회
	public GameState getGameState() {
		return gameState;
	}


	// 게임 상태 수정
	public void setGameState(GameState gameState) {
		this.gameState = gameState;
	}

	// ADD: 아바타 getter/setter
	public Integer getP1Avatar() {
		return p1Avatar;
	}

	public void setP1Avatar(Integer p1Avatar) {
		this.p1Avatar = p1Avatar;
	}

	public Integer getP2Avatar() {
		return p2Avatar;
	}

	public void setP2Avatar(Integer p2Avatar) {
		this.p2Avatar = p2Avatar;
	}
}
