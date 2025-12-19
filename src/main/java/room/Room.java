package room;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import game.GameUser;
import game.Observer;
import room.RoomStatus;

public class Room {
	
	private static Long roomSeqGenerator = 1L;
	private Long roomSeq;

	private List<GameUser> gameUsers = new ArrayList<>();
	private List<Observer> observers = new ArrayList<>();
	
	private RoomStatus roomStatus;
	
	


	public Room(RoomStatus roomStatus) {
		this.roomSeq = roomSeqGenerator++;
		this.roomStatus = roomStatus;
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

	
	
	
}
