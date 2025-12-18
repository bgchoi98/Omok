package util.websocket.dto;

// 웹소켓 처리 메시지 타입
public enum MessageType {
	
	// main.jsp -> 룸 리스트 출력
	ROOMLIST,
    // 방 생성, 삭제
    CREATE_ROOM,
    DELETE_ROOM,

    // 대기 
    WAITING,           
    
    // 게임 
    GAME_START,                
    MOVE,              
    GAME_END,         
    TURN_TIMEOUT,     
    
    // 채팅 
    CHAT,
    
    // 관전
    SPECTATOR_JOIN,           // 관전자 입장
    SPECTATOR_NOTIFICATION,   // 관전자 입장 알림
    
    // 플레이어 퇴장
    PLAYER_LEFT,              // 플레이어 퇴장
    
    // 에러
    ERROR

}
