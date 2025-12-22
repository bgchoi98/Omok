너는 Omok_Mini(Servlet/JSP) 프로젝트에서 백엔드는 절대 수정하지 않고,
오직 다음 파일만 수정한다:

- src/main/webapp/WEB-INF/views/game.jsp

목표:
- 콘솔에는 이미 찍히는 CHAT 메시지(type:"CHAT", sender, message)가
  화면의 채팅 로그 영역(#chatLog 또는 #chatScroll)에 반드시 append되도록 고친다.
- JSP EL 오해석/템플릿리터럴 문제 재발을 완전히 차단한다.

현재 상황/제약:
- JSP는 `${...}`를 EL로 해석해서 터질 수 있다.
- 따라서 JS 코드에 템플릿리터럴(백틱 + ${})을 절대 쓰지 마라.
- innerHTML도 가능하면 쓰지 말고, DOM 생성 + textContent로만 구성해라.
- 수신 payload는 {type,data} 또는 {type,...} 둘 다 올 수 있다.
  => CHAT 처리 시 data는 반드시 아래처럼 정규화해서 사용하라:
     const data = msg.data ?? msg;

수정 범위:
- game.jsp의 WebSocket onmessage switch문에서 case "CHAT" 블록만 최소 diff로 수정한다.
- 다른 기능/스타일/레이아웃은 건드리지 않는다.

구현 요구사항:
1) CHAT 메시지 파싱:
   - sender: data.sender 우선, 없으면 data.nickname, 없으면 "Unknown"
   - message: data.message 우선, 없으면 "" (빈 문자열)
2) 채팅 출력 대상:
   - document.getElementById("chatLog")가 있으면 그곳에 append
   - 없으면 document.getElementById("chatScroll") 사용
   - 둘 다 없으면 console.warn 찍고 break (에러로 터지면 안 됨)
3) 출력 방식:
   - div 한 줄 생성
   - span(이름, 파란색) + span(메시지) 순서로 append
   - textContent 사용 (escapeHtml 함수 필요 없음)
   - append 후 스크롤을 맨 아래로 이동
4) 금지:
   - 백틱 템플릿리터럴 금지
   - ${ } 포함 문자열 금지
   - stray 문자(예: 단독 b) 금지

출력:
- game.jsp에 대한 Unified Diff만 출력해라.
- 설명은 하지 마라. (diff만)
