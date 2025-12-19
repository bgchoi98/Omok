package game;

import javax.websocket.Session;

import room.LobbyUser;

public class GameUser {

	private String nickName;
	private Session session;
	
	public GameUser(LobbyUser lobbyUser) {

		this.nickName = lobbyUser.getNickName();
		this.session = lobbyUser.getSession();
	}

	public String getNickName() {
		return nickName;
	}

	public Session getSession() {
		return session;
	}

	
	
}
