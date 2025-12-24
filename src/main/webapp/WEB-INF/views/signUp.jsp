<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="util.Constants"%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Sign Up</title>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<link
	href="https://fonts.googleapis.com/css2?family=Patrick+Hand&display=swap"
	rel="stylesheet">

<style>
* {
	box-sizing: border-box;
}

body {
	margin: 0;
	padding: 0;
	height: 100vh;
	display: flex;
	justify-content: center;
	align-items: center;
	background-image:
		url('${pageContext.request.contextPath}/assets/images/signUp/signUpBg.png');
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
	padding-top: 190px;
	color: #3e2723;
}

.header-title {
	display: none;
}

form#signupForm {
	width: 100%;
}

.input-group {
	width: 100%;
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

input:-webkit-autofill, input:-webkit-autofill:hover, input:-webkit-autofill:focus,
	input:-webkit-autofill:active {
	-webkit-box-shadow: 0 0 0 30px rgba(255, 255, 255, 0) inset !important;
	-webkit-text-fill-color: #212121 !important;
	transition: background-color 5000s ease-in-out 0s;
}

.status-msg {
	font-size: 0.85rem;
	text-align: right;
	height: 18px;
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

.seal-btn:hover {
	transform: scale(1.1) rotate(5deg);
}

.seal-btn:active {
	transform: scale(0.95);
}

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
			class="paper-bg" alt="Paper">

		<div class="form-content">
			<h1 class="header-title"></h1>

			<form id="signupForm"
				action="${pageContext.request.contextPath}<%= Constants.SIGNUP %>"
				method="post">
				<div class="input-group">
					<div class="input-row">
						<span class="input-label">ID:</span> <input type="text"
							id="user_id" name="user_id" class="input-field"
							placeholder="Eng+Num (4-12)" required autocomplete="off">
					</div>
					<div id="idMsg" class="status-msg"></div>
				</div>

				<div class="input-group">
					<div class="input-row">
						<span class="input-label">PW:</span> <input type="password"
							id="user_pw" name="user_pw" class="input-field"
							placeholder="Eng+Num (8-20)" required>
					</div>
					<div id="pwMsg" class="status-msg"></div>
				</div>

				<div class="input-group">
					<div class="input-row">
						<span class="input-label">Confirm:</span> <input type="password"
							id="user_pwRe" name="user_pwRe" class="input-field" required>
					</div>
					<div id="pwReMsg" class="status-msg"></div>
				</div>

				<div class="input-group">
					<div class="input-row">
						<span class="input-label">Nick:</span> <input type="text"
							id="nickname" name="nickname" class="input-field"
							placeholder="2-10 chars" required autocomplete="off">
					</div>
					<div id="nickMsg" class="status-msg"></div>
				</div>

				<div class="input-group">
					<div class="input-row">
						<span class="input-label">Email:</span> <input type="text"
							id="email" name="email" class="input-field"
							placeholder="email@domain.com" required>
					</div>
					<div id="emailMsg" class="status-msg"></div>
				</div>
			</form>
		</div>

		<button type="submit" form="signupForm" id="join_btn" class="seal-btn"
			title="Join Now" disabled>
			<img
				src="${pageContext.request.contextPath}/assets/images/signUp/joinBtn.png"
				alt="Join Seal">
		</button>
	</div>

	<script>
    $(document).ready(function () {
      const regexId = /^[a-zA-Z0-9]{4,16}$/;
      const regexPw = /^(?=.*[a-zA-Z])(?=.*[0-9])[a-zA-Z0-9]{8,20}$/;
      const regexNick = /^[a-zA-Z0-9가-힣]{2,12}$/;
      const regexEmail = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;

      let status = {
        id: false, idDupl: false,
        pw: false, pwRe: false,
        nick: false, nickDupl: false,
        email: false
      };

      // 디바운싱 타이머 변수
      let idTimer = null;
      let nickTimer = null;

      function checkAllValid() {
        const isValid = status.id && status.idDupl && 
                        status.pw && status.pwRe && 
                        status.nick && status.nickDupl && 
                        status.email;
        $("#join_btn").prop("disabled", !isValid);
      }

      function setMsg(elementId, text, color) {
        $(elementId).text(text).css("color", color);
      }

      // 공통 AJAX 중복 체크 함수
      function checkDuplicate(type, value, msgId, successMsg, failMsg, statusKey) {
        $.ajax({
          url: "<%=request.getContextPath() + Constants.SIGNUP%>
		",
											method : "GET",
											data : {
												ajaxCheck : "true",
												type : type,
												value : value
											},
											success : function(res) {
												if (res === "true") {
													status[statusKey] = true;
													setMsg(msgId, successMsg,
															"#388e3c");
												} else {
													status[statusKey] = false;
													setMsg(msgId, failMsg,
															"#d32f2f");
												}
												checkAllValid();
											}
										});
							}

							// 1. ID 입력 (디바운싱 적용)
							$("#user_id").on(
									"input",
									function() {
										clearTimeout(idTimer); // 기존 타이머 취소
										const val = $(this).val();
										status.idDupl = false;

										if (!regexId.test(val)) {
											status.id = false;
											setMsg("#idMsg",
													"Eng+Num, 4~16 chars",
													"#d32f2f");
										} else {
											status.id = true;
											setMsg("#idMsg", "Checking...",
													"#a1887f");

											// 1초 뒤에 자동으로 중복 체크
											idTimer = setTimeout(function() {
												checkDuplicate("id", val,
														"#idMsg",
														"Available ID",
														"ID already exists",
														"idDupl");
											}, 1000);
										}
										checkAllValid();
									});

							// 1-1. ID 포커스 아웃 (즉시 체크)
							$("#user_id").on(
									"blur",
									function() {
										clearTimeout(idTimer); // 타이머 취소하고 즉시 실행
										if (!status.id)
											return;
										checkDuplicate("id", $(this).val(),
												"#idMsg", "Available ID",
												"ID already exists", "idDupl");
									});

							// 2. PW 입력
							$("#user_pw").on(
									"input",
									function() {
										const val = $(this).val();
										$("#user_pwRe").trigger("input");

										if (!regexPw.test(val)) {
											status.pw = false;
											setMsg("#pwMsg",
													"Eng+Num required (8-20)",
													"#d32f2f");
										} else {
											status.pw = true;
											setMsg("#pwMsg", "Available PW",
													"#388e3c");
										}
										checkAllValid();
									});

							// 3. PW 확인
							$("#user_pwRe").on(
									"input",
									function() {
										const val = $(this).val();
										const originPw = $("#user_pw").val();

										if (val === "") {
											status.pwRe = false;
											setMsg("#pwReMsg", "", "#d32f2f");
										} else if (val !== originPw) {
											status.pwRe = false;
											setMsg("#pwReMsg",
													"Passwords do not match",
													"#d32f2f");
										} else {
											status.pwRe = true;
											setMsg("#pwReMsg", "Matches",
													"#388e3c");
										}
										checkAllValid();
									});

							// 4. 닉네임 입력 (디바운싱 적용)
							$("#nickname").on(
									"input",
									function() {
										clearTimeout(nickTimer); // 기존 타이머 취소
										const val = $(this).val();
										status.nickDupl = false;

										if (!regexNick.test(val)) {
											status.nick = false;
											setMsg("#nickMsg",
													"2~12 chars (Eng/Kor/Num)",
													"#d32f2f");
										} else {
											status.nick = true;
											setMsg("#nickMsg", "Checking...",
													"#a1887f");

											// 1초 뒤에 자동으로 중복 체크
											nickTimer = setTimeout(function() {
												checkDuplicate("nickname", val,
														"#nickMsg",
														"Available Nickname",
														"Nickname taken",
														"nickDupl");
											}, 1000);
										}
										checkAllValid();
									});

							// 4-1. 닉네임 포커스 아웃 (즉시 체크)
							$("#nickname").on(
									"blur",
									function() {
										clearTimeout(nickTimer); // 타이머 취소하고 즉시 실행
										if (!status.nick)
											return;
										checkDuplicate("nickname", $(this)
												.val(), "#nickMsg",
												"Available Nickname",
												"Nickname taken", "nickDupl");
									});

							// 5. 이메일 입력
							$("#email")
									.on(
											"input",
											function() {
												const val = $(this).val();

												if (!regexEmail.test(val)) {
													status.email = false;
													setMsg(
															"#emailMsg",
															"Invalid format (ex: email@address.com)",
															"#d32f2f");
												} else {
													status.email = true;
													setMsg("#emailMsg",
															"Valid Email",
															"#388e3c");
												}
												checkAllValid();
											});

						});
	</script>
</body>
</html>