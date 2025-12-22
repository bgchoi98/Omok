<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="util.Constants" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Sign Up</title>

  <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
  <link href="https://fonts.googleapis.com/css2?family=Patrick+Hand&display=swap" rel="stylesheet">

  <style>
    * { box-sizing: border-box; }

    body {
      margin: 0;
      padding: 0;
      height: 100vh;
      display: flex;
      justify-content: center;
      align-items: center;
      background-image: url('${pageContext.request.contextPath}/assets/images/signUp/signUpBg.png');
      background-size: cover;
      background-position: center;
      background-repeat: no-repeat;
      font-family: 'Patrick Hand', 'Arial', sans-serif;
    }

    .invitation-container {
      position: relative;
      width: 700px;
      height: 600px;
      display: flex;
      justify-content: center;
      align-items: center;
    }

    .paper-bg {
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      z-index: 1;
      filter: drop-shadow(10px 10px 15px rgba(0, 0, 0, 0.4));
      pointer-events: none;
      user-select: none;
    }

    .form-content {
      position: relative;
      z-index: 2;
      width: 65%;
      height: 100%;
      display: flex;
      flex-direction: column;
      align-items: center;
      /* 타이틀과 겹치지 않도록 상단 여백 확보 */
      padding-top: 190px; 
      color: #3e2723;
    }

    .header-title {
      display: none; 
    }

    form#signupForm { width: 100%; }

    .input-group {
      width: 100%;
      /* 메시지가 나올 공간 확보를 위해 마진 조정 */
      margin-bottom: 5px; 
      display: flex;
      flex-direction: column;
    }

    .input-row {
      display: flex;
      align-items: center;
      border-bottom: 2px solid #8d6e63;
      padding-bottom: 3px;
    }

    .input-label {
      width: 80px;
      font-size: 1.3rem;
      font-weight: bold;
      color: #4e342e;
    }

    .input-field {
      flex: 1;
      border: none;
      background-color: transparent !important;
      font-family: 'Patrick Hand', sans-serif;
      font-size: 1.3rem;
      color: #212121;
      outline: none;
      padding-left: 10px;
    }

    .input-field::placeholder {
      color: #a1887f;
      opacity: 0.7;
      font-size: 1.1rem;
    }

    /* 크롬 자동완성 배경색 제거 (투명 유지) */
    input:-webkit-autofill,
    input:-webkit-autofill:hover, 
    input:-webkit-autofill:focus, 
    input:-webkit-autofill:active {
        -webkit-box-shadow: 0 0 0 30px rgba(255, 255, 255, 0) inset !important;
        -webkit-text-fill-color: #212121 !important;
        transition: background-color 5000s ease-in-out 0s;
    }

    /* 유효성 검사 메시지 스타일 */
    .status-msg {
      font-size: 0.85rem;
      text-align: right;
      height: 18px; /* 메시지 공간 고정 */
      line-height: 18px;
      font-weight: bold;
      margin-bottom: 2px;
    }

    .seal-btn {
      position: absolute;
      right: 7%;
      bottom: 6%;
      width: 110px;
      height: 110px;
      background: transparent;
      border: none;
      cursor: pointer;
      z-index: 10;
      transition: transform 0.2s;
      padding: 0;
    }

    .seal-btn:hover { transform: scale(1.1) rotate(5deg); }
    .seal-btn:active { transform: scale(0.95); }

    .seal-btn img {
      width: 100%;
      height: 100%;
      display: block;
    }

    .seal-btn:disabled {
      opacity: 0.5;
      cursor: not-allowed;
      filter: grayscale(100%);
      transform: none;
    }
  </style>
</head>

<body>
  <div class="invitation-container">
    <img
      src="${pageContext.request.contextPath}/assets/images/signUp/invitation.png"
      class="paper-bg"
      alt="Paper"
    >

    <div class="form-content">
      <h1 class="header-title"></h1>

      <form
        id="signupForm"
        action="${pageContext.request.contextPath}<%= Constants.SIGNUP %>"
        method="post"
      >
        <div class="input-group">
          <div class="input-row">
            <span class="input-label">ID:</span>
            <input
              type="text"
              id="user_id"
              name="user_id"
              class="input-field"
              placeholder="Eng+Num (4-12)"
              required
              autocomplete="off"
            >
          </div>
          <div id="idMsg" class="status-msg"></div>
        </div>

        <div class="input-group">
          <div class="input-row">
            <span class="input-label">PW:</span>
            <input 
              type="password" 
              id="user_pw" 
              name="user_pw" 
              class="input-field" 
              placeholder="Eng+Num (8-20)"
              required
            >
          </div>
          <div id="pwMsg" class="status-msg"></div>
        </div>

        <div class="input-group">
          <div class="input-row">
            <span class="input-label">Confirm:</span>
            <input 
              type="password" 
              id="user_pwRe" 
              name="user_pwRe" 
              class="input-field" 
              required
            >
          </div>
          <div id="pwReMsg" class="status-msg"></div>
        </div>

        <div class="input-group">
          <div class="input-row">
            <span class="input-label">Nick:</span>
            <input
              type="text"
              id="nickname"
              name="nickname"
              class="input-field"
              placeholder="2-10 chars"
              required
              autocomplete="off"
            >
          </div>
          <div id="nickMsg" class="status-msg"></div>
        </div>

        <div class="input-group">
          <div class="input-row">
            <span class="input-label">Email:</span>
            <input
              type="text"
              id="email"
              name="email"
              class="input-field"
              placeholder="email@domain.com"
              required
            >
          </div>
          <div id="emailMsg" class="status-msg"></div>
        </div>
      </form>
    </div>

    <button
      type="submit"
      form="signupForm"
      id="join_btn"
      class="seal-btn"
      title="Join Now"
      disabled
    >
      <img
        src="${pageContext.request.contextPath}/assets/images/signUp/joinBtn.png"
        alt="Join Seal"
      >
    </button>
  </div>

  <script>
    $(document).ready(function () {
      // --- 정규식 정의 ---
      // ID: 영문, 숫자 포함 가능 (4~12자)
      const regexId = /^[a-zA-Z0-9]{4,16}$/;
      
      // PW: 영문 + 숫자 필수 포함, 특수문자 금지 (8~20자)
      const regexPw = /^(?=.*[a-zA-Z])(?=.*[0-9])[a-zA-Z0-9]{8,20}$/;
      
      // Nick: 한글, 영문, 숫자 (2~10자)
      const regexNick = /^[a-zA-Z0-9가-힣]{2,12}$/;
      
      // Email: 일반적인 이메일 형식 (@ 뒤에 .이 반드시 포함되어야 함)
      const regexEmail = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;

      // --- 상태 변수 ---
      let status = {
        id: false,
        idDupl: false, // 중복체크 통과 여부
        pw: false,
        pwRe: false,
        nick: false,
        nickDupl: false, // 중복체크 통과 여부
        email: false
      };

      // --- 버튼 활성화 함수 ---
      function checkAllValid() {
        const isValid = status.id && status.idDupl && 
                        status.pw && status.pwRe && 
                        status.nick && status.nickDupl && 
                        status.email;
        $("#join_btn").prop("disabled", !isValid);
      }

      // --- 메시지 출력 헬퍼 ---
      function setMsg(elementId, text, color) {
        $(elementId).text(text).css("color", color);
      }

      // 1. ID 유효성 검사 (입력 시 형식 검사, 변경 시 중복체크 초기화)
      $("#user_id").on("input", function() {
        const val = $(this).val();
        status.idDupl = false; // 입력값이 바뀌면 중복체크 다시 해야 함
        
        if (!regexId.test(val)) {
          status.id = false;
          setMsg("#idMsg", "Eng+Num, 4~16 chars", "#d32f2f");
        } else {
          status.id = true;
          setMsg("#idMsg", "Check availability...", "#a1887f");
        }
        checkAllValid();
      });

      // 1-1. ID 중복 체크 (포커스 아웃 시)
      $("#user_id").on("blur", function() {
        if (!status.id) return; // 형식이 안 맞으면 중복체크 안 함
        
        const val = $(this).val();
        $.ajax({
          url: "<%=request.getContextPath() + Constants.SIGNUP %>",
          method: "GET",
          data: { ajaxCheck: "true", type: "id", value: val },
          success: function(res) {
            if (res === "true") { // 사용 가능
              status.idDupl = true;
              setMsg("#idMsg", "Available ID", "#388e3c");
            } else { // 중복
              status.idDupl = false;
              setMsg("#idMsg", "ID already exists", "#d32f2f");
            }
            checkAllValid();
          }
        });
      });

      // 2. 비밀번호 검사
      $("#user_pw").on("input", function() {
        const val = $(this).val();
        // 비밀번호 확인 로직도 다시 돌려야 함
        $("#user_pwRe").trigger("input");

        if (!regexPw.test(val)) {
          status.pw = false;
          setMsg("#pwMsg", "Eng+Num required (8-20)", "#d32f2f");
        } else {
          status.pw = true;
          setMsg("#pwMsg", "Available PW", "#388e3c");
        }
        checkAllValid();
      });

      // 3. 비밀번호 확인 검사
      $("#user_pwRe").on("input", function() {
        const val = $(this).val();
        const originPw = $("#user_pw").val();

        if (val === "") {
          status.pwRe = false;
          setMsg("#pwReMsg", "", "#d32f2f");
        } else if (val !== originPw) {
          status.pwRe = false;
          setMsg("#pwReMsg", "Passwords do not match", "#d32f2f");
        } else {
          status.pwRe = true;
          setMsg("#pwReMsg", "Matches", "#388e3c");
        }
        checkAllValid();
      });

      // 4. 닉네임 검사
      $("#nickname").on("input", function() {
        const val = $(this).val();
        status.nickDupl = false;

        if (!regexNick.test(val)) {
          status.nick = false;
          setMsg("#nickMsg", "2~12 chars (Eng/Kor/Num)", "#d32f2f");
        } else {
          status.nick = true;
          setMsg("#nickMsg", "Check availability...", "#a1887f");
        }
        checkAllValid();
      });

      // 4-1. 닉네임 중복 체크
      $("#nickname").on("blur", function() {
        if (!status.nick) return;

        const val = $(this).val();
        $.ajax({
          url: "<%=request.getContextPath() + Constants.SIGNUP %>",
          method: "GET",
          data: { ajaxCheck: "true", type: "nickname", value: val },
          success: function(res) {
            if (res === "true") {
              status.nickDupl = true;
              setMsg("#nickMsg", "Available Nickname", "#388e3c");
            } else {
              status.nickDupl = false;
              setMsg("#nickMsg", "Nickname is Already taken", "#d32f2f");
            }
            checkAllValid();
          }
        });
      });

      // 5. 이메일 검사
      $("#email").on("input", function() {
        const val = $(this).val();
        
        if (!regexEmail.test(val)) {
          status.email = false;
          setMsg("#emailMsg", "Invalid format (ex: email@address.com)", "#d32f2f");
        } else {
          status.email = true;
          setMsg("#emailMsg", "Valid Email", "#388e3c");
        }
        checkAllValid();
      });

    });
  </script>
</body>
</html>