package rank;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import repository.*;

public class RankRepository extends OmokRepository<Rank, Integer> {

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
		Rank rank = new Rank(rs.getLong("USERS_SEQ_ID"), rs.getInt("WIN"), rs.getInt("LOSE"), rs.getString("NICKNAME"));
		return rank;
	}

	@Override
	public Rank save(Rank rank) { // 회원가입시 기본값 저장
		String sql = "INSERT INTO RANKS (USERS_SEQ_ID, WIN, LOSE, RATE) "
				   + "VALUES (?,0,0,0)";
		executeUpdate(sql, new SQLConsumer<PreparedStatement>() {
			@Override
			public void accept(PreparedStatement pstmt) throws SQLException {
				pstmt.setLong(1, rank.getUsers_seq_id());
			}
		});
		return rank;
	}

	@Override
	public Rank findById(int seqId) {
		String sql = 
				"SELECT "
				+ "R.USERS_SEQ_ID, R.WIN, R.LOSE, R.RATE, U.NICKNAME "
				+ "FROM RANKS R INNER JOIN USERS U "
				+ "ON R.USERS_SEQ_ID = U.SEQ_ID "
				+ "WHERE U.SEQ_ID = ?";
		
		return executeQuery(sql, new SQLConsumer<PreparedStatement>() {
			@Override
			public void accept(PreparedStatement pstmt) throws SQLException {
				pstmt.setInt(1, seqId);
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
					// TODO Auto-generated catch block
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
					+ "WHERE (R.WIN + R.LOSE) > 0 "
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
	public int update(Rank rank) {
		// TODO Auto-generated method stub
		return 0;
	}

	@Override
	public int delete(Integer e) {
		// TODO Auto-generated method stub
		return 0;
	}

	
}
