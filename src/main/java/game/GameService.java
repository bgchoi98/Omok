package game;

import rank.Rank;
import rank.RankService;
import room.Room;
import room.RoomRepository;
import user.User;
import user.UserService;

import java.util.List;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;


public class GameService {

	private final RoomRepository roomRepository = RoomRepository.getInstance();
	private final RankService rankService = RankService.getInstance();
	private final UserService userService = UserService.getInstance();
	
	private static final Logger log = LoggerFactory.getLogger(GameService.class);
	
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
    

    // 게임 시작 메서드
    public boolean startGame(Long roomSeq) {
        Room room = roomRepository.findById(roomSeq);
        
        if (room == null) {
        	log.error("startGame: Room not found, roomSeq={}", roomSeq);
            return false;
        }
        
        // 2명이 모두 모였는지 확인, 프론트 단에서 한 번 검증 필요
        if (!room.isFull()) {
        	log.warn("startGame: Room not full, roomSeq={}, playerCount={}", 
                    roomSeq, room.getGameUsers().size());
            return false;
        }
        
        synchronized (room) {
            if (room.getGameState() != null) {
            	log.info("startGame: Game already started, roomSeq={}", roomSeq);
                return false;  // 이미 시작되었을 경우
            }
            
            List<GameUser> players = room.getGameUsers();
            String player1 = players.get(0).getNickName();
            String player2 = players.get(1).getNickName();
            
            log.info("startGame: Creating GameState, roomSeq={}, player1(black)={}, player2(white)={}", 
                    roomSeq, player1, player2);
                
            GameState gameState = new GameState(roomSeq, player1, player2);
            room.setGameState(gameState);
            
            log.info("startGame: Game started successfully, roomSeq={}", roomSeq);
            return true;
        }
    }
    

    // 착수 시도
    public boolean makeMove(Long roomSeq, int row, int col, String playerNickname) {
    	// 방 조회
        Room room = roomRepository.findById(roomSeq);
        
        // 방 검증
        if (room == null) {
            log.error("makeMove: Room not found, roomSeq={}", roomSeq);
            return false;
        }
        
        // 현재 게임 상태 조회
        GameState gameState = room.getGameState();
        if (gameState == null) {
            log.error("makeMove: GameState is null, roomSeq={}", roomSeq);
            return false;
        }
        
        log.info("makeMove: Attempt by {}, position=({},{}), currentTurn={}", 
            playerNickname, row, col, gameState.getCurrentTurn());
        
        // 돌을 둔다
        boolean result = gameState.makeMove(row, col, playerNickname);
        
        if (result) {
            log.info("makeMove: Success! Next turn={}", gameState.getCurrentTurn());
        } else {
            log.warn("makeMove: Failed! player={}, currentTurn={}", 
                playerNickname, gameState.getCurrentTurn());
        }
        
        return result;
    }

    // 게임 상태 조회
    public GameState getGameState(Long roomSeq) {
        Room room = roomRepository.findById(roomSeq);
        
        if (room == null) {
            return null;
        }
        
        return room.getGameState();
    }
    

    // 게임 유저인지 판단
    public boolean isGameUser(Long roomSeq, String nickname) {
        Room room = roomRepository.findById(roomSeq);
        
        // room 검증
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
    
    // 옵저버인지 판단
    public boolean isObserver(Long roomSeq, String nickname) {
        Room room = roomRepository.findById(roomSeq);
        
        if (room == null) {
            return false;
        }
        
        for (Observer observer : room.getObservers()) {
            if (observer.getNickName().equals(nickname)) {
                return true;
            }
        }
        
        return false;
    }
    
    // 게임 종료 판단
    public boolean isGameOver(Long roomSeq) {
        Room room = roomRepository.findById(roomSeq);
        
        // 방 검증
        if (room == null) {
            log.warn("isGameOver: Room not found, roomSeq={}", roomSeq);
            return false;
        }
        
        GameState gameState = room.getGameState();
        
        // 게임 상태 검증
        if (gameState == null) {
            log.warn("isGameOver: GameState is null, roomSeq={}", roomSeq);
            return false;
        }
        
        boolean gameOver = gameState.isGameOver();
        
        // 게임 종료 여부 검증
        if (gameOver) {
        	
        	// 게임 종료 시 전적 (Rank) 업데이트
        	User winner = userService.findByNickName(gameState.getWinner());
        	Long winnerId = winner.getUserSeq();
        	Rank winUserRank = rankService.findById(winnerId);
        	
        	// 게임이 계정 생성 후 첫 판이라면 Rank 테이블에 save
        	if (winUserRank == null) {
                Rank newRank = new Rank(winnerId, 1, 0, 100, winner.getNickname()); // 계정 생성 후 첫 승 시 승리 1, 패배 0, 승률 100
                rankService.save(newRank);
        	} else { // 두 번째 판부터는 Rank 테이블에 update
        		winUserRank.addWin();
            	rankService.update(winUserRank);
        	}
        
        	String loserName = gameState.getWinner().equals(gameState.getBlackPlayer()) ? gameState.getWhitePlayer() : gameState.getBlackPlayer();
        	User loser = userService.findByNickName(loserName);
        	Long loserId = loser.getUserSeq();
        	Rank loseUserRank = rankService.findById(loserId);
        	
        	// 게임이 계정 생성 후 첫 판이라면 Rank 테이블에 save
        	if (loseUserRank == null) {
                Rank newRank = new Rank(loserId, 0, 1, 0, loser.getNickname()); // 계정 생성 후 첫 승 시 승리 0, 패배 1, 승률 0
                rankService.save(newRank);
        	} else { // 두 번째 판부터는 Rank 테이블에 update
        		loseUserRank.addLose();
        		rankService.update(loseUserRank);
        	}
        	        	
        	
            log.info("isGameOver: Game is over, roomSeq={}, winner={}", 
                roomSeq, gameState.getWinner());
        }
        
        return gameOver;
    }
    
    // 승리자 판단
    public String getWinner(Long roomSeq) {
        Room room = roomRepository.findById(roomSeq);
        
        if (room == null) {
            log.warn("getWinner: Room not found, roomSeq={}", roomSeq);
            return null;
        }
        
        GameState gameState = room.getGameState();
        
        if (gameState == null) {
            log.warn("getWinner: GameState is null, roomSeq={}", roomSeq);
            return null;
        }
        
        return gameState.getWinner();
    }
}


