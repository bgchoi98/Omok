package rank;

import java.io.IOException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


@WebServlet("/rank")
public class RankController extends HttpServlet {

	private static final RankService RANKSERVICE = RankService.getInstance();


	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		
		List<Rank> ranks = RANKSERVICE.findAll();
		request.setAttribute("ranks", ranks);

	    request.getRequestDispatcher("/WEB-INF/views/rank.jsp")
	           .forward(request, response);
	}
	
}
