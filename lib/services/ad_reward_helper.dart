import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdRewardHelper {
  static final AdRewardHelper instance = AdRewardHelper._init();
  RewardedInterstitialAd? _rewardedAd;
  bool _isLoading = false;
  bool _didEarnReward = false;
  Completer<bool>? _pendingCompleter;

  AdRewardHelper._init();

  static const _adUnitId = 'ca-app-pub-1474045642143501/9082538235';

  Future<void> loadAd() async {
    if (_rewardedAd != null || _isLoading) return;
    _isLoading = true;

    await RewardedInterstitialAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isLoading = false;
          _setupCallbacks(ad);
        },
        onAdFailedToLoad: (error) {
          debugPrint('RewardedInterstitialAd failed to load: $error');
          _isLoading = false;
        },
      ),
    );
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
        _completePending(false);
        ad.dispose();
        _rewardedAd = null;
        _didEarnReward = false;
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
    if (_rewardedAd == null) {
      await loadAd();
      if (_rewardedAd == null) return false;
    }

    _didEarnReward = false;
    final completer = Completer<bool>();
    _pendingCompleter = completer;

    try {
      await _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          _didEarnReward = true;
        },
      );
    } catch (e) {
      debugPrint('RewardedInterstitialAd show failed: $e');
      _completePending(false);
    }

    return completer.future;
  }

  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }
}