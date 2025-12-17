package users.dto;


public class SignUpForm {
	 	private String userId;
	    private String userPw;
	    private String email;
	    private String nickname;

	    public SignUpForm(String userId, String userPw, String email, String nickname) {
	        this.userId = userId;
	        this.userPw = userPw;
	        this.email = email;
	        this.nickname = nickname;
	    }

	    // 서버단 검증
	    public boolean joinValidation() {
	        return isNotBlank(userId)
	            && isNotBlank(userPw)
	            && isNotBlank(email)
	            && isNotBlank(nickname);
	    }

	    private boolean isNotBlank(String s) {	
	        return s != null && !s.trim().isEmpty();
	    }

		public String getUserId() {
			return userId;
		}

		public void setUserId(String userId) {
			this.userId = userId;
		}

		public String getUserPw() {
			return userPw;
		}

		public void setUserPw(String userPw) {
			this.userPw = userPw;
		}

		public String getEmail() {
			return email;
		}

		public void setEmail(String email) {
			this.email = email;
		}

		public String getNickname() {
			return nickname;
		}

		public void setNickname(String nickname) {
			this.nickname = nickname;
		}

		
	    
	    

	    
}
