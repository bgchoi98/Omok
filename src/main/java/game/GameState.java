package game;



public class GameState {
    
    private static final int BOARD_SIZE = 15;
    private static final int WIN_COUNT = 5;
    
    private Long roomSeq;
    private int[][] board;  // 0: 빈칸, 1: 흑돌(선공), 2: 백돌(후공)
    private String blackPlayer;  // 흑돌, 선공
    private String whitePlayer;  // 백돌, 후공
    private String currentTurn;  // 현재 차례인 플레이어
    private boolean gameOver;
    private String winner;  
    //private List<Move> moveHistory;  // 착수 기록
    

    // 내부 클래스, 돌을 둔 곳을 파악
    public static class Move {
        private int row;
        private int col;
        private int stone;  // 1: 흑돌, 2: 백돌
        private String gameUserName; // 닉네임이 unique 이기에 GameUser 객체로 구분하지 않고 메모리가 덜 소요되는 nickName 사용
        
        public Move(int row, int col, int stone, String gameUserName) {
            this.row = row;
            this.col = col;
            this.stone = stone;
            this.gameUserName = gameUserName;
        }
        
        public int getRow() { return row; }
        public int getCol() { return col; }
        public int getStone() { return stone; }
        public String getPlayer() { return gameUserName; }
    }
    

    // 생성자
    public GameState(Long roomSeq, String player1, String player2) {
        this.roomSeq = roomSeq;
        this.board = new int[BOARD_SIZE][BOARD_SIZE];
        this.blackPlayer = player1;  // 첫 번째 플레이어가 흑돌
        this.whitePlayer = player2;  // 두 번째 플레이어가 백돌
        this.currentTurn = player1;  // 흑돌이 선공
        this.gameOver = false;
        this.winner = null;
        // this.moveHistory = new ArrayList<>();
    }
    

    // 착수 시도
    public synchronized boolean makeMove(int row, int col, String gameUserName) {
        // 게임이 이미 종료되었는지 확인
        if (gameOver) {
            return false;
        }
        
        // 현재 턴인지 확인
        if (!currentTurn.equals(gameUserName)) {
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
        int stone = gameUserName.equals(blackPlayer) ? 1 : 2;
        board[row][col] = stone;
        // moveHistory.add(new Move(row, col, stone, gameUserName));
        
        // 승리 조건 확인
        if (checkWin(row, col, stone)) {
            gameOver = true;
            winner = gameUserName;
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
    

    // 승리 조건 확인
    private boolean checkWin(int row, int col, int stone) {
       
        int[][] directions = {
            {0, 1},   // 가로
            {1, 0},   // 세로
            {1, 1},   // 대각선 1
            {1, -1}   // 대각선 2
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
    

    // 특정 방향으로 연속된 같은 돌의 개수를 세아린다
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
    

    // 보드가 가득 찼는지 확인
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
    
    // getter
    public Long getRoomSeq() { return roomSeq; }
    public int[][] getBoard() { return board; }
    public String getBlackPlayer() { return blackPlayer; }
    public String getWhitePlayer() { return whitePlayer; }
    public String getCurrentTurn() { return currentTurn; }
    public boolean isGameOver() { return gameOver; }
    public String getWinner() { return winner; }
    // public List<Move> getMoveHistory() { return moveHistory; }
    
    // 게임 유저의 돌 색상 가져오기, 1: 흑돌 2: 백돌
    public int getPlayerStone(String nickname) {
        if (nickname.equals(blackPlayer)) {
            return 1;
        } else if (nickname.equals(whitePlayer)) {
            return 2;
        }
        return 0;
    }
    
    public static int getBoardSize() {
        return BOARD_SIZE;
    }
}
