package room;

import javax.websocket.Session;

public class LobbyUser {

	private String nickName;
	private Session session;
	
	public LobbyUser(String nickName, Session session) {
		this.nickName = nickName;
		this.session = session;
	}

	public String getNickName() {
		return nickName;
	}

	public void setNickName(String nickName) {
		this.nickName = nickName;
	}

	public Session getSession() {
		return session;
	}

	public void setSession(Session session) {
		this.session = session;
	}
	
	
}
