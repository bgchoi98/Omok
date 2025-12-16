package rooms;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

import repository.OmokRepository;

public class RoomRepository extends OmokRepository<Room, String> {

	
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

	@Override
	protected Room mapRow(ResultSet rs) throws SQLException {
		return new Room( rs.getInt("ROOM_SEQ")
				       , rs.getDate("ROOM_CREATED_AT")
				       , rs.getLong("OWNER_USER_SEQ")
				       , rs.getLong("GUEST_USER_SEQ")
				       , RoomStatusEnum.valueOf(rs.getString("ROOM_STATUS"))
				    );
	}

	@Override
	public Room save(Room room) {
			String sql = 
					     "INSERT INTO ROOMS (ROOM_CREATED_AT, OWNER_USER_SEQ, GUEST_USER_SEQ, ROOM_STATUS) "
					   + "VALUES (NOW(), ?, NULL, 'WAIT')";
		    executeUpdate(sql, new SQLConsumer<PreparedStatement>() {
		    	@Override
		    	public void accept(PreparedStatement pstmt) throws SQLException {
		    		pstmt.setLong(1, room.getOwnerUserSeq());
		    		pstmt.setLong(2, room.getGuestUserSeq());
		    	}
		    });
		return null;
	}
	
	public int joinRoom(Room room) {
		String sql =
				     "UPDATE ROOMS SET GUEST_USER_SEQ = ?, ROOM_STATUS = 'PLAYING' "
				   + "WHERE ROOM_SEQ = ?";
		int result = executeUpdate(sql, new SQLConsumer<PreparedStatement>() {
				@Override
				public void accept(PreparedStatement pstmt) throws SQLException {
					pstmt.setLong(1, room.getGuestUserSeq());
					pstmt.setInt(2, room.getRoomSeq());
				}
			});
		return result;
	}

	@Override
	public Room findById(int id) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public List<Room> findAll() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public int update(Room e) {
		// TODO Auto-generated method stub
		return 0;
	}

	@Override
	public int delete(String id) {
		// TODO Auto-generated method stub
		return 0;
	}
}
