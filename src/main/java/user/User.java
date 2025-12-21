package user;

import java.time.LocalDateTime;

public class User {

	private Long userSeq;
    private String signId;           // USER_ID
    private String password;           // USER_PW
    private String email;            // EMAIL
    private LocalDateTime createdAt; // CREATED_AT
    private LocalDateTime deletedAt; // DELETED_AT
    private String nickname;         // NICKNAME

    public User() {}

    public User(String signId, String password, String email, String nickname) {
        this.signId = signId;
        this.password = password;
        this.email = email;
        this.nickname = nickname;
        this.createdAt = LocalDateTime.now();
    }

    public User(Long userSeq, String signId, String password, String email, String nickname) {
        this.userSeq = userSeq;
        this.signId = signId;
        this.password = password;
        this.email = email;
        this.nickname = nickname;
        this.createdAt = LocalDateTime.now();
    }

    public long getUserSeq() {
    	return userSeq;
    }
    
	public String getSignId() {
        return signId;
    }

    public String getPassword() {
        return password;
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
		return "User [signId=" + signId + ", password=" + password + ", email=" + email + ", createdAt=" + createdAt
				+ ", deletedAt=" + deletedAt + ", nickname=" + nickname + "]";
	} 
}
