import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_ids.dart';
import 'ads_policy.dart';

class AppOpenAdService {
  AppOpenAdService._();

  static final AppOpenAdService instance = AppOpenAdService._();

  static const Duration _maxAdAge = Duration(hours: 4);
  static const Duration _minShowInterval = Duration(hours: 4);

  AppOpenAd? _ad;
  DateTime? _loadedAt;
  DateTime? _lastShownAt;
  StreamSubscription<AppState>? _subscription;
  bool _loading = false;
  bool _showing = false;
  bool _started = false;
  bool _skippedInitialForeground = false;

  Future<void> start() async {
    if (_started) return;
    if (AdIds.appOpenAdUnitId().isEmpty) return;

    _started = true;
    await AppStateEventNotifier.startListening();
    _subscription = AppStateEventNotifier.appStateStream.listen((state) {
      if (state != AppState.foreground) return;

      if (!_skippedInitialForeground) {
        _skippedInitialForeground = true;
        load();
        return;
      }

      showIfAvailable();
    });
    load();
  }

  void load() {
    if (_loading || _ad != null) return;
    if (!AdsPolicy.canRequestAds) return;

    final adUnitId = AdIds.appOpenAdUnitId();
    if (adUnitId.isEmpty) return;

    _loading = true;
    AppOpenAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _ad = ad;
          _loadedAt = DateTime.now();
          _loading = false;
        },
        onAdFailedToLoad: (_) {
          _ad = null;
          _loadedAt = null;
          _loading = false;
        },
      ),
    );
  }

  void showIfAvailable() {
    if (_showing) return;
    if (!AdsPolicy.canShowAds) return;
    if (!_isCooldownSatisfied) {
      load();
      return;
    }

    final ad = _takeFreshAd();
    if (ad == null) {
      load();
      return;
    }

    _showing = true;
    ad.fullScreenContentCallback = FullScreenContentCallback<AppOpenAd>(
      onAdShowedFullScreenContent: (_) {
        _lastShownAt = DateTime.now();
      },
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _showing = false;
        load();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _showing = false;
        load();
      },
    );
    unawaited(ad.show());
  }

  AppOpenAd? _takeFreshAd() {
    final ad = _ad;
    final loadedAt = _loadedAt;
    _ad = null;
    _loadedAt = null;

    if (ad == null || loadedAt == null) return null;
    if (DateTime.now().difference(loadedAt) <= _maxAdAge) return ad;

    ad.dispose();
    return null;
  }

  bool get _isCooldownSatisfied {
    final lastShownAt = _lastShownAt;
    if (lastShownAt == null) return true;
    return DateTime.now().difference(lastShownAt) >= _minShowInterval;
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
    _ad?.dispose();
    _ad = null;
    _started = false;
    _loading = false;
    _showing = false;
  }
}
