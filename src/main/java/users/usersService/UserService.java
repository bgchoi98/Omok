package users.usersService;

import users.SignUpForm;
import users.User;
import users.usersRepository.UserRepository;

public class UserService {

	private static final UserRepository USERREPOSITORY = UserRepository.getInstance();
	
	//싱글톤 
	private static volatile UserService instance;

    private UserService() { }

    public static UserService getInstance() {
        if (instance == null) {
            synchronized (UserRepository.class) {
                if (instance == null) {
                    instance = new UserService();
                }
            }
        }
        return instance;
    }
    
    public User login(String userId, String userPW) {
        User user = USERREPOSITORY.findById(userId);
        if (user == null) {
        	return null;
        }
        if (!user.getUserPw().equals(userPW)) {
            return null;
        }
        return user;
    }
    
    public boolean SignUp(SignUpForm signupform) {	
    	String id = signupform.getUserId();
        User user = USERREPOSITORY.findById(id);
        if (user != null) {
        	System.out.println("이미 존재하는 ID입니다.");
        	return false; 
        } else {
        	//user = USERREPOSITORY; insert 로직
        	return true;
        }
    }
}
