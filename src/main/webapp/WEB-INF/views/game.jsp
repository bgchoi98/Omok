<%@ page language="java" contentType="text/html; charset=UTF-8"
   pageEncoding="UTF-8"%>
<%@ page import="user.User"%>
<%@ page import="util.Constants"%>
<%
User user = (User) session.getAttribute(Constants.SESSION_KEY);
if (user == null) {
   response.sendRedirect(request.getContextPath() + Constants.SIGNIN);
   return;
}

final String CTX = request.getContextPath();

String nickName = "Guest";
int win = 0;
int lose = 0;
try {
   nickName = user.getNickname();
   // win = user.getWin();
   // lose = user.getLose();
} catch (Exception ignore) {
}
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8" />
<title>Omok Game Room</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0" />

<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Patrick+Hand&display=swap" rel="stylesheet">

<style>
/* ===== Global Setting ===== */
* {
   box-sizing: border-box;
}

body {
   margin: 0;
   width: 100vw;
   height: 100vh;
   overflow: hidden;
   font-family: 'Patrick Hand', 'Arial', sans-serif;
   user-select: none;
   background: url('<%=CTX%>/assets/images/game/game_bg.png') no-repeat
      center/cover;
}

/* ===== Main Layout (Grid) ===== */
.layout {
   display: grid;
    /* 오른쪽 컬럼 너비 고정 */
   grid-template-columns: 1fr 520px;
   height: 100%;
   padding: 20px;
   gap: 20px;
}

/* ===== Left: Board Area ===== */
.left-col {
   display: flex;
   justify-content: center;
   align-items: center;
   position: relative;
}

/* [1] 보드 전체 래퍼 (board.png 비율 1024:1024) */
.board-frame-wrap {
   position: relative;
   height: min(90vh, 90vw);
   aspect-ratio: 1024/1024;
   filter: drop-shadow(0 15px 35px rgba(0, 0, 0, 0.5));
}

/* board.png (프레임 이미지) */
.board-frame-img {
   width: 100%;
   height: 100%;
   object-fit: fill;
   pointer-events: none;
   z-index: 1;
}

/* [2] 투명 클릭 영역 (board-hit) */
.board-hit {
   position: absolute;
   top: 50%;
   left: 50%;
   transform: translate(-50%, -50%);
   width: 84.57%;
   height: 84.57%;
   z-index: 10;
   cursor: pointer;
}

/* [3] FX Canvas (승리 효과용) */
#fxCanvas {
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    width: 84.57%;
    height: 84.57%;
    z-index: 20; /* 돌보다 위에 */
    pointer-events: none; /* 클릭 통과 */
}

/* 돌 스타일 */
.stone, .ghost-stone {
   position: absolute;
   transform: translate(-50%, -50%);
   pointer-events: none;
   filter: drop-shadow(3px 4px 4px rgba(0, 0, 0, 0.4));
   will-change: transform;
}

.ghost-stone {
   opacity: 0.6;
   display: none;
   z-index: 11;
}

/* ===== Right Panel (Control) ===== */
.right-col {
   display: flex;
   flex-direction: column;
   height: 100%;
    /* 위쪽부터 정렬 (나가기 버튼 제거됨) */
   justify-content: flex-start;
    align-items: center; 
    padding-top: 10px; /* 상단 여백 살짝 줄임 */
    transform: translateX(-30px); 
}

/* 나가기 버튼 영역 삭제됨 (.right-top) */

.chat-panel {
    width: 100%;
    /* [수정] 나가기 버튼 공간만큼 높이 확장 (600px -> 680px) */
    height: 680px; 
   position: relative;
   background: url('<%=CTX%>/assets/images/game/chatBox.png') no-repeat center center;
    background-size: 100% 100%; 
   filter: drop-shadow(0 8px 16px rgba(0, 0, 0, 0.2));
    margin-bottom: 20px; 
}

.chat-scroll {
   position: absolute;
    /* [수정] 높이가 늘어난 만큼 top 위치 조정 */
   top: 13%; 
   bottom: 22%;
   left: 12%;
   right: 12%;
   overflow-y: auto;
   padding-right: 5px;
   font-size: 16px;
   font-weight: bold;
   color: #3e2723;
   line-height: 1.6;
}

.chat-scroll::-webkit-scrollbar {
   width: 6px;
}

.chat-scroll::-webkit-scrollbar-thumb {
   background: rgba(62, 39, 35, 0.5);
   border-radius: 10px;
}

.chat-input-area {
   position: absolute;
   bottom: 9%; 
   left: 12%;
   right: 12%;
   display: flex;
   gap: 5px;
}

.chat-input {
   flex: 1;
   padding: 6px 10px;
   border: 2px solid #8d6e63;
   border-radius: 4px;
   font-size: 14px;
    font-family: 'Patrick Hand', 'Arial', sans-serif;
   background: rgba(255, 255, 255, 0.8);
}

.chat-send-btn {
   padding: 6px 15px;
   background: #5d4037;
   color: white;
   border: none;
   border-radius: 4px;
   font-weight: bold;
    font-family: 'Patrick Hand', 'Arial', sans-serif;
   cursor: pointer;
}

.chat-send-btn:hover {
   background: #3e2723;
}

.right-bottom {
   display: flex;
   flex-direction: row; 
   gap: 15px;
    width: 100%; 
    align-items: center; 
}

.players-container {
   display: flex;
    flex: 1; 
   justify-content: space-between; 
   gap: 15px;
}

/* ✅ Player Box */
.player-box {
   position: relative;
    width: 48%; 
   height: 130px; 
   padding: 0;
   
   background-repeat: no-repeat;
   background-position: center;
   background-size: contain; 

   color: #3e2723;
   filter: grayscale(1) contrast(0.9);
   transition: filter 0.3s ease, transform 0.2s ease;
   
   text-shadow: 1px 1px 2px rgba(255, 255, 255, 0.9), 0 0 5px rgba(255, 255, 255, 0.8);
}

/* Player 1 Box (왼쪽) */
#p1Box {
    background-image: url('<%=CTX%>/assets/images/game/player1.png');
}

/* Player 2 Box (오른쪽) */
#p2Box {
    background-image: url('<%=CTX%>/assets/images/game/player2.png');
}

.player-box.turn-active {
   filter: grayscale(0) contrast(1.1);
   transform: scale(1.05);
   z-index: 10;
   filter: drop-shadow(0 0 10px rgba(255, 215, 0, 0.6));
}

.player-name {
   position: absolute;
   left: 0; right: 0;
   bottom: 25px;
   text-align: center;
   font-size: 18px;
   font-weight: 900;
   white-space: nowrap;
   overflow: hidden;
   text-overflow: ellipsis;
    background: transparent;
    padding: 2px 0;
    border-radius: 4px;
}

.player-score {
   position: absolute;
   left: 0; right: 0;
   bottom: 5px;
   text-align: center;
   font-size: 14px;
   font-weight: 700;
    background: transparent;
    border-radius: 4px;
}

.config-area {
   display: flex;
   justify-content: center;
   align-items: center;
}

.config-btn {
   width: 65px; 
   cursor: pointer;
   transition: transform 0.3s;
   filter: drop-shadow(0 4px 6px rgba(0, 0, 0, 0.3));
}

.config-btn:hover {
   transform: rotate(30deg) scale(1.1);
}

/* ===== Popup ===== */
.dim-layer {
    position: fixed; inset: 0; background: rgba(0, 0, 0, 0.6); display: none; z-index: 100;
}

.config-popup {
    position: fixed; 
    top: 50%; left: 50%; 
    transform: translate(-50%, -50%);
    width: 400px; 
    height: auto; 
    display: none; 
    flex-direction: column; 
    align-items: center; 
    justify-content: center;
    z-index: 101; 
    filter: drop-shadow(0 10px 20px rgba(0, 0, 0, 0.5));
}

.config-box-frame {
    position: relative;
    width: 400px;
    height: 320px;
    background: url('<%=CTX%>/assets/images/main/ConfigPopUp/configureBox.png') no-repeat center/contain;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
}

.close-popup-btn {
    position: absolute; 
    top: 15px; right: 60px; 
    width: 30px; height: 30px;
    background: #8d6e63; border: 2px solid #5d4037; color: white;
    font-weight: bold; cursor: pointer; border-radius: 4px;
    z-index: 10;
}

.popup-content {
    margin-top: 20px; text-align: center; width: 100%; display: flex; flex-direction: column; align-items: center;
}

.surrender-btn {
    padding: 10px 20px; background: #5d4037; color: white; border: none;
    border-radius: 8px; font-weight: bold; font-size: 16px; cursor: pointer; transition: 0.2s;
    font-family: 'Patrick Hand', 'Arial', sans-serif;
}
.surrender-btn:hover { background: #3e2723; transform: scale(1.05); }

/* Volume UI */
.volume-image-wrapper {
    position: relative; 
    width: 320px; height: 60px;
    background-image: url('<%=CTX%>/assets/images/main/ConfigPopUp/volumeBar.png');
    background-size: 100% 100%; background-position: center; background-repeat: no-repeat;
    display: flex; justify-content: center; align-items: center; 
    margin-top: 15px; 
}

.volume-track-area {
    position: absolute; width: 200px; height: 100%; top: 0; left: 50%; transform: translateX(-50%); cursor: pointer;
}
.volume-knob {
    position: absolute; top: 50%; left: 50%; transform: translate(-50%, -40%);
    width: 30px; height: 40px;
    background-image: url('<%=CTX%>/assets/images/main/ConfigPopUp/volumeBtn.png');
    background-size: contain; background-repeat: no-repeat;
    cursor: pointer; z-index: 5; pointer-events: none;
}

/* 승리 돌 펄스 애니메이션 */
@keyframes win-pulse {
    0%, 100% { transform: translate(-50%, -50%) scale(1); filter: drop-shadow(3px 4px 4px rgba(0,0,0,0.4)); }
    25% { transform: translate(-50%, -50%) scale(1.3); filter: drop-shadow(0 0 15px rgba(255,215,0,0.9)) drop-shadow(0 0 25px rgba(255,215,0,0.6)); }
    50% { transform: translate(-50%, -50%) scale(1); filter: drop-shadow(3px 4px 4px rgba(0,0,0,0.4)); }
}

.stone.win-pulse {
    animation: win-pulse 0.6s ease-in-out 2; /* 2회 반복 */
    z-index: 15; /* 다른 돌보다 위에 */
}

@media (max-width: 1000px) {
    .layout { grid-template-columns: 1fr; grid-template-rows: auto 1fr; overflow-y: auto; }
    body { overflow: auto; }
    .left-col { margin-bottom: 20px; }
    .right-col { height: auto; }
}
</style>
</head>

<body>
    <div class="game-bg"></div>
    
    <audio id="bgmAudio" loop preload="auto">
        <source src="<%=CTX%>/assets/sounds/game_bgm.mp3" type="audio/mp3">
    </audio>

    <div id="gameOverDim" class="dim-layer"></div>
    
    <div id="gameOverPopup" class="config-popup" style="display:none;">
      <div class="config-box-frame">
          <div class="popup-content">
            <h2 id="gameOverTitle" style="color:#3e2723; margin-bottom:15px;"></h2>
            <p id="gameOverMessage" style="font-size:16px; margin-bottom:25px;"></p>
            <button id="gameOverBtn" class="surrender-btn">로비로</button>
          </div>
      </div>
    </div>
    
    <div class="layout">
        <div class="left-col">
            <div class="board-frame-wrap" id="boardFrame">
                <img src="<%=CTX%>/assets/images/game/board.png" class="board-frame-img" alt="Frame" />
                <div id="boardHit" class="board-hit">
                    <canvas id="fxCanvas"></canvas>
                    <img id="ghostStone" class="ghost-stone" src="<%=CTX%>/assets/images/game/stone_1.png" alt="" />
                </div>
            </div>
        </div>

        <div class="right-col">
            <div class="chat-panel">
                <div class="chat-scroll" id="chatScroll">
                    </div>
                <div class="chat-input-area">
                    <input type="text" id="chatInput" class="chat-input" placeholder="메시지 입력..." maxlength="100" />
                    <button id="chatSendBtn" class="chat-send-btn">전송</button>
                </div>
            </div>

            <div class="right-bottom">
                <div class="players-container">
                    <div class="player-box turn-active" id="p1Box">
                        <div class="player-name"><%=nickName%></div>
                        
                    </div>
                    <div class="player-box" id="p2Box">
                        <div class="player-name">Waiting...</div>
                        
                    </div>
                </div>

                <div class="config-area">
                    <img id="configBtn" class="config-btn" src="<%=CTX%>/assets/images/game/configureIcon.png" alt="Config" />
                </div>
            </div>
        </div>
    </div>

    <div id="dimLayer" class="dim-layer"></div>
    <div id="configPopup" class="config-popup">
        <div class="config-box-frame">
            <button id="closePopupBtn" class="close-popup-btn">X</button>
            <div class="popup-content">
                <h2 style="color: #3e2723; margin-bottom: 20px;">Game Settings</h2>
                <button id="surrenderBtn" class="surrender-btn">기권 / 나가기</button>
            </div>
        </div>
        <div class="volume-image-wrapper">
            <div id="volumeTrack" class="volume-track-area">
                <div id="volumeKnob" class="volume-knob"></div>
            </div>
        </div>
    </div>

    <script src="<%= request.getContextPath() %>/assets/js/game/game-chat.js?v=1"></script>

    <script>
    const CTX = "<%=CTX%>";
    const IMG = {
      black: CTX + "/assets/images/game/stone_1.png",
      white: CTX + "/assets/images/game/stone_2.png",
    };
    
    // 착수음
    const stoneAudio = new Audio(CTX + "/assets/sounds/stone_tap.mp3");
    
    const ROLE_COLOR = {
      BLACK:    "#0B6623", 
      WHITE:    "#0B6623", 
      OBSERVER: "#0B6623", 
      SYSTEM:   "#D32F2F", 
    };

    const BOARD_SIZE = 15;
    const LINES = 14;

    let turn = 1; 
    let gameActive = true;
    let boardState = Array.from({ length: BOARD_SIZE }, () => Array(BOARD_SIZE).fill(0));

    let isPlayer = false;
    let isObserver = false;
    let myStone = 0; 
    let blackPlayerName = "";
    let whitePlayerName = "";
    let myNickname = "<%=nickName%>";
    let inputLocked = false;
    let gameEnded = false;
    
    let currentVolume = 0.5;
    let isDraggingVolume = false;
    
    let announcedJoins = new Set();
    let lastAnnouncedTurn = 0;
    let lastMove = null; // 마지막 착수 정보

    // [추가됨] FX 관련 변수
    const fxCanvas = document.getElementById("fxCanvas");
    const fctx = fxCanvas.getContext("2d");
    let fxPlaying = false; // 눈 루프 동작 여부
    let fxStartTime = 0;
    const flakes = [];
    const sparks = []; // 승리라인 스파크 파티클
    const burstFlakes = []; // 라인 완성 시 눈송이 버스트
    const lineTrail = []; // 라인 헤드 트레일
    const MAX_PARTICLES = 120; // 파티클 최대치

    const boardHit   = document.getElementById("boardHit");
    const ghostEl    = document.getElementById("ghostStone");
    const p1Box      = document.getElementById("p1Box");
    const p2Box      = document.getElementById("p2Box");

    let cellW = 0;
    let cellH = 0;

    function resizeFxCanvas() {
      const width = boardHit.clientWidth;
      const height = boardHit.clientHeight;
      const dpr = window.devicePixelRatio || 1;

      fxCanvas.width = width * dpr;
      fxCanvas.height = height * dpr;
      fxCanvas.style.width = width + "px";
      fxCanvas.style.height = height + "px";

      fctx.setTransform(dpr, 0, 0, dpr, 0, 0);
    }

    function recalcMetrics() {
      const width = boardHit.clientWidth;
      const height = boardHit.clientHeight;

      resizeFxCanvas();

      cellW = width / LINES;
      cellH = height / LINES;
      const stoneSize = Math.min(cellW, cellH) * 0.95; 
      ghostEl.style.width = stoneSize + "px";
      ghostEl.style.height = stoneSize + "px";
    }

    function getGridPos(e) {
      const rect = boardHit.getBoundingClientRect();
      const x = e.clientX - rect.left;
      const y = e.clientY - rect.top;
      const col = Math.round(x / cellW);
      const row = Math.round(y / cellH);
      if (col < 0 || col >= BOARD_SIZE || row < 0 || row >= BOARD_SIZE) return null;
      return { row, col };
    }

    function placeStone(row, col, player) {
      const stone = document.createElement("img");
      stone.src = (player === 1) ? IMG.black : IMG.white;
      stone.className = "stone";
      stone.dataset.r = row;  // ← 메타데이터 추가
      stone.dataset.c = col;  // ← 메타데이터 추가
      const stoneSize = Math.min(cellW, cellH) * 0.95;
      stone.style.width = stoneSize + "px";
      stone.style.height = stoneSize + "px";
      stone.style.left = (col * cellW) + "px";
      stone.style.top  = (row * cellH) + "px";
      const deg = Math.random() * 40 - 20;
      stone.style.transform = `translate(-50%, -50%) rotate(${deg}deg)`;
      boardHit.appendChild(stone);
      
      stoneAudio.currentTime = 0;
      stoneAudio.volume = currentVolume;
      stoneAudio.play().catch(e => {});
    }

    function canShowGhost() {
      // 관전자면 무조건 false
      if (isObserver) return false;
      // 플레이어가 아니면 false
      if (!isPlayer) return false;
      // 내 돌이 없으면 false (안전장치)
      if (myStone === 0) return false;
      // 내 역할과 현재 턴이 같을 때만 true
      return myStone === turn;
    }

    function onMouseMove(e) {
      if (!gameActive) return;
      // 고스트를 보여줄 수 있는지 체크
      if (!canShowGhost()) {
        ghostEl.style.display = "none";
        return;
      }
      const pos = getGridPos(e);
      if (!pos || boardState[pos.row][pos.col] !== 0) {
        ghostEl.style.display = "none";
        return;
      }
      ghostEl.style.display = "block";
      ghostEl.src = (turn === 1) ? IMG.black : IMG.white;
      ghostEl.style.left = (pos.col * cellW) + "px";
      ghostEl.style.top  = (pos.row * cellH) + "px";
    }

    // ================= [FX] 눈송이 및 승리 효과 로직 =================
    function spawnSnow(px, py, n = 5) {
        for (let i = 0; i < n; i++) {
            flakes.push({
                x: px + (Math.random() - 0.5) * 50,
                y: py + (Math.random() - 0.5) * 50,
                vx: (Math.random() - 0.5) * 1,
                vy: 1.6 + Math.random() * 2.0, // 1.6~3.6
                r: Math.random() * Math.PI * 2,
                vr: (Math.random() - 0.5) * 0.1,
                s: 4 + Math.random() * 5, // 4~9
                a: 0.65 + Math.random() * 0.35, // 0.65~1.0
                life: 140 + Math.random() * 80 // 140~220
            });
        }
        // 상한 유지
        while (flakes.length > 160) {
            flakes.shift();
        }
    }

    // 라인 완성 시 눈송이 버스트 (방사형)
    function spawnBurst(px, py, count = 50) {
        for (let i = 0; i < count; i++) {
            const angle = (Math.PI * 2 / count) * i + (Math.random() - 0.5) * 0.3;
            const speed = 3 + Math.random() * 5;
            burstFlakes.push({
                x: px,
                y: py,
                vx: Math.cos(angle) * speed,
                vy: Math.sin(angle) * speed - 2, // 위로도 약간 퍼짐
                gravity: 0.15,
                r: Math.random() * Math.PI * 2,
                vr: (Math.random() - 0.5) * 0.15,
                s: 4 + Math.random() * 5,
                a: 0.7 + Math.random() * 0.3,
                life: 60 + Math.random() * 60
            });
        }
    }

    // 줄 그어질 때 헤드 미니 버스트
    function spawnHeadBurst(px, py) {
        const count = 8 + Math.floor(Math.random() * 7); // 8~14개
        for (let i = 0; i < count; i++) {
            const angle = Math.random() * Math.PI * 2;
            const speed = 2 + Math.random() * 3; // 2~5
            burstFlakes.push({
                x: px,
                y: py,
                vx: Math.cos(angle) * speed,
                vy: Math.sin(angle) * speed,
                gravity: 0.12,
                r: Math.random() * Math.PI * 2,
                vr: (Math.random() - 0.5) * 0.15,
                s: 3 + Math.random() * 3,
                a: 0.6 + Math.random() * 0.4,
                life: 30 + Math.random() * 25 // 30~55
            });
        }
    }

    function updateBurstFlakes() {
        for (let i = burstFlakes.length - 1; i >= 0; i--) {
            const f = burstFlakes[i];
            f.x += f.vx;
            f.y += f.vy;
            f.vy += f.gravity;
            f.vx *= 0.98; // 공기 저항
            f.r += f.vr;
            f.life--;
            if (f.life < 30) f.a *= 0.95;
            if (f.life <= 0 || burstFlakes.length > MAX_PARTICLES) {
                burstFlakes.splice(i, 1);
            }
        }
    }

    function updateSnow() {
        const fxH = boardHit.clientHeight;
        for (let i = flakes.length - 1; i >= 0; i--) {
            const f = flakes[i];
            f.x += f.vx;
            f.y += f.vy;
            f.r += f.vr;
            f.life--;
            if (f.life < 20) f.a *= 0.9;
            // 보드 밖으로 나가거나 life 끝나면 제거
            if (f.life <= 0 || f.y > fxH + 30) {
                flakes.splice(i, 1);
            }
        }
    }

    // ================= [승리라인 스파크 파티클] =================
    function spawnSparks(x, y, count) {
        if (sparks.length >= MAX_PARTICLES) return; // 최대치 제한
        for (let i = 0; i < count; i++) {
            const angle = Math.random() * Math.PI * 2;
            const speed = 2 + Math.random() * 4;
            sparks.push({
                x: x,
                y: y,
                vx: Math.cos(angle) * speed,
                vy: Math.sin(angle) * speed,
                life: 20 + Math.random() * 15, // 20~35 프레임
                maxLife: 35,
                size: 2 + Math.random() * 3,
                alpha: 0.8 + Math.random() * 0.2
            });
        }
    }

    function updateSparks() {
        for (let i = sparks.length - 1; i >= 0; i--) {
            const s = sparks[i];
            s.x += s.vx;
            s.y += s.vy;
            s.vx *= 0.9; // 감속
            s.vy *= 0.9;
            s.life--;
            s.alpha = (s.life / s.maxLife) * 0.8;
            if (s.life <= 0) sparks.splice(i, 1);
        }
    }

    function drawSparks(ctx) {
        ctx.save();
        ctx.globalCompositeOperation = "lighter"; // 밝은 합성
        for (const s of sparks) {
            ctx.globalAlpha = s.alpha;
            ctx.fillStyle = "#FFD700"; // 황금색
            ctx.shadowBlur = 6;
            ctx.shadowColor = "rgba(255, 215, 0, 0.8)";
            ctx.beginPath();
            ctx.arc(s.x, s.y, s.size, 0, Math.PI * 2);
            ctx.fill();
        }
        ctx.restore();
    }

    function drawFlake(ctx, x, y, size, rot, alpha) {
        ctx.save();
        ctx.translate(x, y);
        ctx.rotate(rot);
        ctx.globalAlpha = alpha;
        ctx.globalCompositeOperation = "lighter"; // [추가] 밝은 합성
        ctx.shadowBlur = 8; // [추가] Glow 효과
        ctx.shadowColor = "rgba(255,255,255,0.7)"; // [추가]
        ctx.fillStyle = "#fff";
        ctx.beginPath();
        ctx.arc(0, 0, size/2, 0, Math.PI*2); // 간단한 원형 눈송이
        ctx.fill();
        ctx.restore();
    }

    function startWinFx() {
      if (fxPlaying) return; // 이미 눈 루프가 돌고 있으면 재시작하지 않음
      fxPlaying = true;
      fxStartTime = performance.now();
      requestAnimationFrame(tickFx);
    }

    function tickFx(now) {
        fctx.clearRect(0, 0, fxCanvas.width, fxCanvas.height);

        // 전체 화면 눈송이 (승리 축하)
        if (Math.random() < 0.2) {
             spawnSnow(Math.random() * fxCanvas.width, -10, 2);
        }

        updateSnow();
        for (const f of flakes) {
            drawFlake(fctx, f.x, f.y, f.s, f.r, f.a);
        }

        if (fxPlaying) {
            requestAnimationFrame(tickFx);
        }
    }

    // ================= [승리 라인 FX] =================
    // 8방향 탐색
    const directions = [
        [0, 1],   // 가로
        [1, 0],   // 세로
        [1, 1],   // 대각선 \
        [1, -1]   // 대각선 /
    ];

    function getWinLineFromLastMove(board, row, col, stone) {
        if (!stone || board[row][col] !== stone) return null;

        for (const [dr, dc] of directions) {
            let count = 1;
            let startR = row, startC = col;
            let endR = row, endC = col;

            // 정방향 탐색
            let r = row + dr, c = col + dc;
            while (r >= 0 && r < BOARD_SIZE && c >= 0 && c < BOARD_SIZE && board[r][c] === stone) {
                count++;
                endR = r; endC = c;
                r += dr; c += dc;
            }

            // 역방향 탐색
            r = row - dr; c = col - dc;
            while (r >= 0 && r < BOARD_SIZE && c >= 0 && c < BOARD_SIZE && board[r][c] === stone) {
                count++;
                startR = r; startC = c;
                r -= dr; c -= dc;
            }

            if (count >= 5) {
                return { startR, startC, endR, endC };
            }
        }
        return null;
    }

    function findAnyWinLine(board) {
        for (let r = 0; r < BOARD_SIZE; r++) {
            for (let c = 0; c < BOARD_SIZE; c++) {
                const stone = board[r][c];
                if (stone !== 0) {
                    const line = getWinLineFromLastMove(board, r, c, stone);
                    if (line) return line;
                }
            }
        }
        return null;
    }

    // 승리 라인에서 lastMove 포함 5개 돌 찾기
    function getWin5Stones(line, lastMove) {
        if (!line || !lastMove) return [];
        const { startR, startC, endR, endC } = line;
        const dr = endR - startR;
        const dc = endC - startC;
        const len = Math.max(Math.abs(dr), Math.abs(dc)) + 1;

        // 방향 단위벡터
        const dirR = dr === 0 ? 0 : dr / Math.abs(dr);
        const dirC = dc === 0 ? 0 : dc / Math.abs(dc);

        // 라인의 모든 셀 생성
        const allCells = [];
        for (let i = 0; i < len; i++) {
            allCells.push({ r: startR + dirR * i, c: startC + dirC * i });
        }

        // lastMove 포함하는 연속 5개 찾기
        let foundIdx = allCells.findIndex(cell => cell.r === lastMove.row && cell.c === lastMove.col);
        if (foundIdx === -1) foundIdx = 0; // 안전장치

        // 5개 구간 선택 (lastMove가 중간쯤 오도록)
        let start = Math.max(0, foundIdx - 2);
        if (start + 5 > allCells.length) start = allCells.length - 5;
        if (start < 0) start = 0;

        return allCells.slice(start, start + 5);
    }

    // 승리 5돌에 펄스 클래스 적용
    function applyWinPulse(win5Stones) {
        if (!win5Stones || win5Stones.length === 0) return;

        const stones = boardHit.querySelectorAll('.stone');
        const winStoneElements = [];

        for (const pos of win5Stones) {
            for (const stoneEl of stones) {
                if (parseInt(stoneEl.dataset.r) === pos.r && parseInt(stoneEl.dataset.c) === pos.c) {
                    stoneEl.classList.add('win-pulse');
                    winStoneElements.push(stoneEl);
                    break;
                }
            }
        }

        // 1.2초 후 클래스 제거 (2회 펄스 완료 후)
        setTimeout(() => {
            winStoneElements.forEach(el => el.classList.remove('win-pulse'));
        }, 1200);
    }

    function playWinEffect(line, onComplete) {
        const { startR, startC, endR, endC } = line;

        const x1 = startC * cellW;
        const y1 = startR * cellH;
        const x2 = endC * cellW;
        const y2 = endR * cellH;

        // 승리 5돌 찾기 + 펄스 적용
        const win5 = getWin5Stones(line, lastMove);
        applyWinPulse(win5);

        const drawDuration = 600;  // 0.6초 라인 그리기
        const fadeDuration = 400;  // 0.4초 페이드아웃
        const afterSnowMs = 1700;  // 1.7초 강한 눈 내림
        const totalDuration = drawDuration + fadeDuration + afterSnowMs;
        const trailLength = 18; // 트레일 길이

        const startTime = performance.now();
        let animFrame;
        let burstSpawned = false;
        let lastHeadBurstTime = 0; // 헤드 버스트 쿨타임 추적

        function animate(now) {
            const elapsed = now - startTime;
            const progress = Math.min(elapsed / totalDuration, 1);
            const fxW = boardHit.clientWidth;
            const fxH = boardHit.clientHeight;

            fctx.clearRect(0, 0, fxCanvas.width, fxCanvas.height);

            if (elapsed < drawDuration) {
                // ===== 라인 그리기 단계 =====
                const p = elapsed / drawDuration;
                const curX = x1 + (x2 - x1) * p;
                const curY = y1 + (y2 - y1) * p;

                // 헤드 위치 트레일에 추가
                lineTrail.push({ x: curX, y: curY });
                if (lineTrail.length > trailLength) lineTrail.shift();

                // 헤드 스파크 스폰 (2~4개)
                if (Math.random() < 0.6) {
                    spawnSparks(curX, curY, Math.floor(Math.random() * 3) + 2);
                }

                // 헤드 미니 버스트 (50~90ms 간격)
                if (elapsed - lastHeadBurstTime > 50 + Math.random() * 40) {
                    spawnHeadBurst(curX, curY);
                    lastHeadBurstTime = elapsed;
                }

                // 트레일 렌더링 (뒤쪽: 얇고 투명, 앞쪽: 두껍고 밝게)
                fctx.save();
                fctx.globalCompositeOperation = "lighter";
                for (let i = 0; i < lineTrail.length; i++) {
                    const t = lineTrail[i];
                    const ratio = i / lineTrail.length;
                    const alpha = ratio * 0.7;
                    const width = 4 + ratio * 10;

                    fctx.strokeStyle = `rgba(255, 240, 180, ${alpha})`;
                    fctx.lineWidth = width;
                    fctx.lineCap = "round";
                    fctx.shadowBlur = 8 + ratio * 8;
                    fctx.shadowColor = `rgba(255, 215, 0, ${alpha})`;

                    if (i > 0) {
                        fctx.beginPath();
                        fctx.moveTo(lineTrail[i-1].x, lineTrail[i-1].y);
                        fctx.lineTo(t.x, t.y);
                        fctx.stroke();
                    }
                }
                fctx.restore();

                // 메인 라인 (Glow)
                fctx.strokeStyle = "rgba(255, 220, 140, 0.75)";
                fctx.lineWidth = 10;
                fctx.lineCap = "round";
                fctx.beginPath();
                fctx.moveTo(x1, y1);
                fctx.lineTo(curX, curY);
                fctx.stroke();

                // 메인 라인 (Core)
                fctx.strokeStyle = "rgba(255, 250, 235, 0.95)";
                fctx.lineWidth = 4;
                fctx.beginPath();
                fctx.moveTo(x1, y1);
                fctx.lineTo(curX, curY);
                fctx.stroke();

            } else if (elapsed < drawDuration + fadeDuration) {
                // ===== 페이드아웃 단계 =====
                const fadeProgress = (elapsed - drawDuration) / fadeDuration;
                const alpha = 1 - fadeProgress;

                // 라인 완성 시 눈송이 버스트 (1회만)
                if (!burstSpawned) {
                    const burstCount = 35 + Math.floor(Math.random() * 36); // 35~70개
                    spawnBurst(x2, y2, burstCount);
                    burstSpawned = true;
                }

                // Glow
                fctx.strokeStyle = `rgba(255, 220, 140, ${0.75 * alpha})`;
                fctx.lineWidth = 10;
                fctx.lineCap = "round";
                fctx.beginPath();
                fctx.moveTo(x1, y1);
                fctx.lineTo(x2, y2);
                fctx.stroke();

                // Core
                fctx.strokeStyle = `rgba(255, 250, 235, ${0.95 * alpha})`;
                fctx.lineWidth = 4;
                fctx.beginPath();
                fctx.moveTo(x1, y1);
                fctx.lineTo(x2, y2);
                fctx.stroke();
            } else {
                // ===== 강한 눈 내림 단계 (라인 페이드 완료 후) =====
                // 강한 눈 스폰 (확률 0.7, 3~5개)
                if (Math.random() < 0.7) {
                    const count = 3 + Math.floor(Math.random() * 3);
                    spawnSnow(Math.random() * fxW, -10, count);
                }
            }

            // ===== 모든 단계에서 파티클 업데이트 및 렌더링 =====

            // 스파크 업데이트 및 렌더링
            updateSparks();
            drawSparks(fctx);

            // 버스트 눈송이 업데이트 및 렌더링
            updateBurstFlakes();
            for (const f of burstFlakes) {
                drawFlake(fctx, f.x, f.y, f.s, f.r, f.a);
            }

            // 눈송이 업데이트 및 렌더링
            updateSnow();
            for (const f of flakes) {
                drawFlake(fctx, f.x, f.y, f.s, f.r, f.a);
            }

            if (progress < 1) {
                animFrame = requestAnimationFrame(animate);
            } else {
                // 정리 (눈 입자는 유지해 계속 내리게 함)
                fctx.clearRect(0, 0, fxCanvas.width, fxCanvas.height);
                lineTrail.length = 0;
                sparks.length = 0;
                burstFlakes.length = 0;
                cancelAnimationFrame(animFrame);
                if (onComplete) onComplete();
            }
        }

        animFrame = requestAnimationFrame(animate);
    }
    // ===============================================================

    function normalizeTurn(currentTurn, blackPlayer, whitePlayer) {
      if (typeof currentTurn === 'number') return currentTurn;
      if (typeof currentTurn === 'string') {
        if (currentTurn === blackPlayer) return 1;
        if (currentTurn === whitePlayer) return 2;
      }
      return null;
    }

    function normalizePayload(msg) {
      return { type: msg.type, data: msg.data ?? msg };
    }
    
    function showSystemMessage(message, roleColor = null) {
      const chatLog = document.getElementById("chatScroll");
      if (!chatLog) return;
      const lineDiv = document.createElement("div");
      const systemSpan = document.createElement("span");
      systemSpan.style.color = ROLE_COLOR.SYSTEM;
      systemSpan.textContent = "System: ";
      lineDiv.appendChild(systemSpan);

      if (roleColor) {
        const messageSpan = document.createElement("span");
        messageSpan.style.color = roleColor;
        messageSpan.textContent = message;
        lineDiv.appendChild(messageSpan);
      } else {
        lineDiv.appendChild(document.createTextNode(message));
      }
      chatLog.appendChild(lineDiv);
      chatLog.scrollTop = chatLog.scrollHeight;
    }

    function appendRoleChat(sender, message, channel) {
        const chatLog = document.getElementById("chatLog") || document.getElementById("chatScroll");
        if (!chatLog) return;

        let roleLabel = "";
        let roleColor = ROLE_COLOR.OBSERVER;

        if (sender === blackPlayerName) {
            roleLabel = "[User]";
            roleColor = ROLE_COLOR.BLACK;
        } else if (sender === whitePlayerName) {
            roleLabel = "[User]";
            roleColor = ROLE_COLOR.WHITE;
        } else {
            roleLabel = "[User]";
            roleColor = ROLE_COLOR.OBSERVER;
        }

        const lineDiv = document.createElement("div");
        const labelSpan = document.createElement("span");
        labelSpan.style.color = roleColor;
        labelSpan.textContent = roleLabel + " ";
        const senderSpan = document.createElement("span");
        senderSpan.style.color = roleColor;
        senderSpan.textContent = sender + ": ";
        const messageSpan = document.createElement("span");
        messageSpan.textContent = message;

        lineDiv.appendChild(labelSpan);
        lineDiv.appendChild(senderSpan);
        lineDiv.appendChild(messageSpan);
        chatLog.appendChild(lineDiv);
        chatLog.scrollTop = chatLog.scrollHeight;
    }

    function onBoardClick(e) {
      if (!gameActive || gameEnded) return;
      if (inputLocked) return;  
      if (isObserver || !isPlayer) return;
      if (myStone !== turn) return;

      const pos = getGridPos(e);
      if (!pos || boardState[pos.row][pos.col] !== 0) return;

      inputLocked = true;
      socket.send(JSON.stringify({ type: "MAKE_MOVE", row: pos.row, col: pos.col }));
    }

    function updateTurnUI() {
      if (turn === 1) {
        p1Box.classList.add("turn-active");
        p2Box.classList.remove("turn-active");
      } else {
        p1Box.classList.remove("turn-active");
        p2Box.classList.add("turn-active");
      }
    }

    function sendChatMessage() {
      const input = document.getElementById("chatInput");
      const message = input.value.trim();
      if (!message) return;
      const channel = isObserver ? "OBSERVER" : (isPlayer ? "PLAYER" : "ALL");
      if (socket && socket.readyState === WebSocket.OPEN) {
        socket.send(JSON.stringify({ type: "CHAT", message: message, channel: channel }));
      }
      input.value = "";
    }
    
    function initAudio() {
        const savedVolume = localStorage.getItem('omok_volume');
        if (savedVolume !== null) currentVolume = parseFloat(savedVolume);
        
        updateVolumeUI();
        applyVolume();
        
        const bgm = document.getElementById('bgmAudio');
        bgm.play().catch(e => {
            document.body.addEventListener('click', () => bgm.play(), { once: true });
        });
    }

    function applyVolume() {
        const bgm = document.getElementById('bgmAudio');
        if (bgm) bgm.volume = currentVolume;
        if (stoneAudio) stoneAudio.volume = currentVolume;
    }

    function updateVolumeUI() {
        const knob = document.getElementById('volumeKnob');
        if (knob) knob.style.left = (currentVolume * 100) + '%';
    }

    function setBgmVolume(volume) {
        currentVolume = volume;
        localStorage.setItem('omok_volume', volume.toString());
        applyVolume();
    }

    function startDrag(e) {
        e.preventDefault();
        isDraggingVolume = true;
        const track = document.getElementById('volumeTrack');
        updateVolumeFromEvent(e, track);
    }

    function updateVolumeFromEvent(e, trackElement) {
        const rect = trackElement.getBoundingClientRect();
        let clickX = e.clientX - rect.left;
        let volume = clickX / rect.width;
        volume = Math.max(0, Math.min(1, volume));
        updateVolumeUI();
        setBgmVolume(volume);
    }

    window.addEventListener("load", () => {
      recalcMetrics();
      window.addEventListener("resize", recalcMetrics);
      boardHit.addEventListener("mousemove", onMouseMove);
      boardHit.addEventListener("mouseleave", () => { ghostEl.style.display = "none"; });
      boardHit.addEventListener("click", onBoardClick);

      const chatInput = document.getElementById("chatInput");
      const chatSendBtn = document.getElementById("chatSendBtn");
      chatSendBtn.onclick = sendChatMessage;
      chatInput.addEventListener("keypress", (e) => { if (e.key === "Enter") sendChatMessage(); });

     connectWebSocket();
      initAudio();
      
      const volumeTrack = document.getElementById('volumeTrack');
      if (volumeTrack) {
          volumeTrack.addEventListener('mousedown', startDrag);
          document.addEventListener('mousemove', function(e) {
              if (isDraggingVolume) updateVolumeFromEvent(e, volumeTrack);
          });
          document.addEventListener('mouseup', function() {
              isDraggingVolume = false;
          });
      }

      window.addEventListener("beforeunload", () => {
        if (socket && socket.readyState === WebSocket.OPEN) {
          socket.close(1000, "unload");
        }
      });

      const dim = document.getElementById("dimLayer");
      const popup = document.getElementById("configPopup");
      document.getElementById("configBtn").onclick = () => { 
         dim.style.display="flex"; 
         popup.style.display="flex"; 
         updateVolumeUI();
      };
      const close = () => { dim.style.display="none"; popup.style.display="none"; };
      document.getElementById("closePopupBtn").onclick = close;
      dim.onclick = close;

      const exitFunc = () => {
        if(confirm("정말 나가시겠습니까?")) {
          if (socket && socket.readyState === WebSocket.OPEN) {
            try { socket.send(JSON.stringify({ type: "EXIT" })); } catch (e) {}
          }
          if (socket) socket.close(1000, "leave");
          location.replace(CTX + "/main");
        }
      };
      // document.getElementById("exitBtn").onclick = exitFunc; // 제거됨
      document.getElementById("surrenderBtn").onclick = exitFunc;
    });
    
    // ================= WebSocket =================
   const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
   const wsUrl = protocol + '//' + window.location.host + CTX + '/game';
   const params = new URLSearchParams(window.location.search);
   const roomSeq = params.get('roomSeq');
   
   if (!roomSeq) alert("roomSeq가 없습니다.");
   
   let socket = null;
   
   function connectWebSocket() {
     socket = new WebSocket(wsUrl);

     socket.onopen = () => {
       const joinMsg = { type: "JOIN_GAME", roomSeq: Number(roomSeq) };
       socket.send(JSON.stringify(joinMsg)); 
     };
   
     socket.onmessage = (event) => {
        const rawData = JSON.parse(event.data);
        const normalized = normalizePayload(rawData);
        const type = normalized.type;
        const data = normalized.data;

        switch (type) {

          case "JOIN_GAME_SUCCESS": {
            isPlayer = data.isPlayer || false;
            isObserver = data.isObserver || false;
            blackPlayerName = data.blackPlayer || "";
            whitePlayerName = data.whitePlayer || "";

            if (isPlayer && blackPlayerName === myNickname) myStone = 1;
            else if (isPlayer && whitePlayerName === myNickname) myStone = 2;
            else myStone = 0;

            const p1NameEl = p1Box.querySelector('.player-name');
            const p2NameEl = p2Box.querySelector('.player-name');
            if (p1NameEl && blackPlayerName) p1NameEl.textContent = blackPlayerName;
            if (p2NameEl && whitePlayerName) p2NameEl.textContent = whitePlayerName;

            const board = data.board || [];
            const boardSize = data.boardSize || BOARD_SIZE;
            for (let r = 0; r < boardSize; r++) {
              for (let c = 0; c < boardSize; c++) {
                const stoneValue = board[r]?.[c] || 0;
                if (stoneValue !== 0) {
                  boardState[r][c] = stoneValue;
                  placeStone(r, c, stoneValue);
                }
              }
            }

            turn = normalizeTurn(data.currentTurn, blackPlayerName, whitePlayerName) || 1;
            updateTurnUI();

            if (blackPlayerName && !announcedJoins.has(blackPlayerName)) {
              showSystemMessage("흑 : " + blackPlayerName + " 입장했습니다.", ROLE_COLOR.BLACK);
              announcedJoins.add(blackPlayerName);
            }
            if (whitePlayerName && !announcedJoins.has(whitePlayerName)) {
              showSystemMessage("백 : " + whitePlayerName + " 입장했습니다.", ROLE_COLOR.WHITE);
              announcedJoins.add(whitePlayerName);
            }

            if (blackPlayerName && whitePlayerName && lastAnnouncedTurn !== turn) {
              const currentPlayerName = (turn === 1) ? blackPlayerName : whitePlayerName;
              const roleText = (turn === 1) ? "흑" : "백";
              const roleColor = (turn === 1) ? ROLE_COLOR.BLACK : ROLE_COLOR.WHITE;
              showSystemMessage("돌을 놓을 차례입니다. (" + roleText + ": " + currentPlayerName + ")", roleColor);
              lastAnnouncedTurn = turn;
            }
            break;
          }

          case "WAITING_FOR_PLAYER": {
            break;
          }
         case "JOIN_OBSERVER": {
                const { board, blackPlayer, whitePlayer, currentTurn } = data;

                blackPlayerName = blackPlayer || "";
                whitePlayerName = whitePlayer || "";

                for (let r = 0; r < board.length; r++) {
                    for (let c = 0; c < board[r].length; c++) {
                        boardState[r][c] = board[r][c];
                        if (board[r][c] !== 0) {
                            placeStone(r, c, board[r][c]);
                        }
                    }
                }
                turn = currentTurn;
                updateTurnUI();

                const p1NameEl = p1Box.querySelector('.player-name');
                const p2NameEl = p2Box.querySelector('.player-name');
                if (p1NameEl && blackPlayerName) p1NameEl.textContent = blackPlayerName;
                if (p2NameEl && whitePlayerName) p2NameEl.textContent = whitePlayerName;

                if (myNickname && !announcedJoins.has(myNickname)) {
                  showSystemMessage("관전자 : " + myNickname + " 입장했습니다.", ROLE_COLOR.OBSERVER);
                  announcedJoins.add(myNickname);
                }
                break;
            }

          case "MOVE": {
            const { row, col, stone, player, currentTurn } = data;
            if (typeof row !== 'number' || typeof col !== 'number') return;
            if (boardState[row][col] !== 0) return;

            boardState[row][col] = stone;
            placeStone(row, col, stone);

            // 마지막 착수 정보 저장
            lastMove = { row, col, stone };

            if (player && stone) {
              if (stone === 1 && !blackPlayerName) blackPlayerName = player;
              if (stone === 2 && !whitePlayerName) whitePlayerName = player;
              const p1NameEl = p1Box.querySelector('.player-name');
              const p2NameEl = p2Box.querySelector('.player-name');
              if (p1NameEl && blackPlayerName && p1NameEl.textContent === 'Waiting...') p1NameEl.textContent = blackPlayerName;
              if (p2NameEl && whitePlayerName && p2NameEl.textContent === 'Waiting...') p2NameEl.textContent = whitePlayerName;
            }

            turn = normalizeTurn(currentTurn, blackPlayerName, whitePlayerName) || ((turn === 1) ? 2 : 1);
            updateTurnUI();
            inputLocked = false;

            if (lastAnnouncedTurn !== turn && blackPlayerName && whitePlayerName) {
              const currentPlayerName = (turn === 1) ? blackPlayerName : whitePlayerName;
              const roleText = (turn === 1) ? "흑" : "백";
              const roleColor = (turn === 1) ? ROLE_COLOR.BLACK : ROLE_COLOR.WHITE;
              showSystemMessage("돌을 놓을 차례입니다. (" + roleText + ": " + currentPlayerName + ")", roleColor);
              lastAnnouncedTurn = turn;
            }
            break;
          }

          case "GAME_OVER": {
            gameActive = false;
            gameEnded = true;

            // [승리 라인 그리기] - WIN일 때만 (playWinEffect 내부에서 모든 FX 처리)
            if (data.result === "WIN" && lastMove) {
              let line = getWinLineFromLastMove(boardState, lastMove.row, lastMove.col, lastMove.stone);
              if (!line) {
                line = findAnyWinLine(boardState);
              }
              if (line) {
                playWinEffect(line, startWinFx); // 라인 연출이 끝나면 눈 루프 시작
              } else {
                startWinFx(); // 라인 못 찾은 경우에도 눈은 계속 내리게
              }
            } else {
              startWinFx(); // 무승부 등도 눈 계속
            }

            const dim = document.getElementById("gameOverDim");
            const popup = document.getElementById("gameOverPopup");
            const title = document.getElementById("gameOverTitle");
            const msg = document.getElementById("gameOverMessage");

            // 팝업 표시 함수
            const showPopup = () => {
              dim.style.display = "block";
              popup.style.display = "flex";
            };

            if (data.result === "DRAW") {
              title.textContent = "무승부";
              msg.textContent = data.message;
              // DRAW: 즉시 팝업
              showPopup();
            } else if (data.result === "WIN") {
              title.textContent = "게임 종료";
              msg.textContent = data.message;
              // WIN: 1.9초 후 팝업 (승리 효과를 충분히 보여줌)
              setTimeout(showPopup, 1900);
            }
            break;
          }

          case "CHAT": {
            const chatData = data.data ?? data;
            const sender = chatData.sender || chatData.nickname || "Unknown";
            const message = chatData.message || "";
              const channel = chatData.channel || data.channel || "ALL";

              appendRoleChat(sender, message, channel);
            break;
          }

        //   case "NOTIFICATION": {
        //     alert(`[${data.notificationType}] ${data.message}`);
        //     break;
        //   }

          case "ERROR": {
            const errorMsg = data.message || JSON.stringify(data);
            alert("오류: " + errorMsg);
            inputLocked = false; 
            break;
          }

          case "EXIT":
            alert("상대방이 게임을 나갔습니다.");
            location.href = CTX + "/main";
            break;
        }
      };

     socket.onclose = (event) => {};
     socket.onerror = (err) => {
       if (!gameEnded) alert("연결 오류가 발생했습니다.");
     };
   }
   
   document.getElementById("gameOverBtn").onclick = () => {
        location.href = CTX + "/main";
   };

  </script>
</body>
</html>