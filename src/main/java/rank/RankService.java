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
   
    
   // 리포지토리에 위임
   
   public int save(Rank rank) {
	   return RANKREPOSITORY.save(rank);
   }
    
   public List<Rank> findAll() {
	   return RANKREPOSITORY.findAll();
   }
   
   public Rank findById(Long seqId) {
	   return RANKREPOSITORY.findById(seqId);
   }
   
   public Rank update(Rank rank) {
	   return RANKREPOSITORY.update(rank);
   }
}
