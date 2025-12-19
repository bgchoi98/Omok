package game;

import javax.websocket.server.ServerEndpoint;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.google.gson.Gson;

import room.RoomWebSocket;
import util.webSocketDTOs.GetHttpSessionConfigurator;

@ServerEndpoint(
	    value = "/game",
	    configurator = GetHttpSessionConfigurator.class
	    // HTTP 세션(HttpSession)을 WebSocket으로 넘기기 위해 쓰는 장치
	)
public class GameWebSocket {
	private static final Logger log = LoggerFactory.getLogger(RoomWebSocket.class);

	private final Gson gson = new Gson();
	
}
