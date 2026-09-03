import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdRewardHelper {
  static final AdRewardHelper instance = AdRewardHelper._init();
  RewardedAd? _rewardedAd;
  bool _isLoading = false;

  AdRewardHelper._init();

  String get _adUnitId => kReleaseMode
      ? 'ca-app-pub-1474045642143501/1234567890' // TODO: 실제 rewarded ad 단위 ID로 교체
      : 'ca-app-pub-3940256099942521/5224354917'; // Google 테스트 ID

  Future<void> loadAd() async {
    if (_rewardedAd != null || _isLoading) return;
    _isLoading = true;

    await RewardedAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isLoading = false;
          _setupCallbacks(ad);
        },
        onAdFailedToLoad: (error) {
          debugPrint('RewardedAd failed to load: $error');
          _isLoading = false;
        },
      ),
    );
  }

  void _setupCallbacks(RewardedAd ad) {
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        loadAd(); // 다음 광고 미리 로드
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
      },
    );
  }

  Future<bool> showAdAndGetReward() async {
    if (_rewardedAd == null) {
      await loadAd();
      if (_rewardedAd == null) return false;
    }

    bool rewardEarned = false;

    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        rewardEarned = true;
      },
    );

    return rewardEarned;
  }

  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }
}
