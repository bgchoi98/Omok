package room;

import javax.websocket.Session;

public class LobbyUser {

	private String nickName;
	
	public LobbyUser(String nickName) {
		this.nickName = nickName;
	}

	public String getNickName() {
		return nickName;
	}

	public void setNickName(String nickName) {
		this.nickName = nickName;
	}

	
}
