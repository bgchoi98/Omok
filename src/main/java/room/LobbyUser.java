package room;

import java.util.List;
import java.util.Set;

import javax.websocket.Session;

public class LobbyUser {

	private String nickName;
	private Set<Session> LobbyUserSession;

	public LobbyUser(Set<Session> LobbyUserSession) {
		this.LobbyUserSession = LobbyUserSession;
	}

	public Set<Session> getLobbyUserSession() {
		return LobbyUserSession;
	}

	public LobbyUser(String nickName) {
		this.nickName = nickName;
	}

	public String getNickName() {
		return nickName;
	}
}
