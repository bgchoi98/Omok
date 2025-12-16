package users;

import users.User;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;
import java.time.LocalDateTime;
import repository.OmokRepository;

public class UserRepository extends OmokRepository<User, String> {

	private static volatile UserRepository instance;

	private UserRepository() {
	}

	public static UserRepository getInstance() {
		if (instance == null) {
			synchronized (UserRepository.class) {
				if (instance == null) {
					instance = new UserRepository();
				}
			}
		}
		return instance;
	}

	@Override
	protected User mapRow(ResultSet rs) throws SQLException {
		return new User(
				rs.getString("USER_ID")
			,   rs.getString("USER_PW")
			,   rs.getString("EMAIL")
			,   rs.getString("NICKNAME")
			);
	}

	// 기존에 상원님이 만들어 두신거 (회원가입으로 처리함)
	@Override
	public User save(User e) {
		String sql = "INSERT INTO omokdb.USERS (user_id, user_pw, email, nickname, created_at) VALUES (?, ?, ?, ?, ?)";
		// insert문 호출 
		// JDBC INSERT 리턴값은 0(성공) / 1(실패)
		int inserForm = executeUpdate(sql, pstmt -> {
			pstmt.setString(1, e.getUserId());
			pstmt.setString(2, e.getUserPw());
			pstmt.setString(3, e.getEmail());
			pstmt.setString(4, e.getNickname());
			pstmt.setObject(5, LocalDateTime.now());
		});
		
		if (inserForm > 0) {	//insert 성공 시 vo객체 반환 (회원가입 요청한 데이터)
			System.out.println("dasdsadsadsad");
			return e;
		}
		
		return null;
	}

	@Override
	public User findById(int id) {
		String sql = "SELECT * FROM omokdb.USERS WHERE seq_id = ?";

		return executeQuery(sql, pstmt -> pstmt.setInt(1, id), rs -> {
			try {
				if (rs.next()) {
					return mapRow(rs);
				}
			} catch (SQLException e) {
				e.printStackTrace();
			}
			return null;
		});
	}
	
	// 로그인 아이디로 회원 조회
	public User findBySignId(String signId) {
		String sql = "SELECT * FROM omokdb.USERS WHERE USER_ID = ? AND deleted_at IS NULL";

		return executeQuery(sql, pstmt -> pstmt.setString(1, signId), rs -> {
			try {
				if (rs.next()) {
					return mapRow(rs);
				}
			} catch (SQLException e) {
				e.printStackTrace();
			}
			return null;
		});
	}

	// 닉네임으로 회원 조회
	public User findByNickName(String nickname) {
		String sql = "SELECT * FROM omokdb.USERS WHERE nickname = ?";

		return executeQuery(sql, pstmt -> pstmt.setString(1, nickname), rs -> {
			try {
				if (rs.next()) {
					return mapRow(rs);
				}
			} catch (SQLException e) {
				e.printStackTrace();
			}
			return null;
		});
	}

	@Override
	public List<User> findAll() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public int update(User e) {
		// TODO Auto-generated method stub
		return 0;
	}

	@Override  
    public int delete(String id) {
       //String sql = "DELETE FROM USERS WHERE user_id = ?";
       String sql = "UPDATE USERS SET deleted_at = NOW() WHERE user_id = ?"; // soft Delete
      
       // 회원 삭제(탈퇴) 쿼리
       return executeUpdate(sql, pstmt -> {
          pstmt.setString(1, id);
       });
   }

}
