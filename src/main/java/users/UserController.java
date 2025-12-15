package users;

import java.io.IOException;
import java.time.LocalDateTime;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;


import users.User;
import users.dto.SignInForm;
import users.dto.SignUpForm;

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
public class UserController extends HttpServlet {
	
	private static final UserService USERSERVICE = UserService.getInstance();

	
	protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
		String uri = req.getRequestURI().substring(req.getContextPath().length());   

		if (uri.equals("/sign/signUp")) {
			// 회원 가입 기능 구현
		    if ("true".equals(req.getParameter("ajaxCheck"))) { // 아이디, 닉네임 비동기 중복체크 (파라미터가 아이디/닉네임으로 민감한정보 아닐거로 예상되어 GET방식으로 조회함 아님 수정)
		        String type = req.getParameter("type");      // id / nickname
		        String value = req.getParameter("value");	// 사용자 입력값

		        boolean isAvailable = false;
		        if ("id".equals(type)) {
		            isAvailable = USERSERVICE.isIdExist(value);	// 아이디 중복체크일경우
		        } else if("nickname".equals(type)) {
		            isAvailable = USERSERVICE.isNickNameExist(value); // 닉네임 중복체크일경우;
		        }
		        
		        //res.setContentType("text/plain;charset=UTF-8"); 필터로 처리
		        res.getWriter().write(isAvailable ? "true" : "false");
		        return; // AJAX 요청이면 여기서 종료
		    }
		    req.getRequestDispatcher("/signUp.jsp").forward(req, res); //AJAX가 아닐 경우
		} else if (uri.equals("/sign/signIn")) {
			// 로그인 창으로 포워딩
			req.getRequestDispatcher("/signIn.jsp").forward(req, res);
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
			
			boolean isValid = joinform.joinValidation();
			
			if (isValid) {
				User user = new User(id, pw, email, nickname);
				User savedUser = USERSERVICE.signUp(user);
				System.out.println(savedUser.toString()); // 테스트용 출력 (회원가입 정보)
				
				res.sendRedirect(req.getContextPath() + "/main.jsp");
			} else {
				req.setAttribute("errorMessage", "입력해주세요");
			}
			
			
		} else if (uri.equals("/sign/signIn")) {
	         // 로그인 기능 구현
			
	         String id = req.getParameter("user_id");
	         String pw = req.getParameter("user_pw");
	         SignInForm signInForm = new SignInForm(id, pw);
	         
	         if (signInForm.isValid()) {
	        	 User signedInUser = USERSERVICE.signIn(id, pw); 

	        	 if (signedInUser != null) {
	        	     // 로그인 성공 
	        	     HttpSession session = req.getSession();
	        	     session.setAttribute("signInUser", signedInUser);
	        	     res.sendRedirect(req.getContextPath() + "/main.jsp"); // PRG 패턴
	        	 } else {
	        		req.setAttribute("errorMessage", "아이디와 비밀번호 입력이 잘못되었습니다.");
	        		req.getRequestDispatcher("/signIn.jsp").forward(req, res);
	        	}
	         } else {
	            req.setAttribute("errorMessage", "아이디와 비밀번호를 모두 입력해주세요.");
	            req.getRequestDispatcher("/signIn.jsp").forward(req, res);
	         }
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
	}