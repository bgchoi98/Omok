package util.webSocketDTOs;

import javax.servlet.http.HttpSession;
import javax.websocket.HandshakeResponse;
import javax.websocket.server.HandshakeRequest;
import javax.websocket.server.ServerEndpointConfig;

// 웹 소켓에서 HTTP 기능 중 하나인 HTTP Session 을 사용할 수 있도록 하는 객체
public class GetHttpSessionConfigurator extends ServerEndpointConfig.Configurator {
	
    @Override
    public void modifyHandshake(ServerEndpointConfig config,
                                HandshakeRequest request,
                                HandshakeResponse response) {
        HttpSession httpSession = (HttpSession) request.getHttpSession();
        if (httpSession != null) {
            config.getUserProperties().put(HttpSession.class.getName(), httpSession);
        }
    }
    
}
