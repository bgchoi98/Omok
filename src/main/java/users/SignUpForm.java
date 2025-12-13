package users;

import java.time.LocalDateTime;

public class SignUpForm {
	  private String userId;           // USER_ID
	  private String userPw;           // USER_PW
	  private String email;            // EMAIL
	  private String nickname;         // NICKNAME
	  
	  public SignUpForm(String userId, String userPw, String email, String nickname) {
		this.userId = userId;
		this.userPw = userPw;
		this.email = email;
		this.nickname = nickname;
	  }
	  
	  public boolean JoinValidation() {
		    // Null 또는 공백 체크
		    if (userId == null || userId.trim().isEmpty()) {
		        System.out.println("USER_ID가 비어있습니다.");
		        return false;
		    }
		    if (userPw == null || userPw.trim().isEmpty()) {
		        System.out.println("USER_PW가 비어있습니다.");
		        return false;
		    }
		    if (email == null || email.trim().isEmpty()) {
		        System.out.println("EMAIL이 비어있습니다.");
		        return false;
		    }
		    if (nickname == null || nickname.trim().isEmpty()) {
		        System.out.println("NICKNAME이 비어있습니다.");
		        return false;
		    }

		    // 출력 (디버그용)
		    System.out.println("USER_ID   : " + userId);
		    System.out.println("USER_PW   : " + userPw);
		    System.out.println("EMAIL     : " + email);
		    System.out.println("NICKNAME  : " + nickname);

		    return true;
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
