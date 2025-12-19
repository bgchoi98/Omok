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

        body {
            font-family: 'Arial', sans-serif;
            background-image: url('${pageContext.request.contextPath}/assets/images/main/mainBg.png');
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
            right: 30px;
            top: 50%;
            transform: translateY(-50%);
            z-index: 100;
            cursor: pointer;
            transition: transform 0.3s ease;
        }

        .ranking-tree:hover {
            transform: translateY(-50%) scale(1.05);
        }

        .ranking-tree img {
            width: 180px;
            height: auto;
            filter: drop-shadow(0 4px 8px rgba(0, 0, 0, 0.3));
        }

        /* 중앙 방 패널 컨테이너 */
        .room-panel-container {
            position: fixed;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            z-index: 10;
        }

        .room-panel {
            position: relative;
            width: 800px;
            height: 600px;
            background-image: url('${pageContext.request.contextPath}/assets/images/main/RoomBox.png');
            background-size: contain;
            background-position: center;
            background-repeat: no-repeat;
            padding: 80px 60px 60px 60px;
        }

        /* 방 그리드 (3x2) */
        .rooms-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            grid-template-rows: repeat(2, 1fr);
            gap: 20px;
            height: 100%;
            padding: 20px;
        }

        /* 개별 방 슬롯 */
        .room-slot {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: space-between;
            gap: 10px;
        }

        .room-frame {
            position: relative;
            width: 100%;
            flex: 1;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            transition: transform 0.3s ease;
        }

        .room-frame:hover {
            transform: scale(1.05);
        }

        .room-frame img {
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
            font-size: 14px;
        }

        /* 방 버튼들 */
        .room-buttons {
            display: flex;
            gap: 10px;
            justify-content: center;
        }

        .room-btn {
            cursor: pointer;
            transition: transform 0.2s ease;
            border: none;
            background: none;
            padding: 0;
        }

        .room-btn:hover {
            transform: scale(1.1);
        }

        .room-btn img {
            width: 60px;
            height: auto;
        }

        /* 화살표 버튼 (패널 우측 중간) */
        .arrow-btn {
            position: absolute;
            right: -40px;
            top: 50%;
            transform: translateY(-50%);
            cursor: pointer;
            transition: transform 0.3s ease;
            z-index: 20;
        }

        .arrow-btn:hover {
            transform: translateY(-50%) scale(1.1);
        }

        .arrow-btn img {
            width: 50px;
            height: auto;
        }

        /* 방 만들기 버튼 (패널 우하단) */
        .make-room-btn {
            position: absolute;
            right: -20px;
            bottom: 20px;
            cursor: pointer;
            transition: transform 0.3s ease;
            z-index: 20;
        }

        .make-room-btn:hover {
            transform: scale(1.1);
        }

        .make-room-btn img {
            width: 120px;
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
        }

        .config-icon:hover {
            transform: scale(1.1) rotate(30deg);
        }

        .config-icon img {
            width: 60px;
            height: auto;
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
        }

        .debug-console div {
            margin: 2px 0;
        }

        /* 빈 슬롯 스타일 */
        .empty-slot .room-frame {
            opacity: 0.6;
        }

        /* 애니메이션 */
        @keyframes fadeIn {
            from {
                opacity: 0;
                transform: scale(0.8);
            }
            to {
                opacity: 1;
                transform: scale(1);
            }
        }

        .room-slot.new {
            animation: fadeIn 0.3s ease;
        }
    </style>
</head>
<body>
    <!-- 로딩 팝업 -->
    <div id="loadingOverlay" class="loading-overlay">
        <div class="loading-content">
            <div class="spinner"></div>
            <div class="loading-text">방을 생성하는 중...</div>
        </div>
    </div>

    <!-- 연결 상태 표시 -->
    <div id="connectionStatus" class="connection-status status-disconnected">연결 중...</div>

    <!-- 사용자 정보 -->
    <div class="user-info">
        👤 <%= user.getNickname() %>님 환영합니다!
    </div>

    <!-- 우측 랭킹 트리 -->
    <aside class="ranking-tree">
        <a href="${pageContext.request.contextPath}/rank">
            <img src="${pageContext.request.contextPath}/assets/images/main/RankingTree.png" alt="랭킹 페이지">
        </a>
    </aside>

    <!-- 중앙 방 패널 -->
    <main class="room-panel-container">
        <div class="room-panel">
            <!-- 방 그리드 (3x2) -->
            <div id="roomsGrid" class="rooms-grid">
                <!-- 방 목록이 여기에 동적으로 생성됩니다 -->
            </div>

            <!-- 화살표 버튼 (우측 중간) -->
            <button class="arrow-btn" onclick="requestRoomList()">
                <img src="${pageContext.request.contextPath}/assets/images/main/Arrow.png" alt="새로고침">
            </button>

            <!-- 방 만들기 버튼 (우하단) -->
            <button class="make-room-btn" id="createRoomBtn" onclick="createRoom()">
                <img src="${pageContext.request.contextPath}/assets/images/main/MakeRoomBtn.png" alt="방 만들기">
            </button>
        </div>
    </main>

    <!-- 설정 아이콘 (우하단 고정) -->
    <button class="config-icon" onclick="alert('설정 기능 준비중입니다.')">
        <img src="${pageContext.request.contextPath}/assets/images/main/configureIcon.png" alt="설정">
    </button>

    <!-- 디버그 콘솔 -->
    <div class="debug-console" id="debugConsole"></div>

    <script>
        let websocket = null;
        const MAX_ROOMS = 6; // 3x2 그리드
        let currentRooms = [];
        let isCreatingRoom = false;

        // 방 프레임 이미지 순서 (3x2)
        const roomFrames = [
            'Room_3.png', 'Room_2.png', 'Room_1.png',  // 1행
            'Room_1.png', 'Room_2.png', 'Room_3.png'   // 2행
        ];

        // 디버그 로그 함수
        function debugLog(message) {
            const console = document.getElementById('debugConsole');
            const now = new Date().toLocaleTimeString();
            const logEntry = document.createElement('div');
            logEntry.textContent = `[${now}] ${message}`;
            console.appendChild(logEntry);
            console.scrollTop = console.scrollHeight;

            // 콘솔에도 출력
            window.console.log(message);
        }

        // 페이지 로드 시 웹소켓 연결
        window.onload = function() {
            debugLog('페이지 로드 완료');
            connectWebSocket();
        };

        // 웹소켓 연결
        function connectWebSocket() {
            const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
            const wsUrl = protocol + '//' + window.location.host + '<%= request.getContextPath() %>/lobby';

            debugLog('웹소켓 연결 시도: ' + wsUrl);

            try {
                websocket = new WebSocket(wsUrl);

                websocket.onopen = function() {
                    debugLog('✅ 웹소켓 연결 성공!');
                    updateConnectionStatus(true);
                    // 연결 후 즉시 방 목록 요청
                    setTimeout(requestRoomList, 100);
                };

                websocket.onmessage = function(event) {
                    debugLog('📩 메시지 수신: ' + event.data);
                    handleMessage(event.data);
                };

                websocket.onerror = function(error) {
                    debugLog('❌ 웹소켓 에러');
                    console.error('웹소켓 에러:', error);
                    updateConnectionStatus(false);
                };

                websocket.onclose = function(event) {
                    debugLog('🔌 웹소켓 연결 종료 (코드: ' + event.code + ')');
                    updateConnectionStatus(false);
                    // 3초 후 재연결 시도
                    setTimeout(function() {
                        debugLog('재연결 시도...');
                        connectWebSocket();
                    }, 3000);
                };
            } catch (error) {
                debugLog('❌ 웹소켓 연결 실패: ' + error.message);
                updateConnectionStatus(false);
            }
        }

        // 연결 상태 업데이트
        function updateConnectionStatus(isConnected) {
            const statusElement = document.getElementById('connectionStatus');

            if (isConnected) {
                statusElement.textContent = '🟢 연결됨';
                statusElement.className = 'connection-status status-connected';
            } else {
                statusElement.textContent = '🔴 연결 끊김';
                statusElement.className = 'connection-status status-disconnected';
            }

            // 버튼은 항상 활성화 (클릭 시 연결 여부 체크)
            document.getElementById('createRoomBtn').disabled = false;
        }

        // 방 목록 요청
        function requestRoomList() {
            if (websocket && websocket.readyState === WebSocket.OPEN) {
                const message = {
                    type: 'ROOMLIST'
                };
                debugLog('📤 방 목록 요청: ' + JSON.stringify(message));
                websocket.send(JSON.stringify(message));
            } else {
                debugLog('⚠️ 웹소켓이 열려있지 않음');
            }
        }

        // 메시지 처리
        function handleMessage(data) {
            try {
                const message = JSON.parse(data);
                debugLog('📦 메시지 파싱 성공: type=' + message.type);
                debugLog('📦 전체 메시지 내용: ' + JSON.stringify(message));

                if (message.type === 'ROOMLIST') {
                    debugLog('🏠 방 목록 데이터: ' + JSON.stringify(message.data));
                    debugLog('🏠 방 목록 타입: ' + typeof message.data);
                    debugLog('🏠 배열 여부: ' + Array.isArray(message.data));

                    updateRoomList(message.data);

                    // 방 생성 후 로딩 팝업 숨김
                    if (isCreatingRoom) {
                        debugLog('✅ 방 생성 완료! 로딩 숨김');
                        hideLoading();
                        isCreatingRoom = false;
                    }
                } else if (message.type === 'ERROR') {
                    debugLog('❌ 에러 메시지: ' + JSON.stringify(message.data));
                    alert('에러 발생: ' + JSON.stringify(message.data));
                    hideLoading();
                    isCreatingRoom = false;
                } else {
                    debugLog('⚠️ 알 수 없는 메시지 타입: ' + message.type);
                }
            } catch (error) {
                debugLog('❌ 메시지 파싱 에러: ' + error.message);
                console.error('메시지 파싱 에러:', error, 'Data:', data);
                alert('메시지 파싱 에러: ' + error.message + '\n\n원본 데이터: ' + data);
                hideLoading();
            }
        }

        // 방 목록 업데이트
        function updateRoomList(rooms) {
            if (!rooms) {
                debugLog('⚠️ 방 목록이 null 또는 undefined');
                currentRooms = [];
            } else if (Array.isArray(rooms)) {
                debugLog('✅ 방 목록 배열 수신: ' + rooms.length + '개');
                currentRooms = rooms;
            } else {
                debugLog('⚠️ 방 목록이 배열이 아님: ' + typeof rooms);
                currentRooms = [];
            }

            // 최대 6개로 제한 (3x2 그리드)
            if (currentRooms.length > MAX_ROOMS) {
                currentRooms = currentRooms.slice(0, MAX_ROOMS);
            }

            renderRooms();
        }

        // 방 목록 렌더링
        function renderRooms() {
            const roomsGrid = document.getElementById('roomsGrid');
            roomsGrid.innerHTML = '';

            debugLog('🎨 방 렌더링: ' + currentRooms.length + '개');

            // 방 카드 생성 (최대 6개, 3x2 그리드)
            for (let i = 0; i < MAX_ROOMS; i++) {
                if (i < currentRooms.length) {
                    const room = currentRooms[i];
                    const roomSlot = createRoomSlot(room, i);
                    roomsGrid.appendChild(roomSlot);
                } else {
                    const emptySlot = createEmptySlot(i);
                    roomsGrid.appendChild(emptySlot);
                }
            }
        }

        // 방 슬롯 생성 (프레임 + 버튼)
        function createRoomSlot(room, index) {
            const slot = document.createElement('div');
            slot.className = 'room-slot new';

            // 방 프레임
            const frame = document.createElement('div');
            frame.className = 'room-frame';

            const frameImg = document.createElement('img');
            frameImg.src = '${pageContext.request.contextPath}/assets/images/main/' + roomFrames[index];
            frameImg.alt = '방 프레임';

            // 방 정보
            const info = document.createElement('div');
            info.className = 'room-info';

            const roomNumber = document.createElement('div');
            roomNumber.className = 'room-number';
            roomNumber.textContent = '방 #' + room.roomSeq;

            const roomStatus = document.createElement('div');
            roomStatus.className = 'room-status';
            roomStatus.textContent = getRoomStatusText(room.roomStatus);

            info.appendChild(roomNumber);
            info.appendChild(roomStatus);

            frame.appendChild(frameImg);
            frame.appendChild(info);

            // 버튼들
            const buttons = document.createElement('div');
            buttons.className = 'room-buttons';

            // 입장 버튼
            const enterBtn = document.createElement('button');
            enterBtn.className = 'room-btn';
            enterBtn.onclick = function() {
                enterRoom(room.roomSeq);
            };
            const enterImg = document.createElement('img');
            enterImg.src = '${pageContext.request.contextPath}/assets/images/main/goIn.png';
            enterImg.alt = '입장';
            enterBtn.appendChild(enterImg);

            // 관전 버튼
            const watchBtn = document.createElement('button');
            watchBtn.className = 'room-btn';
            watchBtn.onclick = function() {
                watchRoom(room.roomSeq);
            };
            const watchImg = document.createElement('img');
            watchImg.src = '${pageContext.request.contextPath}/assets/images/main/whitness.png';
            watchImg.alt = '관전';
            watchBtn.appendChild(watchImg);

            buttons.appendChild(enterBtn);
            buttons.appendChild(watchBtn);

            slot.appendChild(frame);
            slot.appendChild(buttons);

            return slot;
        }

        // 빈 슬롯 생성
        function createEmptySlot(index) {
            const slot = document.createElement('div');
            slot.className = 'room-slot empty-slot';

            const frame = document.createElement('div');
            frame.className = 'room-frame';

            const frameImg = document.createElement('img');
            frameImg.src = '${pageContext.request.contextPath}/assets/images/main/' + roomFrames[index];
            frameImg.alt = '빈 방';

            frame.appendChild(frameImg);
            slot.appendChild(frame);

            return slot;
        }

        // 방 상태 텍스트 변환
        function getRoomStatusText(status) {
            switch(status) {
                case 'WAIT': return '대기중 ⏳';
                case 'PLAYING': return '게임중 🎮';
                case 'FINISHED': return '종료됨 ✅';
                default: return status;
            }
        }

        // 로딩 팝업 표시
        function showLoading() {
            debugLog('🔄 로딩 팝업 표시');
            const overlay = document.getElementById('loadingOverlay');
            overlay.classList.add('show');
            overlay.style.display = 'flex';
            document.getElementById('createRoomBtn').disabled = true;
        }

        // 로딩 팝업 숨김
        function hideLoading() {
            debugLog('✅ 로딩 팝업 숨김');
            const overlay = document.getElementById('loadingOverlay');
            overlay.classList.remove('show');
            overlay.style.display = 'none';
            document.getElementById('createRoomBtn').disabled = false;
        }

        // 방 생성
        function createRoom() {
            debugLog('🎮 방 생성 버튼 클릭');

            // 일단 로딩 팝업부터 표시
            showLoading();
            isCreatingRoom = true;

            // 웹소켓 연결 확인
            if (!websocket || websocket.readyState !== WebSocket.OPEN) {
                debugLog('❌ 웹소켓 연결 안됨');
                setTimeout(function() {
                    hideLoading();
                    isCreatingRoom = false;
                    alert('웹소켓이 연결되지 않았습니다. 잠시 후 다시 시도해주세요.');
                }, 500);
                return;
            }

            // 방 개수 확인
            if (currentRooms.length >= MAX_ROOMS) {
                hideLoading();
                isCreatingRoom = false;
                alert('최대 ' + MAX_ROOMS + '개의 방만 생성할 수 있습니다!');
                return;
            }

            try {
                // userId를 숫자로 변환 (간단한 해시)
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

                debugLog('📤 방 생성 요청 전송: ' + JSON.stringify(message));
                websocket.send(JSON.stringify(message));

                // 5초 후 타임아웃
                setTimeout(function() {
                    if (isCreatingRoom) {
                        hideLoading();
                        isCreatingRoom = false;
                        debugLog('⏱️ 방 생성 타임아웃');
                        alert('방 생성 시간이 초과되었습니다. 다시 시도해주세요.');
                    }
                }, 5000);
            } catch (error) {
                debugLog('❌ 방 생성 에러: ' + error.message);
                hideLoading();
                isCreatingRoom = false;
                alert('방 생성 중 오류가 발생했습니다: ' + error.message);
            }
        }

        // 방 입장
        function enterRoom(roomSeq) {
            debugLog('🚪 방 #' + roomSeq + ' 입장 시도');
            if (confirm('방 #' + roomSeq + '에 입장하시겠습니까?')) {
                // TODO: 실제 입장 로직 구현
                alert('방 입장 기능은 준비중입니다. (방 #' + roomSeq + ')');
            }
        }

        // 방 관전
        function watchRoom(roomSeq) {
            debugLog('👀 방 #' + roomSeq + ' 관전 시도');
            if (confirm('방 #' + roomSeq + '를 관전하시겠습니까?')) {
                // TODO: 실제 관전 로직 구현
                alert('관전 기능은 준비중입니다. (방 #' + roomSeq + ')');
            }
        }

        // 방 삭제 (개발용 - 기존 기능 유지)
        function deleteRoom(roomSeq) {
            if (confirm('방 #' + roomSeq + '를 삭제하시겠습니까?')) {
                if (websocket && websocket.readyState === WebSocket.OPEN) {
                    const message = {
                        type: 'DELETE_ROOM',
                        data: {
                            roomSeq: roomSeq
                        }
                    };
                    debugLog('📤 방 삭제 요청: ' + JSON.stringify(message));
                    websocket.send(JSON.stringify(message));
                } else {
                    alert('웹소켓이 연결되지 않았습니다.');
                }
            }
        }

        // 페이지 종료 시 웹소켓 닫기
        window.onbeforeunload = function() {
            if (websocket) {
                debugLog('🔌 웹소켓 연결 종료');
                websocket.close();
            }
        };
    </script>
</body>
</html>
