import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppTexts {
  static String _currentLang = '한국어';
  static final ValueNotifier<String> languageNotifier = ValueNotifier(
    _currentLang,
  );

  // 📌 저장된 언어 불러오기 (앱이 켜질 때 호출)
  static Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLang = prefs.getString('selected_language') ?? '한국어';
    languageNotifier.value = _currentLang;
  }

  // 📌 언어 변경 및 저장하기
  static Future<void> setLanguage(String lang) async {
    _currentLang = lang;
    languageNotifier.value = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', lang);
  }

  static String get currentLang => _currentLang;

  // 📌 화면별 다국어 텍스트 데이터 맵
  static final Map<String, Map<String, String>> _texts = {
    '한국어': {
      // 공통 / 헤더 / 네비게이션
      'lobby': '로비',
      'inventory': '인벤토리',
      'shop': '상점',
      'settings': '설정',
      'language': '언어',
      'coins': '코인',
      'loading': '데이터를 불러오는 중입니다...',
      'tapToStart': 'TAP TO START',
      'back': '뒤로',

      // 로그인 / 계정
      'login': '로그인',
      'guest': '게스트로 시작',
      'googleLogin': 'Google 로그인',
      'loginGuideUpdated': '게스트로 시작하세요. Google 계정 연동은 업데이트 예정입니다.',
      'loginSuccess': '로그인되었습니다.',
      'switchToGoogle': 'Google 계정으로 전환',
      'comingSoon': '업데이트 예정',

      // 스테이지 & 리듬 플레이
      'selectStage': '곡 선택',
      'stage': 'TRACK',
      'reward': '클리어 보상',
      'pause': '일시정지',
      'resume': '게임 계속하기',
      'quitToLobby': '포기하고 로비로',
      'victory': 'STAGE CLEAR!',
      'defeat': 'GAME OVER',
      'retry': '다시 도전',
      'score': '점수',
      'maxCombo': 'MAX COMBO',
      'accuracy': '정확도',

      // 커스터마이즈 & DJ 캐릭터
      'all': '전체',
      'equipped': '장착 중',

      // 상점
      'songs': '곡',
      'effects': '이펙트',
      'owned': '보유 중',
      'buyWithAd': '코인 + 광고 시청으로 구매',
      'coinNotEnough': '코인이 부족합니다.',
      'adFailed': '광고 시청에 실패했습니다.',
      'adRewardGranted': '광고 시청 완료! 보상을 지급합니다.',
      'confirmPurchase': '구매 확인',
      'purchaseSuccess': '구매 완료!',
      'yes': '예',
      'no': '아니오',
      'noItems': '보유한 아이템이 없습니다.',

      // 퀘스트 & 공지 / 출석
      'quest': '퀘스트',
      'claimReward': '보상 받기',
      'claimed': '수령 완료',
      'notice': '공지사항',
      'attendance': '출석 이벤트',
      'attendance7Days': '7일 비트 출석 보상',
      'dayUnit': '일',
      'claimTodayReward': '오늘 보상 받기',
      'attendanceDoneToday': '오늘 출석 완료',

      // 설정 & 사운드 & 싱크
      'bgmVolume': 'BGM 음량',
      'sfxVolume': '노트 타격음',
      'timingSync': '판정 타이밍 오프셋',
      'timingSyncDesc': '기기 레이턴시에 맞게 밀리초를 조절하세요.',
      'credits': '크레딧',
      'privacyPolicy': '개인정보 처리방침',
      'creditsDesc': '본 게임에 수록된 곡의 원작자를 표기합니다.',

      // 하드코딩 방지 추가 키
      'adWatchOnce': '+ 광고 1회',
      'allMusicOwned': '모든 음악을 보유하고 있습니다!',
      'basicMusic': '기본곡',
      'bonus': '보너스',
      'googleSyncDesc': '게임 진행 상황과 데이터를 Google 계정에 연동할 수 있습니다.',
      'coinsEarned': '획득!',
      'updateRequired': '업데이트 필요',
      'updateNeeded': '새 버전이 있습니다. 업데이트 후 이용해 주세요.',
      'checking': '확인 중...',
      'update': '업데이트',
      'questFirstClear': '첫 곡 클리어',
      'questFirstClearDesc': '아무 곡이나 1회 클리어하세요.',
      'questClear5': '곡 5개 클리어',
      'questClear5Desc': '누적 5곡을 클리어하세요.',
      'questClear10': '곡 10개 클리어',
      'questClear10Desc': '누적 10곡을 클리어하세요.',
      'questRankS': 'S랭크 달성',
      'questRankSDesc': '한 곡에서 S랭크를 달성하세요.',
    },
    'English': {
      // Common / Header / Navigation
      'lobby': 'Lobby',
      'inventory': 'Inventory',
      'shop': 'Shop',
      'settings': 'Settings',
      'language': 'Language',
      'coins': 'Coins',
      'loading': 'Loading data...',
      'tapToStart': 'TAP TO START',
      'back': 'Back',

      // Login / Account
      'login': 'Login',
      'guest': 'Continue as Guest',
      'googleLogin': 'Sign in with Google',
      'loginGuideUpdated': 'Start as Guest. Google account sync is coming soon.',
      'loginSuccess': 'Logged in successfully.',
      'switchToGoogle': 'Switch to Google Account',
      'comingSoon': 'Coming Soon',

      // Stage & Rhythm Play
      'selectStage': 'Select Track',
      'stage': 'TRACK',
      'reward': 'Reward',
      'pause': 'Paused',
      'resume': 'Resume Game',
      'quitToLobby': 'Quit to Lobby',
      'victory': 'STAGE CLEAR!',
      'defeat': 'GAME OVER',
      'retry': 'Try Again',
      'score': 'Score',
      'maxCombo': 'MAX COMBO',
      'accuracy': 'Accuracy',

      // Customization & DJ Character
      'all': 'All',
      'equipped': 'Equipped',

      // Shop
      'songs': 'Songs',
      'effects': 'Effects',
      'owned': 'Owned',
      'buyWithAd': 'Buy with Coins + Ad',
      'coinNotEnough': 'Not enough coins.',
      'adFailed': 'Failed to load ad.',
      'adRewardGranted': 'Ad watched! Reward granted.',
      'confirmPurchase': 'Confirm Purchase',
      'purchaseSuccess': 'Purchase Complete!',
      'yes': 'Yes',
      'no': 'No',
      'noItems': 'No items owned.',

      // Quest & Notice / Attendance
      'quest': 'Quest',
      'claimReward': 'Claim Reward',
      'claimed': 'Claimed',
      'notice': 'Notice',
      'attendance': 'Attendance Event',
      'attendance7Days': '7-Day Beat Attendance',
      'dayUnit': ' Day',
      'claimTodayReward': 'Claim Today\'s Reward',
      'attendanceDoneToday': 'Attendance Done Today',

      // Settings & Sound & Sync
      'bgmVolume': 'BGM Volume',
      'sfxVolume': 'Hit Sound Volume',
      'timingSync': 'Timing Sync Offset',
      'timingSyncDesc': 'Adjust audio latency in milliseconds.',
      'credits': 'Credits',
      'privacyPolicy': 'Privacy Policy',
      'creditsDesc':
          'The original creators of the tracks featured in this game.',

      // Additional keys
      'adWatchOnce': '+ 1 Ad',
      'allMusicOwned': 'You own all music!',
      'basicMusic': 'Free Track',
      'bonus': 'Bonus',
      'googleSyncDesc':
          'Sync your game progress and data with your Google account.',
      'coinsEarned': 'Earned!',
      'updateRequired': 'Update Required',
      'updateNeeded': 'A new version is available. Please update to continue.',
      'checking': 'Checking...',
      'update': 'Update',
      'questFirstClear': 'First Clear',
      'questFirstClearDesc': 'Clear any track once.',
      'questClear5': 'Clear 5 Tracks',
      'questClear5Desc': 'Clear a total of 5 tracks.',
      'questClear10': 'Clear 10 Tracks',
      'questClear10Desc': 'Clear a total of 10 tracks.',
      'questRankS': 'S Rank',
      'questRankSDesc': 'Achieve S rank on any track.',
    },
    '日本語': {
      // 共通 / ヘッダー / ナビゲーション
      'lobby': 'ロビー',
      'inventory': 'インベントリ',
      'shop': 'ショップ',
      'settings': '設定',
      'language': '言語',
      'coins': 'コイン',
      'loading': 'データを読み込み中...',
      'tapToStart': 'TAP TO START',
      'back': '戻る',

      // ログイン / アカウント
      'login': 'ログイン',
      'guest': 'ゲストで始める',
      'googleLogin': 'Googleでログイン',
      'loginGuideUpdated': 'ゲストで始めてください。Googleアカウント連携はアップデート予定です。',
      'loginSuccess': 'ログインしました。',
      'switchToGoogle': 'Googleアカウントに切り替え',
      'comingSoon': 'アップデート予定',

      // ステージ & リズムプレイ
      'selectStage': '楽曲選択',
      'stage': 'TRACK',
      'reward': 'クリア報酬',
      'pause': '一時停止',
      'resume': 'ゲームを続ける',
      'quitToLobby': 'ロビーへ戻る',
      'victory': 'STAGE CLEAR!',
      'defeat': 'GAME OVER',
      'retry': 'もう一度',
      'score': 'スコア',
      'maxCombo': 'MAXコンボ',
      'accuracy': '正確度',

      // カスタマイズ & DJキャラクター
      'all': 'すべて',
      'equipped': '装備中',

      // ショップ
      'songs': '楽曲',
      'effects': 'エフェクト',
      'owned': '保有中',
      'buyWithAd': 'コイン+広告で購入',
      'coinNotEnough': 'コインが不足しています。',
      'adFailed': '広告の読み込みに失敗しました。',
      'adRewardGranted': '広告視聴完了！報酬を付与しました。',
      'confirmPurchase': '購入確認',
      'purchaseSuccess': '購入完了！',
      'yes': 'はい',
      'no': 'いいえ',
      'noItems': '保有アイテムがありません。',

      // クエスト & お知らせ / 出席
      'quest': 'クエスト',
      'claimReward': '報酬を受け取る',
      'claimed': '受取済み',
      'notice': 'お知らせ',
      'attendance': '出席イベント',
      'attendance7Days': '7日連続出席報酬',
      'dayUnit': '日目',
      'claimTodayReward': '今日の報酬を受け取る',
      'attendanceDoneToday': '今日の出席完了',

      // 設定 & サウンド & シンク
      'bgmVolume': 'BGM音量',
      'sfxVolume': 'ノーツ打撃音',
      'timingSync': '判定タイミング調整',
      'timingSyncDesc': '端末のレイテンシに合わせてミリ秒を調整してください。',
      'credits': 'クレジット',
      'privacyPolicy': 'プライバシーポリシー',
      'creditsDesc': '本ゲームに収録された楽曲の原作者を表記しています。',

      // 追加キー
      'adWatchOnce': '+ 広告1回',
      'allMusicOwned': 'すべての曲を保有しています！',
      'basicMusic': '基本楽曲',
      'bonus': 'ボーナス',
      'googleSyncDesc': 'ゲームの進行状況とデータをGoogleアカウントに同期できます。',
      'coinsEarned': '獲得！',
      'updateRequired': 'アップデートが必要です',
      'updateNeeded': '新しいバージョンがあります。アップデート後にご利用ください。',
      'checking': '確認中...',
      'update': 'アップデート',
      'questFirstClear': '初クリア',
      'questFirstClearDesc': '任意の曲を1回クリアしてください。',
      'questClear5': '5曲クリア',
      'questClear5Desc': '累計5曲をクリアしてください。',
      'questClear10': '10曲クリア',
      'questClear10Desc': '累計10曲をクリアしてください。',
      'questRankS': 'Sランク達成',
      'questRankSDesc': '任意の曲でSランクを達成してください。',
    },
  };

  // 📌 텍스트를 가져오는 함수
  static String get(String key) {
    return _texts[_currentLang]?[key] ?? _texts['한국어']?[key] ?? key;
  }
}
