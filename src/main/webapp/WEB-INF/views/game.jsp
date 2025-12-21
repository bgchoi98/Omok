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
    try { nickName = user.getNickname(); } catch (Exception ignore) {}
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <title>Omok Game Room</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />

  <style>
    /* ===== Global ===== */
    * { box-sizing: border-box; }
    body {
      margin: 0;
      width: 100vw;
      height: 100vh;
      overflow: hidden;
      font-family: system-ui, -apple-system, Segoe UI, Roboto, "Noto Sans KR", Arial, sans-serif;
      user-select: none;
    }

    .game-bg {
      position: fixed;
      inset: 0;
      background: url('<%=CTX%>/assets/images/game/gameBg.png') no-repeat center/cover;
      z-index: -1;
    }

    /* ===== Layout: 좌(보드) / 우(패널) ===== */
    .layout {
      position: relative;
      width: 100%;
      height: 100%;
      display: grid;
      grid-template-columns: minmax(620px, 1fr) minmax(380px, 520px);
      gap: 18px;
      padding: 22px;
      align-items: stretch; /* ✅ 양쪽 세로 꽉 채움 */
    }

    @media (max-width: 1100px) {
      .layout {
        grid-template-columns: 1fr;
        grid-template-rows: auto 1fr;
        height: auto;
        overflow: auto;
      }
      body { overflow: auto; }
    }

    /* ===== Left: Board only ===== */
    .left-col {
      display: flex;
      align-items: center;
      justify-content: center;
      min-height: 0;
    }

    /* ===== Board (img + overlay) ===== */
    .board-wrap {
      position: relative;
      width: min(880px, 78vmin);
      aspect-ratio: 1 / 1;
      filter: drop-shadow(0 18px 34px rgba(0,0,0,0.42));
    }

    .board-img {
      position: absolute;
      inset: 0;
      width: 100%;
      height: 100%;
      object-fit: contain;
      pointer-events: none;
    }

    .board-hit {
      position: absolute;
      left: 0; top: 0;
      width: 100%; height: 100%;
      cursor: pointer;
    }

    .stone, .ghost-stone {
      position: absolute;
      transform: translate(-50%, -50%);
      pointer-events: none;
      filter: drop-shadow(2px 4px 6px rgba(0,0,0,0.4));
      will-change: transform;
    }

    .ghost-stone {
      opacity: 0.55;
      display: none;
    }

    /* ===== Right: (top exit) + (chat) + (bottom players+config) ===== */
    .right-col {
      height: 100%;
      display: flex;
      flex-direction: column;
      gap: 14px;
      min-height: 0;
    }

    .right-top {
      display: flex;
      justify-content: flex-end;
      align-items: flex-start;
    }

    .exit-btn {
      width: 110px;
      height: auto;
      cursor: pointer;
      transition: transform 0.18s ease;
      filter: drop-shadow(0 8px 14px rgba(0,0,0,0.25));
    }
    .exit-btn:hover { transform: scale(1.06); }

    .chat-panel {
      position: relative;
      flex: 1;              /* ✅ 중간에서 늘어나는 영역 */
      min-height: 420px;
      background: url('<%=CTX%>/assets/images/game/chatBox.png') no-repeat center/contain;
      filter: drop-shadow(0 10px 22px rgba(0,0,0,0.25));
    }

    .chat-scroll {
      position: absolute;
      inset: 10% 10% 18% 10%;
      overflow: auto;
      padding: 8px 10px;
      font-size: 18px;
      line-height: 1.5;
      color: #2f2f2f;
    }

    /* ✅ 아래: 플레이어1 / 플레이어2 / 설정 버튼 */
    .right-bottom {
      display: grid;
      grid-template-columns: 1fr 1fr auto;
      gap: 12px;
      align-items: end;
    }

    .player-box {
      height: 120px;
      background: url('<%=CTX%>/assets/images/game/playerBox.png') no-repeat center/contain;
      display: flex;
      flex-direction: column;
      justify-content: center;
      padding-left: 100px;
      color: #333;
      font-weight: 800;
      filter: drop-shadow(0 6px 12px rgba(0,0,0,0.28));
      transition: transform 0.18s ease;
    }
    .player-box:hover { transform: scale(1.02); }

    .player-name {
      font-size: 1.05rem;
      margin-bottom: 6px;
      color: #4e342e;
    }
    .player-score {
      font-size: 0.92rem;
      color: #6b6b6b;
      font-weight: 700;
    }

    .turn-active {
      filter: drop-shadow(0 0 16px rgba(255, 215, 0, 0.9)) !important;
    }

    .config-btn {
      width: 64px;
      height: auto;
      cursor: pointer;
      transition: transform 0.25s ease;
      filter: drop-shadow(0 8px 14px rgba(0,0,0,0.25));
      margin-bottom: 8px; /* 버튼 살짝 위로 */
    }
    .config-btn:hover { transform: rotate(90deg); }

    /* ===== Config Popup ===== */
    .dim-layer {
      position: fixed;
      inset: 0;
      background: rgba(0, 0, 0, 0.65);
      display: none;
      z-index: 100;
    }

    .config-popup {
      position: fixed;
      left: 50%;
      top: 50%;
      transform: translate(-50%, -50%);
      width: min(420px, 92vw);
      height: min(320px, 70vh);
      background: url('<%=CTX%>/assets/images/main/ConfigPopUp/configureBox.png') no-repeat center/contain;
      z-index: 101;
      display: none; /* show -> flex */
      align-items: center;
      justify-content: center;
    }

    .config-inner {
      width: 80%;
      text-align: center;
    }

    .close-popup-btn {
      position: absolute;
      top: 14px;
      right: 18px;
      width: 40px;
      height: 40px;
      border: none;
      border-radius: 12px;
      cursor: pointer;
      background: rgba(0,0,0,0.45);
      color: #fff;
      font-size: 18px;
      font-weight: 900;
    }
  </style>
</head>

<body>
  <div class="game-bg" aria-hidden="true"></div>

  <main class="layout">
    <!-- LEFT : Board -->
    <section class="left-col">
      <div class="board-wrap" id="boardWrap" aria-label="Omok Board">
        <img
          id="boardImg"
          class="board-img"
          src="<%=CTX%>/assets/images/game/board.png"
          alt=""
          aria-hidden="true"
        />

        <div class="board-hit" id="boardHit" role="application" aria-label="Board Interaction Layer">
          <img
            id="ghostStone"
            class="ghost-stone"
            src="<%=CTX%>/assets/images/game/stone_1.png"
            alt=""
            aria-hidden="true"
          />
        </div>
      </div>
    </section>

    <!-- RIGHT : Exit(top) / Chat(mid) / Players+Config(bottom) -->
    <aside class="right-col">
      <div class="right-top">
        <img
          src="<%=CTX%>/assets/images/game/getOut.png"
          class="exit-btn"
          id="exitBtn"
          alt="Exit"
        />
      </div>

      <div class="chat-panel" aria-label="Chat panel">
        <div class="chat-scroll" id="chatScroll">
          <div style="color:red; font-weight:800;">Hi</div>
          <div style="color:blue; font-weight:800;">Hi</div>
          <div style="color:red; font-weight:800;">Ok.</div>
          <div style="color:blue; font-weight:800;">Nice to Meet you</div>
        </div>
      </div>

      <div class="right-bottom">
        <div class="player-box turn-active" id="p1Box">
          <div class="player-name"><%= nickName %></div>
          <div class="player-score">Wins: <%= win %> / Loses: <%= lose %></div>
        </div>

        <div class="player-box" id="p2Box">
          <div class="player-name">Waiting...</div>
          <div class="player-score">-</div>
        </div>

        <img
          src="<%=CTX%>/assets/images/game/configureIcon.png"
          class="config-btn"
          id="configBtn"
          alt="Config"
        />
      </div>
    </aside>
  </main>

  <!-- Config Popup -->
  <div class="dim-layer" id="dimLayer"></div>
  <div class="config-popup" id="configPopup" role="dialog" aria-modal="true" aria-label="Game Settings">
    <button class="close-popup-btn" id="closePopupBtn" type="button">X</button>
    <div class="config-inner">
      <h2 style="color:#4e342e; margin: 0 0 14px;">Game Settings</h2>
      <button id="surrenderBtn" type="button" style="padding:10px 20px; cursor:pointer;">
        Surrender / Exit
      </button>
    </div>
  </div>

  <script>
    const CTX = "<%=CTX%>";
    const IMG = {
      black: CTX + "/assets/images/game/stone_1.png",
      white: CTX + "/assets/images/game/stone_2.png",
    };

    // ✅ 돌 위치/크기 조정은 여기만 만지면 됨
    const BOARD_TUNE = {
      size: 19,
      padXRatio: 0.06,
      padYRatio: 0.06,
      offsetX: 0,
      offsetY: 0,
      stoneScale: 0.85,
    };

    let turn = 1;
    let gameActive = true;
    let boardState = Array.from({ length: BOARD_TUNE.size }, () => Array(BOARD_TUNE.size).fill(0));

    const boardWrap = document.getElementById("boardWrap");
    const boardImg  = document.getElementById("boardImg");
    const boardHit  = document.getElementById("boardHit");
    const ghostEl   = document.getElementById("ghostStone");
    const p1Box     = document.getElementById("p1Box");
    const p2Box     = document.getElementById("p2Box");

    const exitBtn        = document.getElementById("exitBtn");
    const configBtn      = document.getElementById("configBtn");
    const dimLayer       = document.getElementById("dimLayer");
    const configPopup    = document.getElementById("configPopup");
    const closePopupBtn  = document.getElementById("closePopupBtn");
    const surrenderBtn   = document.getElementById("surrenderBtn");

    const metrics = {
      hitW: 0, hitH: 0,
      padX: 0, padY: 0,
      cellX: 0, cellY: 0,
      stone: 32,
    };

    function syncHitAreaToBoardImage() {
      const wrapRect = boardWrap.getBoundingClientRect();
      const imgRect  = boardImg.getBoundingClientRect();

      const left = imgRect.left - wrapRect.left;
      const top  = imgRect.top  - wrapRect.top;

      boardHit.style.left = left + "px";
      boardHit.style.top  = top + "px";
      boardHit.style.width  = imgRect.width + "px";
      boardHit.style.height = imgRect.height + "px";

      metrics.hitW = imgRect.width;
      metrics.hitH = imgRect.height;
    }

    function recalcGridMetrics() {
      metrics.padX = Math.round(metrics.hitW * BOARD_TUNE.padXRatio) + BOARD_TUNE.offsetX;
      metrics.padY = Math.round(metrics.hitH * BOARD_TUNE.padYRatio) + BOARD_TUNE.offsetY;

      metrics.cellX = (metrics.hitW - metrics.padX * 2) / (BOARD_TUNE.size - 1);
      metrics.cellY = (metrics.hitH - metrics.padY * 2) / (BOARD_TUNE.size - 1);

      const cellMin = Math.min(metrics.cellX, metrics.cellY);
      metrics.stone = Math.max(18, Math.round(cellMin * BOARD_TUNE.stoneScale));
    }

    function pxToGrid(x, y) {
      const col = Math.round((x - metrics.padX) / metrics.cellX);
      const row = Math.round((y - metrics.padY) / metrics.cellY);
      if (col < 0 || col >= BOARD_TUNE.size || row < 0 || row >= BOARD_TUNE.size) return null;
      return { row, col };
    }

    function gridToPx(row, col) {
      return {
        x: metrics.padX + col * metrics.cellX,
        y: metrics.padY + row * metrics.cellY,
      };
    }

    function setTurn(nextTurn) {
      turn = nextTurn;
      if (turn === 1) {
        p1Box.classList.add("turn-active");
        p2Box.classList.remove("turn-active");
      } else {
        p1Box.classList.remove("turn-active");
        p2Box.classList.add("turn-active");
      }
    }

    function showGhost(row, col) {
      const { x, y } = gridToPx(row, col);
      ghostEl.style.left = x + "px";
      ghostEl.style.top  = y + "px";
      ghostEl.style.width  = metrics.stone + "px";
      ghostEl.style.height = metrics.stone + "px";
      ghostEl.src = (turn === 1) ? IMG.black : IMG.white;
      ghostEl.style.display = "block";
    }

    function hideGhost() { ghostEl.style.display = "none"; }

    function createStone(row, col, player) {
      const stone = document.createElement("img");
      stone.className = "stone";
      stone.alt = "";
      stone.setAttribute("aria-hidden", "true");
      stone.src = (player === 1) ? IMG.black : IMG.white;

      const { x, y } = gridToPx(row, col);
      stone.style.left = x + "px";
      stone.style.top  = y + "px";
      stone.style.width  = metrics.stone + "px";
      stone.style.height = metrics.stone + "px";

      const rotation = Math.random() * 360;
      stone.style.transform = `translate(-50%, -50%) rotate(${rotation}deg)`;

      boardHit.appendChild(stone);
    }

    function onBoardMove(e) {
      if (!gameActive) return;
      const rect = boardHit.getBoundingClientRect();
      const x = e.clientX - rect.left;
      const y = e.clientY - rect.top;

      const pos = pxToGrid(x, y);
      if (!pos) return hideGhost();

      const { row, col } = pos;
      if (boardState[row][col] !== 0) return hideGhost();
      showGhost(row, col);
    }

    function onBoardLeave() { hideGhost(); }

    function onBoardClick(e) {
      if (!gameActive) return;

      const rect = boardHit.getBoundingClientRect();
      const x = e.clientX - rect.left;
      const y = e.clientY - rect.top;

      const pos = pxToGrid(x, y);
      if (!pos) return;

      const { row, col } = pos;
      if (boardState[row][col] !== 0) return;

      boardState[row][col] = turn;
      createStone(row, col, turn);

      setTurn(turn === 1 ? 2 : 1);
      onBoardMove(e);
    }

    function openConfig() {
      dimLayer.style.display = "block";
      configPopup.style.display = "flex";
    }

    function closeConfig() {
      dimLayer.style.display = "none";
      configPopup.style.display = "none";
    }

    function exitGame() {
      if (!confirm("정말 나갈까요?")) return;
      location.href = CTX + "/main";
    }

    function recalcAll() {
      syncHitAreaToBoardImage();
      recalcGridMetrics();
      hideGhost();
    }

    function init() {
      setTurn(1);

      if (boardImg.complete) recalcAll();
      else boardImg.addEventListener("load", recalcAll);

      boardHit.addEventListener("mousemove", onBoardMove);
      boardHit.addEventListener("mouseleave", onBoardLeave);
      boardHit.addEventListener("click", onBoardClick);

      configBtn.addEventListener("click", openConfig);
      dimLayer.addEventListener("click", closeConfig);
      closePopupBtn.addEventListener("click", closeConfig);

      exitBtn.addEventListener("click", exitGame);
      surrenderBtn.addEventListener("click", exitGame);

      window.addEventListener("resize", recalcAll);
    }

    document.addEventListener("DOMContentLoaded", init);
  </script>
</body>
</html>
