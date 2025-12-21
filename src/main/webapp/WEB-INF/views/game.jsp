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
    /* ===== 튜닝용 변수 (board.png: 460x455, gameBoard.png: 375x375 정확 매칭) ===== */
    :root {
      /* ✅ board(460x455) 안에 gameBoard(375x375)가 정확히 들어가는 비율 */
      --grid-left: 9.239130%;   /* 42.5 / 460 */
      --grid-top:  8.791209%;   /* 40 / 455 */
      --grid-width: 81.521739%; /* 375 / 460 */
      --grid-height: 82.417582%;/* 375 / 455 */

      /* 미세 조정 (필요하면 1~2px) */
      --grid-nudge-x: 0px;
      --grid-nudge-y: 0px;
    }

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
      grid-template-columns: 1fr 400px; /* 왼쪽: 보드, 오른쪽: 패널 */
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

    /* ✅ 오른쪽 패널 400px을 고려해 보드가 과도하게 커지지 않게 */
    .board-frame-wrap {
      position: relative;
      width: min(calc(100vw - 400px - 60px), 90vh);
      height: min(calc(100vw - 400px - 60px), 90vh);
      aspect-ratio: 460 / 455;
      filter: drop-shadow(0 15px 35px rgba(0,0,0,0.5));
    }

    .board-frame-img {
      width: 100%;
      height: 100%;
      object-fit: contain; /* ✅ fill 금지: 왜곡 방지 */
      pointer-events: none;
      z-index: 1;
      display: block;
    }

    /* ✅ gameBoard가 들어갈 "프레임 내부 영역" */
    .board-inner-area {
      position: absolute;
      left: calc(var(--grid-left) + var(--grid-nudge-x));
      top:  calc(var(--grid-top)  + var(--grid-nudge-y));
      width: var(--grid-width);
      height: var(--grid-height);
      z-index: 2;
    }

    /* 필요하면 보이게(현재는 프레임에 격자가 있으니 숨김) */
    .grid-img {
      display: none;
      width: 100%;
      height: 100%;
      object-fit: cover;
      pointer-events: none;
      user-select: none;
    }

    /* ✅ 클릭/돌 배치 영역: 오직 gameBoard(375x375) 영역만 */
    .board-hit {
      position: relative;
      width: 100%;
      height: 100%;
      cursor: pointer;
      z-index: 10;
    }

    /* 돌 스타일 */
    .stone, .ghost-stone {
      position: absolute;
      transform: translate(-50%, -50%); /* 중심 정렬 */
      pointer-events: none;
      filter: drop-shadow(3px 4px 4px rgba(0,0,0,0.4));
      will-change: transform;
    }

    .ghost-stone {
      opacity: 0.6;
      display: none;
      z-index: 11;
    }

    /* ===== Right Panel ===== */
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

    /* 반응형 */
    @media (max-width: 1000px) {
      .layout {
        grid-template-columns: 1fr;
        grid-template-rows: auto 1fr;
        overflow-y: auto;
      }
      body { overflow: auto; }
      .left-col { margin-bottom: 20px; }
      .right-col { height: auto; }
      .board-frame-wrap{
        width: min(90vw, 90vh);
        height: min(90vw, 90vh);
      }
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
          <!-- 프레임에 격자가 이미 있으면 숨김 유지 -->
          <img src="<%=CTX%>/assets/images/game/gameBoard.png" class="grid-img" alt="Grid" />

          <!-- ✅ 이 영역이 gameBoard(375x375)와 정확히 매칭되는 클릭/돌 영역 -->
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

    // ✅ 교차점 15개(=줄 15개) => 간격은 14칸
    const BOARD_SIZE = 15; // 인덱스 0~14
    const LINES = 14;      // 칸 수(간격 수)

    let turn = 1;
    let gameActive = true;
    let boardState = Array.from({ length: BOARD_SIZE }, () => Array(BOARD_SIZE).fill(0));

    const boardHit = document.getElementById("boardHit");
    const ghostEl  = document.getElementById("ghostStone");
    const p1Box    = document.getElementById("p1Box");
    const p2Box    = document.getElementById("p2Box");

    // ✅ 정사각 격자: gap 하나만 사용
    let gap = 0;
    let stoneSize = 0;

    function recalcMetrics() {
      // boardHit는 gameBoard(375x375) 영역에 정확히 매칭되어 있음
      const width = boardHit.clientWidth;

      gap = width / LINES;         // 14칸
      stoneSize = gap * 0.92;

      ghostEl.style.width = stoneSize + "px";
      ghostEl.style.height = stoneSize + "px";
    }

    function getGridPos(e) {
      const rect = boardHit.getBoundingClientRect();
      const x = e.clientX - rect.left;
      const y = e.clientY - rect.top;

      const col = Math.round(x / gap);
      const row = Math.round(y / gap);

      if (col < 0 || col >= BOARD_SIZE || row < 0 || row >= BOARD_SIZE) return null;
      return { row, col };
    }

    function setElementPos(element, row, col) {
      element.style.left = (col * gap) + "px";
      element.style.top  = (row * gap) + "px";
    }

    function placeStone(row, col, player) {
      const stone = document.createElement("img");
      stone.src = (player === 1) ? IMG.black : IMG.white;
      stone.className = "stone";

      stone.style.width = stoneSize + "px";
      stone.style.height = stoneSize + "px";

      setElementPos(stone, row, col);

      const deg = Math.random() * 40 - 20;
      stone.style.transform = `translate(-50%, -50%) rotate(${deg}deg)`;

      boardHit.appendChild(stone);
    }

    function onMouseMove(e) {
      if (!gameActive) return;

      const pos = getGridPos(e);
      if (!pos || boardState[pos.row][pos.col] !== 0) {
        ghostEl.style.display = "none";
        return;
      }

      ghostEl.style.display = "block";
      ghostEl.src = (turn === 1) ? IMG.black : IMG.white;
      setElementPos(ghostEl, pos.row, pos.col);
    }

    function onBoardClick(e) {
      if (!gameActive) return;

      const pos = getGridPos(e);
      if (!pos || boardState[pos.row][pos.col] !== 0) return;

      boardState[pos.row][pos.col] = turn;
      placeStone(pos.row, pos.col, turn);

      turn = (turn === 1) ? 2 : 1;
      updateTurnUI();
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
      // ✅ 레이아웃 확정 후 계산
      requestAnimationFrame(() => recalcMetrics());
      window.addEventListener("resize", recalcMetrics);

      boardHit.addEventListener("mousemove", onMouseMove);
      boardHit.addEventListener("mouseleave", () => { ghostEl.style.display = "none"; });
      boardHit.addEventListener("click", onBoardClick);

      // 팝업 로직
      const dim = document.getElementById("dimLayer");
      const popup = document.getElementById("configPopup");

      document.getElementById("configBtn").onclick = () => {
        dim.style.display = "block";
        popup.style.display = "flex";
      };

      const close = () => {
        dim.style.display = "none";
        popup.style.display = "none";
      };

      document.getElementById("closePopupBtn").onclick = close;
      dim.onclick = close;

      const exitFunc = () => {
        if (confirm("정말 나가시겠습니까?")) location.href = CTX + "/main";
      };
      document.getElementById("exitBtn").onclick = exitFunc;
      document.getElementById("surrenderBtn").onclick = exitFunc;
    });
  </script>
</body>
</html>
