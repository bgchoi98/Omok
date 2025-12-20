package game;

import com.google.gson.Gson;
import room.Room;
import room.RoomRepository;
import java.util.List;

/**
 * 게임 관련 비즈니스 로직을 처리하는 서비스
 */
public class GameService {
	
	private final Gson gson = new Gson();
	private final RoomRepository roomRepository = RoomRepository.getInstance();
	
    // 싱글톤 
	private static volatile GameService instance;

    private GameService() { }

    public static GameService getInstance() {
        if (instance == null) {
            synchronized (GameService.class) {
                if (instance == null) {
                    instance = new GameService();
                }
            }
        }
        return instance;
    }
    
    /**
     * 게임 시작
     * @param roomSeq 방 번호
     * @return 게임 시작 성공 여부
     */
    public boolean startGame(Long roomSeq) {
        Room room = roomRepository.findById(roomSeq);
        
        if (room == null) {
            return false;
        }
        
        // 2명이 모두 모였는지 확인
        if (!room.isFull()) {
            return false;
        }
        
        // 이미 게임이 시작되었는지 확인
        if (room.getGameState() != null) {
            return false;
        }
        
        // 게임 상태 생성
        List<GameUser> players = room.getGameUsers();
        String player1 = players.get(0).getNickName();
        String player2 = players.get(1).getNickName();
        
        GameState gameState = new GameState(roomSeq, player1, player2);
        room.setGameState(gameState);
        
        return true;
    }
    
    /**
     * 착수 시도
     * @param roomSeq 방 번호
     * @param row 행
     * @param col 열
     * @param playerNickname 플레이어 닉네임
     * @return 착수 성공 여부
     */
    public boolean makeMove(Long roomSeq, int row, int col, String playerNickname) {
        Room room = roomRepository.findById(roomSeq);
        
        if (room == null) {
            return false;
        }
        
        GameState gameState = room.getGameState();
        if (gameState == null) {
            return false;
        }
        
        return gameState.makeMove(row, col, playerNickname);
    }
    
    /**
     * 게임 상태 조회
     * @param roomSeq 방 번호
     * @return 게임 상태 또는 null
     */
    public GameState getGameState(Long roomSeq) {
        Room room = roomRepository.findById(roomSeq);
        
        if (room == null) {
            return null;
        }
        
        return room.getGameState();
    }
    
    /**
     * 특정 플레이어가 해당 방의 게임 참여자인지 확인
     * @param roomSeq 방 번호
     * @param nickname 닉네임
     * @return 게임 참여자 여부
     */
    public boolean isPlayer(Long roomSeq, String nickname) {
        Room room = roomRepository.findById(roomSeq);
        
        if (room == null) {
            return false;
        }
        
        for (GameUser player : room.getGameUsers()) {
            if (player.getNickName().equals(nickname)) {
                return true;
            }
        }
        
        return false;
    }
    
    /**
     * 특정 플레이어가 해당 방의 관전자인지 확인
     * @param roomSeq 방 번호
     * @param nickname 닉네임
     * @return 관전자 여부
     */
    public boolean isObserver(Long roomSeq, String nickname) {
        Room room = roomRepository.findById(roomSeq);
        
        if (room == null) {
            return false;
        }
        
        for (Observer observer : room.getObservers()) {
            if (observer.getLobbyUser().getNickName().equals(nickname)) {
                return true;
            }
        }
        
        return false;
    }
}
