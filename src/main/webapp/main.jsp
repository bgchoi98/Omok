<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="users.User" %>
<%
User user = (User) session.getAttribute("signInUser");	//메인화면에 넘어올떄 세션에 값이 없다면 다시 로그인페이지로 리다이렉트
if (user == null) {
    response.sendRedirect("/signIn.jsp");
    return;
}
%>  
<!DOCTYPE html>
<html>
<head>
<meta charset="EUC-KR">
<title>Insert title here</title>
</head>
<body>
	<h1>메인페이지 임시입니다.</h1>
	로그인 및 세션 아이디 : <%=user.getUserId() %> <br>
	닉네임 :  <%=user.getNickname() %> <br>
	이메일 :  <%=user.getEmail() %>
	
</body>
</html>