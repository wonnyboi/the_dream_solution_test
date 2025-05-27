# 더 드림 솔루션 Flutter 개발 지원자 정휘원 Readme

### APK 빌드 파일

https://drive.google.com/file/d/1Ur2mm7I-yREgYZaormrBspjKuNA9lt62/view?usp=sharing

### Firebase를 활용한 Web 배포

https://the-dream-solution.web.app/

## 📦 사용된 라이브러리

### 핵심 라이브러리

- **flutter_riverpod**: 상태 관리
- **go_router**: 라우팅 관리
- **http & http_interceptor**: API 통신 및 인터셉터
- **flutter_secure_storage**: 민감 정보 저장
- **envied**: 환경 변수 관리

### UI/UX 라이브러리

- **markdown_widget**: 마크다운 렌더링
- **image_picker**: 이미지 선택 및 업로드
- **cupertino_icons**: iOS 스타일 아이콘

### 배포 관련

- **firebase_core**: Firebase 웹 배포

## 🏗️ 프로젝트 구조

```
lib/
├── core/                 # 핵심 기능
│   ├── config/          # 환경 설정
│   ├── network/         # 네트워크 관련
│   ├── services/        # 공통 서비스
│   └── storage/         # 저장소 관리
│
└── features/            # 기능별 모듈
    ├── auth/            # 인증 관련
    │   ├── api/         # API 통신
    │   ├── model/       # 데이터 모델
    │   ├── presentation/# UI 컴포넌트
    │   └── providers/   # 상태 관리
    │
    ├── board/           # 게시판 관련
    │   ├── api/
    │   ├── model/
    │   ├── presentation/
    │   └── providers/
    │
    └── main/            # 메인 화면
        └── presentation/
```

## 🔐 JWT 토큰 처리

### 토큰 디코딩

```dart
Map<String, dynamic> decodeJwtPayload(String token) {
  final parts = token.split('.');
  if (parts.length != 3) {
    throw Exception('잘못된 토큰 형식입니다');
  }

  final payload = parts[1];
  final normalized = base64Url.normalize(payload);
  final decoded = utf8.decode(base64Url.decode(normalized));

  return json.decode(decoded);
}
```

### 사용자 정보 추출

- Access Token에서 username과 name 정보를 추출하여 저장
- 로그인 시에만 사용자 정보 저장
- 토큰 갱신 시에는 토큰만 업데이트

## 📥 설치 가이드

1. 프로젝트 클론

   ```bash
   git clone [프로젝트_저장소_URL]
   cd the_dream_solution
   ```

2. 환경 변수 설정

   - 프로젝트 루트 디렉토리에 `.env` 파일 생성
   - 다음 환경 변수를를 설정:
     ```
     DREAM_SERVER="https://front-mission.bigs.or.kr"
     ```

3. Flutter 의존성 설치

   ```bash
   flutter pub get
   ```

4. Envied 파일 설치

   ```bash
   dart run build_runner build
   ```

5. 프로젝트 실행

   - 모바일 환경:
     ```bash
     flutter run
     ```

6. 빌드

   - 안드로이드 빌드:
     ```bash
     flutter build apk
     ```

## 🌐 Web 자동 배포 안내

### 배포 프로세스

1. GitHub 저장소에 코드 푸시
2. GitHub Actions 워크플로우 자동 실행
3. Firebase Hosting에 자동 배포

### 배포 설정

- GitHub Actions 워크플로우 파일: `.github/workflows/firebase-hosting-merge.yml`
- Firebase 프로젝트 설정: `firebase.json`
- 웹 빌드 설정: `web/index.html`

### 배포 확인

- 배포된 웹사이트: https://the-dream-solution.web.app/
- GitHub Actions 로그: 저장소의 Actions 탭에서 확인 가능

자세한 배포 설정 및 과정은 [GitHub with Firebase and Flutter](https://magnificent-postbox-bff.notion.site/01-Github-with-Firebase-and-Flutter-19e42b921da180f88b4bc6ea9dbb0cc6) 문서를 참고해주세요.

## ⚠️ CORS 관련 안내

이 프로젝트는 회사 서버의 API를 사용합니다. 그러나 서버에서 4xx, 5xx 에러 발생 시 CORS 허용 헤더(`Access-Control-Allow-Origin`)가 포함되지 않아, 브라우저 환경(Flutter Web)에서는 서버의 에러 응답을 받을 수 없습니다.

이로 인해, 잘못된 요청(로그인 실패, 게시글 작성 실패 등) 시 서버가 보내는 실제 에러 메시지를 UI에 표시할 수 없으며, 프론트엔드에서 자체적으로 하드코딩을 통해 한글 메세지를 제공해야 합니다.

- 모바일/데스크탑 환경에서는 정상적으로 서버의 에러 메시지를 받을 수 있습니다.

**예시:**

- 로그인 실패 시: "올바른 이메일 형식이 아닙니다." 등
- 게시글 작성 실패 시: "10자 이상 작성해야 합니다." 등

> 서버의 CORS 정책으로 인해 발생하는 문제로, 프론트엔드에서 임의로 해결할 수 없는 점 양해 부탁드립니다.
