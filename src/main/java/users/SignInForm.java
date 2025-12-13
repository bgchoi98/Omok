package users;

public class SignInForm {
	private String userId;
	private String userPw;
	
	public SignInForm(String userId, String userPw) {
		this.userId = userId;
		this.userPw = userPw;
	}
	
	public boolean isValid() {
		Boolean result = true;
		// equals(null)을 하면 NullPointerException 발생
		if (userId == null || userId.isEmpty()) { 
			result = false;
		}
		if (userPw == null || userPw.isEmpty()) {
			result = false;
		}
		return result;
	}

}