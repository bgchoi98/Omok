너는 JSP/Servlet 오목 프로젝트의 프론트 개발자다.
“src/main/webapp/main.jsp” 단 1개 파일만 수정해서,
첨부한 목표 스샷(크리스마스 오두막 배경 + 중앙 RoomBox + 2x3 프레임 + 하단 네비 + 우측 트리 + 우하단 설정)과 유사한 배치를 만든다.
목표스샷은 s.png 파일 참고

[절대 제약]
- 오직 main.jsp만 수정한다.
- 다른 JSP/CSS/JS/Java/서블릿 파일 수정/생성 금지.
- 기존 세션 체크/리다이렉트 로직 유지.
- 기존 웹소켓(ROOMLIST 수신→renderRooms) 흐름 최대한 유지.

[에셋 경로 (중요)]
모든 이미지 파일은 다음 폴더에 존재:
src/main/webapp/assets/images/main/

JSP에서는 무조건 contextPath를 먼저 고정해서 JS에서 사용:
const CTX = '<%= request.getContextPath() %>';
const ASSET = CTX + '/assets/images/main/';

※ JSP EL ${} 를 JS 템플릿리터럴 `${}` 안에서 절대 쓰지 마라(경로 깨짐 원인).

[사용 이미지 파일명(대소문자 포함)]
mainBg.png
RoomBox.png
Room_1.png ~ Room_9.png (없을 수 있음 → fallback 필수)
Arrow.png
RankingTree.png
MakeRoomBtn.png
configureIcon.png

[목표 배치(스샷 기준)]
1) 배경: mainBg.png cover, overflow hidden
2) 중앙 RoomBox:
   - 화면 중앙에서 약간 왼쪽
   - RoomBox.png는 background: contain, no-repeat
   - “RoomBox 배경만” 평소 opacity 0.75, hover 시 1.0
     (텍스트/프레임은 흐려지면 안 됨 → ::before pseudo-element로 배경만 처리)
3) RoomBox 안:
   - 2행 3열 그리드로 “방 카드(프레임)” 6개 배치
   - 각 방 카드는 프레임 이미지가 반드시 보여야 함:
     <img src=...>로 넣고 onerror로 Room_1.png fallback
   - 가운데 텍스트:
     Room {roomSeq 또는 roomId}
     상태(Waiting/Playing)
     WAIT는 파란색, PLAYING은 빨간색
     (스샷스타일은 러프한 가이드일 뿐, 색상/폰트 자유 어울리는걸로 제공)
   - hover 시 scale(1.04) + drop-shadow
4) RoomBox 하단 네비(스샷처럼 박스 내부에 위치):

   - 왼쪽: Arrow.png (좌우 반전) => prev page
   - 가운데: MakeRoomBtn.png => createRoom()
   - 오른쪽: Arrow.png => next page
   - 이 네비는 “RoomBox 안”에 있어야 하며 밖으로 절대 튀어나가면 안 됨.
   - 첫 페이지면 왼쪽 화살표 disabled(opacity 낮게 + pointer-events:none)
   - 마지막 페이지면 오른쪽 화살표 disabled
5) 우측 트리:
   - RankingTree.png를 화면 오른쪽, 사진 참고
   - 클릭 시 랭킹 페이지로 이동 (현재는 /rank 유지, 다르면 실제 매핑을 찾아 수정)
6) 우하단 설정 아이콘:
   - configureIcon.png fixed
   - 클릭 시 ConfigPopUp 오버레이를 띄우는 “훅(기본 UI)”만 만들 것
     (지금은 UI만, 실제 로그아웃/탈퇴 요청은 TODO)
7) 디버그 콘솔:
   - 기본 숨김 display:none
   - URL에 ?debug=1이면 보이게

[방 목록 렌더링/확장 고려]
- 서버가 주는 rooms(JSON 배열)를 그대로 사용하되,
  아직 백엔드가 완성 전일 수 있으니 방 객체의 키는 유연하게 처리:
  room.roomSeq || room.roomId || room.id 를 방 번호로 사용
  room.roomStatus || room.status 로 상태 판단
- 상태가 PLAYING이면 클릭 시 watchRoom(roomSeq/id), 아니면 enterRoom(roomSeq/id)
- 프레임 랜덤:
  Room_1~Room_9 중 랜덤 선택
  단, 같은 방(roomId/roomSeq)은 프레임이 유지되도록 Map에 저장(새로고침/갱신에도 유지)
- Room_4~Room_9 파일이 없을 수 있으니 img.onerror로 Room_1 fallback 필수
- 방이 0개면 RoomBox 중앙에 “방을 만드세요” 문구 표시, 방 생기면 자동 숨김
- 페이지네이션:
  pageIndex * 6 ~ pageIndex*6+5 를 화면에 뿌림

[효과음/배경음악 훅]
- 아직 파일이 없어도 에러 안 나게 빈 함수만 준비:
  function playSfx(name) { /* TODO */ }
  function startBgm() { /* TODO */ }
  클릭 이벤트에서 playSfx('click') 호출만 해둔다.

[출력]
- 수정된 main.jsp 전체 코드를 코드블록 하나로만 출력 (diff 금지)
- 스타일은 main.jsp <style> 내부에만 작성(외부 파일 수정 금지)

이제 main.jsp를 위 요구사항대로 수정해라.
