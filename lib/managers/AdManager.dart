import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';

/// Manages rewarded video ads for the revive system
class AdManager {
  static final AdManager _instance = AdManager._internal();
  factory AdManager() => _instance;
  AdManager._internal();

  RewardedAd? _rewardedAd;
  bool _isAdReady = false;

  /// Test Ad Unit IDs (replace with production IDs before release)
  String get _rewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/5224354917'; // Test ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1712485313'; // Test ID
    }
    return '';
  }

  /// Initialize Google Mobile Ads SDK
  Future<void> init() async {
    await MobileAds.instance.initialize();
    loadRewardedAd();
  }

  /// Load a rewarded ad
  void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isAdReady = true;
          print('Rewarded ad loaded successfully');
        },
        onAdFailedToLoad: (error) {
          print('Failed to load rewarded ad: $error');
          _isAdReady = false;
        },
      ),
    );
  }

  /// Show rewarded ad and execute callback on completion
  Future<bool> showRewardedAd() async {
    if (!_isAdReady || _rewardedAd == null) {
      print('Rewarded ad not ready');
      return false;
    }

    bool adWatched = false;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _isAdReady = false;
        loadRewardedAd(); // Load next ad
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('Failed to show ad: $error');
        ad.dispose();
        _isAdReady = false;
        loadRewardedAd();
      },
    );

    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        adWatched = true;
        print('User earned reward: ${reward.amount} ${reward.type}');
      },
    );

    return adWatched;
  }

  bool get isAdReady => _isAdReady;

  void dispose() {
    _rewardedAd?.dispose();
  }
}
