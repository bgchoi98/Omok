package util.webSocketDTOs;

// 웹소켓 처리 메시지 타입
public enum MessageType {
	
	// main.jsp 에서 전체 룸 리스트 출력
	ROOMLIST,
	
    // main.jsp 에서 방 생성, 삭제
    CREATE_ROOM,
    DELETE_ROOM,

    // main.jsp 에서 방 생성, 대기
    WAITING,           
    
    // 게임 시작 이후 상태
    GAME_START,		// 게임 시작          
    MOVE,           // 돌을 두었을 때 (착수)
    GAME_END,       // 게임 종료
    TURN_TIMEOUT,   // 지정 시간이 지났을 경우
    
    // 채팅 
    CHAT,
    
    // 관전
    OBSERVER_JOIN,           // 관전자 입장
    OBSERVER_NOTIFICATION,   // 관전자 입장 알림
    
    // 플레이어 퇴장
    GAMEUSER_LEFT,              // 게임 유저 퇴장
    
    // 에러
    ERROR

}
