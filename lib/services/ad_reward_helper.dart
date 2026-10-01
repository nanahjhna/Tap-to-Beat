import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdRewardHelper {
  static final AdRewardHelper instance = AdRewardHelper._init();

  RewardedInterstitialAd? _rewardedAd;
  bool _isLoading = false;
  bool _didEarnReward = false;
  Completer<bool>? _pendingCompleter;
  Completer<void>? _loadCompleter;

  AdRewardHelper._init();

  // 테스트 ID와 실제 운영 ID 분리
  // (kDebugMode일 때는 Google 테스트 광고 ID 사용)
  String get _adUnitId {
    if (kDebugMode) {
      // Google AdMob 공식 Rewarded Interstitial Test ID
      return defaultTargetPlatform == TargetPlatform.iOS
          ? 'ca-app-pub-3940256099942544/6978759866'
          : 'ca-app-pub-3940256099942544/5354046379';
    }
    // 실제 운영 광고 ID
    return 'ca-app-pub-1474045642143501/9082538235';
  }

  /// 광고를 로드하고 로드가 완료될 때까지 기다릴 수 있도록 Completer 반환
  Future<void> loadAd() async {
    if (_rewardedAd != null) return;
    if (_isLoading) {
      // 이미 로드 중이라면 진행 중인 로드가 끝날 때까지 대기
      return _loadCompleter?.future;
    }

    _isLoading = true;
    _loadCompleter = Completer<void>();

    await RewardedInterstitialAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isLoading = false;
          _setupCallbacks(ad);
          if (_loadCompleter != null && !_loadCompleter!.isCompleted) {
            _loadCompleter!.complete();
          }
        },
        onAdFailedToLoad: (error) {
          debugPrint('RewardedInterstitialAd failed to load: $error');
          _rewardedAd = null;
          _isLoading = false;
          if (_loadCompleter != null && !_loadCompleter!.isCompleted) {
            _loadCompleter!.complete();
          }
        },
      ),
    );

    return _loadCompleter?.future;
  }

  void _setupCallbacks(RewardedInterstitialAd ad) {
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        _completePending(_didEarnReward);
        ad.dispose();
        _rewardedAd = null;
        _didEarnReward = false;
        loadAd(); // 다음 광고 미리 로드
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('RewardedInterstitialAd failed to show: $error');
        _completePending(false);
        ad.dispose();
        _rewardedAd = null;
        _didEarnReward = false;
        loadAd(); // 실패 시에도 다음 광고 준비
      },
      onAdImpression: (ad) {
        // 단순 노출 로깅용 (보상 판정에 사용 금지)
        debugPrint('RewardedInterstitialAd impression recorded');
      },
    );
  }

  void _completePending(bool success) {
    final completer = _pendingCompleter;
    _pendingCompleter = null;
    if (completer != null && !completer.isCompleted) {
      completer.complete(success);
    }
  }

  Future<bool> showAdAndGetReward() async {
    // 이미 광고가 보류 중이거나 표출 중이면 거부
    if (_pendingCompleter != null) return false;

    // 광고가 없다면 로드를 시도하고 로드가 완료될 때까지 대기
    if (_rewardedAd == null) {
      await loadAd();
      if (_rewardedAd == null) {
        debugPrint('RewardedInterstitialAd is not ready yet.');
        return false;
      }
    }

    _didEarnReward = false;
    final completer = Completer<bool>();
    _pendingCompleter = completer;

    try {
      await _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          // 보상 시청 완료 시에만 플래그 처리
          _didEarnReward = true;
        },
      );
    } catch (e) {
      debugPrint('RewardedInterstitialAd show failed with exception: $e');
      _completePending(false);
    }

    return completer.future;
  }

  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _pendingCompleter = null;
    _loadCompleter = null;
  }
}