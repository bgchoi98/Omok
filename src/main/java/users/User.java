package users;

import java.time.LocalDateTime;

public class User {

    private String userId;           // USER_ID
    private String userPw;           // USER_PW
    private String email;            // EMAIL
    private LocalDateTime createdAt; // CREATED_AT
    private LocalDateTime deletedAt; // DELETED_AT
    private String nickname;         // NICKNAME

    public User() {}

    public User(String userId, String userPw, String email, String nickname) {
        this.userId = userId;	
        this.userPw = userPw;
        this.email = email;
        this.createdAt = LocalDateTime.now();
        this.nickname = nickname;
    }


    public String getUserId() {
        return userId;
    }

    public String getUserPw() {
        return userPw;
    }

    public String getEmail() {
        return email;
    }


    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public LocalDateTime getDeletedAt() {
        return deletedAt;
    }

    public String getNickname() {
        return nickname;
    }

	@Override
	public String toString() {
		return "User [userId=" + userId + ", userPw=" + userPw + ", email=" + email + ", createdAt=" + createdAt
				+ ", deletedAt=" + deletedAt + ", nickname=" + nickname + "]";
	}

    
 

}
