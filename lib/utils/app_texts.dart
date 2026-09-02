import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppTexts {
  static String _currentLang = '한국어';
  static final ValueNotifier<String> languageNotifier = ValueNotifier(_currentLang);

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
      'mainTitle': '바치키',
      'lobby': '로비',
      'inventory': '인벤토리',
      'shop': '상점',
      'character': '캐릭터',
      'settings': '설정',
      'language': '언어',
      'sound': '사운드',
      'coins': '코인',
      'energy': '에너지',
      'close': '닫기',
      'loading': '데이터를 불러오는 중입니다...',
      'tapToStart': 'TAP TO START',
      'home': '홈으로',
      'back': '뒤로',

      // 로그인 / 계정
      'login': '로그인',
      'guest': '게스트로 시작',
      'googleLogin': 'Google 로그인',
      'appleLogin': 'Apple 로그인',
      'loginGuide': '게임 데이터를 안전하게 보관하세요.',
      'loginSuccess': '로그인되었습니다.',
      'account': '계정 연동',
      'logout': '로그아웃',
      'logoutGuide': 'Google 계정에서 로그아웃합니다.',
      'linkGoogle': 'Google 계정으로 연동',
      'currentGuest': '현재 게스트 계정',
      'guestPlaying': '현재 게스트 계정으로 플레이 중',
      'checkingLogin': '로그인 정보 확인 중',
      'linkAccount': '계정 연동',
      'link': '연동',
      'linkStarted': '연동 흐름을 시작합니다.',
      'accountLinkDesc': '계정을 연동하면 기기를 변경해도 데이터를 유지할 수 있습니다.',

      // 스테이지 & 리듬 플레이
      'stageBattle': '음악 플레이',
      'selectStage': '곡 선택',
      'startBattle': '플레이 시작',
      'stage': 'TRACK',
      'boss': '현재 곡',
      'recommendedPower': 'BPM',
      'reward': '클리어 보상',
      'locked': '잠김',
      'pause': '일시정지',
      'resume': '게임 계속하기',
      'quitToLobby': '포기하고 로비로',
      'victory': 'STAGE CLEAR!',
      'defeat': 'GAME OVER',
      'stageClear': 'STAGE CLEAR!',
      'stageFailed': 'GAME OVER',
      'retry': '다시 도전',
      'nextStage': '다음 곡',
      'timeLeft': '남은 시간',
      'attack': '노트 탭',
      'attackGuide': 'D, F, J, K 버튼을 눌러 판정선에 노트를 맞추세요!',
      'play': '플레이',
      'score': '점수',
      'maxCombo': 'MAX COMBO',
      'accuracy': '정확도',
      'rank': '랭크',
      'nowPlaying': '추천 트랙',

      // 커스터마이즈 & DJ 캐릭터
      'all': '전체',
      'equipment': '노트 스킨',
      'consumable': '타격 이펙트',
      'item': '스킨',
      'useItem': '스킨 장착',
      'unequip': '장착 해제',
      'equipped': '장착 중',
      'notEquipped': '미장착',
      'itemEquipped': '스킨을 장착했습니다.',
      'itemUnequipped': '스킨을 해제했습니다.',
      'characterIntro': 'DJ 프로필',
      'characterName': 'DJ 비트 마스터',
      'characterDesc': '뛰어난 리듬감과 정확한 타이밍으로 관중을 열광시키는 탑티어 리듬 DJ입니다.',
      'skill': 'DJ 패시브',
      'stats': '리듬 스탯',
      'level': 'DJ Lv.',
      'power': '그루브',
      'statAtk': '판정 감도',
      'statDef': '라이프 가드',
      'statSpd': '피버 파워',
      'equippedPerks': '장착된 리듬 서포트',
      'quickStrike': '타이밍 가드 (Timing Guard)',
      'vitality': '피버 부스트 (Fever Boost)',

      // 상점
      'starterCoins': '비트 코인 스타터 팩',
      'starterCoinsDesc': '500 비트 코인',
      'energyPack': '리듬 에너지 팩',
      'energyPackDesc': '10 에너지',
      'removeAds': '광고 제거',
      'removeAdsDesc': '영구 광고 제거 및 보너스 스킨',
      'musicPack': 'Mikoshi Mayhem 사운드 팩',
      'musicPackDesc': '신규 익스텐디드 트랙 3곡 해금',

      // 퀘스트 & 공지 / 출석
      'quest': '퀘스트',
      'dailyQuest': '일일 미션',
      'achievement': '업적',
      'dailyMission': '일일 미션',
      'achievementMission': '업적 미션',
      'claimReward': '보상 받기',
      'claimed': '수령 완료',
      'notice': '공지사항',
      'attendance': '출석 이벤트',
      'attendance7Days': '7일 비트 출석 보상',
      'dayUnit': '일',
      'claimTodayReward': '오늘 보상 받기',
      'noticeEvent1': 'TapToBeat 리듬 출시 기념 이벤트',
      'noticeUpdate1': 'Mikoshi Mayhem 트랙 업데이트',
      'termsOfService': '서비스 이용 약관',
      'noticeContent': 'TapToBeat를 플레이해주셔서 감사합니다. 신나는 4버튼 비트를 즐겨보세요!',

      // 설정 & 사운드 & 싱크
      'bgmVolume': 'BGM 음량',
      'sfxVolume': '노트 타격음',
      'soundEffects': '효과음',
      'timingSync': '판정 타이밍 오프셋',
      'timingSyncDesc': '기기 레이턴시에 맞게 밀리초를 조절하세요.',
    },
    'English': {
      // Common / Header / Navigation
      'mainTitle': 'TapToBeat',
      'lobby': 'Lobby',
      'inventory': 'Inventory',
      'shop': 'Shop',
      'character': 'Character',
      'settings': 'Settings',
      'language': 'Language',
      'sound': 'Sound',
      'coins': 'Coins',
      'energy': 'Energy',
      'close': 'Close',
      'loading': 'Loading data...',
      'tapToStart': 'TAP TO START',
      'home': 'Home',
      'back': 'Back',

      // Login / Account
      'login': 'Login',
      'guest': 'Continue as Guest',
      'googleLogin': 'Sign in with Google',
      'appleLogin': 'Sign in with Apple',
      'loginGuide': 'Keep your game data safe.',
      'loginSuccess': 'Logged in successfully.',
      'account': 'Account Link',
      'logout': 'Log Out',
      'logoutGuide': 'Log out of your Google account.',
      'linkGoogle': 'Link Google Account',
      'currentGuest': 'Guest Account',
      'guestPlaying': 'Currently playing as Guest',
      'checkingLogin': 'Checking login info...',
      'linkAccount': 'Link Account',
      'link': 'Link',
      'linkStarted': 'Starting account link flow.',
      'accountLinkDesc': 'Link your account to keep your data safe across devices.',

      // Stage & Rhythm Play
      'stageBattle': 'Play Tracks',
      'selectStage': 'Select Track',
      'startBattle': 'Start Track',
      'stage': 'TRACK',
      'boss': 'Current Song',
      'recommendedPower': 'BPM',
      'reward': 'Reward',
      'locked': 'Locked',
      'pause': 'Paused',
      'resume': 'Resume Game',
      'quitToLobby': 'Quit to Lobby',
      'victory': 'STAGE CLEAR!',
      'defeat': 'GAME OVER',
      'stageClear': 'STAGE CLEAR!',
      'stageFailed': 'GAME OVER',
      'retry': 'Try Again',
      'nextStage': 'Next Track',
      'timeLeft': 'Time Left',
      'attack': 'Tap Note',
      'attackGuide': 'Hit D, F, J, K when notes reach the yellow judge line!',
      'play': 'Play',
      'score': 'Score',
      'maxCombo': 'MAX COMBO',
      'accuracy': 'Accuracy',
      'rank': 'Rank',
      'nowPlaying': 'Featured Track',

      // Customization & DJ Character
      'all': 'All',
      'equipment': 'Note Skins',
      'consumable': 'Hit Effects',
      'item': 'Skin',
      'useItem': 'Equip Skin',
      'unequip': 'Unequip',
      'equipped': 'Equipped',
      'notEquipped': 'Not equipped',
      'itemEquipped': 'Skin equipped.',
      'itemUnequipped': 'Skin unequipped.',
      'characterIntro': 'DJ Profile',
      'characterName': 'DJ Beat Master',
      'characterDesc': 'A top-tier DJ captivating audiences with perfect rhythm sense and precise timing.',
      'skill': 'DJ Skill',
      'stats': 'Rhythm Stats',
      'level': 'DJ Lv.',
      'power': 'Groove',
      'statAtk': 'Timing Sensitivity',
      'statDef': 'Life Guard',
      'statSpd': 'Fever Power',
      'equippedPerks': 'EQUIPPED SUPPORTS',
      'quickStrike': 'Timing Guard',
      'vitality': 'Fever Boost',

      // Shop
      'starterCoins': 'Beat Coins Starter Pack',
      'starterCoinsDesc': '500 beat coins',
      'energyPack': 'Rhythm Energy Pack',
      'energyPackDesc': '10 energy',
      'removeAds': 'Remove Ads',
      'removeAdsDesc': 'Permanent ad removal & bonus skin',
      'musicPack': 'Mikoshi Mayhem Track Pack',
      'musicPackDesc': 'Unlock 3 Extended Tracks',

      // Quest & Notice / Attendance
      'quest': 'Quest',
      'dailyQuest': 'Daily Missions',
      'achievement': 'Achievements',
      'dailyMission': 'Daily Mission',
      'achievementMission': 'Achievement Mission',
      'claimReward': 'Claim Reward',
      'claimed': 'Claimed',
      'notice': 'Notice',
      'attendance': 'Attendance Event',
      'attendance7Days': '7-Day Beat Attendance',
      'dayUnit': ' Day',
      'claimTodayReward': 'Claim Today\'s Reward',
      'noticeEvent1': 'TapToBeat Rhythm Launch Event',
      'noticeUpdate1': 'Mikoshi Mayhem Track Update',
      'termsOfService': 'Terms of Service',
      'noticeContent': 'Thank you for playing TapToBeat. Enjoy high-energy 4-button rhythm action!',

      // Settings & Sound & Sync
      'bgmVolume': 'BGM Volume',
      'sfxVolume': 'Hit Sound Volume',
      'soundEffects': 'Sound Effects',
      'timingSync': 'Timing Sync Offset',
      'timingSyncDesc': 'Adjust audio latency in milliseconds.',
    },
    '日本語': {
      // 共通 / ヘッダー / ナビゲーション
      'mainTitle': 'バチキ',
      'lobby': 'ロビー',
      'inventory': 'インベントリ',
      'shop': 'ショップ',
      'character': 'キャラクター',
      'settings': '設定',
      'language': '言語',
      'sound': 'サウンド',
      'coins': 'コイン',
      'energy': 'エネルギー',
      'close': '閉じる',
      'loading': 'データを読み込み中...',
      'tapToStart': 'TAP TO START',
      'home': 'ホームへ',
      'back': '戻る',

      // ログイン / アカウント
      'login': 'ログイン',
      'guest': 'ゲストで始める',
      'googleLogin': 'Googleでログイン',
      'appleLogin': 'Appleでログイン',
      'loginGuide': 'ゲームデータを安全に保管します。',
      'loginSuccess': 'ログインしました。',
      'account': 'アカウント連携',
      'logout': 'ログアウト',
      'logoutGuide': 'Googleアカウントからログアウトします。',
      'linkGoogle': 'Googleアカウントと連携',
      'currentGuest': '現在ゲストアカウント',
      'guestPlaying': '現在ゲストアカウントでプレイ中',
      'checkingLogin': 'ログイン情報確認中',
      'linkAccount': 'アカウント連携',
      'link': '連携',
      'linkStarted': 'アカウント連携を開始します。',
      'accountLinkDesc': 'アカウントを連携すると端末を変更してもデータを保持できます。',

      // ステージ & リズムプレイ
      'stageBattle': '楽曲プレイ',
      'selectStage': '楽曲選択',
      'startBattle': 'プレイ開始',
      'stage': 'TRACK',
      'boss': '現在の曲',
      'recommendedPower': 'BPM',
      'reward': 'クリア報酬',
      'locked': 'ロック中',
      'pause': '一時停止',
      'resume': 'ゲームを続ける',
      'quitToLobby': 'ロビーへ戻る',
      'victory': 'STAGE CLEAR!',
      'defeat': 'GAME OVER',
      'stageClear': 'STAGE CLEAR!',
      'stageFailed': 'GAME OVER',
      'retry': 'もう一度',
      'nextStage': '次の曲',
      'timeLeft': '残り時間',
      'attack': 'ノーツタップ',
      'attackGuide': 'D、F、J、Kキーを押して判定線に合わせてタップ！',
      'play': 'プレイ',
      'score': 'スコア',
      'maxCombo': 'MAXコンボ',
      'accuracy': '正確度',
      'rank': 'ランク',
      'nowPlaying': 'おすすめ楽曲',

      // カスタマイズ & DJキャラクター
      'all': 'すべて',
      'equipment': 'ノーツスキン',
      'consumable': '打撃エフェクト',
      'item': 'スキン',
      'useItem': 'スキン装備',
      'unequip': '装備解除',
      'equipped': '装備中',
      'notEquipped': '未装備',
      'itemEquipped': 'スキンを装備しました。',
      'itemUnequipped': 'スキンを解除しました。',
      'characterIntro': 'DJプロフィール',
      'characterName': 'DJビートマスター',
      'characterDesc': '抜群のリズム感と正確なタイミングで会場を盛り上げるトップDJです。',
      'skill': 'DJパッシブ',
      'stats': 'リズム能力値',
      'level': 'DJ Lv.',
      'power': 'グルーヴ',
      'statAtk': '判定感度',
      'statDef': 'ライフガード',
      'statSpd': 'フィーバーパワー',
      'equippedPerks': '装備中のサポート',
      'quickStrike': 'タイミングガード (Timing Guard)',
      'vitality': 'フィーバーブースト (Fever Boost)',

      // ショップ
      'starterCoins': 'ビートコインパック',
      'starterCoinsDesc': '500ビートコイン',
      'energyPack': 'リズムエネルギーパック',
      'energyPackDesc': '10エネルギー',
      'removeAds': '広告削除',
      'removeAdsDesc': '広告を永久削除＆ボーナススキン',
      'musicPack': 'Mikoshi Mayhem楽曲パック',
      'musicPackDesc': '新規拡張トラック3曲解放',

      // クエスト & お知らせ / 出席
      'quest': 'クエスト',
      'dailyQuest': 'デイリーミッション',
      'achievement': '実績',
      'dailyMission': 'デイリーミッション',
      'achievementMission': '実績ミッション',
      'claimReward': '報酬を受け取る',
      'claimed': '受取済み',
      'notice': 'お知らせ',
      'attendance': '出席イベント',
      'attendance7Days': '7日連続出席報酬',
      'dayUnit': '日目',
      'claimTodayReward': '今日の報酬を受け取る',
      'noticeEvent1': 'TapToBeat正式リリース記念',
      'noticeUpdate1': 'Mikoshi Mayhemトラック更新',
      'termsOfService': '利用規約',
      'noticeContent': 'TapToBeatをプレイしていただきありがとうございます。爽快な4ボタンリズムアクションをお楽しみください！',

      // 設定 & サウンド & シンク
      'bgmVolume': 'BGM音量',
      'sfxVolume': 'ノーツ打撃音',
      'soundEffects': '効果音',
      'timingSync': '判定タイミング調整',
      'timingSyncDesc': '端末のレイテンシに合わせてミリ秒を調整してください。',
    },
  };

  // 📌 텍스트를 가져오는 함수
  static String get(String key) {
    return _texts[_currentLang]?[key] ?? _texts['한국어']?[key] ?? key;
  }

  // 📌 초 단위 시간 포맷 (예: 12.34초 / 12.34s / 12.34秒)
  static String formatTimeSec(int seconds, int centiseconds) {
    String csStr = centiseconds.toString().padLeft(2, '0');
    if (_currentLang == 'English') {
      return '$seconds.$csStr s';
    } else if (_currentLang == '日本語') {
      return '$seconds.$csStr秒';
    } else {
      return '$seconds.$csStr초';
    }
  }

  // 📌 분/초 단위 시간 포맷 (예: 1분 12.34초 / 1m 12.34s / 1分 12.34秒)
  static String formatTimeMinSec(int minutes, int seconds, int centiseconds) {
    String csStr = centiseconds.toString().padLeft(2, '0');
    if (_currentLang == 'English') {
      return '$minutes m $seconds.$csStr s';
    } else if (_currentLang == '日本語') {
      return '$minutes分 $seconds.$csStr秒';
    } else {
      return '$minutes분 $seconds.$csStr초';
    }
  }
}
