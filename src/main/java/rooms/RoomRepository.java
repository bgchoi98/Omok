package rooms;

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
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public Room save(Room e) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public Room findById(String id) {
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
