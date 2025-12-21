package rank;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import util.JDBCRepository;

public class RankRepository extends JDBCRepository<Rank, Integer> {

	private static volatile RankRepository instance;

	private RankRepository() { }

	public static RankRepository getInstance() {
		if (instance == null) {
			synchronized (RankRepository.class) {
				if (instance == null) {
					instance = new RankRepository();
				}
			}
		}
		return instance;
	}

	@Override
	protected Rank mapRow(ResultSet rs) throws SQLException {
		return new Rank( rs.getLong("USERS_SEQ_ID")
				       , rs.getInt("WIN")
				       , rs.getInt("LOSE")
				       , rs.getInt("RATE")
				    );
	}

	@Override
	public int save(Rank rank) { // 회원가입시 기본값 저장
		String sql = 
				     "INSERT INTO RANKS (USERS_SEQ_ID, WIN, LOSE, RATE) "
				   + "VALUES (?, ?, ?, ?)";
		int insertForm = executeUpdate(sql, new SQLConsumer<PreparedStatement>() {
			@Override
			public void accept(PreparedStatement pstmt) throws SQLException {
				pstmt.setLong(1, rank.getUsers_seq_id());
				pstmt.setInt(2, rank.getWin());
				pstmt.setInt(3, rank.getLose());
				pstmt.setInt(4, rank.getRate());
			}
		});
		return insertForm;
	}

	@Override
	public Rank findById(Long seqId) {
		String sql = 
				     "SELECT "
				   + "R.USERS_SEQ_ID, R.WIN, R.LOSE, R.RATE, U.NICKNAME "
				   + "FROM RANKS R INNER JOIN USERS U "
				   + "ON R.USERS_SEQ_ID = U.SEQ_ID "
				   + "WHERE U.SEQ_ID = ?";
		
		return executeQuery(sql, new SQLConsumer<PreparedStatement>() {
			@Override
			public void accept(PreparedStatement pstmt) throws SQLException {
				pstmt.setLong(1, seqId);
			}
		},
				
			new java.util.function.Function<ResultSet, Rank>(){
			@Override
			public Rank apply(ResultSet rs) {
				try {
					if (rs.next()) {
						return mapRow(rs);
					}
				} catch (SQLException e) {
					
					e.printStackTrace();
				}
				return null;
			}
		}
	);
				
}

	@Override
	public List<Rank> findAll() {
		String sql = 
					 "SELECT "
				   + "R.USERS_SEQ_ID, R.WIN, R.LOSE, R.RATE, U.NICKNAME "
				   + "FROM RANKS R INNER JOIN USERS U "
				   + "ON R.USERS_SEQ_ID = U.SEQ_ID "
				   + "ORDER BY R.RATE DESC, R.WIN DESC";
				
			return executeQuery(sql, null, 
					new java.util.function.Function<ResultSet, List<Rank>>() {
				@Override
				public List<Rank> apply(ResultSet rs) {
					List<Rank> ranks = new ArrayList<>();
					try {
						while (rs.next()) {
							Rank rank = mapRow(rs);
							ranks.add(rank);
						}
					} catch (SQLException e) {
						e.printStackTrace();
					}
					return ranks;
				}
			}
		);
	}


	@Override
	public Rank update(Rank r) {
		
		String sql = 
			     "UPDATE RANKS "
			     + "SET WIN = ?, LOSE = ?, RATE = ? "
			     + "WHERE users_seq_id = ?";
	executeUpdate(sql, new SQLConsumer<PreparedStatement>() {
		@Override
		public void accept(PreparedStatement pstmt) throws SQLException {
			pstmt.setInt(1, r.getWin());
            pstmt.setInt(2, r.getLose());
            pstmt.setInt(3, r.getRate());
            pstmt.setLong(4, r.getUsers_seq_id());
		}
	});
	return r;
	}

	@Override
	public int delete(Long id) {
		// TODO Auto-generated method stub
		return 0;
	}



	
}
