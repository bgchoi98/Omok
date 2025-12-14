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
    
    // 로그인 요청
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
    
    // 회원가입 요청
    public User SignUp(SignUpForm form) {	
        if (!form.joinValidation()) {	// 서버단 유효성 검증
        	return null;
        }
        // 검증 통과되면 form객체를 user객체로 변환
        // 이렇게 하는게 맞는건진 잘 모르겠음 User타입으로 USERREPOSITORY에 save메서드가 USER타입으로 선언되어있어서 바꿈
        User user = new User(form.getId(),form.getPw(),form.getEmail(),form.getNickname());
        user = USERREPOSITORY.save(user);	// DB INSERT
        return user;
    }
    
    // ID 중복체크
    public boolean isIdExist(String userID) {	
        User user = USERREPOSITORY.findById(userID);
        if (user == null) { // 중복된 ID가 없을때
        	return true;
        }
        
        return false;
    }
    
    // 닉네임 중복체크
    public boolean isNickNameExist(String userID) {	
        User user = USERREPOSITORY.findByNickName(userID);
        if (user == null) {	// 중복된 닉네임이 없을때
        	return true;
        }
        
        return false;
    }
}
