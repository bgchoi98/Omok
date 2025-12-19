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
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
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

        /* 상단 헤더 영역 */
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
            padding: 0 20px;
        }

        .user-info {
            color: white;
            font-size: 18px;
            font-weight: bold;
        }

        /* 방 생성 버튼 (좌측 상단) */
        .create-room-btn {
            padding: 12px 30px;
            background-color: #4CAF50;
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 16px;
            font-weight: bold;
            cursor: pointer;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.3);
            transition: all 0.3s ease;
        }

        .create-room-btn:hover {
            background-color: #45a049;
            transform: translateY(-2px);
            box-shadow: 0 6px 8px rgba(0, 0, 0, 0.4);
        }

        .create-room-btn:active {
            transform: translateY(0);
        }

        /* 중앙 컨테이너 */
        .room-container-wrapper {
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: calc(100vh - 150px);
        }

        .room-container {
            width: 900px;
            min-height: 500px;
            background-color: rgba(255, 255, 255, 0.95);
            border-radius: 15px;
            padding: 30px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
        }

        .container-title {
            text-align: center;
            font-size: 24px;
            font-weight: bold;
            color: #333;
            margin-bottom: 30px;
            padding-bottom: 15px;
            border-bottom: 3px solid #667eea;
        }

        /* 방 목록 그리드 */
        .rooms-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            grid-template-rows: repeat(2, 1fr);
            gap: 20px;
            min-height: 400px;
        }

        /* 개별 방 카드 */
        .room-card {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border-radius: 10px;
            padding: 20px;
            color: white;
            cursor: pointer;
            transition: all 0.3s ease;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.2);
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            position: relative;
            overflow: hidden;
        }

        .room-card:hover {
            transform: translateY(-5px) scale(1.05);
            box-shadow: 0 8px 12px rgba(0, 0, 0, 0.3);
        }

        .room-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(255, 255, 255, 0.1);
            opacity: 0;
            transition: opacity 0.3s ease;
        }

        .room-card:hover::before {
            opacity: 1;
        }

        .room-number {
            font-size: 36px;
            font-weight: bold;
            margin-bottom: 10px;
        }

        .room-status {
            font-size: 14px;
            opacity: 0.9;
        }

        /* 빈 슬롯 */
        .empty-slot {
            background: rgba(0, 0, 0, 0.05);
            border: 2px dashed rgba(0, 0, 0, 0.1);
            border-radius: 10px;
        }

        /* 연결 상태 표시 */
        .connection-status {
            position: fixed;
            top: 20px;
            right: 20px;
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

        .room-card.new {
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

    <!-- 상단 헤더 -->
    <div class="header">
        <button class="create-room-btn" id="createRoomBtn" onclick="createRoom()">🎮 방 생성</button>
        <div class="user-info">
            👤 <%= user.getNickname() %>님 환영합니다!
        </div>
    </div>

    <!-- 중앙 컨테이너 -->
    <div class="room-container-wrapper">
        <div class="room-container">
            <div class="container-title">오목 대기실 (최대 8개 방)</div>
            <div id="roomsGrid" class="rooms-grid">
                <!-- 방 목록이 여기에 동적으로 생성됩니다 -->
            </div>
        </div>
    </div>

    <!-- 디버그 콘솔 -->
    <div class="debug-console" id="debugConsole"></div>

    <script>
        let websocket = null;
        const MAX_ROOMS = 8;
        let currentRooms = [];
        let isCreatingRoom = false;

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
            const wsUrl = protocol + '//' + window.location.host + '<%= request.getContextPath() %>/roomList';
            
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
            
            // 최대 8개로 제한
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
            
            // 방 카드 생성 (최대 8개)
            for (let i = 0; i < MAX_ROOMS; i++) {
                if (i < currentRooms.length) {
                    const room = currentRooms[i];
                    const roomCard = createRoomCard(room, i);
                    roomsGrid.appendChild(roomCard);
                } else {
                    const emptySlot = createEmptySlot(i);
                    roomsGrid.appendChild(emptySlot);
                }
            }
        }

        // 방 카드 생성
        function createRoomCard(room, index) {
            const card = document.createElement('div');
            card.className = 'room-card new';
            card.onclick = function() {
                deleteRoom(room.roomSeq);
            };
            
            const roomNumber = document.createElement('div');
            roomNumber.className = 'room-number';
            roomNumber.textContent = '방 #' + room.roomSeq;
            
            const roomStatus = document.createElement('div');
            roomStatus.className = 'room-status';
            roomStatus.textContent = getRoomStatusText(room.roomStatus);
            
            const roomAction = document.createElement('div');
            roomAction.className = 'room-status';
            roomAction.style.fontSize = '12px';
            roomAction.style.marginTop = '5px';
            roomAction.textContent = '클릭하여 삭제';
            
            card.appendChild(roomNumber);
            card.appendChild(roomStatus);
            card.appendChild(roomAction);
            
            return card;
        }

        // 빈 슬롯 생성
        function createEmptySlot(index) {
            const slot = document.createElement('div');
            slot.className = 'empty-slot';
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

        // 방 삭제
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
