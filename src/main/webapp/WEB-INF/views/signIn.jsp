<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="util.Constants" %>
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

      /* 패널 위치 프리셋 A (추천, 균형형) */
      --panel-bottom: 33%;         /* 문 안 중앙~상단 배치 (기존 16% → 33%) */
      --panel-translateY: 43%;     /* Y축 오프셋 조정 (기존 50% → 30%) */
      --panel-width: clamp(200px, 22vw, 260px);
      --panel-gap: 10px;
      --panel-inv-scale: 0.4;

      /* [동적 카메라] 계산 기반 transform 변수 */
      --cam-scale: 2.5;
      --cam-x: 0px;
      --cam-y: 0px;

      /* [문 지오메트리] door/glow 전용 좌표 */
      --door-left: 50%;
      --door-bottom: 13.5%;
      --door-w: 18.5%;
      --door-h: 40%;

      /* [구멍 지오메트리] inside-bg 전용 좌표 (door와 분리) */
      --hole-left: 50%;         /* 구멍 좌측 위치 (door와 독립) */
      --hole-bottom: 13.5%;     /* 구멍 하단 위치 */
      --hole-w: 18.5%;          /* 구멍 너비 */
      --hole-h: 41%;            /* 구멍 높이 */
      --hole-offset-y: -6%;     /* 구멍 Y축 오프셋 (음수=위, 양수=아래) */
    }
    * { box-sizing: border-box; }
    body {
      margin: 0;
      font-family: 'EF_Diary', sans-serif;
      background: #0b0d18;
      overflow: hidden;
    }
    @font-face {
        font-family: 'EF_Diary';
        src: url('https://cdn.jsdelivr.net/gh/projectnoonnu/noonfonts_2210-EF@1.0/EF_Diary.woff2') format('woff2');
        font-weight: normal;
        font-style: normal;
    }


    .scene {
      position: relative;
      width: var(--scene-w);
      height: var(--scene-h);
      background: url("${pageContext.request.contextPath}/assets/images/bg.png") center/cover no-repeat;
      overflow: hidden;
      perspective: 1000px;
    }

    .zoom-wrapper {
        position: relative;
        width: 100%;
        height: 100%;
        transform-origin: center 60%;
    }

    /* [walking] 키프레임 애니메이션으로 접근 */
    .scene.walking .zoom-wrapper {
        animation: walk var(--walk-duration) ease-in-out forwards;
    }

    @keyframes walk {
        0% { transform: scale(1) translateY(0) rotateZ(0deg); }
        20% { transform: scale(1.3) translateY(2%) rotateZ(1deg); }
        40% { transform: scale(1.6) translateY(4%) rotateZ(-1deg); }
        60% { transform: scale(1.9) translateY(6%) rotateZ(1deg); }
        80% { transform: scale(2.2) translateY(8%) rotateZ(-0.5deg); }
        100% { transform: scale(2.5) translateY(9.5%) rotateZ(0deg); }
    }

    /* [arrived 이후] 동적 카메라(CSS 변수 기반) */
    .scene.arrived .zoom-wrapper {
        animation: none;
        transition: none;
        /* transform: translate(var(--cam-x), var(--cam-y)) scale(var(--cam-scale)); */
        /* transition: transform 0.6s ease-out; */
    }

    /* [배치 래퍼] 화면 배치 담당 */
    .cabin-anchor {
        position: absolute;
        left: 50%;
        bottom: 25vh;
        transform: translateX(-50%);
        width: min(60vw, 600px);
        height: auto;
        z-index: 10;
    }

    /* [레이아웃 컨테이너] inside-bg/glow/door/panel의 containing block */
    .cabin-container {
        position: relative;
        width: 100%;
        height: auto;
    }

    .cabin { width: 100%; display: block; height: auto; }

    /* [접근성] door를 button으로 변경 후 스타일 */
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
        cursor: default;
        transition: transform var(--door-duration) ease-in-out;
    }
    .door img { display: block; width: 100%; height: auto; }
    .scene.door-open .door { transform: translateX(-50%) rotateY(-120deg); }

    /* [접근성] door 포커스 스타일 */
    .door:focus-visible {
        outline: 2px solid rgba(220, 179, 92, 0.8);
        outline-offset: 4px;
        box-shadow: 0 0 12px rgba(220, 179, 92, 0.6);
    }

    .glow {
        position: absolute;
        left: var(--door-left);
        bottom: var(--door-bottom);
        width: var(--door-w);
        height: var(--door-h);
        transform: translateX(-50%);
        background: radial-gradient(circle, rgba(255,220,100,0.9) 10%, rgba(255,220,100,0) 80%);
        z-index: 11;
        opacity: 0;
        transition: opacity 0.8s ease;
        border-radius: 5px 5px 0 0;
    }
    .scene.form-ready .glow { opacity: 1; }

    /* 문 안쪽 CSS 오버레이 (이미지 없음) - hole 변수 기반으로 변경 */
    .inside-bg {
        position: absolute;
        left: var(--hole-left);
        bottom: var(--hole-bottom);
        width: var(--hole-w);
        height: var(--hole-h);
        transform: translateX(-50%) translateY(var(--hole-offset-y));
        border-radius: 5px 5px 0 0;
        overflow: hidden;
        z-index: 10; /* inside-bg(10) < glow(11) < door(12) < login-panel(20) */
        opacity: 0;
        transition: opacity 1.2s ease 0.3s;
        pointer-events: none; /* 클릭 차단 방지 */

        /* 어두운 실내 느낌: 비네팅 + 따뜻한 중심광 */
        background:
            radial-gradient(
                ellipse 60% 80% at center 40%,
                rgba(220, 180, 100, 0.35) 0%,    /* 중심: 따뜻한 노란빛 */
                rgba(139, 115, 85, 0.65) 30%,    /* 중간: 목재 톤 */
                rgba(40, 30, 25, 0.92) 70%,      /* 외곽: 어두운 갈색 */
                rgba(20, 15, 12, 0.98) 100%      /* 가장자리: 거의 검정 */
            );

        /* 모던 브라우저: 배경 블러 (선택적) */
        backdrop-filter: blur(3px);
        -webkit-backdrop-filter: blur(3px);
    }
    .scene.door-open .inside-bg { opacity: 1; }
    .scene.form-ready .inside-bg { opacity: 1; }

    /* [디버깅] hole 변수 튜닝용 - .scene에 debug 클래스 추가 시 빨간 테두리 표시 */
    .scene.debug .inside-bg {
        outline: 2px solid red;
        outline-offset: -1px; /* 내부로 테두리 그리기 */
    }

    /* [반응형] 타이틀 폰트 크기 clamp 적용 */
    .omok-title {
        position: absolute;
        top: 25%;
        left: 50%;
        transform: translateX(-50%);
        margin: 0;
        font-size: clamp(2rem, 6vw, 4rem);
        color: #dcb35c;
        text-shadow: 2px 2px 4px rgba(0,0,0,0.8), 0 0 20px rgba(255,220,100,0.6);
        font-family: 'EF_Diary', serif;
        z-index: 15;
        opacity: 0;
        transition: opacity 1.0s ease;
    }
    .scene.form-ready .omok-title { opacity: 1; }

    /* [반응형] 로그인 패널 - 문 안 기준 배치 (door 중앙~상단 정렬) */
    .login-panel {
      position: absolute;
      /* door 위치(left: 50%, bottom: 13.5%) 기준으로 정렬 */
      /* door opening 영역 상단 쪽에 폼 배치 */
      left: 50%;
      bottom: var(--panel-bottom); /* CSS 변수로 조절 가능 */
      transform: translateX(-50%) translateY(var(--panel-translateY)); /* Y축 오프셋도 변수화 */
      width: var(--panel-width);
      padding: 0;
      background: transparent;
      border: none;
      box-shadow: none;
      z-index: 20;
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
      display: flex;
      flex-direction: column;
      gap: var(--panel-gap);
    }
    .scene.form-ready .login-panel-inner {
      transform: scale(1);
      opacity: 1;
    }

    .login-panel h2 { display: none; }

    /* ID/PW 박스 크기 통일 - 고정 규격 적용 */
    .input-group {
        position: relative;
        width: 100%;
        /* 고정된 aspect-ratio로 외형 크기 통일 */
        aspect-ratio: 966 / 401;
        height: auto;
        min-height: 60px; /* 최소 높이 보장 */
    }

    /* 배경 이미지를 박스 크기에 맞춤 (이미지 비율 무관하게 동일 크기 표현) */
    .input-bg {
        position: absolute;
        inset: 0;
        width: 100%;
        height: 100%;
        /* contain으로 변경하여 이미지가 박스 안에 완전히 들어가도록 */
        /* 또는 fill로 박스를 완전히 채우도록 (비율 무시) */
        object-fit: fill;
        pointer-events: none;
    }

    .input-slot {
        position: absolute;
        left: 18%;
        right: 18%;
        top: 22%;
        bottom: 22%;
        display: flex;
        align-items: center;
        border-radius: 8px;
    }

    .input-field {
        width: 100%;
        height: 100%;
        border: 0;
        outline: 0;
        background: transparent;
        padding: 0 0 0 52px;
        font-family: system-ui, -apple-system, 'Segoe UI', sans-serif;
        font-size: 16px;
        text-align: left;
        color: #2b2b2b;
        caret-color: #8b7355;
    }

    .input-field::placeholder {
        opacity: 0;
    }

    .input-group:focus-within .input-slot {
        box-shadow: 0 0 0 2px rgba(220, 179, 92, 0.35);
    }

    /* Login/Join 버튼 컨테이너 - 문 안쪽 공간에 맞춤 */
    .button-container {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 12px; /* 간격을 약간 증가시켜 균형감 개선 */
        margin-top: 10px; /* 상단 여백 약간 증가 */
        padding-bottom: 8px;
        justify-items: center;
        align-items: center;
    }
    .img-btn {
        width: 100%;
        max-width: 100%; /* 최대 너비 제한 */
        border: none;
        background-color: transparent;
        background-size: contain;
        background-repeat: no-repeat;
        background-position: center;
        cursor: pointer;
        transition: transform 0.1s;
    }
    .img-btn:active { transform: scale(0.95); }

    /* 버튼 크기 통일 및 최적화 */
    #login-btn {
        height: clamp(56px, 9vw, 82px);
        aspect-ratio: 1 / 1; /* 정사각형 비율 유지 */
    }

    #register-btn {
        height: clamp(56px, 9vw, 82px);
        aspect-ratio: 1 / 1; /* 정사각형 비율 유지 */
    }

    #login-btn { background-image: url('${pageContext.request.contextPath}/assets/images/btn_login.png'); }
    #register-btn { background-image: url('${pageContext.request.contextPath}/assets/images/btn_join.png'); }

    /* [접근성] 시작 버튼 포커스 스타일 */
    .start-btn {
        position: absolute;
        bottom: 10%;
        left: 50%;
        transform: translateX(-50%);
        padding: 12px 35px;
        font-size: 1.2rem;
        font-family: 'EF_Diary', sans-serif;
        color: #fff;
        background: #8b0000;
        border: 3px solid #dcb35c;
        border-radius: 30px;
        cursor: pointer;
        z-index: 30;
        box-shadow: 0 0 20px rgba(220, 179, 92, 0.6);
        transition: opacity 0.5s;
    }
    .start-btn:hover { background: #a00000; }
    .scene.walking .start-btn,
    .scene.arrived .start-btn,
    .scene.door-open .start-btn,
    .scene.form-ready .start-btn { opacity: 0; pointer-events: none; }

    /* [접근성] 시작 버튼 포커스 스타일 */
    .start-btn:focus-visible {
        outline: 3px solid rgba(220, 179, 92, 0.9);
        outline-offset: 4px;
        box-shadow: 0 0 30px rgba(220, 179, 92, 0.8);
    }

    .error-msg {
        color: #ffcccc;
        text-align: center;
        font-size: 0.8rem;
        text-shadow: 1px 1px 2px #000;
        margin-bottom: 5px;
    }

    /* [에러 핸들링] 오디오 토스트 스타일 */
    .audio-toast {
        position: fixed;
        bottom: 30px;
        left: 50%;
        transform: translateX(-50%);
        background: rgba(30, 30, 40, 0.95);
        color: #dcb35c;
        padding: 12px 24px;
        border-radius: 8px;
        border: 1px solid rgba(220, 179, 92, 0.4);
        font-size: 0.9rem;
        font-family: 'EF_Diary', sans-serif;
        z-index: 1000;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.5);
        opacity: 0;
        pointer-events: none;
        transition: opacity 0.3s ease;
    }
    .audio-toast.show {
        opacity: 1;
    }

    /* [반응형] 작은 화면 대응 */
    @media (max-width: 480px) {
        .login-panel-inner {
            gap: 8px;
        }
        .button-container {
            gap: 10px; /* 작은 화면에서도 적절한 간격 유지 */
            margin-top: 8px;
        }
        .start-btn {
            padding: 10px 28px;
            font-size: 1rem;
        }
    }
  </style>
  <script>
    /* [디버그] 카메라 계산 로그 활성화 플래그 */
    const DEBUG_CAMERA = false; // true로 설정하면 콘솔에 카메라 계산 정보 출력

    /* [프리로드] 이미지 프리로드 함수 */
    function preloadImages() {
      const contextPath = '${pageContext.request.contextPath}';
      const images = [
        '/assets/images/bg.png',
        '/assets/images/cabin.png',
        '/assets/images/door.png',
        '/assets/images/btn_login.png',
        '/assets/images/btn_join.png',
        '/assets/images/id_box.png',
        '/assets/images/pw_box.png'
      ];

      images.forEach(src => {
        const img = new Image();
        img.src = contextPath + src;
      });
    }

    /* [프리로드] 오디오 프리로드 함수 */
    function preloadAudio(audio) {
      return new Promise((resolve) => {
        audio.load();
        audio.addEventListener('canplaythrough', () => resolve(), { once: true });
        setTimeout(() => resolve(), 3000); // 타임아웃 방지
      });
    }

    /* [에러 핸들링] 토스트 메시지 표시 함수 */
    function showToast(message, duration = 2000) {
      const toast = document.getElementById('audioToast');
      if (toast) {
        toast.textContent = message;
        toast.classList.add('show');
        setTimeout(() => {
          toast.classList.remove('show');
        }, duration);
      }
    }

    /* [에러 핸들링] 사운드 재생 유틸 함수 */
    function playSound(audio, options = {}) {
      const { onSuccess, onFail } = options;

      audio.play()
        .then(() => {
          if (onSuccess) onSuccess();
        })
        .catch((error) => {
          console.warn('오디오 재생 실패:', error);
          showToast('브라우저 설정으로 소리가 차단될 수 있어요');
          if (onFail) onFail(error);
        });
    }

    window.onload = function () {
      /* [프리로드] 이미지 및 오디오 프리로드 */
      preloadImages();

      const urlParams = new URLSearchParams(window.location.search);
      const msg = urlParams.get("msg");
      if (msg) history.replaceState({}, null, location.pathname);
      if (msg === "logout") alert("로그아웃 되었습니다.");

      const startBtn = document.getElementById('startBtn');
      const scene = document.getElementById('scene');
      const zoomWrapper = document.querySelector('.zoom-wrapper');
      const door = document.querySelector('.door');

      const soundFootsteps = new Audio('${pageContext.request.contextPath}/assets/sounds/footsteps.mp3');
      const soundOpen = new Audio('${pageContext.request.contextPath}/assets/sounds/open.mp3');
      const soundBgm = new Audio('${pageContext.request.contextPath}/assets/sounds/bgm.mp3');
      soundBgm.loop = true;
      soundBgm.volume = 0.3;

      /* [프리로드] 오디오 로드 (재생은 클릭 후) */
      Promise.all([
        preloadAudio(soundFootsteps),
        preloadAudio(soundOpen),
        preloadAudio(soundBgm)
      ]).then(() => {
        console.log('모든 오디오 프리로드 완료');
      });

      /* [중복 방지] 시퀀스 시작 플래그
       * 공부 포인트: started 가드는 사용자가 START 버튼을 연타해도
       * 시퀀스가 여러 번 시작되지 않도록 막습니다. 한 번 true가 되면
       * 이후 클릭은 무시됩니다.
       */
      let sequenceStarted = false;

      /* [이벤트 기반 시퀀스] 줌 애니메이션 종료 → arrived
       * 공부 포인트: setTimeout 대신 animationend 이벤트를 사용하는 이유는
       * 애니메이션 실제 종료 시점을 정확히 감지하기 위함입니다.
       * CSS --walk-duration이 변경되어도 JS 수정 없이 자동 대응됩니다.
       *
       * animationName 필터링: walk 외 다른 애니메이션 종료도 감지될 수 있으므로
       * e.animationName을 체크하여 정확히 walk 애니메이션 종료만 처리합니다.
       *
       * { once: true }: 이벤트 리스너를 한 번만 실행하고 자동 제거합니다.
       * 이를 통해 메모리 누수를 방지하고 중복 실행을 막습니다.
       */
      zoomWrapper.addEventListener('animationend', function handleWalkEnd(e) {
        if (e.animationName !== 'walk') return;

        // ✅ [FIX 1] 클래스 변경 전에 walk 최종 프레임 transform을 즉시 캡처
        const finalTransform = getComputedStyle(zoomWrapper).transform;

        // ✅ [FIX 2] inline style로 즉시 고정 (CSS 클래스 변경보다 먼저)
        zoomWrapper.style.transform = finalTransform;
        zoomWrapper.style.animation = 'none';
        zoomWrapper.style.transition = 'none';

        // ✅ [FIX 3] 클래스 상태 변경 (이제 transform이 이미 고정되어 영향 없음)
        scene.classList.remove('walking');
        scene.classList.add('arrived');

        // footsteps 정지
        soundFootsteps.pause();
        soundFootsteps.currentTime = 0;

        // 문 열림 시작
        scene.classList.add('door-open');
        playSound(soundOpen);

      }, { once: true });

      /* [이벤트 기반 시퀀스] 문 열림 종료 → form-ready
       * 공부 포인트: transitionend 이벤트로 CSS transition 종료를 정확히 감지합니다.
       *
       * propertyName 필터링: 여러 속성이 transition될 수 있으므로 (opacity, transform 등)
       * e.propertyName === 'transform'으로 문 열림 transition만 감지합니다.
       */
      door.addEventListener('transitionend', function handleDoorOpen(e) {
        if (e.propertyName !== 'transform') return;

        // form-ready 상태로 전환
        scene.classList.add('form-ready');

        // BGM 시작
        playSound(soundBgm);
      }, { once: true });

      /* [START 버튼] 시퀀스 시작 */
      startBtn.addEventListener('click', () => {
        // 중복 클릭 방지
        if (sequenceStarted) return;
        sequenceStarted = true;

        // walking 상태로 전환
        scene.classList.add('walking');

        // footsteps 재생
        playSound(soundFootsteps);
      });

      // arrived 이후에는 walk 최종 프레임을 고정 유지한다.
      // (여기서 transform을 건드리면 다시 튐/원상복귀 느낌이 생김)
      window.addEventListener('resize', () => {
        // arrived 상태면 아무것도 하지 않음
        // (문을 중앙에 유지하려면 별도 설계 필요)
      });
    };
  </script>
</head>
<body>
  <div class="scene" id="scene">
    <div class="zoom-wrapper">
        <div class="cabin-anchor">
          <div class="cabin-container">
            <img class="cabin" src="${pageContext.request.contextPath}/assets/images/cabin.png" alt="오두막" />

            <h1 class="omok-title">Omok</h1>

            <!-- [접근성] 장식 요소 aria-hidden 추가 -->
            <div class="glow" aria-hidden="true"></div>

            <!-- 문 안쪽 실내 배경 -->
            <div class="inside-bg" aria-hidden="true"></div>

            <!-- [접근성] door를 button으로 변경 -->
            <button type="button" class="door" aria-label="문 열기">
                <img src="${pageContext.request.contextPath}/assets/images/door.png" alt="" />
            </button>

            <div class="login-panel">
              <div class="login-panel-inner">
                <form action="${pageContext.request.contextPath}<%= Constants.SIGNIN %>" method="post">
                  <div class="input-group id-group">
                    <img class="input-bg" src="${pageContext.request.contextPath}/assets/images/id_box.png" alt="" aria-hidden="true">
                    <div class="input-slot">
                      <input class="input-field" type="text" name="user_id" placeholder="" required aria-label="아이디" autocomplete="username" />
                    </div>
                  </div>
                  <div class="input-group pw-group">
                    <img class="input-bg" src="${pageContext.request.contextPath}/assets/images/pw_box.png" alt="" aria-hidden="true">
                    <div class="input-slot">
                      <input class="input-field" type="password" name="user_pw" placeholder="" required aria-label="비밀번호" autocomplete="current-password" />
                    </div>
                  </div>

                  <% String error = (String) request.getAttribute("errorMessage");
                     if(error != null) { %>
                    <div class="error-msg"><%=error%></div>
                  <%} %>

                  <div class="button-container">
                    <button type="submit" id="login-btn" class="img-btn" title="입장하기"></button>
                    <button type="button" id="register-btn" class="img-btn" title="회원가입" onclick="location.href='<%=request.getContextPath() + Constants.SIGNUP %>'"></button>
                  </div>
                </form>
              </div>
            </div>
          </div>
        </div>
    </div>

    <!-- [접근성] 시작 버튼 aria-label 추가 -->
    <button class="start-btn" id="startBtn" aria-label="시작하기">PRESS TO START</button>
  </div>

  <!-- [에러 핸들링] 오디오 토스트 메시지 -->
  <div id="audioToast" class="audio-toast">브라우저 설정으로 소리가 차단될 수 있어요</div>
</body>
</html>
