<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="user.User" %>
<%@ page import="util.Constants" %>
<%
    User user = (User) session.getAttribute(Constants.SESSION_KEY);
    if (user == null) {
        response.sendRedirect(request.getContextPath() + Constants.SIGNIN);
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>오목 메인 로비</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        :root {
            --room-panel-width: clamp(900px, 85vw, 1200px);
            --room-panel-height: clamp(600px, 75vh, 720px);
            --tree-w: clamp(200px, 18vw, 280px);
            --config-w: clamp(80px, 7vw, 120px);
            --nav-arrow-w: clamp(60px, 5vw, 90px);
            --make-w: clamp(120px, 10vw, 180px);
            --grid-gap: clamp(20px, 2.5vw, 34px);
        }

        body {
            font-family: 'Arial', sans-serif;
            background-image: url('<%= request.getContextPath() %>/assets/images/main/mainBg.png');
            background-size: cover;
            background-position: center;
            background-repeat: no-repeat;
            background-attachment: fixed;
            min-height: 100vh;
            overflow: hidden;
            position: relative;
        }

        /* 로딩 팝업 */
        .loading-overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.7);
            z-index: 9999;
            display: none;
            justify-content: center;
            align-items: center;
        }

        .loading-overlay.show {
            display: flex !important;
        }

        .loading-content {
            background-color: white;
            padding: 40px;
            border-radius: 15px;
            text-align: center;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.5);
        }

        .spinner {
            border: 5px solid #f3f3f3;
            border-top: 5px solid #667eea;
            border-radius: 50%;
            width: 60px;
            height: 60px;
            animation: spin 1s linear infinite;
            margin: 0 auto 20px;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        .loading-text {
            font-size: 18px;
            color: #333;
            font-weight: bold;
        }

        /* 우측 랭킹 트리 */
        .ranking-tree {
            position: fixed;
            right: 55px;
            top: 56%;
            transform: translateY(-50%);
            z-index: 100;
            cursor: pointer;
            transition: transform 0.3s ease;
        }

        .ranking-tree:hover {
            transform: translateY(-50%) scale(1.05);
        }

        .ranking-tree img {
            width: var(--tree-w);
            height: auto;
            filter: drop-shadow(0 4px 8px rgba(0, 0, 0, 0.3));
        }

        /* 중앙 방 패널 컨테이너 */
        .room-panel-container {
            position: fixed;
            top: 50%;
            left: 44%;
            transform: translate(-50%, -50%);
            z-index: 10;
        }

        .room-panel {
            position: relative;
            display: flex;
            flex-direction: column;
            width: var(--room-panel-width);
            height: var(--room-panel-height);
            padding: 85px 95px 80px;
            overflow: visible;
        }

        /* RoomBox 배경 (::before로 opacity만 적용) */
        .room-panel::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-image: url('<%= request.getContextPath() %>/assets/images/main/RoomBox.png');
            background-size: 100% 100%;
            background-position: center;
            background-repeat: no-repeat;
            opacity: 0.85;
            transition: opacity 0.3s ease;
            z-index: -1;
        }

        .room-panel:hover::before {
            opacity: 1.0;
        }

        /* 방 그리드 (2x3) */
        .rooms-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            grid-template-rows: repeat(2, 1fr);
            gap: var(--grid-gap);
            flex: 1;
            padding: 0;
            z-index: 2;
        }

        /* 개별 방 카드 */
        .room-card {
            position: relative;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            height: 100%;
            cursor: pointer;
            transition: transform 0.3s ease, filter 0.3s ease;
        }

        .room-card:hover {
            transform: scale(1.04);
            filter: drop-shadow(0 8px 16px rgba(0, 0, 0, 0.4));
        }

        .room-frame {
            position: relative;
            width: 100%;
            height: 100%;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .room-frame-img {
            width: 100%;
            height: 100%;
            object-fit: contain;
        }

        .room-info {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            text-align: center;
            color: white;
            text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.8);
            pointer-events: none;
        }

        .room-number {
            font-size: 24px;
            font-weight: bold;
            margin-bottom: 5px;
        }

        .room-status {
            font-size: 16px;
            font-weight: bold;
        }

        .room-status.waiting {
            color: #4da6ff;
        }

        .room-status.playing {
            color: #ff4d4d;
        }

        .room-players {
            font-size: 12px;
            margin-top: 3px;
        }

        /* 빈 방 표시 */
        .empty-room {
            opacity: 0.5;
            cursor: default;
        }

        .empty-room:hover {
            transform: none;
            filter: none;
        }

        .empty-message {
            font-size: 20px;
            color: #fff;
            text-align: center;
            text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.8);
            font-weight: bold;
        }

        /* 페이지 네비게이션 (RoomBox 내부) */
        .page-navigation {
            position: absolute;
            bottom: 40px;
            left: 50%;
            transform: translateX(-50%);
            display: flex;
            align-items: center;
            gap: 40px;
            z-index: 3;
        }

        .nav-arrow {
            cursor: pointer;
            transition: transform 0.3s ease, opacity 0.3s ease;
            opacity: 1;
        }

        .nav-arrow:hover:not(.disabled) {
            transform: scale(1.1);
        }

        .nav-arrow.disabled {
            opacity: 0.6;
            cursor: not-allowed;
            pointer-events: none;
        }

        .nav-arrow img {
            width: var(--nav-arrow-w);
            height: auto;
        }

        /* 방 만들기 버튼 */
        .make-room-btn {
            cursor: pointer;
            transition: transform 0.3s ease;
        }

        .make-room-btn:hover {
            transform: scale(1.1);
        }

        .make-room-btn img {
            width: var(--make-w);
            height: auto;
        }

        /* 설정 아이콘 (우하단 고정) */
        .config-icon {
            position: fixed;
            right: 30px;
            bottom: 30px;
            cursor: pointer;
            transition: transform 0.3s ease;
            z-index: 100;
            background: none;
            border: none;
            padding: 0;
        }

        .config-icon:hover {
            transform: scale(1.1) rotate(30deg);
        }

        .config-icon img {
            width: var(--config-w);
            height: auto;
        }

        /* 설정 팝업 */
        .config-popup {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.7);
            z-index: 9998;
            display: none;
            justify-content: center;
            align-items: center;
        }

        .config-popup.show {
            display: flex !important;
        }

        .config-content {
            background-color: white;
            padding: 40px;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.5);
            min-width: 400px;
        }

        .config-header {
            font-size: 24px;
            font-weight: bold;
            margin-bottom: 30px;
            text-align: center;
            color: #333;
        }

        .config-section {
            margin-bottom: 25px;
        }

        .config-label {
            font-size: 16px;
            font-weight: bold;
            margin-bottom: 10px;
            color: #555;
        }

        .volume-control {
            margin-top: 10px;
        }

        .volume-track {
            position: relative;
            width: 100%;
            height: 40px;
            background: linear-gradient(to right, #ddd 10%, #667eea 10%, #667eea 90%, #ddd 90%);
            border-radius: 20px;
            cursor: pointer;
            overflow: visible;
        }

        .volume-groove {
            position: absolute;
            left: 10%;
            top: 50%;
            transform: translateY(-50%);
            width: 80%;
            height: 8px;
            background-color: #667eea;
            border-radius: 4px;
        }

        .volume-fill {
            position: absolute;
            left: 0;
            top: 0;
            height: 100%;
            background-color: #4CAF50;
            border-radius: 4px;
            transition: width 0.1s ease;
        }

        .volume-thumb {
            position: absolute;
            top: 50%;
            transform: translate(-50%, -50%);
            width: 20px;
            height: 20px;
            background-color: white;
            border: 3px solid #667eea;
            border-radius: 50%;
            cursor: grab;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
            transition: left 0.1s ease;
        }

        .volume-thumb:active {
            cursor: grabbing;
        }

        .volume-percentage {
            text-align: center;
            margin-top: 10px;
            font-size: 14px;
            color: #666;
        }

        .config-buttons {
            display: flex;
            gap: 10px;
            margin-top: 30px;
        }

        .config-btn {
            flex: 1;
            padding: 12px 20px;
            border: none;
            border-radius: 8px;
            font-size: 16px;
            font-weight: bold;
            cursor: pointer;
            transition: transform 0.2s ease, background-color 0.2s ease;
        }

        .config-btn:hover {
            transform: scale(1.05);
        }

        .btn-logout {
            background-color: #ff9800;
            color: white;
        }

        .btn-logout:hover {
            background-color: #e68900;
        }

        .btn-withdrawal {
            background-color: #f44336;
            color: white;
        }

        .btn-withdrawal:hover {
            background-color: #da190b;
        }

        .btn-close {
            background-color: #9e9e9e;
            color: white;
        }

        .btn-close:hover {
            background-color: #757575;
        }

        /* 연결 상태 표시 */
        .connection-status {
            position: fixed;
            top: 20px;
            left: 20px;
            padding: 10px 20px;
            border-radius: 20px;
            font-size: 14px;
            font-weight: bold;
            color: white;
            z-index: 1000;
        }

        .status-connected {
            background-color: #4CAF50;
        }

        .status-disconnected {
            background-color: #f44336;
        }

        /* 사용자 정보 */
        .user-info {
            position: fixed;
            top: 20px;
            right: 20px;
            color: white;
            font-size: 18px;
            font-weight: bold;
            text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.8);
            z-index: 1000;
        }

        /* 디버그 콘솔 */
        .debug-console {
            position: fixed;
            bottom: 20px;
            left: 20px;
            width: 400px;
            max-height: 200px;
            background-color: rgba(0, 0, 0, 0.9);
            color: #00ff00;
            padding: 10px;
            border-radius: 8px;
            font-family: 'Courier New', monospace;
            font-size: 12px;
            overflow-y: auto;
            z-index: 1000;
            display: none;
        }

        .debug-console.show {
            display: block !important;
        }

        .debug-console div {
            margin: 2px 0;
        }

        /* 반응형 대응: CSS 변수의 clamp로 자동 처리됨 */
    </style>
</head>
<body>
    <!-- 로딩 팝업 -->
    <div id="loadingOverlay" class="loading-overlay">
        <div class="loading-content">
            <div class="spinner"></div>
            <div class="loading-text">방을 생성하는 중...</div>
            <button onclick="DELETE_ROOM()">취소</button>
        </div>
    </div>

    <!-- 설정 팝업 -->
    <div id="configPopup" class="config-popup">
        <div class="config-content">
            <div class="config-header">설정</div>

            <div class="config-section">
                <div class="config-label">볼륨 조절</div>
                <div class="volume-control">
                    <div id="volumeTrack" class="volume-track">
                        <div class="volume-groove">
                            <div id="volumeFill" class="volume-fill"></div>
                        </div>
                        <div id="volumeThumb" class="volume-thumb"></div>
                    </div>
                    <div id="volumePercentage" class="volume-percentage">50%</div>
                </div>
            </div>

            <div class="config-buttons">
                <button class="config-btn btn-logout" onclick="handleLogout()">로그아웃</button>
                <button class="config-btn btn-withdrawal" onclick="handleWithdrawal()">회원탈퇴</button>
                <button class="config-btn btn-close" onclick="closeConfigPopup()">닫기</button>
            </div>
        </div>
    </div>

    <!-- 연결 상태 표시 -->
    <div id="connectionStatus" class="connection-status status-disconnected">연결 중...</div>

    <!-- 사용자 정보 -->
    <div class="user-info">
        <%= user.getNickname() %>님 환영합니다!
    </div>

    <!-- 우측 랭킹 트리 -->
    <aside class="ranking-tree" onclick="goToRanking()">
        <img src="<%= request.getContextPath() %>/assets/images/main/RankingTree.png" alt="랭킹 페이지">
    </aside>

    <!-- 중앙 방 패널 -->
    <main class="room-panel-container">
        <div class="room-panel">
            <!-- 방 그리드 (2x3) -->
            <div id="roomsGrid" class="rooms-grid">
                <!-- 방 목록이 여기에 동적으로 생성됩니다 -->
            </div>

            <!-- 페이지 네비게이션 -->
            <div class="page-navigation">
                <div id="prevBtn" class="nav-arrow arrow-left" onclick="changePage(-1)">
                    <img src="<%= request.getContextPath() %>/assets/images/main/Arrow_left.png" alt="이전 페이지">
                </div>
                <div class="make-room-btn" onclick="createRoom()">
                    <img src="<%= request.getContextPath() %>/assets/images/main/MakeRoomBtn.png" alt="방 만들기">
                </div>
                <div id="nextBtn" class="nav-arrow" onclick="changePage(1)">
                    <img src="<%= request.getContextPath() %>/assets/images/main/Arrow.png" alt="다음 페이지">
                </div>
            </div>
        </div>
    </main>

    <!-- 설정 아이콘 (우하단 고정) -->
    <button class="config-icon" onclick="openConfigPopup()">
        <img src="<%= request.getContextPath() %>/assets/images/main/configureIcon.png" alt="설정">
    </button>

    <!-- 디버그 콘솔 -->
    <div class="debug-console" id="debugConsole"></div>

    <script>
        // ========== 전역 변수 설정 ==========
        const CTX = '<%= request.getContextPath() %>';
        const ASSET = CTX + '/assets/images/main/';

        let websocket = null;
        const ROOMS_PER_PAGE = 6;
        let allRooms = [];
        let currentPageIndex = 0;
        let isCreatingRoom = false;
        let roomFrameMap = new Map();
        let currentVolume = 0.5;
        let isDraggingVolume = false;

        let creatingRoomKey = 0;

        // URL 파라미터에서 debug 모드 확인
        const urlParams = new URLSearchParams(window.location.search);
        const debugMode = urlParams.get('debug') === '1';

        // ========== 유틸리티 함수 ==========
        function debugLog(message) {
            if (!debugMode) return;
            const console = document.getElementById('debugConsole');
            const now = new Date().toLocaleTimeString();
            const logEntry = document.createElement('div');
            logEntry.textContent = '[' + now + '] ' + message;
            console.appendChild(logEntry);
            console.scrollTop = console.scrollHeight;
            window.console.log(message);
        }

        function playSfx(name) {
            debugLog('SFX 재생 시도: ' + name);
        }

        function startBgm() {
            debugLog('BGM 시작 시도');
        }

        // ========== 페이지 초기화 ==========
        window.onload = function() {
            debugLog('페이지 로드 완료');
            if (debugMode) {
                document.getElementById('debugConsole').classList.add('show');
                debugLog('디버그 모드 활성화');
            }
            initVolumeControl();
            loadVolumeFromStorage();
            connectWebSocket();
            startBgm();
        };

        // ========== 볼륨 컨트롤 ==========
        function initVolumeControl() {
            const track = document.getElementById('volumeTrack');
            const thumb = document.getElementById('volumeThumb');

            track.addEventListener('mousedown', function(e) {
                updateVolumeFromMouse(e, track);
                isDraggingVolume = true;
            });

            thumb.addEventListener('mousedown', function(e) {
                e.stopPropagation();
                isDraggingVolume = true;
            });

            document.addEventListener('mousemove', function(e) {
                if (isDraggingVolume) {
                    updateVolumeFromMouse(e, track);
                }
            });

            document.addEventListener('mouseup', function() {
                isDraggingVolume = false;
            });
        }

        function updateVolumeFromMouse(e, track) {
            const rect = track.getBoundingClientRect();
            const trackWidth = rect.width;
            const clickX = e.clientX - rect.left;
            const minX = trackWidth * 0.1;
            const maxX = trackWidth * 0.9;
            const usableWidth = maxX - minX;
            let volume = (clickX - minX) / usableWidth;
            volume = Math.max(0, Math.min(1, volume));
            currentVolume = volume;
            updateVolumeUI();
            setBgmVolume(currentVolume);
        }

        function updateVolumeUI() {
            const fill = document.getElementById('volumeFill');
            const thumb = document.getElementById('volumeThumb');
            const percentage = document.getElementById('volumePercentage');
            const volumePercent = Math.round(currentVolume * 100);
            fill.style.width = (currentVolume * 100) + '%';
            thumb.style.left = (10 + currentVolume * 80) + '%';
            percentage.textContent = volumePercent + '%';
        }

        function loadVolumeFromStorage() {
            const savedVolume = localStorage.getItem('omok_volume');
            if (savedVolume !== null) {
                currentVolume = parseFloat(savedVolume);
                updateVolumeUI();
                debugLog('저장된 볼륨 불러옴: ' + Math.round(currentVolume * 100) + '%');
            }
        }

        function setBgmVolume(volume) {
            localStorage.setItem('omok_volume', volume.toString());
            debugLog('볼륨 설정: ' + Math.round(volume * 100) + '%');
        }

        // ========== UI 제어 ==========
        function openConfigPopup() {
            playSfx('click');
            document.getElementById('configPopup').classList.add('show');
        }

        function closeConfigPopup() {
            playSfx('click');
            document.getElementById('configPopup').classList.remove('show');
        }

        function handleLogout() {
            playSfx('click');
            if (confirm('정말 로그아웃 하시겠습니까?')) {
                debugLog('로그아웃 시도');
                alert('로그아웃 기능은 준비중입니다.');
            }
        }

        function handleWithdrawal() {
            playSfx('click');
            const password = prompt('회원탈퇴를 진행하려면 비밀번호를 입력하세요:');
            if (password) {
                if (confirm('정말 회원탈퇴 하시겠습니까? 이 작업은 되돌릴 수 없습니다.')) {
                    debugLog('회원탈퇴 시도 (비밀번호 확인됨)');
                    alert('회원탈퇴 기능은 준비중입니다.');
                }
            }
        }

        function goToRanking() {
            playSfx('click');
            window.location.href = CTX + '/rank';
        }

        function showLoading() {
            debugLog('로딩 팝업 표시');
            document.getElementById('loadingOverlay').classList.add('show');
        }

        function hideLoading() {
            debugLog('로딩 팝업 숨김');
            document.getElementById('loadingOverlay').classList.remove('show');
        }

        // ========== 웹소켓 연결 ==========
        function connectWebSocket() {
            const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
            const wsUrl = protocol + '//' + window.location.host + CTX + '/lobby';
            debugLog('웹소켓 연결 시도: ' + wsUrl);

            try {
                websocket = new WebSocket(wsUrl);

                websocket.onopen = function() {
                    debugLog('웹소켓 연결 성공!');
                    updateConnectionStatus(true);
                    /* setTimeout(requestRoomList, 100); */
                };

                websocket.onmessage = function(event) {
                    debugLog('메시지 수신: ' + event.data);
                    handleMessage(event.data);
                };

                websocket.onerror = function(error) {
                    debugLog('웹소켓 에러');
                    console.error('웹소켓 에러:', error);
                    updateConnectionStatus(false);
                };

                websocket.onclose = function(event) {
                    debugLog('웹소켓 연결 종료 (코드: ' + event.code + ')');
                    updateConnectionStatus(false);
                    setTimeout(function() {
                        debugLog('재연결 시도...');
                        connectWebSocket();
                    }, 3000);
                };
            } catch (error) {
                debugLog('웹소켓 연결 실패: ' + error.message);
                updateConnectionStatus(false);
            }
        }

        function updateConnectionStatus(isConnected) {
            const statusElement = document.getElementById('connectionStatus');
            if (isConnected) {
                statusElement.textContent = '연결됨';
                statusElement.className = 'connection-status status-connected';
            } else {
                statusElement.textContent = '연결 끊김';
                statusElement.className = 'connection-status status-disconnected';
            }
        }

        function requestRoomList() {
            if (websocket && websocket.readyState === WebSocket.OPEN) {
                const message = { type: 'ROOMLIST' };
                debugLog('방 목록 요청: ' + JSON.stringify(message));
                websocket.send(JSON.stringify(message));
            } else {
                debugLog('웹소켓이 열려있지 않음');
            }
        }

        function handleMessage(data) {
            try {
                const message = JSON.parse(data);
                debugLog('메시지 파싱 성공: type=' + message.type);

                creatingRoomKey = message.roomSeq;

                if (message.type === 'ROOMLIST') {
                    debugLog('방 목록 데이터: ' + JSON.stringify(message.data));
                    updateRoomList(message.data);
                    if (isCreatingRoom) {
                        debugLog('방 생성 완료! 로딩 숨김');
                        //hideLoading();
                        isCreatingRoom = false;
                    }
                } else if (message.type === 'ERROR') {
                    debugLog('에러 메시지: ' + JSON.stringify(message.data));
                    alert('에러 발생: ' + JSON.stringify(message.data));
                    hideLoading();
                    isCreatingRoom = false;

                // 게임 시작일경우  bgchoi
                } else if (message.type === 'START') {

                	window.location.href = "main/game?roomId=" + message.roomId;
                } else {
                    debugLog('알 수 없는 메시지 타입: ' + message.type);
                }
            } catch (error) {
                debugLog('메시지 파싱 에러: ' + error.message);
                console.error('메시지 파싱 에러:', error, 'Data:', data);
                hideLoading();
            }
        }

        // ========== 방 목록 관리 ==========
        function updateRoomList(rooms) {
            if (!rooms) {
                debugLog('방 목록이 null 또는 undefined');
                allRooms = [];
            } else if (Array.isArray(rooms)) {
                debugLog('방 목록 배열 수신: ' + rooms.length + '개');
                allRooms = rooms;
            } else {
                debugLog('방 목록이 배열이 아님: ' + typeof rooms);
                allRooms = [];
            }
            currentPageIndex = 0;
            renderCurrentPage();
        }

        function renderCurrentPage() {
            const startIndex = currentPageIndex * ROOMS_PER_PAGE;
            const endIndex = Math.min(startIndex + ROOMS_PER_PAGE, allRooms.length);
            const currentPageRooms = allRooms.slice(startIndex, endIndex);
            debugLog('현재 페이지 렌더링: ' + (currentPageIndex + 1) + '페이지, ' + currentPageRooms.length + '개 방');
            renderRooms(currentPageRooms);
            updateNavButtons();
        }

        function renderRooms(rooms) {
            const roomsGrid = document.getElementById('roomsGrid');
            roomsGrid.innerHTML = '';

            if (rooms.length === 0) {
                const emptyMessage = document.createElement('div');
                emptyMessage.style.gridColumn = '1 / -1';
                emptyMessage.style.gridRow = '1 / -1';
                emptyMessage.style.display = 'flex';
                emptyMessage.style.alignItems = 'center';
                emptyMessage.style.justifyContent = 'center';
                emptyMessage.className = 'empty-message';
                emptyMessage.innerHTML = '<h2>방을 만드세요</h2>';
                roomsGrid.appendChild(emptyMessage);
                return;
            }

            for (let i = 0; i < ROOMS_PER_PAGE; i++) {
                if (i < rooms.length) {
                    const room = rooms[i];
                    const roomCard = createRoomCard(room);
                    roomsGrid.appendChild(roomCard);
                } else {
                    const emptyCard = createEmptyCard();
                    roomsGrid.appendChild(emptyCard);
                }
            }
        }

        function createRoomCard(room) {
            const card = document.createElement('div');
            card.className = 'room-card';

            const roomKey = room.roomSeq || room.roomId || room.id || 0;
            if (!roomFrameMap.has(roomKey)) {
                roomFrameMap.set(roomKey, Math.floor(Math.random() * 9) + 1);
            }
            const frameNum = roomFrameMap.get(roomKey);

            const frame = document.createElement('div');
            frame.className = 'room-frame';

            const frameImg = document.createElement('img');
            frameImg.className = 'room-frame-img';
            frameImg.src = ASSET + 'room_' + frameNum + '.png';
            frameImg.onerror = function() {
                debugLog('room_' + frameNum + '.png 로딩 실패, room_1.png로 fallback');
                frameImg.src = ASSET + 'room_1.png';
            };

            const info = document.createElement('div');
            info.className = 'room-info';

            const roomNumber = document.createElement('div');
            roomNumber.className = 'room-number';
            roomNumber.textContent = 'Room ' + (room.roomSeq || room.roomId || room.id || '?');

            const roomStatus = document.createElement('div');
            roomStatus.className = 'room-status';
            const status = room.roomStatus || room.status || 'UNKNOWN';
            if (status === 'WAIT' || status === 'Waiting') {
                roomStatus.textContent = 'Waiting';
                roomStatus.classList.add('waiting');
            } else if (status === 'PLAYING' || status === 'Playing') {
                roomStatus.textContent = 'Playing';
                roomStatus.classList.add('playing');
            } else {
                roomStatus.textContent = status;
            }

            const roomPlayers = document.createElement('div');
            roomPlayers.className = 'room-players';
            const playerCount = (room.gameUsers && room.gameUsers.length) || 0;
            roomPlayers.textContent = playerCount + '/2';

            // 옵저버 추가 임시
            const roomObservers = document.createElement('div');
            roomObservers.className = 'room-observers';
            const observerCount = (room.observers && room.observers.length) || 0;
            roomObservers.textContent = observerCount + '/2';

            info.appendChild(roomNumber);
            info.appendChild(roomStatus);
            info.appendChild(roomPlayers);
            
            info.appendChild(roomObservers);

            frame.appendChild(frameImg);
            frame.appendChild(info);
            card.appendChild(frame);

            card.onclick = function() {
                playSfx('click');
                if (status === 'PLAYING' || status === 'Playing') {
                    watchRoom(roomKey);
                } else {
                    enterRoom(roomKey);
                }
            };

            return card;
        }

        function createEmptyCard() {
            const card = document.createElement('div');
            card.className = 'room-card empty-room';

            const frame = document.createElement('div');
            frame.className = 'room-frame';

            const frameImg = document.createElement('img');
            frameImg.className = 'room-frame-img';
            frameImg.src = ASSET + 'room_1.png';

            frame.appendChild(frameImg);
            card.appendChild(frame);

            return card;
        }

        function updateNavButtons() {
            const prevBtn = document.getElementById('prevBtn');
            const nextBtn = document.getElementById('nextBtn');
            const totalPages = Math.ceil(allRooms.length / ROOMS_PER_PAGE) || 1;

            if (currentPageIndex === 0) {
                prevBtn.classList.add('disabled');
            } else {
                prevBtn.classList.remove('disabled');
            }

            if (currentPageIndex >= totalPages - 1) {
                nextBtn.classList.add('disabled');
            } else {
                nextBtn.classList.remove('disabled');
            }
        }

        function changePage(direction) {
            playSfx('page');
            const totalPages = Math.ceil(allRooms.length / ROOMS_PER_PAGE) || 1;
            const newPageIndex = currentPageIndex + direction;

            if (newPageIndex >= 0 && newPageIndex < totalPages) {
                currentPageIndex = newPageIndex;
                renderCurrentPage();
            }
        }

        // ========== 방 생성/입장/관전 ==========
        function createRoom() {
            playSfx('create');
            debugLog('방 생성 버튼 클릭');

            showLoading();
            isCreatingRoom = true;

            if (!websocket || websocket.readyState !== WebSocket.OPEN) {
                debugLog('웹소켓 연결 안됨');
                setTimeout(function() {
                    hideLoading();
                    isCreatingRoom = false;
                    alert('웹소켓이 연결되지 않았습니다. 잠시 후 다시 시도해주세요.');
                }, 500);
                return;
            }

            try {
                const userId = '<%= user.getUserId() %>';
                let hash = 0;
                for (let i = 0; i < userId.length; i++) {
                    hash = ((hash << 5) - hash) + userId.charCodeAt(i);
                    hash = hash & hash;
                }

                const message = {
                    type: 'CREATE_ROOM',
                    data: {
                        ownerUserSeq: Math.abs(hash)
                    }
                };

                debugLog('방 생성 요청 전송: ' + JSON.stringify(message));
                websocket.send(JSON.stringify(message));

                setTimeout(function() {
                    if (isCreatingRoom) {
                        hideLoading();
                        isCreatingRoom = false;
                        debugLog('방 생성 타임아웃');
                        alert('방 생성 시간이 초과되었습니다. 다시 시도해주세요.');
                    }
                }, 5000);
            } catch (error) {
                debugLog('방 생성 에러: ' + error.message);
                hideLoading();
                isCreatingRoom = false;
                alert('방 생성 중 오류가 발생했습니다: ' + error.message);
            }
        }

        function enterRoom(roomKey) {
            debugLog('방 #' + roomKey + ' 입장 시도');

            if (!websocket || websocket.readyState !== WebSocket.OPEN) {
                alert('서버와 연결되어 있지 않습니다.');
                return;
            }
            if (confirm('방 #' + roomKey + '에 입장하시겠습니까?')) {
            /*
                alert('방 입장 기능은 준비중입니다.');
            */
            	console.log(roomKey);
                const message = {
                    type: 'JOIN_ROOM',
                    roomId: roomKey
                };
                debugLog('방 입장 요청 전송: ' + JSON.stringify(message));
                websocket.send(JSON.stringify(message));
            } 
        }
        
     	// 방생성 취소 시 삭제 bgchoi

        function DELETE_ROOM() {
            debugLog('방 생성/대기 취소 요청');
            if (!websocket || websocket.readyState !== WebSocket.OPEN) {
                alert('서버와 연결되어 있지 않습니다.');
                hideLoading();
                return;
            }
			console.log("룸삭제 번호 : " + creatingRoomKey);
			const message = {
				    type: 'DELETE_ROOM',
				    data: {
				        roomId: creatingRoomKey
				    }
				};
            websocket.send(JSON.stringify(message));
            hideLoading();
        }

     	/*
        function watchRoom(roomKey) {
            debugLog('방 #' + roomKey + ' 관전 시도');
            if (confirm('방 #' + roomKey + '를 관전하시겠습니까?')) {
                alert('관전 기능은 준비중입니다.');
            }
        }
		*/
     	// 방 입장 시 처리(관전자) bgchoi
        function watchRoom(roomKey) {
        	 debugLog('방 #' + roomKey + ' 입장 시도');
 			
             if (!websocket || websocket.readyState !== WebSocket.OPEN) {
                 alert('서버와 연결되어 있지 않습니다.');
                 return;
             }

             if (confirm('방 #' + roomKey + '을 관전 하시겠습니까?')) {
             	console.log(roomKey);
                 const message = {
                     type: 'OBSERVE_ROOM',
                     roomId : roomKey
                 };

                 debugLog('방 입장 요청 전송: ' + JSON.stringify(message));
                 websocket.send(JSON.stringify(message));
             }
     	}
		
		
        // ========== 페이지 종료 처리 ==========
        window.onbeforeunload = function() {
            if (websocket) {
                debugLog('웹소켓 연결 종료');
                websocket.close();
            }
        };
    </script>
</body>
</html>
