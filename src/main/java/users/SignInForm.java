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
		return result;
	}

}
