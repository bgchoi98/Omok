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
	font-family: 'Arial', sans-serif;
	user-select: none;
	background: url('<%=CTX%>/assets/images/game/game_bg.png') no-repeat
		center/cover;
}

/* ===== Main Layout (Grid) ===== */
.layout {
	display: grid;
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
	/* 화면 크기에 맞춰 반응형으로 조절 */
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

/* [2] 투명 클릭 영역 (board-hit)
       inBoard.png를 제거하고, board.png 내의 실제 격자 영역만 잡음.
       전체 1024x1024 중 격자 영역 866x866 비율 계산:
       - Width: 866 / 1024 ≈ 84.57%
       - Height: 866 / 1024 ≈ 84.57%
       - 중앙 정렬
    */
.board-hit {
	position: absolute;
	top: 50%;
	left: 50%;
	transform: translate(-50%, -50%); /* 정확한 중앙 정렬 */
	width: 84.57%;
	height: 84.57%;
	z-index: 10;
	cursor: pointer;
	/* border: 1px solid rgba(255, 0, 0, 0.3); 디버깅용: 격자 위치 확인 시 주석 해제 */
}

/* 돌 스타일 */
.stone, .ghost-stone {
	position: absolute;
	/* 돌의 중심점이 좌표에 오도록 설정 */
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
	gap: 15px;
	height: 100%;
	justify-content: center;
}

.right-top {
	display: flex;
	justify-content: flex-end;
	height: 50px;
}

.exit-btn {
	height: 100%;
	cursor: pointer;
	transition: transform 0.2s;
	filter: drop-shadow(0 4px 4px rgba(0, 0, 0, 0.3));
}

.exit-btn:hover {
	transform: scale(1.05);
}

.chat-panel {
	flex: 1;
	position: relative;
	background: url('<%=CTX%>/assets/images/game/chatBox.png') no-repeat
		center/100% 100%;
	min-height: 250px;
	filter: drop-shadow(0 8px 16px rgba(0, 0, 0, 0.2));
	transform: translateX(-30px);
	margin-top: 10px; /* align chat top closer to board top */
}

.chat-scroll {
	position: absolute;
	top: 12%;
	bottom: 25%;
	left: 10%;
	right: 10%;
	overflow-y: auto;
	padding-right: 5px;
	font-size: 15px;
	font-weight: bold;
	color: #3e2723;
	line-height: 1.5;
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
	bottom: 8%;
	left: 10%;
	right: 10%;
	display: flex;
	gap: 5px;
}

.chat-input {
	flex: 1;
	padding: 6px 10px;
	border: 2px solid #8d6e63;
	border-radius: 4px;
	font-size: 14px;
	background: rgba(255, 255, 255, 0.9);
}

.chat-send-btn {
	padding: 6px 15px;
	background: #5d4037;
	color: white;
	border: none;
	border-radius: 4px;
	font-weight: bold;
	cursor: pointer;
}

.chat-send-btn:hover {
	background: #3e2723;
}

.right-bottom {
	display: flex;
	flex-direction: column;
	gap: 10px;
}

.players-container {
	display: flex;
	justify-content: space-between;
	gap: 10px;
}

.player-box {
	flex: 1;
	height: 90px;
	/* ADD: 멀티 background로 playerBox + 아바타 합성 */
	background:
		var(--avatar-img, none) no-repeat left center / auto 85%,
		url('<%=CTX%>/assets/images/game/playerBox.png') no-repeat center/100% 100%;
	display: flex;
	flex-direction: column;
	justify-content: center;
	padding-left: 75px;
	padding-right: 10px;
	color: #3e2723;
	filter: drop-shadow(0 4px 6px rgba(0, 0, 0, 0.2));
	transition: transform 0.2s;
}

.player-name {
	font-size: 15px;
	font-weight: 800;
	white-space: nowrap;
	overflow: hidden;
	text-overflow: ellipsis;
}

.player-score {
	font-size: 11px;
	margin-top: 4px;
	opacity: 0.8;
}

.turn-active {
	transform: scale(1.05);
	filter: drop-shadow(0 0 8px rgba(255, 215, 0, 0.9)) !important;
}

.config-area {
	display: flex;
	justify-content: flex-end;
	padding-right: 5px;
}

.config-btn {
	width: 45px;
	cursor: pointer;
	transition: transform 0.3s;
	filter: drop-shadow(0 4px 6px rgba(0, 0, 0, 0.3));
}

.config-btn:hover {
	transform: rotate(30deg) scale(1.1);
}

/* ===== Popup ===== */
.dim-layer {
	position: fixed;
	inset: 0;
	background: rgba(0, 0, 0, 0.6);
	display: none;
	z-index: 100;
}

.config-popup {
	position: fixed;
	top: 50%;
	left: 50%;
	transform: translate(-50%, -50%);
	width: 400px;
	height: 320px;
	background:
		url('<%=CTX%>/assets/images/main/ConfigPopUp/configureBox.png')
		no-repeat center/contain;
	display: none;
	flex-direction: column;
	align-items: center;
	justify-content: center;
	z-index: 101;
	filter: drop-shadow(0 10px 20px rgba(0, 0, 0, 0.5));
}

.close-popup-btn {
	position: absolute;
	top: 45px;
	right: 30px;
	width: 30px;
	height: 30px;
	background: #8d6e63;
	border: 2px solid #5d4037;
	color: white;
	font-weight: bold;
	cursor: pointer;
	border-radius: 4px;
}

.popup-content {
	margin-top: 20px;
	text-align: center;
}

.surrender-btn {
	padding: 10px 20px;
	background: #5d4037;
	color: white;
	border: none;
	border-radius: 8px;
	font-weight: bold;
	font-size: 16px;
	cursor: pointer;
	transition: 0.2s;
}

.surrender-btn:hover {
	background: #3e2723;
	transform: scale(1.05);
}

@media ( max-width : 1000px) {
	.layout {
		grid-template-columns: 1fr;
		grid-template-rows: auto 1fr;
		overflow-y: auto;
	}
	body {
		overflow: auto;
	}
	.left-col {
		margin-bottom: 20px;
	}
	.right-col {
		height: auto;
	}
}
</style>
</head>

<body>
	<div class="game-bg"></div>
	<!-- 게임 종료 팝업 -->
	<div id="gameOverDim" class="dim-layer"></div>
	
	<div id="gameOverPopup" class="config-popup" style="display:none;">
	  <div class="popup-content">
	    <h2 id="gameOverTitle" style="color:#3e2723; margin-bottom:15px;"></h2>
	    <p id="gameOverMessage" style="font-size:16px; margin-bottom:25px;"></p>
	    <button id="gameOverBtn" class="surrender-btn">로비로</button>
	  </div>
	</div>
	
	<div class="layout">
		<div class="left-col">
			<div class="board-frame-wrap" id="boardFrame">
				<img src="<%=CTX%>/assets/images/game/board.png"
					class="board-frame-img" alt="Frame" />

				<div id="boardHit" class="board-hit">
					<img id="ghostStone" class="ghost-stone"
						src="<%=CTX%>/assets/images/game/stone_1.png" alt="" />
				</div>
			</div>
		</div>

		<div class="right-col">
			<!-- <div class="right-top">
				<img id="exitBtn" class="exit-btn"
					src="<%=CTX%>/assets/images/game/getOut.png" alt="Exit" />
			</div> -->

			<div class="chat-panel">
				<div class="chat-scroll" id="chatScroll">
					<div>
						<span style="color: #d32f2f;">System:</span> 게임에 입장했습니다.
					</div>
					<div>
						<span style="color: #d32f2f;">System:</span> 즐거운 대국 되세요!
					</div>
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
						<div class="player-score">
							Wins:
							<%=win%></div>
					</div>
					<div class="player-box" id="p2Box">
						<div class="player-name">Waiting...</div>
						<div class="player-score">-</div>
					</div>
				</div>

				<div class="config-area">
					<img id="configBtn" class="config-btn"
						src="<%=CTX%>/assets/images/game/configureIcon.png" alt="Config" />
				</div>
			</div>
		</div>
	</div>

	<div id="dimLayer" class="dim-layer"></div>
	<div id="configPopup" class="config-popup">
		<button id="closePopupBtn" class="close-popup-btn">X</button>
		<div class="popup-content">
			<h2 style="color: #3e2723; margin-bottom: 20px;">Game Settings</h2>
			<button id="surrenderBtn" class="surrender-btn">기권 / 나가기</button>
		</div>
	</div>

	<script src="<%= request.getContextPath() %>/assets/js/game/game-chat.js?v=1"></script>

	<script>
    const CTX = "<%=CTX%>";
    const IMG = {
      black: CTX + "/assets/images/game/stone_1.png",
      white: CTX + "/assets/images/game/stone_2.png",
    };

    // 역할별 색상 상수
    const ROLE_COLOR = {
      BLACK: "#212121",
      WHITE: "#1565C0",
      OBSERVER: "#6A1B9A",
      SYSTEM: "#D32F2F",
    };

    // 오목판 격자 (15줄 = 14칸 간격)
    const BOARD_SIZE = 15;
    const LINES = 14;

    let turn = 1; // 1: 흑, 2: 백
    let gameActive = true;
    let boardState = Array.from({ length: BOARD_SIZE }, () => Array(BOARD_SIZE).fill(0));

    // Role state variables (for player/observer distinction)
    let isPlayer = false;
    let isObserver = false;
    let myStone = 0;  // 1 or 2, 0 if observer
    let blackPlayerName = "";
    let whitePlayerName = "";
    let myNickname = "<%=nickName%>";
    let inputLocked = false;
    let gameEnded = false;

    // 중복 출력 방지를 위한 상태 관리
    let announcedJoins = new Set(); // 입장 안내한 닉네임들
    let lastAnnouncedTurn = 0; // 마지막으로 안내한 턴

    const boardHit   = document.getElementById("boardHit");
    const ghostEl    = document.getElementById("ghostStone");
    const p1Box      = document.getElementById("p1Box");
    const p2Box      = document.getElementById("p2Box");

    let cellW = 0;
    let cellH = 0;

    // 1. 그리드 수치 계산 (보드 크기에 맞춰 동적 계산)
    function recalcMetrics() {
      // boardHit가 CSS에 의해 이미 격자 영역에 맞춰져 있음
      const width = boardHit.clientWidth;
      const height = boardHit.clientHeight;

      // 14칸으로 나눔
      cellW = width / LINES;
      cellH = height / LINES;
      
      // 돌 크기는 칸의 95% (가로/세로 중 작은 쪽 기준)
      const stoneSize = Math.min(cellW, cellH) * 0.95; 
      
      ghostEl.style.width = stoneSize + "px";
      ghostEl.style.height = stoneSize + "px";
    }

    // 2. 좌표 변환 (Pixel -> Grid Index)
    function getGridPos(e) {
      const rect = boardHit.getBoundingClientRect();
      const x = e.clientX - rect.left;
      const y = e.clientY - rect.top;

      // 반올림하여 가장 가까운 교차점 찾기
      const col = Math.round(x / cellW);
      const row = Math.round(y / cellH);

      // 0 ~ 14 범위 체크
      if (col < 0 || col >= BOARD_SIZE || row < 0 || row >= BOARD_SIZE) {
        return null;
      }
      return { row, col };
    }

    // 3. 돌 놓기 (UI)
    function placeStone(row, col, player) {
      const stone = document.createElement("img");
      stone.src = (player === 1) ? IMG.black : IMG.white;
      stone.className = "stone";
      
      const stoneSize = Math.min(cellW, cellH) * 0.95;
      stone.style.width = stoneSize + "px";
      stone.style.height = stoneSize + "px";

      // 위치 설정: (인덱스 * 간격) = 해당 교차점의 중심
      // CSS에서 translate(-50%, -50%)를 했으므로 정확히 중앙에 옴
      stone.style.left = (col * cellW) + "px";
      stone.style.top  = (row * cellH) + "px";

      // 랜덤 회전으로 자연스럽게
      const deg = Math.random() * 40 - 20;
      stone.style.transform = `translate(-50%, -50%) rotate(${deg}deg)`;

      boardHit.appendChild(stone);
    }

    // 4. 마우스 이동 (Ghost Stone)
    function onMouseMove(e) {
      if (!gameActive) return;
      const pos = getGridPos(e);
      
      if (!pos || boardState[pos.row][pos.col] !== 0) {
        ghostEl.style.display = "none";
        return;
      }

      ghostEl.style.display = "block";
      ghostEl.src = (turn === 1) ? IMG.black : IMG.white;
      
      // 위치 업데이트 (독립 좌표 사용)
      ghostEl.style.left = (pos.col * cellW) + "px";
      ghostEl.style.top  = (pos.row * cellH) + "px";
    }

    // Utility: Normalize turn value (handle nickname or 1/2)
    function normalizeTurn(currentTurn, blackPlayer, whitePlayer) {
      if (typeof currentTurn === 'number') return currentTurn;
      if (typeof currentTurn === 'string') {
        if (currentTurn === blackPlayer) return 1;
        if (currentTurn === whitePlayer) return 2;
      }
      return null;
    }

    // Utility: Normalize payload structure
    function normalizePayload(msg) {
      return {
        type: msg.type,
        data: msg.data ?? msg
      };
    }

    // 시스템 메시지 출력 함수
    function showSystemMessage(message, roleColor = null) {
      const chatLog = document.getElementById("chatScroll");
      if (!chatLog) return;

      const lineDiv = document.createElement("div");

      // System 라벨
      const systemSpan = document.createElement("span");
      systemSpan.style.color = ROLE_COLOR.SYSTEM;
      systemSpan.textContent = "System: ";

      lineDiv.appendChild(systemSpan);

      // 메시지 내용 (역할 색상 적용)
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

		// 플레이어/관전자 채팅 라벨 출력
		function appendRoleChat(sender, message, channel) {
			const chatLog = document.getElementById("chatLog") || document.getElementById("chatScroll");
			if (!chatLog) return;

			// 역할/색상 결정
			let roleLabel = "";
			let roleColor = "#1976d2";
			if (channel === "OBSERVER") {
				roleLabel = "[관전]";
				roleColor = ROLE_COLOR.OBSERVER;
			} else if (sender === blackPlayerName) {
				roleLabel = "[흑]";
				roleColor = ROLE_COLOR.BLACK;
			} else if (sender === whitePlayerName) {
				roleLabel = "[백]";
				roleColor = ROLE_COLOR.WHITE;
			} else {
				roleLabel = "[채널]";
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

    // 5. 클릭 (착수)
    function onBoardClick(e) {
      if (!gameActive || gameEnded) return;
      if (inputLocked) return;  // Prevent double-click

      // Observer cannot make moves
      if (isObserver || !isPlayer) {
        console.warn("Observers cannot make moves");
        return;
      }

      // Not my turn
      if (myStone !== turn) {
        console.warn("Not your turn");
        return;
      }

      const pos = getGridPos(e);
      console.log('Board clicked:', pos);
      if (!pos || boardState[pos.row][pos.col] !== 0) return;

      // Lock input until server responds
      inputLocked = true;

      // Send move to server
      socket.send(JSON.stringify({
        type: "MAKE_MOVE",
        row: pos.row,
        col: pos.col
      }));
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

    // Chat send function
    function sendChatMessage() {
      const input = document.getElementById("chatInput");
      const message = input.value.trim();
      if (!message) return;

      // Determine channel based on role
      const channel = isObserver ? "OBSERVER" : (isPlayer ? "PLAYER" : "ALL");

      // Send to server
      if (socket && socket.readyState === WebSocket.OPEN) {
        socket.send(JSON.stringify({
          type: "CHAT",
          message: message,
          channel: channel  // NOTE: server-side channel isolation required for true separation
        }));
      }

      input.value = "";
    }

    window.addEventListener("load", () => {
      recalcMetrics();
      window.addEventListener("resize", recalcMetrics);

      boardHit.addEventListener("mousemove", onMouseMove);
      boardHit.addEventListener("mouseleave", () => { ghostEl.style.display = "none"; });
      boardHit.addEventListener("click", onBoardClick);

      // Chat input events
      const chatInput = document.getElementById("chatInput");
      const chatSendBtn = document.getElementById("chatSendBtn");
      chatSendBtn.onclick = sendChatMessage;
      chatInput.addEventListener("keypress", (e) => {
        if (e.key === "Enter") sendChatMessage();
      });

	  // 웹소켓 연결 함수 호출 bgchoi
	  connectWebSocket();

      // Close socket on page unload
      window.addEventListener("beforeunload", () => {
        if (socket && socket.readyState === WebSocket.OPEN) {
          socket.close(1000, "unload");
        }
      });


      // 팝업 로직
      const dim = document.getElementById("dimLayer");
      const popup = document.getElementById("configPopup");
      document.getElementById("configBtn").onclick = () => { dim.style.display="block"; popup.style.display="flex"; };
      const close = () => { dim.style.display="none"; popup.style.display="none"; };
      document.getElementById("closePopupBtn").onclick = close;
      dim.onclick = close;

      const exitFunc = () => {
        if(confirm("정말 나가시겠습니까?")) {
          // Send EXIT message to server (if server ignores, still harmless)
          if (socket && socket.readyState === WebSocket.OPEN) {
            try {
              socket.send(JSON.stringify({ type: "EXIT" }));
            } catch (e) { console.warn("Exit message send failed:", e); }
          }
          // Close WebSocket
          if (socket) {
            socket.close(1000, "leave");
          }
          // Redirect to lobby
          location.replace(CTX + "/main");
        }
      };
      document.getElementById("exitBtn").onclick = exitFunc;
      document.getElementById("surrenderBtn").onclick = exitFunc;
    });
    
    
 // 웹소켓 호출 bgchoi
 /* ======================
   WebSocket 연결
	====================== */
	const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
	const wsUrl = protocol + '//' + window.location.host + CTX + '/game';
	
	// GET 방식으로 넘어온 roomSeq
	const params = new URLSearchParams(window.location.search);
	const roomSeq = params.get('roomSeq');
	
	if (!roomSeq) {
	  alert("roomSeq가 없습니다.");
	}
	
	let socket = null;
	
	function connectWebSocket() {
	  socket = new WebSocket(wsUrl);   // ✅ 1. 생성 먼저
	
	  socket.onopen = () => {
	    console.log("✅ [DIAG] WebSocket OPEN:", wsUrl);
	    console.log("[DIAG] Current state - isPlayer:", isPlayer, "isObserver:", isObserver, "myStone:", myStone);
	
	    const joinMsg = {
	      type: "JOIN_GAME",
	      roomSeq: Number(roomSeq)
	    };
	
	    socket.send(JSON.stringify(joinMsg)); // ✅ 2. 여기서 전송
	    console.log("📤 [DIAG] JOIN_GAME sent - roomSeq:", roomSeq, "msg:", joinMsg);
	  };
	
	  // 서버 응답
	  socket.onmessage = (event) => {
		  const rawData = JSON.parse(event.data);
		  console.log("📩 [DIAG] WS message received:", rawData);

		  const normalized = normalizePayload(rawData);
		  const type = normalized.type;
		  const data = normalized.data;

		  console.log("[DIAG] Message type:", type, "| Keys:", Object.keys(data || {}));

		  switch (type) {

		    case "JOIN_GAME_SUCCESS": {
		      console.log("[DIAG] JOIN_GAME_SUCCESS - blackPlayer:", data.blackPlayer, "whitePlayer:", data.whitePlayer,
		                  "isPlayer:", data.isPlayer, "isObserver:", data.isObserver, "boardSize:", data.boardSize,
		                  "currentTurn:", data.currentTurn, "p1Avatar:", data.p1Avatar, "p2Avatar:", data.p2Avatar);

		      // Game joined - initialize board and player info
		      isPlayer = data.isPlayer || false;
		      isObserver = data.isObserver || false;
		      blackPlayerName = data.blackPlayer || "";
		      whitePlayerName = data.whitePlayer || "";

		      // Determine my stone color
		      if (isPlayer && blackPlayerName === myNickname) myStone = 1;
		      else if (isPlayer && whitePlayerName === myNickname) myStone = 2;
		      else myStone = 0;

		      console.log("[DIAG] Role determined - isPlayer:", isPlayer, "isObserver:", isObserver, "myStone:", myStone);

		      // Update player name UI
		      const p1NameEl = p1Box.querySelector('.player-name');
		      const p2NameEl = p2Box.querySelector('.player-name');
		      if (p1NameEl && blackPlayerName) p1NameEl.textContent = blackPlayerName;
		      if (p2NameEl && whitePlayerName) p2NameEl.textContent = whitePlayerName;

		      // ADD: 아바타 이미지 설정 (서버에서 받은 값 적용)
		      if (data.p1Avatar) {
		        p1Box.style.setProperty('--avatar-img', `url('${CTX}/assets/images/game/player${data.p1Avatar}.png')`);
		      }
		      if (data.p2Avatar) {
		        p2Box.style.setProperty('--avatar-img', `url('${CTX}/assets/images/game/player${data.p2Avatar}.png')`);
		      }

		      // Load initial board state
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

		      // Set turn
		      const serverTurn = data.currentTurn;
		      turn = normalizeTurn(serverTurn, blackPlayerName, whitePlayerName) || 1;
		      updateTurnUI();

		      console.log("✅ JOIN_GAME_SUCCESS - isPlayer:", isPlayer, "myStone:", myStone);

		      // 입장 안내 메시지 출력 (중복 방지)
		      if (blackPlayerName && !announcedJoins.has(blackPlayerName)) {
		        showSystemMessage("흑 : " + blackPlayerName + " 입장했습니다.", ROLE_COLOR.BLACK);
		        announcedJoins.add(blackPlayerName);
		      }
		      if (whitePlayerName && !announcedJoins.has(whitePlayerName)) {
		        showSystemMessage("백 : " + whitePlayerName + " 입장했습니다.", ROLE_COLOR.WHITE);
		        announcedJoins.add(whitePlayerName);
		      }

		      // 턴 안내 메시지 출력 (게임 시작 시 첫 턴)
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
		      // Waiting for second player
		      console.log("⏳ Waiting for another player...");
		      // Optional: show waiting overlay
		      break;
		    }
			case "JOIN_OBSERVER": {
                const { board, blackPlayer, whitePlayer, currentTurn } = data;
                console.log("옵저버일떄 확인" , data);

                // 플레이어 이름 저장
                blackPlayerName = blackPlayer || "";
                whitePlayerName = whitePlayer || "";

                // 전체 보드 상태 초기화
                for (let r = 0; r < board.length; r++) {
                    for (let c = 0; c < board[r].length; c++) {
                        boardState[r][c] = board[r][c];
                        if (board[r][c] !== 0) {
                            placeStone(r, c, board[r][c]);
                        }
                    }
                }
                // 턴 표시
                turn = currentTurn;
                updateTurnUI();

                // 플레이어 정보 등 UI 업데이트 가능
                updatePlayersUI(blackPlayer, whitePlayer);

                // 관전자 입장 안내 (내가 관전자로 들어온 경우)
                if (myNickname && !announcedJoins.has(myNickname)) {
                  showSystemMessage("관전자 : " + myNickname + " 입장했습니다.", ROLE_COLOR.OBSERVER);
                  announcedJoins.add(myNickname);
                }

                break;
            }

		    case "MOVE": {
		      const { row, col, stone, player, currentTurn } = data;
		      console.log("[DIAG] MOVE - row:", row, "col:", col, "stone:", stone, "player:", player, "currentTurn:", currentTurn);

		      // [GUARD] Validate move data
		      if (typeof row !== 'number' || typeof col !== 'number') {
		        console.error("[GUARD] Invalid row/col type:", {row, col});
		        return;
		      }
		      if (row < 0 || row >= BOARD_SIZE || col < 0 || col >= BOARD_SIZE) {
		        console.error("[GUARD] Out of bounds:", {row, col, BOARD_SIZE});
		        return;
		      }
		      if (stone !== 1 && stone !== 2) {
		        console.error("[GUARD] Invalid stone value:", stone);
		        return;
		      }
		      if (!boardState || !boardState[row]) {
		        console.error("[GUARD] boardState not initialized:", {row, col, boardState});
		        return;
		      }

		      // 이미 놓인 돌이면 무시 (중복 방지)
		      if (boardState[row][col] !== 0) {
		        console.log("[DIAG] Cell already occupied, skipping");
		        return;
		      }

		      // UI 반영
		      boardState[row][col] = stone;
		      placeStone(row, col, stone);

		      // Backup: update player names from MOVE if not set yet
		      if (player && stone) {
		        if (stone === 1 && !blackPlayerName) blackPlayerName = player;
		        if (stone === 2 && !whitePlayerName) whitePlayerName = player;
		        const p1NameEl = p1Box.querySelector('.player-name');
		        const p2NameEl = p2Box.querySelector('.player-name');
		        if (p1NameEl && blackPlayerName && p1NameEl.textContent === 'Waiting...') p1NameEl.textContent = blackPlayerName;
		        if (p2NameEl && whitePlayerName && p2NameEl.textContent === 'Waiting...') p2NameEl.textContent = whitePlayerName;
		      }

		      // 턴은 서버 기준으로 정규화 (⭐ nickname or 1/2 handle)
		      turn = normalizeTurn(currentTurn, blackPlayerName, whitePlayerName) || ((turn === 1) ? 2 : 1);
		      updateTurnUI();

		      // Unlock input
		      inputLocked = false;

		      console.log(`🪨 ${player} 가 (${row}, ${col}) 착수, 다음 턴: ${turn}`);

		      // 턴 안내 메시지 (턴이 실제로 바뀔 때만 출력)
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
		      console.log("[DIAG] GAME_OVER - result:", data.result, "message:", data.message);
		      gameActive = false;
		      gameEnded = true;
		      const dim = document.getElementById("gameOverDim");
		      const popup = document.getElementById("gameOverPopup");
		      const title = document.getElementById("gameOverTitle");
		      const msg = document.getElementById("gameOverMessage");

		      if (data.result === "DRAW") {
		        title.textContent = "무승부";
		        msg.textContent = data.message;
		      } else if (data.result === "WIN") {
		        title.textContent = "게임 종료";
		        msg.textContent = data.message;
		      }
		      dim.style.display = "block";
		      popup.style.display = "flex";
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

		    case "NOTIFICATION": {
		      // System notification
		      const notifType = data.notificationType || "INFO";
		      const message = data.message || "";
		      console.log(`🔔 ${notifType}: ${message}`);
		      // Optional: show toast
		      alert(`[${notifType}] ${message}`);
		      break;
		    }

		    case "ERROR": {
		      // Error message
		      const errorMsg = data.message || JSON.stringify(data);
		      console.error("❌ [DIAG] ERROR received - message:", errorMsg, "data:", data);
		      alert("오류: " + errorMsg);
		      inputLocked = false;  // Unlock on error
		      break;
		    }

		    case "EXIT":
		      alert("상대방이 게임을 나갔습니다.");
		      location.href = CTX + "/main";
		      break;

		    default:
		      console.warn("[DIAG] Unknown WS type:", type, "data:", data, "rawData:", rawData);
		  }
		};


	  socket.onclose = (event) => {
	    console.warn("⚠ [DIAG] WebSocket CLOSE - code:", event.code, "reason:", event.reason,
	                 "wasClean:", event.wasClean, "gameEnded:", gameEnded);
	    console.log("[DIAG] State at close - isPlayer:", isPlayer, "isObserver:", isObserver, "myStone:", myStone);

	    if (gameEnded) {
	      // Normal close after game ended
	      console.log("[DIAG] Normal close after game ended");
	    } else {
	      // Abnormal close - opponent may have left
	      /* console.warn("[DIAG] Abnormal close - prompting user to return to lobby");
	      if (confirm("연결이 종료되었습니다. 로비로 돌아가시겠습니까?")) {
	        location.replace(CTX + "/main");
	      } */
	    }
	  };

	  socket.onerror = (err) => {
	    console.error("❌ [DIAG] WebSocket ERROR - gameEnded:", gameEnded, "error:", err);
	    console.log("[DIAG] State at error - isPlayer:", isPlayer, "isObserver:", isObserver, "myStone:", myStone);
	    if (!gameEnded) {
	      alert("연결 오류가 발생했습니다.");
	    }
	  };
	}
	
	// 게임결과 안내창 클릭시 메인 페이지
	document.getElementById("gameOverBtn").onclick = () => {
		  location.href = CTX + "/main";
	};

  </script>
</body>
</html>