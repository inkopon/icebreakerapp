import 'dart:async';
import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_ids.dart';
import 'ads_policy.dart';

class InterstitialAdService {
  static const int refreshesBeforeAd = 3;
  static const Duration _minShowInterval = Duration(minutes: 3);

  InterstitialAd? _ad;
  bool _loading = false;
  DateTime? _lastShownAt;

  Future<void> loadRefreshAd() async {
    if (_loading || _ad != null) return;
    if (!AdsPolicy.canRequestAds) return;

    final adUnitId = AdIds.refreshInterstitialAdUnitId();
    if (Platform.isIOS && adUnitId.isEmpty) return;
    if (adUnitId.isEmpty) return;

    _loading = true;
    await InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _ad = ad;
          _loading = false;
        },
        onAdFailedToLoad: (_) {
          _ad = null;
          _loading = false;
        },
      ),
    );
  }

  Future<void> showRefreshAd() async {
    if (!AdsPolicy.canShowAds) return;
    if (!_isCooldownSatisfied) return;

    final ad = _ad;
    if (ad == null) {
      unawaited(loadRefreshAd());
      return;
    }

    _ad = null;
    ad.fullScreenContentCallback = FullScreenContentCallback<InterstitialAd>(
      onAdShowedFullScreenContent: (_) {
        _lastShownAt = DateTime.now();
      },
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        unawaited(loadRefreshAd());
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        unawaited(loadRefreshAd());
      },
    );

    try {
      await ad.show();
    } catch (_) {
      ad.dispose();
      unawaited(loadRefreshAd());
    }
  }

  bool get _isCooldownSatisfied {
    final lastShownAt = _lastShownAt;
    if (lastShownAt == null) return true;
    return DateTime.now().difference(lastShownAt) >= _minShowInterval;
  }

  void dispose() {
    _ad?.dispose();
    _ad = null;
  }
}
