package game;

import java.util.ArrayList;
import java.util.List;

/**
 * 오목 게임의 상태를 관리하는 클래스
 */
public class GameState {
    
    private static final int BOARD_SIZE = 15;
    private static final int WIN_COUNT = 5;
    
    private Long roomSeq;
    private int[][] board;  // 0: 빈칸, 1: 흑돌(선공), 2: 백돌(후공)
    private String blackPlayer;  // 흑돌 플레이어 (선공)
    private String whitePlayer;  // 백돌 플레이어 (후공)
    private String currentTurn;  // 현재 턴의 플레이어
    private boolean gameOver;
    private String winner;  // 승자 닉네임
    private List<Move> moveHistory;  // 착수 기록
    
    /**
     * 착수 정보를 담는 내부 클래스
     */
    public static class Move {
        private int row;
        private int col;
        private int stone;  // 1: 흑돌, 2: 백돌
        private String player;
        
        public Move(int row, int col, int stone, String player) {
            this.row = row;
            this.col = col;
            this.stone = stone;
            this.player = player;
        }
        
        public int getRow() { return row; }
        public int getCol() { return col; }
        public int getStone() { return stone; }
        public String getPlayer() { return player; }
    }
    
    /**
     * GameState 생성자
     * @param roomSeq 방 번호
     * @param player1 첫 번째 플레이어 (흑돌, 선공)
     * @param player2 두 번째 플레이어 (백돌, 후공)
     */
    public GameState(Long roomSeq, String player1, String player2) {
        this.roomSeq = roomSeq;
        this.board = new int[BOARD_SIZE][BOARD_SIZE];
        this.blackPlayer = player1;  // 첫 번째 플레이어가 흑돌
        this.whitePlayer = player2;  // 두 번째 플레이어가 백돌
        this.currentTurn = player1;  // 흑돌이 선공
        this.gameOver = false;
        this.winner = null;
        this.moveHistory = new ArrayList<>();
    }
    
    /**
     * 착수 시도
     * @param row 행
     * @param col 열
     * @param playerNickname 착수하는 플레이어
     * @return 착수 성공 여부
     */
    public synchronized boolean makeMove(int row, int col, String playerNickname) {
        // 게임이 이미 종료되었는지 확인
        if (gameOver) {
            return false;
        }
        
        // 현재 턴인지 확인
        if (!currentTurn.equals(playerNickname)) {
            return false;
        }
        
        // 범위 확인
        if (row < 0 || row >= BOARD_SIZE || col < 0 || col >= BOARD_SIZE) {
            return false;
        }
        
        // 이미 돌이 놓여있는지 확인
        if (board[row][col] != 0) {
            return false;
        }
        
        // 착수
        int stone = playerNickname.equals(blackPlayer) ? 1 : 2;
        board[row][col] = stone;
        moveHistory.add(new Move(row, col, stone, playerNickname));
        
        // 승리 조건 확인
        if (checkWin(row, col, stone)) {
            gameOver = true;
            winner = playerNickname;
            return true;
        }
        
        // 무승부 확인 (보드가 가득 찼는지)
        if (isBoardFull()) {
            gameOver = true;
            winner = "DRAW";
            return true;
        }
        
        // 턴 교체
        currentTurn = currentTurn.equals(blackPlayer) ? whitePlayer : blackPlayer;
        
        return true;
    }
    
    /**
     * 승리 조건 확인
     */
    private boolean checkWin(int row, int col, int stone) {
        // 4방향 체크: 가로, 세로, 대각선(\), 대각선(/)
        int[][] directions = {
            {0, 1},   // 가로
            {1, 0},   // 세로
            {1, 1},   // 대각선 \
            {1, -1}   // 대각선 /
        };
        
        for (int[] dir : directions) {
            int count = 1;  // 현재 돌 포함
            
            // 양방향 체크
            count += countStones(row, col, stone, dir[0], dir[1]);
            count += countStones(row, col, stone, -dir[0], -dir[1]);
            
            if (count >= WIN_COUNT) {
                return true;
            }
        }
        
        return false;
    }
    
    /**
     * 특정 방향으로 연속된 같은 돌의 개수 세기
     */
    private int countStones(int row, int col, int stone, int dRow, int dCol) {
        int count = 0;
        int r = row + dRow;
        int c = col + dCol;
        
        while (r >= 0 && r < BOARD_SIZE && c >= 0 && c < BOARD_SIZE && board[r][c] == stone) {
            count++;
            r += dRow;
            c += dCol;
        }
        
        return count;
    }
    
    /**
     * 보드가 가득 찼는지 확인
     */
    private boolean isBoardFull() {
        for (int i = 0; i < BOARD_SIZE; i++) {
            for (int j = 0; j < BOARD_SIZE; j++) {
                if (board[i][j] == 0) {
                    return false;
                }
            }
        }
        return true;
    }
    
    // Getters
    public Long getRoomSeq() { return roomSeq; }
    public int[][] getBoard() { return board; }
    public String getBlackPlayer() { return blackPlayer; }
    public String getWhitePlayer() { return whitePlayer; }
    public String getCurrentTurn() { return currentTurn; }
    public boolean isGameOver() { return gameOver; }
    public String getWinner() { return winner; }
    public List<Move> getMoveHistory() { return moveHistory; }
    
    /**
     * 특정 플레이어의 돌 색상 가져오기
     * @param nickname 플레이어 닉네임
     * @return 1: 흑돌, 2: 백돌, 0: 해당 없음
     */
    public int getPlayerStone(String nickname) {
        if (nickname.equals(blackPlayer)) {
            return 1;
        } else if (nickname.equals(whitePlayer)) {
            return 2;
        }
        return 0;
    }
    
    /**
     * 보드 크기 가져오기
     * @return 보드 크기
     */
    public static int getBoardSize() {
        return BOARD_SIZE;
    }
}
