<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>로그인</title>
    <style>
        /* 전체 화면 중앙 정렬 */
        body {
            font-family: Arial, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            background-color: #f0f0f0;
        }

        /* 로그인 박스 */
        .login-container {
            width: 350px;
            padding: 40px;
            border-radius: 10px;
            background-color: #ffffff;
            text-align: center;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
        }

    
        .input-group {
            display: flex;              /* 한 줄 정렬 */
            justify-content: left;  
            align-items: center;        /* 높이 중심 맞춤 */
            margin-bottom: 20px;
            width: 100%;
        }

        .input-group label {
            width: 60px;                /* 라벨 고정 너비 */
            margin-right: 10px;         /* input과 간격 */
            font-weight: bold;
            color: #555;
            text-align: right;          /* 라벨 오른쪽 정렬 */
        }

        .input-group input {
            flex: 1;                    /* 남은 공간을 모두 사용 */
            max-width: 250px;
            padding: 10px;
            border: 1px solid #ccc;
            border-radius: 5px;
            box-sizing: border-box;
            text-align: center;         /* 입력 텍스트 가운데 정렬 */
        }

        /* 버튼 영역 */
        .button-container {
            display: flex;
            justify-content: space-between;
            margin-top: 30px;
        }

        .button-container button {
            width: 48%;
            padding: 12px;
            border: none;
            border-radius: 5px;
            font-weight: bold;
            cursor: pointer;
            transition: 0.3s ease;
        }

        /* 로그인 버튼 */
        #login-btn {
            background-color: #5aaad1;
            color: white;
        }
        #login-btn:hover {
            background-color: #b84a4a
        }

        /* 회원가입 버튼 */
        #register-btn {
            background-color: #5aaad1;
            color: white;
        }
        #register-btn:hover {
            background-color: #4a94b8;
        }
    </style>
</head>
<body>

    <div class="login-container">
        <form action="${pageContext.request.contextPath}/sign/signIn" method="post">
            <div class="input-group">
                <label for="user_id">ID</label>
                <input type="text" id="user_id" name="user_id" placeholder="아이디" required>
            </div>
            <div class="input-group">
                <label for="user_pw">PW</label>
                <input type="password" id="user_pw" name="user_pw" placeholder="비밀번호" required>
            </div>
            <div>
              <% String error = (String) request.getAttribute("errorMessage"); 
              	 if(error != null) {
              %>
            <div style="color:red; font-size:13px; margin-top:10px;">
            	<%=error%>
			</div>
			  <%} %>
            </div>
            <div class="button-container">
                <button type="submit" id="login-btn">로그인</button>
                <button type="button" id="register-btn" onclick="location.href='${pageContext.request.contextPath}/signUp.jsp'">회원가입</button>
            </div>
            
        </form>
    </div>

</body>
</html>
