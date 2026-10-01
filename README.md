# TapToBeat

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## AdMob `app-ads.txt` 자동 배포

`hosting/app-ads.txt` 또는 Hosting 설정이 바뀐 내용을 `main` 브랜치에
푸시하면 GitHub Actions가 Firebase Hosting의 라이브 사이트에 자동
배포합니다. 수동 실행은 **GitHub → Actions → Deploy app-ads.txt → Run
workflow**에서 할 수 있습니다.

### 최초 1회 설정

1. Firebase 콘솔에서 `taptobeat-cd62f` 프로젝트의 기본 Hosting 사이트를
   생성/사용 설정합니다. 별도 도메인을 쓸 경우 이 단계에서 커스텀 도메인도
   연결합니다.
2. 이 프로젝트에 Google Cloud 서비스 계정을 만들고 **Firebase Hosting
   Admin** 역할을 부여합니다. JSON 키를 만든 뒤 전체 JSON 내용을
   **GitHub → Settings → Secrets and variables → Actions**에
   `FIREBASE_SERVICE_ACCOUNT_TAPTOBEAT_CD62F`라는 이름의 Secret으로
   등록합니다. 키 파일이나 키 내용을 저장소에 커밋하지 마세요.
3. Firebase Hosting 주소(또는 연결한 커스텀 도메인)를 앱의 Google Play
   스토어 등록정보에 개발자 웹사이트로 등록해야 AdMob이 `app-ads.txt`를
   앱과 연결할 수 있습니다.

현재 파일에는 다음 판매자 선언이 들어 있습니다.

```text
google.com, pub-1474045642143501, DIRECT, f08c47fec0942fa0
```

### 확인 및 이후 업데이트

첫 배포가 끝나면 `https://taptobeat-cd62f.web.app/app-ads.txt` 또는 커스텀
도메인의 동일한 경로를 열어 선언문이 일반 텍스트로 제공되는지 확인합니다.
그 다음 AdMob에서 `app-ads.txt` 상태를 확인합니다. 크롤링 및 상태 반영에는
시간이 걸릴 수 있습니다. 이후에는 `hosting/app-ads.txt`를 수정해 `main`에
푸시하기만 하면 자동으로 배포됩니다.
