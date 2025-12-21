package game;


import room.LobbyUser;

public class GameUser {

	private String nickName;

	
	public GameUser(LobbyUser lobbyUser) {

		this.nickName = lobbyUser.getNickName();
		
	}

	public String getNickName() {
		return nickName;
	}
	
}
