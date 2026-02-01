# 🎮 Omok - 실시간 웹 오목 게임

![Java](https://img.shields.io/badge/Java-8-007396?style=for-the-badge&logo=java&logoColor=white)
![JSP](https://img.shields.io/badge/JSP-Servlet-FF0000?style=for-the-badge&logo=apachetomcat&logoColor=white)
![WebSocket](https://img.shields.io/badge/WebSocket-Realtime-0099FF?style=for-the-badge&logo=websocket&logoColor=white)
![MariaDB](https://img.shields.io/badge/MariaDB-003545?style=for-the-badge&logo=mariadb&logoColor=white)
![Tomcat](https://img.shields.io/badge/Apache%20Tomcat-9-F8DC75?style=for-the-badge&logo=apachetomcat&logoColor=black)

> **WebSocket 기반 실시간 멀티플레이 오목 게임 플랫폼**  
> 실시간 대전, 채팅, 관전, 랭킹 시스템을 제공하는 웹 기반 오목 게임입니다.

---

## 📋 목차

- [프로젝트 소개](#-프로젝트-소개)
- [주요 기능](#-주요-기능)
- [기술 스택](#-기술-스택)
- [시스템 아키텍처](#-시스템-아키텍처)
- [ERD](#-erd)
- [API 명세서](#-api-명세서)
- [설치 및 실행](#-설치-및-실행)
- [프로젝트 구조](#-프로젝트-구조)
- [주요 구현 사항](#-주요-구현-사항)

---

## 🎯 프로젝트 소개

**Omok Mini**는 WebSocket을 활용한 실시간 멀티플레이 오목 게임 플랫폼입니다.  
전통적인 JSP/Servlet 기술 스택을 기반으로 하되, WebSocket을 통한 실시간 양방향 통신으로 끊김 없는 게임 경험을 제공합니다.

### 📅 프로젝트 정보

- **개발 기간**: 2024.12.12 ~ 2024.12.24 (13일)
- **개발 인원**: 6명 (팀 프로젝트)
- **프로젝트 테마**: 🎄 크리스마스 (발표일: 12월 24일)

### ✨ 핵심 가치

- **실시간성**: WebSocket 기반 즉각적인 게임 상태 동기화
- **확장성**: MVC 패턴과 Repository 패턴을 통한 유지보수성 확보
- **사용자 경험**: 직관적인 UI/UX와 실시간 피드백
- **커뮤니티**: 채팅, 관전, 랭킹 시스템을 통한 사용자 간 소통

---

## 🔥 주요 기능

### 1. 회원 관리 시스템
- ✅ **회원가입**: 아이디/닉네임 중복 검사 (AJAX)
- ✅ **로그인/로그아웃**: 세션 기반 인증
- ✅ **회원탈퇴**: 비밀번호 재확인 후 탈퇴 처리

### 2. 게임 로비
- 🎮 **방 목록 조회**: 실시간 방 상태 확인 (대기/게임중/종료)
- 🎮 **방 생성**: 방장 시스템, 최대 2인 플레이어
- 🎮 **빠른 참가**: 대기 중인 방 자동 입장

### 3. 실시간 오목 게임
- ⚫⚪ **15x15 바둑판**: 표준 오목 규칙 적용
- ⚫⚪ **턴제 시스템**: 흑돌/백돌 번갈아가며 착수
- ⚫⚪ **승리 판정**: 5목 달성 시 자동 승리 처리
- ⚫⚪ **기권 기능**: 게임 중 기권 가능
- ⚫⚪ **관전 모드**: 진행 중인 게임 실시간 관전

### 4. 실시간 채팅
- 💬 게임 중 실시간 채팅
- 💬 플레이어 및 관전자 모두 참여 가능
- 💬 타임스탬프 표시

### 5. 랭킹 시스템
- 🏆 전적 기록 (승/패/승률)
- 🏆 실시간 랭킹 업데이트
- 🏆 승률 기반 순위 정렬

### 6. 아바타 시스템
- 👤 플레이어별 아바타 선택 (1~4번)
- 👤 게임 중 아바타 표시

---

## 🛠 기술 스택

### Backend
```
- Java 8
- JSP 2.3 / Servlet 4.0
- WebSocket (javax.websocket-api)
- JSTL 1.2
- Gson 2.13.2
- SLF4J 2.0.17 (slf4j-api + slf4j-simple)
- MariaDB Java Client 3.3.2
```

### Frontend
```
- HTML5 / CSS3
- JavaScript (ES6+)
- WebSocket API
- AJAX (Fetch API)
```

### Database
```
- MariaDB 11.4.8
- MariaDB Java Client 3.3.2
- JNDI DataSource (Connection Pooling)
```

### Server & Deployment
```
- Apache Tomcat 9.0
- AWS EC2 (Ubuntu)
- AWS RDS (MariaDB)
```

### Development Tools
```
- Eclipse IDE
- DBeaver (Database Management)
- Postman (API Testing)
- Git / GitHub
- Maven (라이브러리 관리)
```

---

## 🏗 시스템 아키텍처

```
┌─────────────────────────────────────────────────────────────┐
│                         Client Layer                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Browser    │  │  WebSocket   │  │    AJAX      │      │
│  │  (HTML/CSS)  │  │    Client    │  │   Request    │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                              ↕
┌─────────────────────────────────────────────────────────────┐
│                      Presentation Layer                      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │    Filter    │  │  Controller  │  │  WebSocket   │      │
│  │  (Encoding,  │  │   Servlet    │  │  Endpoint    │      │
│  │   Auth)      │  └──────────────┘  └──────────────┘      │
│  └──────────────┘           ↕                ↕              │
└─────────────────────────────────────────────────────────────┘
                              ↕
┌─────────────────────────────────────────────────────────────┐
│                       Business Layer                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ UserService  │  │ GameService  │  │ RankService  │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                              ↕
┌─────────────────────────────────────────────────────────────┐
│                      Persistence Layer                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │    User      │  │     Rank     │  │     Room     │      │
│  │  Repository  │  │  Repository  │  │  Repository  │      │
│  │   (JDBC)     │  │   (JDBC)     │  │  (Memory)    │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│   JDBCRepository         │            ConcurrentHashMap     │
└─────────────────────────────────────────────────────────────┘
                              ↕
┌─────────────────────────────────────────────────────────────┐
│                        Database Layer                        │
│                    MariaDB (AWS RDS)                         │
│           JNDI DataSource (Connection Pool)                  │
│              + In-Memory Storage (Room)                      │
└─────────────────────────────────────────────────────────────┘
```

### 주요 설계 패턴

#### 1. **MVC 패턴**
- **Model**: User, Room, Rank, GameState 등 도메인 모델
- **View**: JSP 페이지 (signIn.jsp, main.jsp, game.jsp, rank.jsp)
- **Controller**: Servlet 기반 Controller (UserController, LobbyController, RankController)

#### 2. **Repository 패턴**
- 추상 클래스 `JDBCRepository<E, ID>`를 통한 공통 CRUD 로직 캡슐화
- **DB 기반 Repository**: UserRepository, RankRepository (JDBCRepository 상속)
- **메모리 기반 Repository**: RoomRepository (ConcurrentHashMap 사용, 실시간 세션 관리)

#### 3. **Singleton 패턴**
- Service, Repository 클래스에 적용 (멀티 스레드 환경 고려)

#### 4. **Observer 패턴**
- WebSocket을 통한 게임 상태 변화 실시간 브로드캐스팅

---

## 📊 ERD

```sql
┌──────────────────────────┐
│        USERS             │
├──────────────────────────┤
│ SEQ_ID (PK)       BIGINT │
│ USER_ID (UQ)      VARCHAR│
│ USER_PW           VARCHAR│
│ EMAIL             VARCHAR│
│ NICKNAME (UQ)     VARCHAR│
│ CREATED_AT        TIMESTAMP│
│ DELETED_AT        TIMESTAMP│
└──────────────────────────┘
             │
             │ 1:1
             ↓
┌──────────────────────────┐
│        RANKS             │
├──────────────────────────┤
│ USERS_SEQ_ID (PK,FK) BIGINT│
│ WIN               INT    │
│ LOSE              INT    │
│ RATE              INT    │
└──────────────────────────┘
```

### 테이블 상세

#### USERS 테이블
| 컬럼명 | 타입 | 제약조건 | 설명 |
|--------|------|----------|------|
| SEQ_ID | BIGINT | PK, AUTO_INCREMENT | 사용자 고유 ID |
| USER_ID | VARCHAR(50) | UNIQUE, NOT NULL | 로그인 아이디 |
| USER_PW | VARCHAR(50) | NOT NULL | 비밀번호 (평문 저장) |
| EMAIL | VARCHAR(100) | NOT NULL | 이메일 |
| NICKNAME | VARCHAR(50) | UNIQUE, NOT NULL | 닉네임 |
| CREATED_AT | TIMESTAMP | NOT NULL | 가입일시 |
| DELETED_AT | TIMESTAMP | NULL | 탈퇴일시 |

#### RANKS 테이블
| 컬럼명 | 타입 | 제약조건 | 설명 |
|--------|------|----------|------|
| USERS_SEQ_ID | BIGINT | PK, FK (USERS.SEQ_ID) | 사용자 ID |
| WIN | INT | DEFAULT 0 | 승리 횟수 |
| LOSE | INT | DEFAULT 0 | 패배 횟수 |
| RATE | INT | DEFAULT 0 | 승률 (%) |

---

## 📡 API 명세서

### 1. 회원 관리 API

#### 1.1 로그인 페이지
```http
GET /sign/signIn
```
**응답**: 로그인 페이지 (signIn.jsp)

#### 1.2 로그인 처리
```http
POST /sign/signIn
Content-Type: application/x-www-form-urlencoded

user_id=testuser&user_pw=password123
```
**성공 응답**: 302 Redirect → `/main`  
**실패 응답**: 로그인 페이지 + 에러 메시지

#### 1.3 회원가입 페이지
```http
GET /sign/signUp
```
**응답**: 회원가입 페이지 (signUp.jsp)

#### 1.4 아이디/닉네임 중복 검사
```http
GET /sign/signUp?ajaxCheck=true&type=id&value=testuser
GET /sign/signUp?ajaxCheck=true&type=nickname&value=홍길동
```
**응답**: `"true"` (사용 가능) or `"false"` (중복)

#### 1.5 회원가입 처리
```http
POST /sign/signUp
Content-Type: application/x-www-form-urlencoded

user_id=testuser&user_pw=password123&email=test@example.com&nickname=홍길동
```
**성공 응답**: 302 Redirect → `/sign/signIn?msg=register`

#### 1.6 로그아웃
```http
POST /sign/signOut
```
**응답**: 302 Redirect → `/sign/signIn?msg=logout`

#### 1.7 회원탈퇴
```http
POST /sign/signWithdraw
Content-Type: application/x-www-form-urlencoded

user_pw=password123
```
**성공 응답**: 302 Redirect → `/sign/signIn?msg=bye`  
**실패 응답**: 302 Redirect → `/main?error=wrong_password`

---

### 2. 로비 API

#### 2.1 메인 로비
```http
GET /main
```
**응답**: 메인 로비 페이지 (main.jsp)  
**인증**: 로그인 필요 (세션 검증)

#### 2.2 게임 페이지
```http
GET /main/game
```
**응답**: 게임 페이지 (game.jsp)

---

### 3. 랭킹 API

#### 3.1 랭킹 조회
```http
GET /rank
```
**응답**: 랭킹 페이지 (rank.jsp) + 랭킹 데이터

---

### 4. WebSocket API

#### 4.1 게임 WebSocket 연결
```
ws://[host]/game
```

##### 메시지 타입

**1) JOIN_GAME - 게임 입장**
```json
{
  "type": "JOIN_GAME",
  "roomSeq": 1
}
```
**응답**:
```json
{
  "type": "JOIN_GAME_SUCCESS",
  "roomSeq": 1,
  "isPlayer": true,
  "isObserver": false,
  "blackPlayer": "player1",
  "whitePlayer": "player2",
  "currentTurn": "player1",
  "boardSize": 19,
  "board": [[0, 0, ...], ...],
  "myStone": 1,
  "p1Avatar": 1,
  "p2Avatar": 2
}
```

**2) MAKE_MOVE - 돌 착수**
```json
{
  "type": "MAKE_MOVE",
  "row": 9,
  "col": 9
}
```
**브로드캐스트**:
```json
{
  "type": "MOVE",
  "row": 9,
  "col": 9,
  "stone": 1,
  "player": "player1",
  "currentTurn": "player2"
}
```

**3) CHAT - 채팅**
```json
{
  "type": "CHAT",
  "message": "안녕하세요!"
}
```
**브로드캐스트**:
```json
{
  "type": "CHAT",
  "sender": "player1",
  "message": "안녕하세요!",
  "timestamp": 1704067200000
}
```

**4) EXIT - 기권/나가기**
```json
{
  "type": "EXIT"
}
```
**브로드캐스트**:
```json
{
  "type": "GAME_OVER",
  "result": "WIN",
  "winner": "player2",
  "message": "player1님이 기권하여 player2님이 승리했습니다."
}
```

**5) GAME_OVER - 게임 종료**
```json
{
  "type": "GAME_OVER",
  "result": "WIN",
  "winner": "player1",
  "message": "player1님이 승리했습니다!"
}
```

#### 4.2 로비 WebSocket 연결
```
ws://[host]/room/{roomSeq}
```

##### 메시지 타입

**1) JOIN_ROOM - 방 입장**
```json
{
  "type": "JOIN_ROOM"
}
```

**2) LEAVE_ROOM - 방 나가기**
```json
{
  "type": "LEAVE_ROOM"
}
```

**3) START_GAME - 게임 시작**
```json
{
  "type": "START_GAME",
  "avatarNum": 1
}
```

---

## ⚙️ 설치 및 실행

### 사전 요구사항
- Java 8 이상
- Apache Tomcat 9
- MariaDB 10.x 이상

### 의존성 라이브러리

프로젝트에 필요한 JAR 파일들은 `src/main/webapp/WEB-INF/lib/` 디렉토리에 포함되어 있습니다:

| 라이브러리 | 버전 | 용도 |
|-----------|------|------|
| gson | 2.13.2 | JSON 파싱 및 직렬화 |
| mariadb-java-client | 3.3.2 | MariaDB JDBC 드라이버 |
| jstl | 1.2 | JSP 표준 태그 라이브러리 |
| slf4j-api | 2.0.17 | 로깅 API |
| slf4j-simple | 2.0.17 | SLF4J 로깅 구현체 |

> 💡 **참고**: JAR 파일들은 이미 프로젝트에 포함되어 있으므로 별도 다운로드가 필요하지 않습니다.

---

### 1. 프로젝트 클론
```bash
git clone https://github.com/nippyclouding/Omok.git
cd Omok_Mini
```

### 2. 데이터베이스 설정

#### 2.1 MariaDB 설치 및 데이터베이스 생성
```sql
CREATE DATABASE omokdb CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

USE omokdb;

-- USERS 테이블
CREATE TABLE `USERS` (
  `SEQ_ID` bigint(20) NOT NULL AUTO_INCREMENT,
  `USER_ID` varchar(50) NOT NULL,
  `USER_PW` varchar(50) NOT NULL,
  `EMAIL` varchar(100) NOT NULL,
  `NICKNAME` varchar(50) NOT NULL,
  `CREATED_AT` timestamp NOT NULL,
  `DELETED_AT` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`SEQ_ID`),
  UNIQUE KEY `USER_ID` (`USER_ID`),
  UNIQUE KEY `NICKNAME` (`NICKNAME`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- RANKS 테이블
CREATE TABLE `RANKS` (
  `USERS_SEQ_ID` bigint(20) NOT NULL,
  `WIN` int(11) NOT NULL DEFAULT 0,
  `LOSE` int(11) NOT NULL DEFAULT 0,
  `RATE` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`USERS_SEQ_ID`),
  KEY `idx_rate` (`RATE`),
  CONSTRAINT `fk_user_record_users` FOREIGN KEY (`USERS_SEQ_ID`) REFERENCES `USERS` (`SEQ_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
```

#### 2.2 DB 연결 설정
```bash
# db.properties.example을 복사하여 db.properties 생성
cp src/main/webapp/WEB-INF/db.properties.example \
   src/main/webapp/WEB-INF/db.properties

# db.properties 파일 수정
vi src/main/webapp/WEB-INF/db.properties
```

**db.properties 내용**:
```properties
db.driver=org.mariadb.jdbc.Driver
db.url=jdbc:mariadb://localhost:3306/omokdb?useSSL=false&characterEncoding=UTF-8
db.username=your_username
db.password=your_password
db.maxTotal=20
db.maxIdle=10
db.maxWaitMillis=1000
```

#### 2.3 Tomcat Context 설정
`$TOMCAT_HOME/conf/Catalina/localhost/Omok_Mini.xml` 파일 생성:
```xml
<Context>
    <Resource
        name="jdbc/omokdb"
        auth="Container"
        type="javax.sql.DataSource"
        driverClassName="org.mariadb.jdbc.Driver"
        url="jdbc:mariadb://localhost:3306/omokdb?useSSL=false&amp;characterEncoding=UTF-8"
        username="your_username"
        password="your_password"
        maxTotal="20"
        maxIdle="10"
        maxWaitMillis="1000"
    />
</Context>
```

### 3. 빌드 및 배포

#### 3.1 빌드
```bash
# 빌드 스크립트 실행 권한 부여
chmod +x scripts/build.sh

# 빌드
./scripts/build.sh
```

#### 3.2 Tomcat 배포 (심링크 방식 권장)
```bash
# 기존 배포 제거
rm -rf $TOMCAT_HOME/webapps/Omok_Mini

# 심링크 생성
ln -s $(pwd)/src/main/webapp $TOMCAT_HOME/webapps/Omok_Mini

# Tomcat 캐시 삭제
rm -rf $TOMCAT_HOME/work/Catalina/localhost/Omok_Mini
```

### 4. Tomcat 실행
```bash
# 시작
$TOMCAT_HOME/bin/startup.sh

# 로그 확인
tail -f $TOMCAT_HOME/logs/catalina.out

# 종료 (필요 시)
$TOMCAT_HOME/bin/shutdown.sh
```

### 5. 접속
```
http://localhost:8080/Omok_Mini
```

> 💡 **Tip**: 자세한 빌드 및 배포 가이드는 [빌드및배포.md](빌드및배포.md) 파일을 참고하세요.

---

## 📁 프로젝트 구조

```
Omok_Mini/
├── src/
│   └── main/
│       ├── java/
│       │   ├── filter/              # 필터 (인코딩, 인증)
│       │   │   ├── EncodingFilter.java
│       │   │   └── SignInCheckFilter.java
│       │   ├── user/                # 회원 관리
│       │   │   ├── User.java
│       │   │   ├── UserController.java
│       │   │   ├── UserService.java
│       │   │   ├── UserRepository.java
│       │   │   └── dto/
│       │   │       ├── SignInForm.java
│       │   │       └── SignUpForm.java
│       │   ├── room/                # 방 관리 & 로비
│       │   │   ├── Room.java
│       │   │   ├── RoomRepository.java
│       │   │   ├── RoomService.java
│       │   │   ├── RoomStatus.java
│       │   │   ├── RoomWebSocket.java
│       │   │   ├── LobbyUser.java
│       │   │   └── LobbyController.java
│       │   ├── game/                # 게임 로직
│       │   │   ├── GameState.java
│       │   │   ├── GameService.java
│       │   │   ├── GameWebSocket.java
│       │   │   ├── GameUser.java
│       │   │   └── Observer.java
│       │   ├── rank/                # 랭킹 시스템
│       │   │   ├── Rank.java
│       │   │   ├── RankController.java
│       │   │   ├── RankService.java
│       │   │   └── RankRepository.java
│       │   └── util/                # 유틸리티
│       │       ├── Constants.java
│       │       ├── JDBCRepository.java
│       │       └── webSocketDTOs/
│       │           ├── WebSocketMessage.java
│       │           ├── MessageType.java
│       │           └── GetHttpSessionConfigurator.java
│       └── webapp/
│           ├── WEB-INF/
│           │   ├── views/           # JSP 뷰
│           │   │   ├── signIn.jsp
│           │   │   ├── signUp.jsp
│           │   │   ├── main.jsp
│           │   │   ├── game.jsp
│           │   │   └── rank.jsp
│           │   ├── lib/             # 라이브러리 (JAR)
│           │   │   ├── gson-2.13.2.jar
│           │   │   ├── mariadb-java-client-3.3.2.jar
│           │   │   ├── jstl-1.2.jar
│           │   │   ├── slf4j-api-2.0.17.jar
│           │   │   └── slf4j-simple-2.0.17.jar
│           │   ├── web.xml          # 웹 애플리케이션 설정
│           │   └── db.properties    # DB 설정 (Git 제외)
│           └── assets/              # 정적 리소스
│               ├── images/
│               ├── js/
│               └── sounds/
├── scripts/
│   └── build.sh                     # 빌드 스크립트
├── .gitignore
├── README.md
└── 빌드및배포.md
```

---

## 💡 주요 구현 사항

### 1. WebSocket 실시간 통신
- **양방향 통신**: 서버 ↔ 클라이언트 실시간 데이터 동기화
- **브로드캐스팅**: 같은 방의 모든 참여자에게 게임 상태 전파
- **세션 관리**: ConcurrentHashMap을 활용한 스레드 안전 세션 관리

### 2. Repository 패턴

**DB 기반 Repository (JDBCRepository 상속)**
```java
public abstract class JDBCRepository<E, ID> {
    protected Connection getConnection() throws SQLException;
    protected <T> T executeQuery(String sql, ...);
    protected int executeUpdate(String sql, ...);
    public abstract E findById(Long id);
    public abstract List<E> findAll();
    // ...
}
```
- 공통 CRUD 로직을 추상 클래스로 캡슐화
- UserRepository, RankRepository가 JDBCRepository를 상속
- JNDI DataSource를 통한 커넥션 풀 활용

**메모리 기반 Repository**
```java
public class RoomRepository {
    private static Map<Long, Room> rooms = new ConcurrentHashMap<>();
    
    public Room save(LobbyUser lobbyUser);
    public List<Room> findAll();
    public Room findById(Long roomId);
    public List<Room> findByStatus(RoomStatus status);
    // ...
}
```
- RoomRepository는 ConcurrentHashMap 사용 (실시간 세션 관리)
- 게임 방은 휘발성 데이터로 DB 저장 불필요
- 빠른 읽기/쓰기 성능과 동시성 제어

### 3. 게임 로직
```java
public class GameState {
    private int[][] board = new int[19][19];  // 0: 빈칸, 1: 흑, 2: 백
    private String currentTurn;               // 현재 턴
    private String winner;                    // 승자
    
    public boolean makeMove(int row, int col, String player);
    public boolean checkWin(int row, int col);
    public void quit(String player);
}
```
- **턴제 시스템**: 흑/백 번갈아가며 착수
- **승리 판정**: 가로/세로/대각선 5목 체크
- **무효수 검증**: 범위 체크, 착수 가능 여부 확인

### 4. 세션 기반 인증
```java
@WebFilter(urlPatterns = {"/*"})
public class SignInCheckFilter implements Filter {
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) {
        HttpSession session = httpRequest.getSession(false);
        User user = (User) session.getAttribute("signInUser");
        
        if (user == null && requiresAuth(uri)) {
            response.sendRedirect("/sign/signIn");
            return;
        }
        chain.doFilter(request, response);
    }
}
```
- 모든 요청에 대한 인증 검증
- 로그인 필요 페이지 접근 시 로그인 페이지로 리다이렉트

### 5. AJAX 중복 검사
```javascript
// 아이디 중복 검사
fetch(`/sign/signUp?ajaxCheck=true&type=id&value=${userId}`)
    .then(response => response.text())
    .then(isAvailable => {
        if (isAvailable === "false") {
            alert("이미 사용 중인 아이디입니다.");
        }
    });
```
- 회원가입 시 실시간 중복 검사
- 사용자 경험 향상

### 6. PRG 패턴 (Post-Redirect-Get)
```java
// 회원가입 처리 후 PRG 패턴 적용
if (isValid) {
    User savedUser = USERSERVICE.signUp(user);
    res.sendRedirect(req.getContextPath() + Constants.SIGNIN + "?msg=register");
}
```
- 회원가입, 로그인 등 POST 요청 후 Redirect로 새로고침 이슈 방지
- 폼 재전송 문제 해결

### 7. SQL 성능 최적화 (인덱싱)
```sql
-- 랭킹 조회 성능 향상을 위한 인덱스 생성
CREATE INDEX idx_rate ON RANKS(RATE);
```
- RATE 컬럼에 인덱스 생성으로 정렬 성능 최적화
- `/rank` 요청 시 매번 정렬 작업 불필요
- 데이터 삽입 시 정렬된 상태 자동 유지


---
## 🚀 배포

### 프로덕션 환경

- **URL**: https://www.shinhan6th.com
- **서버**: AWS EC2 (Ubuntu)
- **데이터베이스**: AWS RDS (MariaDB)
- **웹서버**: Nginx + Certbot (HTTPS)
- **도메인**: 가비아

> ⚠️ **참고**: 현재 비용 절감을 위해 EC2 인스턴스가 중지된 상태입니다.

### 아키텍처
```
[사용자] → [가비아 도메인] → [AWS EC2 - Nginx (HTTPS)] 
         → [Tomcat 9] → [AWS RDS - MariaDB]
```

### 주요 설정

- **HTTPS**: Let's Encrypt SSL 인증서 (Certbot 자동 갱신)
- **리버스 프록시**: Nginx → Tomcat (8080 포트)
- **WebSocket**: Nginx에서 WebSocket 프록시 설정
- **보안**: RDS Private Subnet, Security Group 설정

---

## 🚀 향후 개선 사항

### 보안
- [ ] 비밀번호 암호화 (BCrypt)
- [ ] SQL Injection 방어 (PreparedStatement 완전 적용)
- [ ] XSS 방어 (입력값 검증 및 이스케이프)
- [ ] CSRF 토큰 적용

### 기능
- [ ] 친구 시스템
- [ ] 1:1 매칭 시스템
- [ ] 게임 복기 저장
- [ ] 시간 제한 (타이머)
- [ ] 무르기 기능
- [ ] 이메일 인증
- [ ] 비밀번호 찾기

---

## 📸 아래 링크에서 부가적인 내용과 시연 화면을 확인할 수 있습니다.

https://nippyclouding.tistory.com/30

---

## 📝 라이선스

이 프로젝트는 개인 학습 목적으로 제작되었습니다.

---

## 🙏 Acknowledgments

- **Shinhan DS SW Academy**: 프로젝트 기획 및 개발 지원
- **Apache Tomcat**: 안정적인 서블릿 컨테이너 제공
- **MariaDB**: 오픈소스 데이터베이스
- **Google Gson**: JSON 파싱 라이브러리

---

<div align="center">



Developed by Team 배꼽시계 | Shinhan DS SW Academy 6기

</div>
