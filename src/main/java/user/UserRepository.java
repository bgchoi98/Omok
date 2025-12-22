package user;

import util.JDBCRepository;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;
import java.time.LocalDateTime;

import rank.*;
import user.User;

public class UserRepository extends JDBCRepository<User, String> {

	private static volatile UserRepository instance;

	private UserRepository() { }

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
				         rs.getLong("SEQ_ID")
				       , rs.getString("USER_ID")
	                   , rs.getString("USER_PW")
	                   , rs.getString("EMAIL")
	                   , rs.getString("NICKNAME")
	                );
	}

	// 기존에 상원님이 만들어 두신거 (회원가입으로 처리함)
	@Override
	public int save(User user) {
		String sql = 
				     "INSERT INTO USERS (USER_ID, USER_PW, EMAIL, NICKNAME, CREATED_AT) "
				   + "VALUES (?, ?, ?, ?, ?)";
		// insert 문 호출 
		// JDBC INSERT 리턴값은 0(성공) / 1(실패)
		int inserForm = executeUpdate(sql, pstmt -> {
			pstmt.setString(1, user.getSignId());
			pstmt.setString(2, user.getPassword());
			pstmt.setString(3, user.getEmail());
			pstmt.setString(4, user.getNickname());
			pstmt.setObject(5, LocalDateTime.now());
		});
		
		
		
		return inserForm;
	}
	
	@Override
	public User findById(Long seqId) {
		String sql = 
				     "SELECT "
				   + "SEQ_ID, USER_ID, USER_PW, EMAIL, NICKNAME, CREATED_AT, DELETED_AT "
				   + "FROM USERS "
				   + "WHERE SEQ_ID = ?";

		return executeQuery(sql, pstmt -> pstmt.setLong(1, seqId), rs -> {
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
	
	/* rank테이블 seq_id 자동 삽입용
	public Long findBySeq_Id(String id) {
		String sql = 
				     "SELECT "
				   + "SEQ_ID, USER_ID, USER_PW, EMAIL, NICKNAME, CREATED_AT, DELETED_AT "
				   + "FROM USERS "
				   + "WHERE USER_ID = ?";

		return executeQuery(sql, pstmt -> pstmt.setString(1, id), rs -> {
			try {
				if (rs.next()) {
					return rs.getLong("SEQ_ID");
				}
			} catch (SQLException e) {
				e.printStackTrace();
			}
			return null;
		});
	}
	*/
	

	// 로그인 아이디로 회원 조회
	public User findBySignId(String signId) {
		String sql = 
				     "SELECT "
				   + "SEQ_ID, USER_ID, USER_PW, EMAIL, NICKNAME, CREATED_AT, DELETED_AT "
				   + "FROM USERS "
				   + "WHERE USER_ID = ? "
				   + "AND DELETED_AT IS NULL";

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
	public User findByNickName(String nickName) {
		String sql = 
				     "SELECT "
				   + "SEQ_ID, USER_ID, USER_PW, EMAIL, NICKNAME, CREATED_AT, DELETED_AT "
				   + "FROM USERS "
				   + "WHERE NICKNAME = ?";

		return executeQuery(sql, pstmt -> pstmt.setString(1, nickName), rs -> {
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
	public User update(User e) {
		// TODO Auto-generated method stub
		return null;
	}

	 
    public int withDraw(Long id, String userPw) {
       //String sql = "DELETE FROM USERS WHERE user_id = ?";
       String sql = 
    		        "UPDATE USERS SET DELETED_AT = NOW() "
       		      + "WHERE USER_PW = ?"
       		      + "AND SEQ_ID = ?"; // soft Delete
      
       // 회원 삭제(탈퇴) 쿼리
       return executeUpdate(sql, pstmt -> {
           pstmt.setString(1, userPw);
           pstmt.setLong(2, id);
       });
   }

	@Override
	public int delete(Long id) {
		// TODO Auto-generated method stub
		return 0;
	}


}
