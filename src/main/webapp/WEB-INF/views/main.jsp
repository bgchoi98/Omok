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
        * { margin: 0; padding: 0; box-sizing: border-box; }

        :root {
            --room-panel-width: clamp(900px, 85vw, 1200px);
            --room-panel-height: clamp(600px, 75vh, 720px);
            --tree-w: clamp(280px, 22vw, 380px); 
            --grid-gap: clamp(30px, 4vw, 50px);
            --config-w: clamp(80px, 7vw, 120px);
            --nav-arrow-w: clamp(60px, 5vw, 90px);
            --make-w: clamp(120px, 10vw, 180px);
            --config-box-w: 400px;  
            --config-box-h: 500px;
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

        /* --- 로딩 팝업 --- */
        .loading-overlay { 
            position: fixed; top: 0; left: 0; width: 100%; height: 100%; 
            background-color: rgba(0, 0, 0, 0.6); 
            z-index: 9999; 
            display: none; 
            justify-content: center; align-items: center; 
            backdrop-filter: blur(3px);
        }
        .loading-overlay.show { display: flex !important; }
        
        .loading-container {
            display: flex; flex-direction: column; align-items: center; justify-content: center; position: relative;
        }

        .spinner-wrapper {
            position: relative; width: 380px; height: 380px; 
            display: flex; justify-content: center; align-items: center;
        }

        .wreath-img { width: 100%; height: 100%; object-fit: contain; animation: spinWreath 4s linear infinite; }
        .loading-text-img {
            position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%);
            width: 60%; height: auto; object-fit: contain;
        }

        @keyframes spinWreath {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        .loading-status-text {
            margin-top: 20px; font-size: 20px; color: #fff; font-weight: bold; text-shadow: 0 2px 4px rgba(0,0,0,0.5);
        }

        .loading-cancel-btn {
            margin-top: 15px; padding: 8px 30px; background-color: #8d6e63; border: 2px solid #5d4037; border-radius: 8px; color: white; font-weight: bold; font-size: 16px; cursor: pointer; transition: transform 0.2s, background-color 0.2s; box-shadow: 0 4px 6px rgba(0,0,0,0.3);
        }
        .loading-cancel-btn:hover { background-color: #6d4c41; transform: scale(1.05); }

        /* --- 랭킹 트리 --- */
        .ranking-tree { 
            position: fixed; right: 3%; top: 55%; transform: translateY(-50%); 
            z-index: 1; cursor: pointer; transition: transform 0.3s ease; 
        }
        .ranking-tree:hover { transform: translateY(-50%) scale(1.05); }
        .ranking-tree img { width: var(--tree-w); height: auto; filter: drop-shadow(0 4px 8px rgba(0, 0, 0, 0.3)); }

        .room-panel-container { 
            position: fixed; top: 50%; left: 44%; transform: translate(-50%, -50%); z-index: 10; 
        }
        .room-panel { position: relative; display: flex; flex-direction: column; width: var(--room-panel-width); height: var(--room-panel-height); padding: 85px 95px 80px; overflow: visible; }
        .room-panel::before { content: ''; position: absolute; top: 0; left: 0; width: 100%; height: 100%; background-image: url('<%= request.getContextPath() %>/assets/images/main/RoomBox.png'); background-size: 100% 100%; background-position: center; background-repeat: no-repeat; opacity: 0.85; transition: opacity 0.3s ease; z-index: -1; }
        .room-panel:hover::before { opacity: 1.0; }
        
        .rooms-grid { display: grid; grid-template-columns: repeat(3, 1fr); grid-template-rows: repeat(2, 1fr); gap: var(--grid-gap); flex: 1; padding: 0; z-index: 2; }
        .room-card { position: relative; display: flex; flex-direction: column; align-items: center; justify-content: center; height: 100%; cursor: pointer; transition: transform 0.3s ease, filter 0.3s ease; }
        .room-card:hover { transform: scale(1.04); filter: drop-shadow(0 8px 16px rgba(0, 0, 0, 0.4)); }
        .room-frame { position: relative; width: 100%; height: 100%; display: flex; align-items: center; justify-content: center; }
        .room-frame-img { width: 100%; height: 100%; object-fit: contain; }
        .room-info { position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); text-align: center; color: white; text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.8); pointer-events: none; }
        .room-number { font-size: 24px; font-weight: bold; margin-bottom: 5px; }
        .room-status { font-size: 16px; font-weight: bold; }
        .room-status.waiting { color: #4da6ff; }
        .room-status.playing { color: #ff4d4d; }
        .room-players { font-size: 12px; margin-top: 3px; }
        
        .empty-room { visibility: hidden; pointer-events: none; cursor: default; }
        .empty-message { font-size: 20px; color: #fff; text-align: center; text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.8); font-weight: bold; }

        .page-navigation { position: absolute; bottom: 40px; left: 50%; transform: translateX(-50%); display: flex; align-items: center; gap: 40px; z-index: 3; }
        .nav-arrow { cursor: pointer; transition: transform 0.3s ease, opacity 0.3s ease; opacity: 1; }
        .nav-arrow:hover:not(.disabled) { transform: scale(1.1); }
        .nav-arrow.disabled { opacity: 0.6; cursor: not-allowed; pointer-events: none; }
        .nav-arrow img { width: var(--nav-arrow-w); height: auto; }
        .make-room-btn { cursor: pointer; transition: transform 0.3s ease; }
        .make-room-btn:hover { transform: scale(1.1); }
        .make-room-btn img { width: var(--make-w); height: auto; }
        
        .config-icon { position: fixed; right: 30px; bottom: 30px; cursor: pointer; transition: transform 0.3s ease; z-index: 100; background: none; border: none; padding: 0; }
        .config-icon:hover { transform: scale(1.1) rotate(30deg); }
        .config-icon img { width: var(--config-w); height: auto; }

        /* 설정 팝업 */
        .config-popup {
            position: fixed; top: 0; left: 0; width: 100%; height: 100%;
            background-color: rgba(0, 0, 0, 0.5); z-index: 9998;
            display: none; justify-content: center; align-items: center;
        }
        .config-popup.show { display: flex !important; }

        .config-box {
            position: relative; width: var(--config-box-w); height: var(--config-box-h);
            background-image: url('<%= request.getContextPath() %>/assets/images/main/ConfigPopUp/configureBox.png');
            background-size: contain; background-position: center; background-repeat: no-repeat;
            display: flex; flex-direction: column; align-items: center; justify-content: center;
            padding-top: 0; filter: drop-shadow(0 10px 20px rgba(0,0,0,0.5));
        }

        .btn-close-popup {
            position: absolute; top: 55px; right: 35px; width: 30px; height: 30px;
            background: #8b4513; border: 2px solid #5d2906; color: white;
            border-radius: 5px; font-weight: bold; cursor: pointer;
            display: flex; align-items: center; justify-content: center; z-index: 10;
        }
        .btn-close-popup:hover { background: #5d2906; }

        .config-menu-group { display: flex; flex-direction: column; align-items: center; gap: 15px; width: 100%; margin-top: -20px; }
        .img-btn { display: block; width: 180px; height: auto; cursor: pointer; transition: transform 0.2s; }
        .img-btn:hover { transform: scale(1.05); }
        .img-btn:active { transform: scale(0.95); }

        .input-box-wrapper {
            position: relative; width: 180px; height: 50px;
            background-image: url('<%= request.getContextPath() %>/assets/images/main/ConfigPopUp/textbox.png');
            background-size: 100% 100%; background-repeat: no-repeat;
            display: flex; align-items: center; justify-content: center; margin-top: 5px;
        }
        .input-box-wrapper input {
            width: 90%; height: 80%; background: transparent; border: none; outline: none;
            text-align: center; font-family: 'Arial', sans-serif; font-size: 14px; color: #5d4037;
        }
        .input-label { font-size: 12px; color: #5d4037; margin-bottom: -10px; font-weight: bold; }

        .volume-image-wrapper {
            position: absolute; bottom: -35px; left: 50%; transform: translateX(-50%);
            width: 420px; height: 80px;
            background-image: url('<%= request.getContextPath() %>/assets/images/main/ConfigPopUp/volumeBar.png');
            background-size: 100% 100%; background-position: center; background-repeat: no-repeat;
            display: flex; justify-content: center; align-items: center;
        }
        .volume-track-area { position: absolute; width: 260px; height: 100%; top: 0; left: 50%; transform: translateX(-50%); cursor: pointer; }
        .volume-knob {
            position: absolute; top: 50%; left: 50%; transform: translate(-50%, -40%);
            width: 40px; height: 50px;
            background-image: url('<%= request.getContextPath() %>/assets/images/main/ConfigPopUp/volumeBtn.png');
            background-size: contain; background-repeat: no-repeat;
            cursor: pointer; z-index: 5; pointer-events: none; 
        }

        .connection-status { position: fixed; top: 20px; left: 20px; padding: 10px 20px; border-radius: 20px; font-size: 14px; font-weight: bold; color: white; z-index: 1000; }
        .status-connected { background-color: #4CAF50; }
        .status-disconnected { background-color: #f44336; }
        .user-info { position: fixed; top: 20px; right: 20px; color: white; font-size: 18px; font-weight: bold; text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.8); z-index: 1000; }
        .debug-console { position: fixed; bottom: 20px; left: 20px; width: 400px; max-height: 200px; background-color: rgba(0, 0, 0, 0.9); color: #00ff00; padding: 10px; border-radius: 8px; font-family: 'Courier New', monospace; font-size: 12px; overflow-y: auto; z-index: 1000; display: none; }
        .debug-console.show { display: block !important; }
        .debug-console div { margin: 2px 0; }
    </style>
</head>
<body>
    <audio id="bgmAudio" loop preload="auto">
        <source src="<%= request.getContextPath() %>/assets/sounds/bgm.mp3" type="audio/mp3">
        <source src="<%= request.getContextPath() %>/assets/sounds/bgm.wav" type="audio/wav">
    </audio>

    <div id="loadingOverlay" class="loading-overlay">
        <div class="loading-container">
            <div class="spinner-wrapper">
                <img src="<%= request.getContextPath() %>/assets/images/main/loading_wreath.png" class="wreath-img" alt="Loading Wreath">
                <img src="<%= request.getContextPath() %>/assets/images/main/loading_text.png" class="loading-text-img" alt="Loading...">
            </div>
            <div class="loading-status-text">방을 생성하는 중...</div>
            <button class="loading-cancel-btn" onclick="DELETE_ROOM()">취소</button>
        </div>
    </div>

    <div id="configPopup" class="config-popup">
        <div class="config-box">
            <button class="btn-close-popup" onclick="closeConfigPopup()">X</button>
            <div class="config-menu-group">
                <img src="<%= request.getContextPath() %>/assets/images/main/ConfigPopUp/logout_btn.png" alt="로그아웃" class="img-btn" onclick="handleLogout()">
                <img src="<%= request.getContextPath() %>/assets/images/main/ConfigPopUp/deleteMem.png" alt="회원탈퇴" class="img-btn" onclick="requestWithdrawal()">
                <div class="input-label">Password Check</div>
                <div class="input-box-wrapper">
                    <input type="password" id="withdrawalPw" placeholder="비밀번호 입력">
                </div>
            </div>
            <div class="volume-image-wrapper">
                <div id="volumeTrack" class="volume-track-area">
                    <div id="volumeKnob" class="volume-knob"></div>
                </div>
            </div>
        </div>
    </div>

    <div style="display:none;">
        <form id="logoutForm" action="<%= request.getContextPath() + Constants.SIGNOUT %>" method="get"></form>
        <form id="withdrawForm" action="<%= request.getContextPath() + Constants.WITHDRAW %>" method="post">
            <input type="hidden" name="user_pw" id="hiddenPw">
        </form>
    </div>

    <div id="connectionStatus" class="connection-status status-disconnected">연결 중...</div>

    <div class="user-info">
        <%= user.getNickname() %>님 환영합니다!
    </div>

    <aside class="ranking-tree" onclick="goToRanking()">
        <img src="<%= request.getContextPath() %>/assets/images/main/RankingTree.png" alt="랭킹 페이지">
    </aside>

    <main class="room-panel-container">
        <div class="room-panel">
            <div id="roomsGrid" class="rooms-grid"></div>
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

    <button class="config-icon" onclick="openConfigPopup()">
        <img src="<%= request.getContextPath() %>/assets/images/main/configureIcon.png" alt="설정">
    </button>

    <div class="debug-console" id="debugConsole"></div>

    <script>
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

        const urlParams = new URLSearchParams(window.location.search);
        const debugMode = urlParams.get('debug') === '1';

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

        // ========== [수정됨] 강력한 BGM 재생 로직 ==========
        function startBgm() {
            debugLog('BGM 시작 로직 진입');
            const audio = document.getElementById('bgmAudio');
            if (!audio) return;

            // 저장된 볼륨 적용
            audio.volume = currentVolume;

            // 저장된 재생 시간 복원 (페이지 이동 간 연속성)
            const savedTime = sessionStorage.getItem('omok_bgm_time');
            if (savedTime) {
                audio.currentTime = parseFloat(savedTime);
                debugLog('저장된 BGM 시간 복원: ' + savedTime);
            }

            // 재생 시도
            const playPromise = audio.play();

            if (playPromise !== undefined) {
                playPromise.then(() => {
                    debugLog('BGM 자동 재생 성공');
                }).catch(error => {
                    debugLog('자동 재생 실패(브라우저 정책). 클릭 대기 중...');
                    // 브라우저 정책으로 자동 재생이 막혔을 때, 화면의 아무 곳이나 클릭하면 바로 재생되도록 이벤트 등록
                    document.body.addEventListener('click', function playOnInteraction() {
                        audio.play().then(() => {
                            debugLog('사용자 클릭으로 BGM 시작');
                        });
                        // 한 번 실행 후 이벤트 제거
                        document.body.removeEventListener('click', playOnInteraction);
                    }, { once: true });
                });
            }
        }

        window.onload = function() {
            if (debugMode) document.getElementById('debugConsole').classList.add('show');
            initVolumeControl();
            loadVolumeFromStorage();
            
            // 페이지 로드 시 무조건 BGM 시작 시도
            startBgm();
            
            connectWebSocket();
        };

        // 페이지를 떠날 때 현재 재생 시간 저장
        window.onbeforeunload = function() {
            const audio = document.getElementById('bgmAudio');
            if (audio && !audio.paused) {
                sessionStorage.setItem('omok_bgm_time', audio.currentTime);
            }
            if (websocket) websocket.close();
        };

        function initVolumeControl() {
            const track = document.getElementById('volumeTrack');
            track.addEventListener('mousedown', startDrag);
            document.addEventListener('mousemove', function(e) {
                if (isDraggingVolume) updateVolumeFromEvent(e, track);
            });
            document.addEventListener('mouseup', function() {
                isDraggingVolume = false;
            });
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
            currentVolume = volume;
            updateVolumeUI();
            setBgmVolume(currentVolume);
        }

        function updateVolumeUI() {
            const knob = document.getElementById('volumeKnob');
            knob.style.left = (currentVolume * 100) + '%';
        }

        function loadVolumeFromStorage() {
            const savedVolume = localStorage.getItem('omok_volume');
            if (savedVolume !== null) currentVolume = parseFloat(savedVolume);
            updateVolumeUI();
        }

        function setBgmVolume(volume) {
            localStorage.setItem('omok_volume', volume.toString());
            const audio = document.getElementById('bgmAudio');
            if(audio) audio.volume = volume;
        }

        function openConfigPopup() {
            playSfx('click');
            document.getElementById('configPopup').classList.add('show');
            updateVolumeUI();
        }

        function closeConfigPopup() {
            playSfx('click');
            document.getElementById('configPopup').classList.remove('show');
            document.getElementById('withdrawalPw').value = '';
        }

        function handleLogout() {
            playSfx('click');
            if (confirm('정말 로그아웃 하시겠습니까?')) {
                document.getElementById('logoutForm').submit();
            }
        }

        function requestWithdrawal() {
            playSfx('click');
            const pwInput = document.getElementById('withdrawalPw');
            const password = pwInput.value.trim();
            if (!password) {
                alert('회원탈퇴를 진행하려면 비밀번호를 입력해주세요.');
                pwInput.focus();
                return;
            }
            if (confirm('정말 회원탈퇴 하시겠습니까? 이 작업은 되돌릴 수 없습니다.')) {
                document.getElementById('hiddenPw').value = password;
                document.getElementById('withdrawForm').submit();
            }
        }

        function goToRanking() {
            playSfx('click');
            // 페이지 이동 전 재생 시간 저장은 window.onbeforeunload에서 처리됨
            window.location.href = CTX + '/rank';
        }

        function showLoading() {
            document.getElementById('loadingOverlay').classList.add('show');
        }

        function hideLoading() {
            document.getElementById('loadingOverlay').classList.remove('show');
        }

        function connectWebSocket() {
            const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
            const wsUrl = protocol + '//' + window.location.host + CTX + '/lobby';
            try {
                websocket = new WebSocket(wsUrl);
                websocket.onopen = function() { updateConnectionStatus(true); };
                websocket.onmessage = function(event) { handleMessage(event.data); };
                websocket.onerror = function(error) { updateConnectionStatus(false); };
                websocket.onclose = function(event) {
                    updateConnectionStatus(false);
                    setTimeout(() => connectWebSocket(), 3000);
                };
            } catch (error) {
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

        function handleMessage(data) {
            try {
                const message = JSON.parse(data);
                creatingRoomKey = message.roomSeq;

                if (message.type === 'ROOMLIST') {
                    updateRoomList(message.data);
                    if (isCreatingRoom) isCreatingRoom = false;
                } else if (message.type === 'ERROR') {
                    alert('에러 발생: ' + JSON.stringify(message.data));
                    hideLoading();
                    isCreatingRoom = false;
                } else if (message.type === 'START') {
                    window.location.href = "main/game?roomId=" + message.roomId;
                }
            } catch (error) {
                console.error('메시지 파싱 에러:', error);
                hideLoading();
            }
        }

        function updateRoomList(rooms) {
            if (!rooms) allRooms = [];
            else if (Array.isArray(rooms)) allRooms = rooms;
            else allRooms = [];
            
            currentPageIndex = 0;
            renderCurrentPage();
        }

        function renderCurrentPage() {
            const startIndex = currentPageIndex * ROOMS_PER_PAGE;
            const endIndex = Math.min(startIndex + ROOMS_PER_PAGE, allRooms.length);
            const currentPageRooms = allRooms.slice(startIndex, endIndex);
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
                    roomsGrid.appendChild(createRoomCard(rooms[i]));
                } else {
                    roomsGrid.appendChild(createEmptyCard());
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
            frameImg.onerror = function() { frameImg.src = ASSET + 'room_1.png'; };

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
            return card;
        }

        function updateNavButtons() {
            const prevBtn = document.getElementById('prevBtn');
            const nextBtn = document.getElementById('nextBtn');
            const totalPages = Math.ceil(allRooms.length / ROOMS_PER_PAGE) || 1;

            if (currentPageIndex === 0) prevBtn.classList.add('disabled');
            else prevBtn.classList.remove('disabled');

            if (currentPageIndex >= totalPages - 1) nextBtn.classList.add('disabled');
            else nextBtn.classList.remove('disabled');
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

        function createRoom() {
            playSfx('create');
            showLoading();
            isCreatingRoom = true;

            if (!websocket || websocket.readyState !== WebSocket.OPEN) {
                setTimeout(function() {
                    hideLoading();
                    isCreatingRoom = false;
                    alert('웹소켓이 연결되지 않았습니다.');
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
                const message = { type: 'CREATE_ROOM', data: { ownerUserSeq: Math.abs(hash) } };
                websocket.send(JSON.stringify(message));

                setTimeout(function() {
                    if (isCreatingRoom) {
                        hideLoading();
                        isCreatingRoom = false;
                        alert('방 생성 시간이 초과되었습니다.');
                    }
                }, 5000);
            } catch (error) {
                hideLoading();
                isCreatingRoom = false;
                alert('오류 발생: ' + error.message);
            }
        }

        function enterRoom(roomKey) {
            if (!websocket || websocket.readyState !== WebSocket.OPEN) {
                alert('서버와 연결되어 있지 않습니다.');
                return;
            }
            if (confirm('방 #' + roomKey + '에 입장하시겠습니까?')) {
                const message = { type: 'JOIN_ROOM', roomId: roomKey };
                websocket.send(JSON.stringify(message));
            } 
        }
        
        function DELETE_ROOM() {
            if (!websocket || websocket.readyState !== WebSocket.OPEN) {
                hideLoading();
                return;
            }
            const message = { type: 'DELETE_ROOM', data: { roomId: creatingRoomKey } };
            websocket.send(JSON.stringify(message));
            hideLoading();
        }

        function watchRoom(roomKey) {
             if (!websocket || websocket.readyState !== WebSocket.OPEN) {
                 alert('서버와 연결되어 있지 않습니다.');
                 return;
             }
             if (confirm('방 #' + roomKey + '을 관전 하시겠습니까?')) {
                 const message = { type: 'OBSERVE_ROOM', roomId : roomKey };
                 websocket.send(JSON.stringify(message));
             }
        }
    </script>
</body>
</html>