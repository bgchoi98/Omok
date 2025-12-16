<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="users.User" %>
<%
    User user = (User) session.getAttribute("signInUser");
    // 메인화면에 넘어올 때 세션에 값이 없다면 다시 로그인페이지로 리다이렉트
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/signIn.jsp");
        return;
    }
%>  
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>오목 메인</title>
    <style>
        /* 전체 화면 중앙 정렬 (signIn.jsp와 동일) */
        body {
            font-family: Arial, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            background-color: #f0f0f0;
        }

        /* 흰색 박스 컨테이너 (signIn.jsp와 동일) */
        .main-container {
            width: 350px;
            padding: 40px;
            border-radius: 10px;
            background-color: #ffffff;
            text-align: center;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
        }

        /* 텍스트 정보 영역 스타일 */
        .info-group {
            text-align: left;
            margin-bottom: 30px;
            padding: 20px;
            background-color: #f9f9f9;
            border-radius: 5px;
            border: 1px solid #eee;
            line-height: 1.6;
            color: #555;
        }
        
        .info-group span {
            font-weight: bold;
            color: #333;
        }

        /* 버튼 영역 (signIn.jsp와 동일하게 양옆 배치) */
        .button-container {
            display: flex;
            justify-content: space-between;
            margin-top: 30px;
        }

        /* 공통 버튼 스타일 */
        .button-container button {
            padding: 12px;
            border: none;
            border-radius: 5px;
            font-weight: bold;
            cursor: pointer;
            transition: 0.3s ease;
            font-size: 14px;
        }
        
        /* 회원탈퇴 폼 (버튼 배치를 위해 너비 설정) */
        .signout-form {
            width: 48%;
            margin: 0; /* 폼 기본 마진 제거 */
        }

        /* 로그아웃 버튼 (기본 파란색) */
        #signout-btn {
            width: 48%; /* 버튼 너비 설정 */
            background-color: #5aaad1;
            color: white;
        }
        #signout-btn:hover {
            background-color: #4a94b8;
        }

        /* 회원탈퇴 폼 (버튼 배치를 위해 너비 설정) */
        .withdraw-form {
            width: 48%;
            margin: 0; /* 폼 기본 마진 제거 */
        }

        /* 회원탈퇴 버튼 (위험하므로 붉은색) */
        #withdraw-btn {
            width: 100%; /* 폼 안에서 꽉 차게 */
            background-color: #d9534f;
            color: white;
        }
        #withdraw-btn:hover {
            background-color: #c9302c;
        }
        
        h1 {
            color: #333;
            margin-bottom: 20px;
            font-size: 24px;
        }
        
        .bottom-center-btn {
		    position: fixed;          
		    bottom: 30px;             
		    left: 50%;               
		    transform: translateX(-50%); 
		
		    padding: 12px 24px;
		    font-size: 16px;
		    cursor: pointer;
		}
    </style>
</head>
<body>

    <div class="main-container">
        <h1>메인 로비</h1>
        <h2><%= user.getNickname() %>님, 안녕하세요!</h2>
        
        <div class="info-group">
            <span>아이디:</span> <%=user.getUserId() %> <br>
            <span>닉네임:</span> <%=user.getNickname() %> <br>
            <span>이메일:</span> <%=user.getEmail() %>
        </div>
        
        <div class="button-container">
            <!-- <button type="button" id="logout-btn" 
                    onclick="location.href='${pageContext.request.contextPath}/sign/signOut'">
                로그아웃
            </button> -->
            
            <form action="${pageContext.request.contextPath}/sign/signOut" method="post" 
                  class="signout-form"
                  onsubmit="return confirm('로그아웃 하시겠습니까?');">
                <button type="submit" id="signout-btn">로그아웃</button>
            </form>
            
            <form action="${pageContext.request.contextPath}/sign/signWithdraw" method="post" 
                  class="withdraw-form"
                  onsubmit="return confirm('정말로 탈퇴하시겠습니까?\n삭제된 데이터는 복구할 수 없습니다.');">
                <button type="submit" id="withdraw-btn">회원탈퇴</button>
            </form>
        </div>
        
		<div>
			<button
    			type="button"
    			id="register-btn"
    			class="bottom-center-btn"
    			onclick="location.href='<%=request.getContextPath() %>/rank'">
    			랭킹 페이지
			</button>
		</div>        
        
    </div>

</body>
</html>