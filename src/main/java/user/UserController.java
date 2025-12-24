package user;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import game.GameWebSocket;
import user.dto.SignInForm;
import user.dto.SignUpForm;
import util.Constants;

/**
 * Servlet implementation class UsersServlet
 */
@WebServlet(urlPatterns = { "", Constants.SIGN, Constants.SIGNUP, Constants.SIGNIN, Constants.SIGNOUT,
		Constants.WITHDRAW })
public class UserController extends HttpServlet {

	private static final UserService USERSERVICE = UserService.getInstance();
	private static final Logger log = LoggerFactory.getLogger(UserController.class);

	protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
		String uri = req.getRequestURI().substring(req.getContextPath().length());

		if (uri.equals(Constants.SIGNUP)) {
			// 회원 가입 페이지 이동 및 중복 체크 로직
			if ("true".equals(req.getParameter("ajaxCheck"))) {
				String type = req.getParameter("type");
				String value = req.getParameter("value");

				boolean isAvailable = false;
				if ("id".equals(type)) {
					isAvailable = USERSERVICE.isIdExist(value);
				} else if ("nickname".equals(type)) {
					isAvailable = USERSERVICE.isNickNameExist(value);
				}

				res.getWriter().write(isAvailable ? "true" : "false");
				return;
			}
			req.getRequestDispatcher(Constants.VIEW_SIGNUP).forward(req, res);

		} else if (uri.equals(Constants.SIGNIN) || uri.equals(Constants.SIGN)) {
			// 로그인 페이지 이동
			req.getRequestDispatcher(Constants.VIEW_SIGNIN).forward(req, res);

		} else if (uri.equals(Constants.ROOT) || uri.equals("")) {
			// [수정됨] 루트 경로("/") 접근 시 로직

			HttpSession session = req.getSession(false); // 세션이 없으면 null 반환
			boolean isLoggedIn = (session != null && session.getAttribute(Constants.SESSION_KEY) != null);

			if (isLoggedIn) {
				// 로그인 상태면 메인으로
				res.sendRedirect(req.getContextPath() + Constants.MAIN);
			} else {
				// 비로그인 상태면 로그인 창으로
				res.sendRedirect(req.getContextPath() + Constants.SIGNIN);
			}
		}
	}

	protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
		req.setCharacterEncoding("UTF-8");
		String uri = req.getRequestURI().substring(req.getContextPath().length());

		if (uri.equals(Constants.SIGNUP)) {
			// 회원 가입 기능 구현

			String id = req.getParameter("user_id");
			String pw = req.getParameter("user_pw");
			String email = req.getParameter("email");
			String nickname = req.getParameter("nickname");

			SignUpForm joinform = new SignUpForm(id, pw, email, nickname); // 서버단 검증 객체 생성

			boolean isValid = joinform.joinValidation(); // 입력이 null 이 아닌지 검증

			if (isValid) {
				User user = new User(id, pw, email, nickname);
				User savedUser = USERSERVICE.signUp(user); // 입력이 중복인지 아닌지 service 레이어에서 검증
				log.info("new Member join : {}, {}, {}, {}", savedUser.getSignId(), savedUser.getPassword(),
						savedUser.getNickname(), savedUser.getNickname());

				res.sendRedirect(req.getContextPath() + Constants.SIGNIN + "?msg=register");
			} else {
				req.setAttribute("errorMessage", "입력해주세요");
			}

		} else if (uri.equals(Constants.SIGNIN)) {
			// 로그인 기능 구현
			String id = req.getParameter("user_id");
			String pw = req.getParameter("user_pw");
			SignInForm signInForm = new SignInForm(id, pw);

			if (signInForm.isValid()) {
				User signedInUser = USERSERVICE.signIn(id, pw);

				if (signedInUser != null) {
					// 로그인 성공
					HttpSession session = req.getSession();
					session.setAttribute(Constants.SESSION_KEY, signedInUser);
					res.sendRedirect(req.getContextPath() + Constants.MAIN); // PRG 패턴
				} else {
					req.setAttribute("errorMessage", "아이디와 비밀번호 입력이 잘못되었습니다.");
					req.getRequestDispatcher(Constants.VIEW_SIGNIN).forward(req, res);
				}
			} else {
				req.setAttribute("errorMessage", "아이디와 비밀번호를 모두 입력해주세요.");
				req.getRequestDispatcher(Constants.VIEW_SIGNIN).forward(req, res);
			}
		} else if (uri.equals(Constants.SIGNOUT)) {
			// 로그 아웃 기능 구현

			HttpSession session = req.getSession(false); // 기존 세션이 존재하는지 확인 (없으면 null 반환)

			if (session != null) {
				session.invalidate(); // 세션이 있다면 invalidate();
			}

			// 로그아웃 후 로그인 페이지로 다시 돌아가기
			res.sendRedirect(req.getContextPath() + Constants.SIGNIN + "?msg=logout");
		} else if (uri.equals(Constants.WITHDRAW)) {
			// 회원 탈퇴 기능 구현

			HttpSession session = req.getSession(false);
			if (session == null || session.getAttribute(Constants.SESSION_KEY) == null) {
				res.sendRedirect(req.getContextPath() + Constants.SIGNIN + "?msg=logout");

				return;

			}

			String inputPassword = req.getParameter("user_pw");

			if (inputPassword == null || inputPassword.trim().isEmpty()) {
				res.sendRedirect(req.getContextPath() + Constants.MAIN + "?error=no_password");
				return;
			}

			User user = (User) session.getAttribute(Constants.SESSION_KEY);
			boolean isDeleted = USERSERVICE.withdraw(user.getUserSeq(), inputPassword);

			if (isDeleted) {
				// 성공 시 세션 파기하고 메인으로
				session.invalidate();
				res.sendRedirect(req.getContextPath() + Constants.SIGNIN + "?msg=bye");
			} else {
				// 실패 시 예외처리
//                  res.sendRedirect(req.getContextPath() + Constants.VIEW_MAIN +"?error=fail");
				res.sendRedirect(req.getContextPath() + Constants.MAIN + "?error=wrong_password");
			}
		}
	}
}