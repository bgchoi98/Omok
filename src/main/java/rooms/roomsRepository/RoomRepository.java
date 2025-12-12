package rooms.roomsRepository;



public class RoomRepository {

	
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
}
