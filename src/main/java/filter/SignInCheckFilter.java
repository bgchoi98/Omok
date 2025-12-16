package filter;

import java.io.IOException;


import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import consts.Constants;



public class SignInCheckFilter extends HttpFilter implements Filter {


	
	
	public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {

		HttpServletRequest httpRequest = (HttpServletRequest) request;
		HttpServletResponse httpResponse = (HttpServletResponse) response;
		
		String requestURI = httpRequest.getRequestURI();
		

		 if (isLoginCheckPath(httpRequest)) {
	            HttpSession session = httpRequest.getSession(false);

	            if (session == null ||
	            		session.getAttribute(Constants.SESSION_KEY) == null) { // 세션에 signMember 말고 다른 이름으로 넣는다면 변경 필요

	                httpResponse.sendRedirect(httpRequest.getContextPath() + Constants.SIGNIN);
	                return;
	            }
	        }

	        chain.doFilter(request, response);
	}
	
	private boolean isLoginCheckPath(HttpServletRequest request) {
		String uri = request.getRequestURI();
	    String ctx = request.getContextPath();
	    
	    return !(
	            uri.equals(ctx + "/") ||
	            uri.equals(ctx + Constants.SIGNIN) ||
	            uri.equals(ctx + Constants.SIGNUP) ||
	            uri.startsWith(ctx + "/css/") ||
	            uri.startsWith(ctx + "/js/")
	        );
	}
}
