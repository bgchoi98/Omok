package users.usersController;

import java.io.IOException;
import java.time.LocalDateTime;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

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
			
			//굳이 서블릿 거쳐야되나? 물어보기
		} else if (uri.equals("/sign/signIn")) {
			// 로그인 기능 구현	
			req.getRequestDispatcher("/signIn.jsp")
	           .forward(req, res);
		} else if (uri.equals("/sign/signOut")) {
			// 로그 아웃 기능 구현
			
		} 

	} 
	
	protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
		String uri = req.getRequestURI().substring(req.getContextPath().length());         
	
		if (uri.equals("/sign/signUp")) {
			// 회원 가입 기능 구현
			String id = req.getParameter("user_id");
			String pw = req.getParameter("user_pw");
			String pwRe = req.getParameter("user_pwRe");
			String email = req.getParameter("email");
			String nickname = req.getParameter("nickname");
			
			SignUpForm joinform = new SignUpForm(id, pw, email, nickname);
			if(joinform.JoinValidation()) {
				boolean SignFormChk = USERSERVICE.SignUp(joinform);
				if (SignFormChk) {
					res.sendRedirect("/Omok/main.jsp");	//회원가입 성공 시
				} else {
					req.setAttribute("errorMessage", "이미 존재하는 ID입니다.");
					req.getRequestDispatcher("/signUp.jsp").forward(req, res);
				}
			} else {	
				req.getRequestDispatcher("/signUp.jsp").forward(req, res);
				return;
			}
			
		} else if (uri.equals("/sign/signIn")) {
			// 로그인 기능 구현
			String id = req.getParameter("user_id");
			String pw = req.getParameter("user_pw");
			User user = USERSERVICE.login(id, pw);
				
			if (user == null) {
				req.setAttribute("errorMessage", "아이디 또는 비밀번호가 올바르지 않습니다.");
				req.getRequestDispatcher("/signIn.jsp").forward(req, res);
				return;
			} else {
			    HttpSession session = req.getSession();	//세션 저장
			    session.setAttribute("user_id", id);
			    //상원님이 말한 prg 패턴인듯 리다이렉트를해야 get요청으로 이동해서 post요청이 안나는듯?
			    res.sendRedirect("/Omok/main.jsp");
			}
		} else if (uri.equals("/sign/signWithdraw")) {
			// 회원 탈퇴 기능 구현
			
		}
	} 
		
	}