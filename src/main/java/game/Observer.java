package game;

import room.LobbyUser;

public class Observer {

	private String nickName;

	public Observer(LobbyUser lobbyUser) {
		this.nickName = lobbyUser.getNickName();
	}

	public String getNickName() {
		return nickName;
	}
	
}
