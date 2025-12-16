package rank;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

import repository.OmokRepository;



public class RankRepository extends OmokRepository<Rank, String> {

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
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public Rank save(Rank e) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public Rank findById(String id) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public List<Rank> findAll() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public int update(Rank e) {
		// TODO Auto-generated method stub
		return 0;
	}

	@Override
	public int delete(String id) {
		// TODO Auto-generated method stub
		return 0;
	}

}

