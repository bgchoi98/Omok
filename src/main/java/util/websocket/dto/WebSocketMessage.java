package util.websocket.dto;


public class WebSocketMessage {
    private MessageType type;
    private String gameId; // 게임 대기 화면에서는 필요 없다.
    private Object data;
    
    public WebSocketMessage() {}
    
    public WebSocketMessage(MessageType type, String gameId, Object data) {
        this.type = type;
        this.gameId = gameId;
        this.data = data;
    }

    
    // getter setter
    public MessageType getType() {
        return type;
    }

    public void setType(MessageType type) {
        this.type = type;
    }

    public String getGameId() {
        return gameId;
    }

    public void setGameId(String gameId) {
        this.gameId = gameId;
    }

    public Object getData() {
        return data;
    }

    public void setData(Object data) {
        this.data = data;
    }
}
