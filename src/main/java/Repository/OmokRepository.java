
package Repository;


import java.util.List;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.function.Function;

import users.User;

public abstract class OmokRepository <E, ID> {

    protected Connection getConnection() throws SQLException {
    	try {
            Class.forName("org.mariadb.jdbc.Driver"); // MariaDB 드라이버 로드
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            throw new SQLException("MariaDB Driver not found", e);
        }
        // 환경에 맞게 JDBC URL, 계정, 비밀번호 수정
        return DriverManager.getConnection(
        		"jdbc:mariadb://omokdb.ctacq0y0i2c0.ap-northeast-2.rds.amazonaws.com:3306/omokdb?useUnicode=true&characterEncoding=UTF-8&serverTimezone=Asia/Seoul&useSSL=false",
      	        "admin",
      	        "qorhqtlrp" 
        	);
    }

    // SELECT 
    protected <T> T executeQuery(String sql, SQLConsumer<PreparedStatement> parameterSetter,
                                 Function<ResultSet, T> mapper) {
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            if (parameterSetter != null) parameterSetter.accept(pstmt);

            try (ResultSet rs = pstmt.executeQuery()) {
                return mapper.apply(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return null;
        }
    }

    // INSERT, UPDATE, DELETE
    protected int executeUpdate(String sql, SQLConsumer<PreparedStatement> parameterSetter) {
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            if (parameterSetter != null) parameterSetter.accept(pstmt);

            int affected = pstmt.executeUpdate();
            return affected;
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }


    @FunctionalInterface
    protected interface SQLConsumer<T> {
        void accept(T t) throws SQLException;
    }
    
    protected abstract E mapRow(ResultSet rs) throws SQLException;

    public abstract E save(E e);
    public abstract E findById(ID id);
    public abstract E findByNickName(ID id);
    public abstract List<E> findAll();
    public abstract int update(E e);
    public abstract int delete(ID id);

	
}

