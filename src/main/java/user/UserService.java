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
    public User signIn(String signId, String password) {
    	
	    if (signId == null || signId.trim().isEmpty()) {
	        return null;
	    }
    	
    	User findUser = USERREPOSITORY.findBySignId(signId);
    	
    	if (findUser != null &&  password.equals(findUser.getPassword())) {
    		return findUser;
    	} else {
    		return null; // 로그인 실패 시 null 리턴
    	}
    }
    
    // 회원가입 요청
    public User signUp(User newUser) {	
    	
    	if(isIdAvailable(newUser.getSignId()) && isNickNameAvailable(newUser.getNickname())) {
    		int insertForm = USERREPOSITORY.save(newUser);	// DB INSERT
        	if (insertForm > 0) {	//insert 성공 시 vo 객체 반환 (회원가입 요청한 데이터)
				// RankService.getInstance().save(new Rank(newUser.getUserSeq())); 
        		// -> 여기서 rank 를 save 하지 않고 gameService에서 게임 종료 후 '게임이 첫 판이었을 때' rank 테이블에 save, '첫 판이 아니면' update
        		// 기존 : user 데이터 생성 시 rank 테이블에 win 0, lose 0, rate 0 값이 바로 들어감
        		// 수정 : user 데이터 생성 이후 경기를 한 판이라도 했을 경우 rank 테이블에 값이 save 됨
				return newUser;
			}
    	}
        return null; // 회원 가입 실패 시 null 리턴
    }
    
    private boolean isIdAvailable(String userID) {  
        User user = USERREPOSITORY.findBySignId(userID);
        return user == null;  
    }
    private boolean isNickNameAvailable(String nickName) {  
        User user = USERREPOSITORY.findByNickName(nickName);
        return user == null;  
    }
    
    // 비동기 회원가입 ID 중복체크
    public boolean isIdExist(String userID) {	
        User user = USERREPOSITORY.findBySignId(userID);
        if (user != null) { // 중복된 ID가 없을때
        	return false;
        } else if (user.getDeletedAt() != null) {
        	return false;
        }
        return true;
    }
    
    // 비동기 회원가입 닉네임 중복체크
    public boolean isNickNameExist(String userID) {	
        User user = USERREPOSITORY.findByNickName(userID);
        if (user == null) {	// 중복된 닉네임이 없을때
        	return true;
        }
        return false;
    }


	
	public User findById(Long id) {
		return USERREPOSITORY.findById(id);
	}
	
	public User findBySignId(String signId) {	
		return USERREPOSITORY.findBySignId(signId);
	}
	
	public User findByNickName(String nickName) {
		return USERREPOSITORY.findByNickName(nickName);
	}
	
    public boolean withdraw(Long userId) {
        int result = USERREPOSITORY.delete(userId);
        return result > 0;
     }
    
    
}
