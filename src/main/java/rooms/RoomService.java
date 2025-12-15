package rooms;

import repository.OmokRepository;

public class RoomService {

	private static final RoomRepository ROOMREPOSITORY = RoomRepository.getInstance();
	
	private static volatile RoomService instance;

    private RoomService() { }

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
}
