package util;
public class Constants {
   
   // root
   public static final String ROOT = "/";
   
   // session
   public static final String SESSION_KEY = "signInUser";
   
   
   // sign 
   public static final String SIGN = "/sign";
   public static final String SIGNIN = "/sign/signIn";
   public static final String SIGNOUT = "/sign/signOut";
   public static final String SIGNUP = "/sign/signUp";
   public static final String WITHDRAW = "/sign/signWithdraw";
   
   
   // JSP View paths (WEB-INF 안쪽)
    public static final String VIEW_SIGNIN = "/WEB-INF/views/signIn.jsp";
    public static final String VIEW_SIGNUP = "/WEB-INF/views/signUp.jsp";
    public static final String VIEW_MAIN = "/WEB-INF/views/main.jsp";
    public static final String VIEW_MYPAGE = "/WEB-INF/views/mypage.jsp";
    public static final String VIEW_GAME = "/WEB-INF/views/game.jsp"; // 새로운 추가
   
   // rank
   public static final String RANK = "/rank";
   
   
   // main
   public static final String MAIN = "/main";
   public static final String MAIN_GAME = "/main/game";
   public static final String GAME = "/main/{roomId}";
   
   
}
