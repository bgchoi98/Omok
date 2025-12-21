<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="user.User" %>
<%@ page import="util.Constants" %>
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
    } catch (Exception ignore) {}
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <title>Omok Game Room</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />

  <style>
    /* ===== 튜닝용 변수 (여기서 1px 단위 미세 조정 가능) ===== */
    :root {
      /* board.png(460x455) 기준 격자 시작점과 크기 비율 */
      --grid-left: 9.13%;   /* 좌측 여백 비율 */
      --grid-top: 3.52%;    /* 상단 여백 비율 */
      --grid-width: 81.52%; /* 격자 전체 너비 비율 */
      --grid-height: 94.07%;/* 격자 전체 높이 비율 */

      /* 미세 조정 (화면에서 살짝 밀리면 숫자를 1px, -1px 등으로 변경) */
      --grid-nudge-x: 0px;
      --grid-nudge-y: 0px;
    }

    /* ===== Global Setting ===== */
    * { box-sizing: border-box; }
    body {
      margin: 0;
      width: 100vw;
      height: 100vh;
      overflow: hidden;
      font-family: 'Arial', sans-serif;
      user-select: none;
      background: url('<%=CTX%>/assets/images/game/gameBg.png') no-repeat center/cover;
    }

    /* ===== Main Layout (Grid) ===== */
    .layout {
      display: grid;
      grid-template-columns: 1fr 400px;
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

    /* [1] 보드 프레임 (460 x 455 비율 유지) */
    .board-frame-wrap {
      position: relative;
      height: min(90vh, 90vw);
      aspect-ratio: 460 / 455; 
      filter: drop-shadow(0 15px 35px rgba(0,0,0,0.5));
    }

    .board-frame-img {
      width: 100%;
      height: 100%;
      object-fit: fill;
      pointer-events: none;
      z-index: 1;
    }

    /* [2] 격자판 배치 영역 (수정됨) 
       - 기존: 중앙 정렬
       - 변경: CSS 변수 기반 절대 좌표 배치 (직사각형 대응)
    */
    .board-inner-area {
      position: absolute;
      left: calc(var(--grid-left) + var(--grid-nudge-x));
      top: calc(var(--grid-top) + var(--grid-nudge-y));
      width: var(--grid-width);
      height: var(--grid-height);
      z-index: 2;
    }

    /* board.png 자체에 선이 있다면, 이 이미지는 숨김 처리 */
    .grid-img {
      display: none; 
      /* 만약 별도 격자 이미지를 써야 한다면 display: block; width:100%; height:100%; fill; */
    }

    /* [3] 클릭 및 돌 배치 레이어 */
    .board-hit {
      position: relative; /* 자식(돌)의 기준점이 됨 */
      width: 100%; 
      height: 100%;
      cursor: pointer;
      z-index: 10;
    }

    /* 돌 스타일 */
    .stone, .ghost-stone {
      position: absolute;
      /* 중요: 돌의 중심점이 좌표가 되도록 변환 */
      transform: translate(-50%, -50%); 
      pointer-events: none;
      filter: drop-shadow(3px 4px 4px rgba(0,0,0,0.4));
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
      filter: drop-shadow(0 4px 4px rgba(0,0,0,0.3));
    }
    .exit-btn:hover { transform: scale(1.05); }

    .chat-panel {
      flex: 1;
      position: relative;
      background: url('<%=CTX%>/assets/images/game/chatBox.png') no-repeat center/100% 100%;
      min-height: 250px;
      filter: drop-shadow(0 8px 16px rgba(0,0,0,0.2));
    }
    .chat-scroll {
      position: absolute;
      top: 12%; bottom: 15%;
      left: 10%; right: 10%;
      overflow-y: auto;
      padding-right: 5px;
      font-size: 15px;
      font-weight: bold;
      color: #3e2723;
      line-height: 1.5;
    }
    .chat-scroll::-webkit-scrollbar { width: 6px; }
    .chat-scroll::-webkit-scrollbar-thumb { background: rgba(62, 39, 35, 0.5); border-radius: 10px; }

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
      background: url('<%=CTX%>/assets/images/game/playerBox.png') no-repeat center/100% 100%;
      display: flex;
      flex-direction: column;
      justify-content: center;
      padding-left: 75px; 
      padding-right: 10px;
      color: #3e2723;
      filter: drop-shadow(0 4px 6px rgba(0,0,0,0.2));
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
      filter: drop-shadow(0 4px 6px rgba(0,0,0,0.3));
    }
    .config-btn:hover { transform: rotate(30deg) scale(1.1); }

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
      top: 50%; left: 50%;
      transform: translate(-50%, -50%);
      width: 400px; height: 320px;
      background: url('<%=CTX%>/assets/images/main/ConfigPopUp/configureBox.png') no-repeat center/contain;
      display: none;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      z-index: 101;
      filter: drop-shadow(0 10px 20px rgba(0,0,0,0.5));
    }
    .close-popup-btn {
      position: absolute;
      top: 45px; right: 30px;
      width: 30px; height: 30px;
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
    .surrender-btn:hover { background: #3e2723; transform: scale(1.05); }

    @media (max-width: 1000px) {
      .layout {
        grid-template-columns: 1fr;
        grid-template-rows: auto 1fr;
        overflow-y: auto;
      }
      body { overflow: auto; }
      .left-col { margin-bottom: 20px; }
      .right-col { height: auto; }
    }
  </style>
</head>

<body>
  <div class="game-bg"></div>

  <div class="layout">
    <div class="left-col">
      <div class="board-frame-wrap" id="boardFrame">
        <img src="<%=CTX%>/assets/images/game/board.png" class="board-frame-img" alt="Frame" />
        
        <div class="board-inner-area" id="boardInner">
          <img src="<%=CTX%>/assets/images/game/gameBoard.png" class="grid-img" alt="Grid" />
          
          <div id="boardHit" class="board-hit">
            <img id="ghostStone" class="ghost-stone" src="<%=CTX%>/assets/images/game/stone_1.png" alt="" />
          </div>
        </div>
      </div>
    </div>

    <div class="right-col">
      <div class="right-top">
        <img id="exitBtn" class="exit-btn" src="<%=CTX%>/assets/images/game/getOut.png" alt="Exit" />
      </div>

      <div class="chat-panel">
        <div class="chat-scroll" id="chatScroll">
          <div><span style="color:#d32f2f;">System:</span> 게임에 입장했습니다.</div>
          <div><span style="color:#d32f2f;">System:</span> 즐거운 대국 되세요!</div>
        </div>
      </div>

      <div class="right-bottom">
        <div class="players-container">
          <div class="player-box turn-active" id="p1Box">
            <div class="player-name"><%= nickName %></div>
            <div class="player-score">Wins: <%= win %></div>
          </div>
          <div class="player-box" id="p2Box">
            <div class="player-name">Waiting...</div>
            <div class="player-score">-</div>
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
    <button id="closePopupBtn" class="close-popup-btn">X</button>
    <div class="popup-content">
      <h2 style="color:#3e2723; margin-bottom: 20px;">Game Settings</h2>
      <button id="surrenderBtn" class="surrender-btn">기권 / 나가기</button>
    </div>
  </div>

  <script>
    const CTX = "<%=CTX%>";
    const IMG = {
      black: CTX + "/assets/images/game/stone_1.png",
      white: CTX + "/assets/images/game/stone_2.png",
    };

    // 오목판 격자 (15줄 = 14칸 간격)
    const BOARD_SIZE = 15; 
    const LINES = 14; 

    let turn = 1; // 1: 흑, 2: 백
    let gameActive = true;
    let boardState = Array.from({ length: BOARD_SIZE }, () => Array(BOARD_SIZE).fill(0));

    const boardHit   = document.getElementById("boardHit");
    const ghostEl    = document.getElementById("ghostStone");
    const p1Box      = document.getElementById("p1Box");
    const p2Box      = document.getElementById("p2Box");

    // 가로/세로 간격을 각각 저장 (직사각형 격자 대응)
    let gapX = 0;
    let gapY = 0;
    let stoneSize = 0;

    // 1. 그리드 수치 계산 (가로/세로 독립 계산)
    function recalcMetrics() {
      const width = boardHit.clientWidth;
      const height = boardHit.clientHeight;

      // 가로, 세로 간격 독립 계산
      gapX = width / LINES;
      gapY = height / LINES;
      
      // 돌 크기는 칸의 약 92% (가로/세로 중 작은 쪽 기준)
      stoneSize = Math.min(gapX, gapY) * 0.92; 
      
      ghostEl.style.width = stoneSize + "px";
      ghostEl.style.height = stoneSize + "px";
    }

    // 2. 좌표 변환 (Pixel -> Grid Index)
    function getGridPos(e) {
      const rect = boardHit.getBoundingClientRect();
      const x = e.clientX - rect.left;
      const y = e.clientY - rect.top;

      // X는 gapX로, Y는 gapY로 나눔
      const col = Math.round(x / gapX);
      const row = Math.round(y / gapY);

      // 범위 체크 (0 ~ 14)
      if (col < 0 || col >= BOARD_SIZE || row < 0 || row >= BOARD_SIZE) {
        return null;
      }
      return { row, col };
    }

    // 3. 요소 위치 설정 헬퍼 (Grid Index -> Pixel)
    function setElementPos(element, row, col) {
      element.style.left = (col * gapX) + "px";
      element.style.top  = (row * gapY) + "px";
    }

    // 4. 돌 놓기 (UI)
    function placeStone(row, col, player) {
      const stone = document.createElement("img");
      stone.src = (player === 1) ? IMG.black : IMG.white;
      stone.className = "stone";
      
      stone.style.width = stoneSize + "px";
      stone.style.height = stoneSize + "px";

      // 위치 설정 (X/Y 개별 간격 적용)
      setElementPos(stone, row, col);

      // 랜덤 회전 (자연스럽게)
      const deg = Math.random() * 40 - 20;
      stone.style.transform = `translate(-50%, -50%) rotate(${deg}deg)`;

      boardHit.appendChild(stone);
    }

    // 5. 마우스 이동 (Ghost Stone)
    function onMouseMove(e) {
      if (!gameActive) return;
      const pos = getGridPos(e);
      
      if (!pos || boardState[pos.row][pos.col] !== 0) {
        ghostEl.style.display = "none";
        return;
      }

      ghostEl.style.display = "block";
      ghostEl.src = (turn === 1) ? IMG.black : IMG.white;
      
      // 고스트 스톤 위치 업데이트
      setElementPos(ghostEl, pos.row, pos.col);
    }

    // 6. 클릭 (착수)
    function onBoardClick(e) {
      if (!gameActive) return;
      const pos = getGridPos(e);

      if (!pos || boardState[pos.row][pos.col] !== 0) return;

      boardState[pos.row][pos.col] = turn;
      placeStone(pos.row, pos.col, turn);

      turn = (turn === 1) ? 2 : 1;
      updateTurnUI();
      // 클릭 후 마우스가 제자리에 있을 때 고스트 갱신
      onMouseMove(e);
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

    window.addEventListener("load", () => {
      // 레이아웃 확정 후 계산을 위해 프레임 요청
      requestAnimationFrame(() => {
        recalcMetrics();
      });
      window.addEventListener("resize", recalcMetrics);

      boardHit.addEventListener("mousemove", onMouseMove);
      boardHit.addEventListener("mouseleave", () => { ghostEl.style.display = "none"; });
      boardHit.addEventListener("click", onBoardClick);

      // 팝업 로직
      const dim = document.getElementById("dimLayer");
      const popup = document.getElementById("configPopup");
      document.getElementById("configBtn").onclick = () => { dim.style.display="block"; popup.style.display="flex"; };
      const close = () => { dim.style.display="none"; popup.style.display="none"; };
      document.getElementById("closePopupBtn").onclick = close;
      dim.onclick = close;

      const exitFunc = () => { if(confirm("정말 나가시겠습니까?")) location.href = CTX + "/main"; };
      document.getElementById("exitBtn").onclick = exitFunc;
      document.getElementById("surrenderBtn").onclick = exitFunc;
    });
  </script>
</body>
</html>