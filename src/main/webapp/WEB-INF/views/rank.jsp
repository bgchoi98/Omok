<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>
<%@ page import="rank.Rank" %>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%
  if (request.getAttribute("ranks") == null) {
    List<Rank> ranks = new ArrayList<>();
    try {
      ranks.add(new Rank(0L, 12, 2, "Tomas"));
      ranks.add(new Rank(0L, 10, 5, "Scott"));
      ranks.add(new Rank(0L, 8,  4, "Allen"));
      ranks.add(new Rank(0L, 7,  7, "Kate"));
      ranks.add(new Rank(0L, 5,  3, "James"));
      ranks.add(new Rank(0L, 4, 10, "Alice"));
      ranks.add(new Rank(0L, 3,  2, "Bob"));
      ranks.add(new Rank(0L, 2,  8, "Sam"));
      ranks.add(new Rank(0L, 1, 12, "Mike"));
      ranks.add(new Rank(0L, 0, 15, "Zoe"));
    } catch (Exception e) { e.printStackTrace(); }
    request.setAttribute("ranks", ranks);
  }
%>

<c:set var="ctx" value="${pageContext.request.contextPath}" />

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <title>Omok Ranking</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <link href="https://fonts.googleapis.com/css2?family=Patrick+Hand&display=swap" rel="stylesheet">

  <style>
    :root{
      --shadow: 0 20px 40px rgba(0,0,0,0.5);
      --ink: #5d4037;
      --ink-strong: #3e2723;

      /* rankingPaper.png 실제 비율 */
      --paper-rw: 587;
      --paper-rh: 425;

      /* 화면에 맞춰 최대 크기 */
      --paper-max-w: 1400px;
      --paper-fit-vw: 96vw;
      --paper-fit-vh: 86vh;

      /* 종이 1.2배 + 약간 위로 */
      --paper-scale: 1.2;
      --paper-shift-y: -30px;

      /* ✅ 타이틀/순위 전체를 "살짝 왼쪽" (여기만 미세조정하면 됨) */
      --ui-shift-x: -8px;

      /* JS가 계산해서 넣는 값 */
      --pad-top: 18px;
      --pad-x: 18px;
      --pad-bottom: 16px;

      --scroll-top: 10px;
      --scroll-right: 8px;
      --scroll-h: 200px;
      --track-w: 18px;
    }

    * { margin:0; padding:0; box-sizing:border-box; user-select:none; }

    body{
      width:100vw; height:100vh;
      overflow:hidden;
      background: none;              /* ✅ 실제 배경은 ::before로 깔 거라 제거 */
      font-family: 'Patrick Hand', cursive, sans-serif;
      position:relative;

      display:flex;
      justify-content:center;
      align-items:flex-start;
      padding-top: 28px;

      isolation: isolate;            /* ✅ 배경 레이어링 안전하게 */
    }

    /* ✅ 배경 불투명도 75% */
    body::before{
      content:"";
      position: fixed;
      inset: 0;
      background: url('${ctx}/assets/images/rank/rankingBg.png') no-repeat center/cover;
      opacity: 0.75;
      z-index: 0;
      pointer-events: none;
    }

    .back-btn{
      position:absolute;
      top: 22px;
      left: 22px;
      width: clamp(140px, 12vw, 230px);
      height:auto;
      cursor:pointer;
      z-index: 2;
      transition: transform .2s;
      filter: drop-shadow(0 10px 18px rgba(0,0,0,0.25));
    }
    .back-btn:hover{ transform: scale(1.08); }

    .paper-wrap{
      position: relative;
      z-index: 1;

      width: min(
        var(--paper-max-w),
        var(--paper-fit-vw),
        calc(var(--paper-fit-vh) * var(--paper-rw) / var(--paper-rh))
      );
      aspect-ratio: var(--paper-rw) / var(--paper-rh);
      height: auto;

      filter: drop-shadow(var(--shadow));
      transform: translateY(var(--paper-shift-y)) scale(var(--paper-scale));
      transform-origin: top center;

      overflow: hidden;
    }

    .paper-img{
      position:absolute;
      inset:0;
      width:100%;
      height:100%;
      object-fit: contain;
      pointer-events:none;
    }

    .paper-ui{
      position:absolute;
      left:0; top:0;
      width:100%; height:100%;
      overflow:hidden;

      display:flex;
      flex-direction: column;
      align-items: stretch;
      padding: var(--pad-top) var(--pad-x) var(--pad-bottom);

      /* ✅ 전체를 왼쪽으로 조금 */
      transform: translateX(var(--ui-shift-x));
    }

    /* ✅ 타이틀: 상단 중앙 + 종이 안쪽 */
    .title{
      width:100%;
      text-align:center;
      font-size: clamp(1.85rem, 2.55vw, 2.7rem);
      color: var(--ink-strong);
      margin: 2px 0 8px;
      text-shadow: 2px 2px 0 rgba(255,255,255,0.4);
      pointer-events:none;
      line-height: 1.05;
    }

    .list-wrapper{
      width:100%;
      flex:1;
      min-height:0;
      overflow-y:auto;
      overflow-x:hidden;
      scrollbar-width:none;
    }
    .list-wrapper::-webkit-scrollbar{ width:0; height:0; }

    /* ✅ 오른쪽 여백(스크롤바 자리) 너무 많이 먹지 않게 줄임 */
    .rank-list{
      width:100%;
      display:flex;
      flex-direction: column;
      gap: 8px;
      padding-right: 34px; /* <- 기존 46px에서 줄임 */
    }

    /* ✅ 종이 안에 "무조건" 들어가게 더 타이트하게 */
    .rank-item{
      width:100%;
      display:grid;
      grid-template-columns: 40px minmax(0, 1fr) 70px; /* 등수 / 닉 / 승패 */
      column-gap: 6px;
      align-items:center;

      font-size: clamp(0.95rem, 1.35vw, 1.18rem);
      color: var(--ink);

      padding: 2px 0 4px;
      border-bottom: 2px dashed rgba(93,64,55,0.28);
    }
    .rank-item:last-child{ border-bottom:none; }

    .rank-num{ font-weight:700; text-align:left; white-space:nowrap; }
    .rank-name{
      text-align:left;
      overflow:hidden;
      text-overflow:ellipsis;
      white-space:nowrap;
      min-width: 0;
    }
    .rank-score{
      text-align:right;
      white-space:nowrap;
      font-size: 0.95em;
      letter-spacing: 0.2px;
    }

    .rank-item.top-1{
      color:#d84315;
      font-weight:800;
      font-size: clamp(1.05rem, 1.55vw, 1.35rem);
      text-shadow:1px 1px 0 rgba(255,255,0,0.35);
    }
    .rank-item.top-2{ color:#5d4037; font-weight:800; }
    .rank-item.top-3{ color:#795548; font-weight:800; }

    .scrollbar{
      position:absolute;
      top: var(--scroll-top);
      right: var(--scroll-right);
      width: var(--track-w);
      height: var(--scroll-h);
      z-index: 50;
      display:none;
    }
    .scrollbar-track{
      position:absolute;
      inset:0;
      background: url('${ctx}/assets/images/rank/yScrollBar.png') no-repeat center/100% 100%;
    }
    .scrollbar-thumb{
      position:absolute;
      left:50%;
      transform: translateX(-50%);
      width:40px;
      height:48px;
      background: url('${ctx}/assets/images/rank/yScrollBtn.png') no-repeat center/contain;
      cursor: grab;
      top:0;
    }
    .scrollbar-thumb:active{ cursor: grabbing; }

    @media (max-width: 700px){
      :root{
        --paper-fit-vw: 98vw;
        --paper-fit-vh: 78vh;
        --paper-scale: 1.05;
        --paper-shift-y: -18px;
        --ui-shift-x: -18px;
      }
      .back-btn{ width: clamp(110px, 18vw, 170px); }
      .rank-item{ grid-template-columns: 38px minmax(0,1fr) 66px; }
      .rank-list{ padding-right: 30px; gap: 7px; }
    }
  </style>
</head>

<body>
  <img
    src="${ctx}/assets/images/rank/Arrow_left.png"
    class="back-btn"
    onclick="location.href='${ctx}/main'"
    alt="Back"
  >

  <div class="paper-wrap" id="paperWrap">
    <img
      src="${ctx}/assets/images/rank/rankingPaper.png"
      class="paper-img"
      id="paperImg"
      alt=""
      aria-hidden="true"
    >

    <main class="paper-ui" id="paperUi" aria-label="Ranking Board">
      <div class="title">Ranking</div>

      <div class="list-wrapper" id="listWrapper" aria-label="Ranking list scroll area">
        <div class="rank-list" id="rankList">
          <c:forEach var="r" items="${ranks}" varStatus="st">
            <c:set var="rank" value="${st.index + 1}" />
            <div class="rank-item ${rank == 1 ? 'top-1' : (rank == 2 ? 'top-2' : (rank == 3 ? 'top-3' : ''))}">
              <span class="rank-num">
                ${rank}
                <small style="font-size:0.62em">
                  <c:choose>
                    <c:when test="${rank == 1}">st</c:when>
                    <c:when test="${rank == 2}">nd</c:when>
                    <c:when test="${rank == 3}">rd</c:when>
                    <c:otherwise>th</c:otherwise>
                  </c:choose>
                </small>
              </span>
              <span class="rank-name">${r.nickName}</span>
              <span class="rank-score">${r.win}W ${r.lose}L</span>
            </div>
          </c:forEach>

          <c:if test="${fn:length(ranks) < 10}">
            <div style="height: 42px;"></div>
          </c:if>
        </div>
      </div>

      <div class="scrollbar" id="scrollbar">
        <div class="scrollbar-track" id="scrollTrack"></div>
        <div class="scrollbar-thumb" id="scrollThumb"></div>
      </div>
    </main>
  </div>

  <script>
    (function () {
      const wrap = document.getElementById('paperWrap');
      const img  = document.getElementById('paperImg');
      const ui   = document.getElementById('paperUi');

      const wrapper = document.getElementById('listWrapper');
      const scrollbar = document.getElementById('scrollbar');
      const thumb = document.getElementById('scrollThumb');

      /*
        ✅ 핵심: 종이 "태그 몸통"에 맞춰 안전영역 잡기
        - 오른쪽(W/L) 튀는 걸 막으려고 rightRatio를 조금 더 크게 잡음
        - 타이틀/리스트를 왼쪽으로 맞추기 위해 leftRatio를 아주 살짝 더 크게 잡아
          (CSS의 --ui-shift-x로 왼쪽 이동하는 만큼 안전영역에서 여유를 확보)
      */
      const PAPER_SAFE = {
        leftRatio: 0.315,
        rightRatio: 0.345,
        topRatio: 0.150,
        bottomRatio: 0.105,
      };

      const PAPER_TUNE = {
        padTopRatio: 0.045,
        padXRatio: 0.055,
        padBottomRatio: 0.040,

        scrollTopRatio: 0.17,
        scrollRightRatio: 0.02,
        scrollHeightRatio: 0.74,

        offsetX: -50,
        offsetY: 0,
      };

      function clamp(v, min, max) { return Math.max(min, Math.min(max, v)); }

      function syncUiToPaperImage() {
        const wrapRect = wrap.getBoundingClientRect();
        const imgRect  = img.getBoundingClientRect();

        const innerW = imgRect.width  * (1 - PAPER_SAFE.leftRatio - PAPER_SAFE.rightRatio);
        const innerH = imgRect.height * (1 - PAPER_SAFE.topRatio  - PAPER_SAFE.bottomRatio);

        const innerLeft = (imgRect.left - wrapRect.left)
          + (imgRect.width * PAPER_SAFE.leftRatio)
          + PAPER_TUNE.offsetX;

        const innerTop  = (imgRect.top - wrapRect.top)
          + (imgRect.height * PAPER_SAFE.topRatio)
          + PAPER_TUNE.offsetY;

        ui.style.left = innerLeft + 'px';
        ui.style.top  = innerTop + 'px';
        ui.style.width  = innerW + 'px';
        ui.style.height = innerH + 'px';

        ui.style.setProperty('--pad-top',    Math.round(innerH * PAPER_TUNE.padTopRatio) + 'px');
        ui.style.setProperty('--pad-x',      Math.round(innerW * PAPER_TUNE.padXRatio) + 'px');
        ui.style.setProperty('--pad-bottom', Math.round(innerH * PAPER_TUNE.padBottomRatio) + 'px');

        ui.style.setProperty('--scroll-top',   Math.round(innerH * PAPER_TUNE.scrollTopRatio) + 'px');
        ui.style.setProperty('--scroll-right', Math.round(innerW * PAPER_TUNE.scrollRightRatio) + 'px');
        ui.style.setProperty('--scroll-h',     Math.round(innerH * PAPER_TUNE.scrollHeightRatio) + 'px');
      }

      let isDragging = false;
      let startY = 0;
      let startTop = 0;

      function measure() {
        const trackHeight = scrollbar.clientHeight;
        const thumbHeight = thumb.clientHeight;
        return {
          thumbHeight,
          maxThumbTop: Math.max(0, trackHeight - thumbHeight),
        };
      }

      function needScrollbar() {
        return wrapper.scrollHeight > wrapper.clientHeight + 1;
      }

      function syncThumbToContent() {
        const { maxThumbTop } = measure();
        const maxScroll = wrapper.scrollHeight - wrapper.clientHeight;
        if (maxScroll <= 0) return;

        const ratio = wrapper.scrollTop / maxScroll;
        thumb.style.top = (ratio * maxThumbTop) + 'px';
      }

      function syncContentToThumb(thumbTop) {
        const { maxThumbTop } = measure();
        const maxScroll = wrapper.scrollHeight - wrapper.clientHeight;
        if (maxScroll <= 0) return;

        const ratio = (maxThumbTop <= 0) ? 0 : (thumbTop / maxThumbTop);
        wrapper.scrollTop = ratio * maxScroll;
      }

      function updateScrollbar() {
        if (!needScrollbar()) {
          scrollbar.style.display = 'none';
          wrapper.scrollTop = 0;
          return;
        }
        scrollbar.style.display = 'block';
        syncThumbToContent();
      }

      wrapper.addEventListener('scroll', () => {
        if (!needScrollbar()) return;
        syncThumbToContent();
      });

      thumb.addEventListener('mousedown', (e) => {
        if (!needScrollbar()) return;
        isDragging = true;
        startY = e.clientY;
        startTop = parseFloat(thumb.style.top || '0');
        document.body.style.cursor = 'grabbing';
        e.preventDefault();
      });

      document.addEventListener('mousemove', (e) => {
        if (!isDragging) return;
        const { maxThumbTop } = measure();
        const delta = e.clientY - startY;
        const newTop = clamp(startTop + delta, 0, maxThumbTop);
        thumb.style.top = newTop + 'px';
        syncContentToThumb(newTop);
      });

      document.addEventListener('mouseup', () => {
        isDragging = false;
        document.body.style.cursor = 'default';
      });

      scrollbar.addEventListener('mousedown', (e) => {
        if (!needScrollbar()) return;
        if (e.target === thumb) return;

        const { thumbHeight, maxThumbTop } = measure();
        const rect = scrollbar.getBoundingClientRect();
        const clickY = e.clientY - rect.top;
        const newTop = clamp(clickY - (thumbHeight / 2), 0, maxThumbTop);
        thumb.style.top = newTop + 'px';
        syncContentToThumb(newTop);
      });

      function recalcAll() {
        syncUiToPaperImage();
        updateScrollbar();
      }

      window.addEventListener('load', () => {
        if (img.complete) recalcAll();
        else img.addEventListener('load', recalcAll);
      });
      window.addEventListener('resize', () => requestAnimationFrame(recalcAll));
    })();
  </script>
</body>
</html>
