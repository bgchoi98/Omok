<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script> <!-- jQuery -->
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

        .input-with-msg {
            display: flex;
            flex-direction: column;
            flex: 1;
        }

        /* 버튼 영역 */
        .button-container {
            display: flex;
            justify-content: center;
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

        /* 가입 버튼 */
        #join_btn {
            background-color: #5aaad1;
            color: white;
        }

        #join_btn:disabled {
            opacity: 0.5;
            cursor: not-allowed;
        }
    </style>
</head>

<body>


<div class="login-container">
    <form action="${pageContext.request.contextPath}/sign/signUp" method="post">
        <div class="input-group">
            <label for="user_id">ID</label>
            <div class="input-with-msg">
                <input type="text" id="user_id" name="user_id" placeholder="아이디" required>
                <div id="idMsg" style="color:red; font-size:13px; margin-top:2px;"></div>
            </div>
        </div>

        <div class="input-group">
            <label for="user_pw">PW</label>
            <input type="password" id="user_pw" name="user_pw" placeholder="비밀번호" required>	
        </div> 

        <div class="input-group">
            <label></label>
            <input type="password" id="user_pwRe" name="user_pwRe" placeholder="비밀번호 재입력" required>
        </div>

        <div class="input-group">
            <label>닉네임</label>
            <div class="input-with-msg">
                <input type="text" id="nickname" name="nickname" placeholder="닉네임" required>
                <div id="nickMsg" style="color:red; font-size:13px; margin-top:2px;"></div>
            </div>
        </div>

        <div class="input-group">
            <label>이메일</label>
            <input type="text" id="email" name="email" placeholder="이메일" required>
        </div>

        <div class="button-container">
            <!-- 기본 비활성화 -->
            <button type="submit" id="join_btn" disabled>가입하기</button>
        </div>       
    </form>
</div>

</body>

<script>
$(document).ready(function() {

    // ID / 닉네임 사용 가능 여부 상태값
    // 여기에 패스워드, 이메일등 검증도 추가해야됨. (정규식)
    let isIdAvailable = false;
    let isNickAvailable = false;

    // 가입 버튼 활성/비활성 처리
    function toggleJoinBtn() {
        if (isIdAvailable && isNickAvailable) {
            $("#join_btn").prop("disabled", false);
        } else {
            $("#join_btn").prop("disabled", true);
        }
    }

    // 중복 체크 AJAX
    function checkAvailability(type, value, msgId) {
        if(value.trim() === "") return;

        $.ajax({
            url: "/Omok_Mini/sign/signUp",
            method: "GET",
            data: { 
                ajaxCheck: "true",   // ajax요청인지 구분
                type: type,         // id or nickname
                value: value        // 입력값
            },
            success: function(response) {
                const msg = $("#" + msgId);

                if (response === "false") {	// 중복된 값이라면
                    msg.css("color", "red");

                    if (type === "id") {
                        msg.text(value + " 는 사용중인 ID 입니다.");
                        isIdAvailable = false;
                    } else {
                        msg.text(value + " 는 사용중인 닉네임 입니다.");
                        isNickAvailable = false;
                    }

                } else { // 사용 가능
                    msg.css("color", "green");

                    if (type === "id") {
                        msg.text("사용가능한 ID 입니다.");
                        isIdAvailable = true;
                    } else {
                        msg.text("사용가능한 닉네임 입니다.");
                        isNickAvailable = true;
                    }
                }

                // 버튼 상태 갱신
                toggleJoinBtn();
            }
        });
    }

    // blur 이벤트로 AJAX 체크
    $("#user_id").blur(function() {
        checkAvailability("id", $(this).val(), "idMsg");
    });

    $("#nickname").blur(function() {
        checkAvailability("nickname", $(this).val(), "nickMsg");
    });

    // input 이벤트로 다시 비활성화 (값 바꾸면 재검증 필요)
    // 아이디나 닉네임 다시 입력하면 초기화
    $("#user_id").on("input", function() {
        isIdAvailable = false;
        $("#idMsg").text("");
        toggleJoinBtn();
    });

    $("#nickname").on("input", function() {
        isNickAvailable = false;
        $("#nickMsg").text("");
        toggleJoinBtn();
    });

});
</script>
</html>
