package util;

import java.util.List;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.function.Function;

import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;

public abstract class JDBCRepository<E, ID> {

	private final DataSource dataSource;

	protected JDBCRepository() {
		try {
			InitialContext ctx = new InitialContext();
			this.dataSource = (DataSource) ctx.lookup("java:comp/env/jdbc/omokdb");

		} catch (NamingException e) {
			throw new RuntimeException("JNDI DataSource lookup failed: jdbc/omokdb", e); // 서버가 뜰 때 바로 실패서 원인 추적 쉬움
		}
	} // OmokRepository

	protected Connection getConnection() throws SQLException {
		return dataSource.getConnection();

	}

	// SELECT
	protected <T> T executeQuery(String sql, SQLConsumer<PreparedStatement> parameterSetter,
			Function<ResultSet, T> mapper) {
		try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {

			if (parameterSetter != null)
				parameterSetter.accept(pstmt);

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

			if (parameterSetter != null)
				parameterSetter.accept(pstmt);

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

	public abstract int save(E e);

	public abstract E findById(Long id);

	public abstract List<E> findAll();

	public abstract E update(E e);

	public abstract int delete(Long id);

}
