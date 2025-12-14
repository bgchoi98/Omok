package users.usersController;

import java.io.IOException;
import java.time.LocalDateTime;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import users.SignInForm;
import users.SignUpForm;
import users.User;
import users.usersService.UserService;

/**
 * Servlet implementation class UsersServlet
 */
@WebServlet(urlPatterns = {
		"/sign" ,
		"/sign/signUp",
		"/sign/signIn",
		"/sign/signOut",
		"/sign/signWithdraw"

})
public class UsersServlet extends HttpServlet {
	
	private static final UserService USERSERVICE = UserService.getInstance();

	
	protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
		String uri = req.getRequestURI().substring(req.getContextPath().length());   

		if (uri.equals("/sign/signUp")) {
			// 회원 가입 기능 구현
			// 아이디, 닉네임 비동기 중복체크 (파라미터가 아이디/닉네임으로 민감한정보 아닐거로 예상되어 GET방식으로 조회함 아님 수정)
		    if ("true".equals(req.getParameter("ajaxCheck"))) {
		        String type = req.getParameter("type");      // id / nickname
		        String value = req.getParameter("value");	// 사용자 입력값

		        boolean isAvailable = false;
		        if ("id".equals(type)) {
		            isAvailable = USERSERVICE.isIdExist(value);	// 아이디 중복체크일경우
		        } else if("nickname".equals(type)) {
		            isAvailable = USERSERVICE.isNickNameExist(value); // 닉네임 중복체크일경우;
		        }
		        res.setContentType("text/plain;charset=UTF-8");
		        res.getWriter().write(isAvailable ? "true" : "false");
		        return; // AJAX 요청이면 여기서 종료
		    }
		} else if (uri.equals("/sign/signIn")) {
			// 로그인 기능 구현	
			req.getRequestDispatcher("/signIn.jsp")
	           .forward(req, res);
		} else if (uri.equals("/sign/signOut")) {
			// 로그 아웃 기능 구현
			HttpSession session = req.getSession(false); // 기존 세션이 존재하는지 확인 (없으면 null 반환)
			
			if (session != null) {
				session.invalidate(); // 세션이 있다면 invalidate();
			}
			
			// 로그아웃 후 로그인 페이지로 다시 돌아가기
			res.sendRedirect(req.getContextPath() + "/signIn.jsp?msg=logout");
		} 

	} 
	
	protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
		req.setCharacterEncoding("UTF-8");
		String uri = req.getRequestURI().substring(req.getContextPath().length());         
	
		if (uri.equals("/sign/signUp")) {
			// 회원 가입 기능 구현
			
			String id = req.getParameter("user_id");
			String pw = req.getParameter("user_pw");
			String email = req.getParameter("email");
			String nickname = req.getParameter("nickname");
			
			SignUpForm joinform = new SignUpForm(id, pw, email, nickname);	// 서버단 검증 객체 생성
			User user = USERSERVICE.SignUp(joinform);	// 서비스 로직에서 검증구현하기위해 객체 넘겨줌
			
			if (user != null) {	//회원가입 성공 시
				res.sendRedirect(req.getContextPath()+"/signIn.jsp"); // 로그인 페이지로
				System.out.println(user.toString()); // 테스트용 출력 (회원가입 정보)
			} else {
				// 서버 및 DB 에러시 어떻게 처리할지
			}
			
		} else if (uri.equals("/sign/signIn")) {
	         // 로그인 기능 구현
	         String id = req.getParameter("user_id");
	         String pw = req.getParameter("user_pw");
	         SignInForm signInForm = new SignInForm(id, pw);

	         User user = null;
	         
	         if (signInForm.isValid()) {
	            user = USERSERVICE.login(id, pw); // 사용자 form이 정상이면
	            if (user == null) { // DB에서 불러온 user가 null이면 다시 SignIn 페이지로 보냄
	               req.setAttribute("errorMessage", "아이디 또는 비밀번호가 올바르지 않습니다.");
	               req.getRequestDispatcher("/signIn.jsp").forward(req, res);
	               return;
	            } else { // DB에서 불러온 user가 정상이면 메인 화면으로 보냄
	            	System.out.println("여기들어옴");
	                HttpSession session = req.getSession();   //세션 저장
	                session.setAttribute("loginUser", user); // UserVO 객체째로 저장. DB 조회를 다시 안 해도 괜찮도록
	                //상원님이 말한 prg 패턴인듯 리다이렉트를해야 get요청으로 이동해서 post요청이 안나는듯?
	                res.sendRedirect(req.getContextPath() + "/main.jsp"); // ContextPath 사용 동적으로 경로 가져오기
	            }            
	         } else {
	            req.setAttribute("errorMessage", "아이디와 비밀번호를 모두 입력해주세요.");
	            req.getRequestDispatcher("/signIn.jsp").forward(req, res);
	         }
	         

	      }
		}	
	}