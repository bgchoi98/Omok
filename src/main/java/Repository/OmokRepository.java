
package Repository;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.function.Function;

public abstract class OmokRepository <E, ID> {

    protected Connection getConnection() throws SQLException {
        // 환경에 맞게 JDBC URL, 계정, 비밀번호 수정
        return DriverManager.getConnection(
        	    "jdbc:mysql://omokdb.ctacq0y0i2c0.ap-northeast-2.rds.amazonaws.com:3306/omokdb?useSSL=false&serverTimezone=UTC",
        	    "admin",
        	    "qorhqtlrp"
        	);

    }

    /**
     * SELECT 쿼리 실행
     * mapper: ResultSet -> 객체 변환
     */
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

    /**
     * INSERT, UPDATE, DELETE 실행
     */
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

    // PreparedStatement 파라미터 설정을 람다로 받을 수 있게 FunctionalInterface
    @FunctionalInterface
    protected interface SQLConsumer<T> {
        void accept(T t) throws SQLException;
    }
}
