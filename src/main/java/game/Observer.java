package game;

import room.LobbyUser;

public class Observer {

	private LobbyUser lobbyUser;

	public Observer(LobbyUser lobbyUser) {
		this.lobbyUser = lobbyUser;
	}

	public LobbyUser getLobbyUser() {
		return lobbyUser;
	}

}
