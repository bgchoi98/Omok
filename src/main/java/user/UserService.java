package user;


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
    public User signIn(String userId, String userPW) {
    	
	    if (userId == null || userId.trim().isEmpty()) {
	        return null;
	    }
    	
    	User findUser = USERREPOSITORY.findBySignId(userId);
    	
    	if (findUser != null &&  userPW.equals(findUser.getUserPw())) {
    		return findUser;
    	} else {
    		return null; // 로그인 실패 시 null 리턴
    	}
    }
    
    // 회원가입 요청
    public User signUp(User newUser) {	
        User savedUser = USERREPOSITORY.save(newUser);	// DB INSERT
        return savedUser;
    }

    
    // ID 중복체크
    public boolean isIdExist(String userID) {	
        User user = USERREPOSITORY.findBySignId(userID);
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

	public User findBySignId(String signId) {
		
		return USERREPOSITORY.findBySignId(signId);
	}
	
	public User findById(int id) {
		return USERREPOSITORY.findById(id);
	}
	
    public boolean withdraw(String userId) {
        int result = USERREPOSITORY.delete(userId);
        return result > 0;
     }
    
    
}
