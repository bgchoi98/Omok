package users;

import java.sql.Timestamp;
import java.time.LocalDateTime;

public class User {
	private static Long SEQ_ID = 1L;              // SEQ_ID (PK)
    private String userId;           // USER_ID
    private String userPw;           // USER_PW
    private String email;            // EMAIL
    private LocalDateTime createdAt; // CREATED_AT
    private LocalDateTime deletedAt; // DELETED_AT
    private String nickname;         // NICKNAME

    public User() {}

    public User(String userId, String userPw, String email,
                String nickname) {
        this.SEQ_ID = SEQ_ID++;
        this.userId = userId;	
        this.userPw = userPw;
        this.email = email;
        this.createdAt = LocalDateTime.now();
        this.nickname = nickname;
    }

    public Long getSeqId() {
        return SEQ_ID;
    }

    public void setSeqId(int seqId) {
        this.SEQ_ID = SEQ_ID;
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

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public LocalDateTime getDeletedAt() {
        return deletedAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
	    this.createdAt = createdAt;
	}

	public void setDeletedAt(LocalDateTime deletedAt) {
        this.deletedAt = deletedAt;
    }

    public String getNickname() {
        return nickname;
    }

    public void setNickname(String nickname) {
        this.nickname = nickname;
    }

}
