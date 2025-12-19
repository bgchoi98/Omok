package util;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;



/**
 * Servlet implementation class RoomsServlet
 */
@WebServlet(urlPatterns = {
		Constants.MAIN,
		Constants.GAME
})
public class LobbyController extends HttpServlet {
	

	protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
		String uri = req.getRequestURI();
		String contextPath = req.getContextPath();

		if (uri.equals(contextPath + Constants.MAIN)) {
			
			HttpSession session = req.getSession(false);
			
			if (session == null || session.getAttribute(Constants.SESSION_KEY) == null) {
				res.sendRedirect(req.getContextPath() + Constants.SIGNIN);
				return;
			}
			req.getRequestDispatcher(Constants.VIEW_MAIN).forward(req, res);
			
		}
	}



	protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
		String uri = req.getRequestURI();

		if (uri.equals(Constants.GAME)) {
		
			// 게임 시작
		} 
	}

}
