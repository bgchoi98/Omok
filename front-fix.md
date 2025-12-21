# Claude Code Prompt (복붙용) — Omok_Mini 프론트만 수정 (game.jsp/main.jsp) 문제 해결 + Unified Diff 출력 강제

너는 Omok_Mini(Servlet/JSP) 프로젝트에서 **백엔드(Java) 코드는 절대 수정하지 않고**,  
**오직 `game.jsp` / `main.jsp`만** 최소 diff로 수정한다.


(파일 구조 변경/대규모 리팩토링/새 폴더 분리 금지)

---

## ✅ 목표(프론트만)

### 1) 채팅이 콘솔에만 찍히고 화면에 안 보이는 문제 해결

- 콘솔에서 이미 `type:"CHAT", sender, message`가 수신되고 있음이 확인됨.
- 채팅 로그 UI에 실제로 append 되도록 구현해라.
- `#chatLog` 요소가 없다면 **채팅 종이 영역 내부에 생성**해라(가려지지 않게).

### 2) 플레이어 이름이 없고 항상 Waiting...으로 고정되는 문제 해결

- `JOIN_GAME_SUCCESS`를 처리해서 `blackPlayer/whitePlayer`를 p1/p2 박스에 표시해라.
- 보험으로 `MOVE` 메시지의 `{stone, player}`를 이용해 p1/p2 이름을 보정해라.
- p1/p2 표시 DOM id는 **game.jsp에서 실제 요소를 찾아** 사용하라(임의 id 추측/하드코딩 금지).

### 3) 게임 중간에 “나가기”가 제대로 안 되는 문제 해결

- 나가기 버튼 클릭 시:
  1. 서버가 무시해도 무해하게 `EXIT` 또는 `LEAVE_GAME` 메시지를 1회 send 시도
  2. `socket.close(1000,"leave")`
  3. 로비로 `location.replace(정확한 로비 URL)` 이동
- `beforeunload`에서도 `socket.close()` 되게 해서 “나갔는데 접속 유지”를 방지하라.
- 로비 URL은 **프로젝트의 main.jsp(로비 페이지) 실제 경로를 기준으로 정확히 찾아서** 사용하라(추측 금지).

### 4) 로비에서 방 목록이 “잔상처럼” 오래 남아 보이는 현상 최소화

- `main.jsp` 로비 진입/로비 WS 연결 시점에 `allRooms = []`로 초기화하고,
  **ROOMLIST를 수신했을 때만** 렌더하도록 만들어라.
- ROOMLIST 수신 시 DOM을 “부분 업데이트”하지 말고, **일관되게 통째로 갱신**하도록 하여 이전 잔상이 남지 않게 해라.

---

## ✅ 제약(호환성/안정성 필수)

### 메시지 파싱 호환

수신 메시지가 `{type,data:{...}}` 또는 `{type,...}` 둘 다 대응해야 한다.

- 공통 파싱 패턴을 반드시 사용:
  - `const msg = JSON.parse(e.data);`
  - `const type = msg.type;`
  - `const data = msg.data ?? msg;`

### Unknown type 로그

처리되지 않은 type은 반드시:

- `console.warn("Unknown WS type:", type, msg);`

### 최소 diff 원칙

- 기존 함수/변수 최대 활용(예: updateRoomList, placeStone, updateTurnUI 등)
- 필요한 경우에만 짧은 유틸 함수 추가(escapeHtml, appendChatLine 등)
- 기존 UI 스타일/레이아웃은 최대한 유지(기능 연결 위주)

---

## ✅ 디버그 로그(필수: 1줄씩만)

다음 이벤트마다 콘솔에 1줄 로그를 남겨 실제 동작을 검증하라:

- `JOIN_GAME_SUCCESS` 수신
- `CHAT` 수신(화면 append 직전)
- `MOVE` 수신
- `GAME_OVER` 수신
- `socket.onclose` / `socket.onerror` (gameEnded 여부 포함 가능)

---

## ✅ 결과물(반드시 준수)

1. 수정 대상 파일은 오직 아래 2개:

- `src/main/webapp/WEB-INF/views/game.jsp`
- `src/main/webapp/WEB-INF/views/main.jsp`

2. 최종 출력은 반드시 **Unified Diff** 형식:

- `--- a/...`
- `+++ b/...`
- `@@` 라인 포함

3. **추측 금지 강제 조건**

- p1/p2/exit/chatLog의 DOM id, 로비 이동 URL, 채팅 영역 위치는
  반드시 실제 파일을 열어 확인한 뒤 그 값으로 patch를 작성하라.
- 임의로 id를 만들어 붙이지 말고(필요 시 “기존 영역 내부에 생성”만 허용),
  존재하지 않는 함수/변수명을 새로 만들지 말고(필요하면 아주 작은 유틸만 추가).

---

## 🔥 지금부터 실행

위 조건으로 `game.jsp`와 `main.jsp`를 패치하고, **Unified Diff**를 출력해라.
백엔드는 절대 건드리지 마라.
