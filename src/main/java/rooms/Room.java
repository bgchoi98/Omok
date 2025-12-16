package rooms;

import java.sql.Date;

public class Room {
	
	private int roomSeq;
	private Date roomCreatedAt;
	private Long ownerUserSeq;
	private Long guestUserSeq;
	private RoomStatusEnum roomStatus;
	
	public Room(int roomSeq, Date roomCreatedAt, Long ownerUserSeq, Long guestUserSeq, RoomStatusEnum roomStatus) {
		this.roomSeq = roomSeq;
		this.roomCreatedAt = roomCreatedAt;
		this.ownerUserSeq = ownerUserSeq;
		this.guestUserSeq = guestUserSeq;
		this.roomStatus = roomStatus;
	}
	
	public int getRoomSeq() {
		return roomSeq;
	}
	
	public Date getRoomCreatedAt() {
		return roomCreatedAt;
	}
	
	public Long getOwnerUserSeq() {
		return ownerUserSeq;
	}
	
	public Long getGuestUserSeq() {
		return guestUserSeq;
	}
	
	public RoomStatusEnum getRoomStatus() {
		return roomStatus;
	}
	
	
	
}
