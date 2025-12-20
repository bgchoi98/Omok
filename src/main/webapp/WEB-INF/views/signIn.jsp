<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="util.Constants" %>

<%
  String ctx = request.getContextPath();
%>

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>산타의 오목방 - 로그인</title>

  <style>
    :root {
      --scene-w: 100vw;
      --scene-h: 100vh;
      --walk-duration: 3.5s;
      --door-duration: 1.2s;

      /* 패널 */
      --panel-bottom: 33%;
      --panel-translateY: 43%;
      --panel-width: clamp(260px, 26vw, 360px); /* ✅ 전체 폼 영역 더 큼 */
      --panel-inv-scale: 0.40;

      /* ===== UI 요소(입력/버튼) 크기 키우기 ===== */
      --ui-item-w: 94%;       /* ✅ 폭 증가 */
      --ui-input-h: 82px;     /* ✅ 입력 박스 높이 증가 */
      --ui-btn-h: 72px;       /* ✅ 버튼도 같은 높이로 증가 */
      --ui-gap: 14px;

      /* Hover / Focus 효과 */
      --hover-scale: 1.05;
      --hover-shadow: 0 10px 22px rgba(0,0,0,0.22);
      --hover-glow: 0 0 0 3px rgba(255, 230, 180, 0.25);

      /* Door Geometry */
      --door-left: 50%;
      --door-bottom: 14%;
      --door-w: 25.5%;
      --door-scale-x: 1.00;
      --door-scale-y: 0.9;

      /* Hole Geometry */
      --hole-left: 50%;
      --hole-bottom: 12.8%;
      --hole-w: 26.0%;
      --hole-h: 40%;
      --hole-offset-y: 0%;
    }

    * { box-sizing: border-box; }
    body {
      margin: 0;
      font-family: system-ui, -apple-system, Segoe UI, Roboto, "Noto Sans KR", sans-serif;
      background: #0b0d18;
      overflow: hidden;
    }

    .scene {
      position: relative;
      width: var(--scene-w);
      height: var(--scene-h);
      background: url("<%=ctx%>/assets/images/signIn/bg.png") center/cover no-repeat;
      overflow: hidden;
      perspective: 1000px;
    }

    .zoom-wrapper {
      position: relative;
      width: 100%;
      height: 100%;
      transform-origin: center 60%;
      will-change: transform;
    }
    .scene.walking .zoom-wrapper {
      animation: walk var(--walk-duration) ease-in-out forwards;
    }
    @keyframes walk {
      0%   { transform: scale(1) translateY(0) rotateZ(0deg); }
      20%  { transform: scale(1.3) translateY(2%) rotateZ(1deg); }
      40%  { transform: scale(1.6) translateY(4%) rotateZ(-1deg); }
      60%  { transform: scale(1.9) translateY(6%) rotateZ(1deg); }
      80%  { transform: scale(2.2) translateY(8%) rotateZ(-0.5deg); }
      100% { transform: scale(2.5) translateY(9.5%) rotateZ(0deg); }
    }

    .cabin-anchor {
      position: absolute;
      left: 50%;
      bottom: 25vh;
      transform: translateX(-50%);
      width: min(60vw, 600px);
      z-index: 10;
    }

    .cabin-container {
      position: relative;
      width: 100%;
      aspect-ratio: 562 / 444;
    }

    .cabin {
      position: absolute;
      inset: 0;
      width: 100%;
      height: 100%;
      object-fit: contain;
      display: block;
      z-index: 10;
      pointer-events: none;
    }

    .title-img {
      position: absolute;
      top: 12%;
      left: 50%;
      transform: translateX(-50%);
      width: 45%;
      z-index: 15;
      opacity: 0;
      transition: opacity 1.0s ease;
      pointer-events: none;
    }
    .scene.form-ready .title-img { opacity: 1; }

    .inside-bg {
      position: absolute;
      left: var(--hole-left);
      bottom: var(--hole-bottom);
      width: var(--hole-w);
      height: var(--hole-h);
      transform: translateX(-50%) translateY(var(--hole-offset-y));
      z-index: 11;
      opacity: 0;
      pointer-events: none;
      border-radius: 18px 18px 12px 12px;
      filter: blur(1.2px);
      background: radial-gradient(
        ellipse 70% 90% at center 35%,
        rgba(255, 210, 140, 0.55) 0%,
        rgba(80, 55, 35, 0.22) 55%,
        rgba(20, 15, 12, 0.00) 100%
      );
      transition: opacity 1.1s ease 0.25s;
    }
    .scene.door-open .inside-bg { opacity: 0.9; }
    .scene.form-ready .inside-bg { opacity: 0.5; }

    .door {
      position: absolute;
      left: var(--door-left);
      bottom: var(--door-bottom);
      width: var(--door-w);
      transform: translateX(-50%);
      transform-origin: left center;
      z-index: 12;
      background: transparent;
      border: none;
      padding: 0;
      transition: transform var(--door-duration) ease-in-out;
      display: block;
      cursor: default;
    }
    .door .door-scaler {
      display: block;
      transform: scale(var(--door-scale-x), var(--door-scale-y));
      transform-origin: left center;
    }
    .door img { width: 100%; height: auto; display: block; }
    .scene.door-open .door { transform: translateX(-50%) rotateY(-120deg); }

    /* Login Panel */
    .login-panel {
      position: absolute;
      left: 50%;
      bottom: var(--panel-bottom);
      transform: translateX(-50%) translateY(var(--panel-translateY));
      width: var(--panel-width);
      z-index: 20;

      background: transparent !important;
      box-shadow: none !important;
      border: none !important;

      pointer-events: none;
      transition: transform 0.8s cubic-bezier(0.34, 1.56, 0.64, 1);
    }

    .scene.form-ready .login-panel {
      pointer-events: auto;
      transform: translateX(-50%) translateY(var(--panel-translateY)) scale(var(--panel-inv-scale));
    }

    .login-panel-inner {
      transform: scale(0.1);
      opacity: 0;
      transition: all 0.8s cubic-bezier(0.34, 1.56, 0.64, 1);
      background: transparent !important;
    }
    .scene.form-ready .login-panel-inner { transform: scale(1); opacity: 1; }

    .login-panel-inner form {
      width: 100%;
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: var(--ui-gap);
      background: transparent !important;
    }

    /* ✅ Input Group: hover/focus 효과를 “박스 전체”에 적용 */
    .input-group {
      position: relative;
      width: var(--ui-item-w);
      height: var(--ui-input-h);
      transition: transform 0.14s ease, filter 0.14s ease;
      will-change: transform;
    }

    /* 마우스 올리면 살짝 커짐 */
    .input-group:hover {
      transform: scale(var(--hover-scale));
      filter: drop-shadow(0 8px 14px rgba(0,0,0,0.22));
    }

    /* 포커스(클릭)되면 좀 더 확실히 */
    .input-group:focus-within {
      transform: scale(calc(var(--hover-scale) + 0.01));
      filter: drop-shadow(0 10px 18px rgba(0,0,0,0.26));
    }

    /* 포커스 시 “은은한 글로우” 오버레이 */
    .input-group::after {
      content: "";
      position: absolute;
      inset: 6% 8%;
      border-radius: 12px;
      opacity: 0;
      transition: opacity 0.14s ease;
      box-shadow: var(--hover-glow);
      pointer-events: none;
    }
    .input-group:focus-within::after {
      opacity: 1;
    }

    .input-bg {
      position: absolute;
      inset: 0;
      width: 100%;
      height: 100%;
      object-fit: contain;
      pointer-events: none;
    }

    .input-field {
      position: absolute;
      left: 20%;
      right: 15%;
      top: 22%;
      bottom: 22%;

      background: transparent !important;
      background-color: transparent !important;
      border: none !important;
      outline: none !important;
      box-shadow: none !important;

      appearance: none;
      -webkit-appearance: none;
      -moz-appearance: none;

      font-size: 18px;            /* ✅ 글자도 약간 키움 */
      color: #2b2b2b;
      text-align: center;
      caret-color: #2b2b2b;
    }

    input.input-field:-webkit-autofill,
    input.input-field:-webkit-autofill:hover,
    input.input-field:-webkit-autofill:focus,
    input.input-field:-webkit-autofill:active {
      -webkit-box-shadow: 0 0 0px 1000px transparent inset !important;
      box-shadow: 0 0 0px 1000px transparent inset !important;
      -webkit-text-fill-color: #2b2b2b !important;
      caret-color: #2b2b2b !important;
      transition: background-color 99999s ease-in-out 0s;
    }

    .button-container {
      width: var(--ui-item-w);
      display: flex;
      flex-direction: column;
      gap: var(--ui-gap);
      align-items: center;
      margin-top: 6px;
    }

    .img-btn {
      width: 100%;
      background: transparent;
      border: none;
      cursor: pointer;
      padding: 0;
      transition: transform 0.12s ease, filter 0.12s ease;
      display: block;
      will-change: transform;
    }

    .img-btn img {
      width: 100%;
      height: var(--ui-btn-h);
      object-fit: contain;
      display: block;
    }

    .img-btn:hover {
      transform: scale(var(--hover-scale));
      filter: drop-shadow(0 10px 18px rgba(0,0,0,0.25));
    }
    .img-btn:active { transform: scale(0.96); }

    .start-btn-container {
      position: absolute;
      bottom: 10%;
      left: 50%;
      transform: translateX(-50%);
      width: 250px;
      z-index: 30;
      cursor: pointer;
      transition: opacity 0.5s, transform 0.2s;
      animation: pulse 2s infinite;
    }
    @keyframes pulse {
      0% { transform: translateX(-50%) scale(1); }
      50% { transform: translateX(-50%) scale(1.05); }
      100% { transform: translateX(-50%) scale(1); }
    }
    .start-btn-img { width: 100%; height: auto; display: block; }

    .scene.walking .start-btn-container,
    .scene.arrived .start-btn-container,
    .scene.door-open .start-btn-container,
    .scene.form-ready .start-btn-container {
      opacity: 0;
      pointer-events: none;
    }

    .error-msg {
      color: #ffcccc;
      font-size: 0.95rem;
      text-shadow: 1px 1px 2px #000;
      background: rgba(0, 0, 0, 0.35);
      padding: 8px 12px;
      border-radius: 10px;
      width: var(--ui-item-w);
      text-align: center;
    }
  </style>

  <script>
    window.onload = function () {
      const urlParams = new URLSearchParams(window.location.search);
      if (urlParams.get("msg") === "logout") alert("로그아웃 되었습니다.");

      const startBtn = document.getElementById('startBtn');
      const scene = document.getElementById('scene');
      const zoomWrapper = document.querySelector('.zoom-wrapper');
      const door = document.querySelector('.door');

      const soundFootsteps = new Audio('<%=ctx%>/assets/sounds/footsteps.mp3');
      const soundOpen = new Audio('<%=ctx%>/assets/sounds/open.mp3');
      const soundBgm = new Audio('<%=ctx%>/assets/sounds/bgm.mp3');
      soundBgm.loop = true; soundBgm.volume = 0.3;

      let sequenceStarted = false;

      zoomWrapper.addEventListener('animationend', (e) => {
        if (e.animationName !== 'walk') return;
        const finalTransform = getComputedStyle(zoomWrapper).transform;
        zoomWrapper.style.transform = finalTransform;
        zoomWrapper.style.animation = 'none';

        scene.classList.remove('walking');
        scene.classList.add('arrived');

        soundFootsteps.pause();
        soundFootsteps.currentTime = 0;

        scene.classList.add('door-open');
        soundOpen.play().catch(()=>{});
      }, { once: true });

      door.addEventListener('transitionend', (e) => {
        if (e.propertyName !== 'transform') return;
        scene.classList.add('form-ready');
        soundBgm.play().catch(()=>{});
      }, { once: true });

      startBtn.addEventListener('click', () => {
        if (sequenceStarted) return;
        sequenceStarted = true;
        scene.classList.add('walking');
        soundFootsteps.play().catch(()=>{});
      });
    };
  </script>
</head>

<body>
  <div class="scene" id="scene">
    <div class="zoom-wrapper">
      <div class="cabin-anchor">
        <div class="cabin-container">
          <img class="cabin" src="<%=ctx%>/assets/images/signIn/cabin.png" alt="Cabin" />

          <img class="title-img"
               src="<%=ctx%>/assets/images/signIn/title.png"
               alt="Omok Title"
               onerror="this.style.display='none'" />

          <div class="inside-bg"></div>

          <button type="button" class="door" aria-label="door">
            <span class="door-scaler">
              <img src="<%=ctx%>/assets/images/signIn/door.png" alt="Door" />
            </span>
          </button>

          <div class="login-panel">
            <div class="login-panel-inner">
              <form action="<%=ctx + Constants.SIGNIN%>" method="post">

                <div class="input-group">
                  <img class="input-bg" src="<%=ctx%>/assets/images/signIn/input_id.png" alt="ID Box">
                  <input class="input-field" type="text" name="user_id" required autocomplete="username" />
                </div>

                <div class="input-group">
                  <img class="input-bg" src="<%=ctx%>/assets/images/signIn/input_pw.png" alt="PW Box">
                  <input class="input-field" type="password" name="user_pw" required autocomplete="current-password" />
                </div>

                <%
                  String error = (String) request.getAttribute("errorMessage");
                  if (error != null) {
                %>
                  <div class="error-msg"><%=error%></div>
                <%
                  }
                %>

                <div class="button-container">
                  <button type="submit" class="img-btn">
                    <img src="<%=ctx%>/assets/images/signIn/login_btn.png" alt="Login">
                  </button>

                  <button type="button" class="img-btn"
                          onclick="location.href='<%=ctx + Constants.SIGNUP%>'">
                    <img src="<%=ctx%>/assets/images/signIn/signup_btn.png" alt="Join">
                  </button>
                </div>

              </form>
            </div>
          </div>

        </div>
      </div>
    </div>

    <div class="start-btn-container" id="startBtn">
      <img src="<%=ctx%>/assets/images/signIn/pressToStart.png" class="start-btn-img" alt="Press To Start" />
    </div>
  </div>
</body>
</html>
