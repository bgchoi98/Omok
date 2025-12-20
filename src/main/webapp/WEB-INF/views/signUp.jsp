<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="util.Constants" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Invitation - Sign Up</title>

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
      width: 60%;
      height: 75%;
      display: flex;
      flex-direction: column;
      align-items: center;
      padding-top: 10px;
      color: #3e2723;
    }

    .header-title {
      font-size: 3rem;
      margin-bottom: 20px;
      color: #5d4037;
      text-decoration: underline;
      text-decoration-style: double;
      text-decoration-color: #8d6e63;
    }

    form#signupForm { width: 100%; }

    .input-group {
      width: 100%;
      margin-bottom: 15px;
      display: flex;
      flex-direction: column;
    }

    .input-row {
      display: flex;
      align-items: center;
      border-bottom: 2px solid #8d6e63;
      padding-bottom: 5px;
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
      background: transparent;
      font-family: 'Patrick Hand', sans-serif;
      font-size: 1.3rem;
      color: #212121;
      outline: none;
      padding-left: 10px;
    }

    .input-field::placeholder {
      color: #a1887f;
      opacity: 0.7;
    }

    .status-msg {
      font-size: 0.9rem;
      text-align: right;
      height: 15px;
      margin-top: 2px;
    }

    /* ✅ Join 버튼을 “종이 이미지의 우측 하단”에 고정 */
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
      opacity: 0.6;
      cursor: not-allowed;
      filter: grayscale(80%);
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
      onerror="this.src='https://placehold.co/700x600/f5deb3/8b4513?text=Parchment'"
    >

    <div class="form-content">
      <h1 class="header-title">Invitation</h1>

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
              placeholder="User ID"
              required
              autocomplete="off"
            >
          </div>
          <div id="idMsg" class="status-msg"></div>
        </div>

        <div class="input-group" style="margin-bottom: 10px;">
          <div class="input-row">
            <span class="input-label">PW:</span>
            <input type="password" id="user_pw" name="user_pw" class="input-field" required>
          </div>
        </div>

        <div class="input-group">
          <div class="input-row">
            <span class="input-label">Confirm:</span>
            <input type="password" id="user_pwRe" name="user_pwRe" class="input-field" required>
          </div>
        </div>

        <div class="input-group">
          <div class="input-row">
            <span class="input-label">Nick:</span>
            <input
              type="text"
              id="nickname"
              name="nickname"
              class="input-field"
              placeholder="Nickname"
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
              placeholder="Email@address.com"
              required
            >
          </div>
        </div>
      </form>
    </div>

    <!-- ✅ form 밖으로 빼고, form="signupForm"으로 submit 연결 -->
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
        onerror="this.src='https://placehold.co/100x100/8b0000/ffffff?text=Seal'"
      >
    </button>
  </div>

  <script>
    $(document).ready(function () {
      let isIdAvailable = false;
      let isNickAvailable = false;

      function toggleJoinBtn() {
        $("#join_btn").prop("disabled", !(isIdAvailable && isNickAvailable));
      }

      function checkAvailability(type, value, msgId) {
        if (value.trim() === "") return;

        $.ajax({
          url: "<%=request.getContextPath() + Constants.SIGNUP %>",
          method: "GET",
          data: { ajaxCheck: "true", type: type, value: value },
          success: function (response) {
            const msg = $("#" + msgId);

            if (response === "false") {
              msg.css("color", "#d32f2f");
              msg.text(type === "id" ? "Unavailable ID" : "Unavailable Nickname");
              if (type === "id") isIdAvailable = false;
              else isNickAvailable = false;
            } else {
              msg.css("color", "#388e3c");
              msg.text("Available");
              if (type === "id") isIdAvailable = true;
              else isNickAvailable = true;
            }
            toggleJoinBtn();
          }
        });
      }

      $("#user_id").blur(function () { checkAvailability("id", $(this).val(), "idMsg"); });
      $("#nickname").blur(function () { checkAvailability("nickname", $(this).val(), "nickMsg"); });

      $("#user_id").on("input", function () {
        isIdAvailable = false;
        $("#idMsg").text("");
        toggleJoinBtn();
      });

      $("#nickname").on("input", function () {
        isNickAvailable = false;
        $("#nickMsg").text("");
        toggleJoinBtn();
      });
    });
  </script>
</body>
</html>
