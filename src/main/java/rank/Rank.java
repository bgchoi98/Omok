package rank;


public class Rank {
	private Long users_seq_id;
	private int win;
	private int lose;
	private int rate;
	private String nickName;
	
	public Rank() {}
	
	public Rank(Long users_seq_id) {
		this.users_seq_id = users_seq_id;
	}
	

	
	
	public Rank(Long users_seq_id, int win, int lose, int rate) {
		super();
		this.users_seq_id = users_seq_id;
		this.win = win;
		this.lose = lose;
		this.rate = rate;
	}

	public Rank(Long users_seq_id, int win, int lose, int rate, String nickName) {
		this.users_seq_id = users_seq_id;
		this.win = win;
		this.lose = lose;
		this.rate = (int) ((double) win / (win + lose) * 100);
		this.nickName = nickName;
	}
	
	public void addWin() {
		win++;
		rate = (int) ((double) win / (win + lose) * 100);
	}
	
	public void addLose() {
		lose++;
		rate = (int) ((double) win / (win + lose) * 100);
	}
	

	public Long getUsers_seq_id() {
		return users_seq_id;
	}

	public int getWin() {
		return win;
	}

	public int getLose() {
		return lose;
	}

	public int getRate() {
		return rate;
	}

	public String getNickName() {
		return nickName;
	}

}
