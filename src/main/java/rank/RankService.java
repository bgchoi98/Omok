package rank;

import java.util.List;

import rank.Rank;
;

public class RankService {
	
	private static final RankRepository RANKREPOSITORY = RankRepository.getInstance();
	
	private static volatile RankService instance;

    private RankService() { }

    public static RankService getInstance() {
        if (instance == null) {
            synchronized (RankService.class) {
                if (instance == null) {
                    instance = new RankService();
                }
            }
        }
        return instance;
    }
    
   public List<Rank> findAll() {
	   return RANKREPOSITORY.findAll();
   }
}
