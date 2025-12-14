package rank.rankRepository;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

import Repository.OmokRepository;

public class RankRepository extends OmokRepository {

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
	protected Object mapRow(ResultSet rs) throws SQLException {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public Object save(Object e) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public Object findById(Object id) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public List findAll() {
		// TODO Auto-generated method stub
		// 정렬해서 리턴, 해당 메서드만 구현하기
		
		return null;
	}

	@Override
	public int update(Object e) {
		// TODO Auto-generated method stub
		return 0;
	}

	@Override
	public int delete(Object id) {
		// TODO Auto-generated method stub
		return 0;
	}

	@Override
	public Object findByNickName(Object id) {
		// TODO Auto-generated method stub
		return null;
	}
}
