package users.usersRepository;

import users.User;
import Repository.OmokRepository;

public class UserRepository extends OmokRepository<User, Integer>{

	private static volatile UserRepository instance;

    private UserRepository() { }

    public static UserRepository getInstance() {
        if (instance == null) {
            synchronized (UserRepository.class) {
                if (instance == null) {
                    instance = new UserRepository();
                }
            }
        }
        return instance;
    }
    
    

}
