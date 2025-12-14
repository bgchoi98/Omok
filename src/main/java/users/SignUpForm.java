package users;

import java.time.LocalDateTime;

public class SignUpForm {
	 	private String id;
	    private String pw;
	    private String email;
	    private String nickname;

	    public SignUpForm(String id, String pw, String email, String nickname) {
	        this.id = id;
	        this.pw = pw;
	        this.email = email;
	        this.nickname = nickname;
	    }

	    // 서버단 검증
	    public boolean joinValidation() {
	        return isNotBlank(id)
	            && isNotBlank(pw)
	            && isNotBlank(email)
	            && isNotBlank(nickname);
	    }

	    private boolean isNotBlank(String s) {	// 검증로직 추후 확인
	        return s != null && !s.trim().isEmpty();
	    }

	    public String getId() {
	        return id;
	    }

	    public String getPw() {
	        return pw;
	    }

	    public String getEmail() {
	        return email;
	    }

	    public String getNickname() {
	        return nickname;
	    }
}
