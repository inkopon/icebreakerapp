import 'dart:io';

import 'package:flutter/foundation.dart';

class AdIds {
  AdIds._();

  // App ID copied from runninghitapp, per project reference.
  static const String applicationId = 'ca-app-pub-8058177413315087~6584092902';

  // Create dedicated Ice Breaker release units in AdMob and fill these values.
  static const String _androidHomeBannerRelease = '';
  static const String _iosHomeBannerRelease = '';
  static const String _androidRefreshInterstitialRelease = '';
  static const String _iosRefreshInterstitialRelease = '';
  static const String _androidAppOpenRelease = '';
  static const String _iosAppOpenRelease = '';

  // Official Google sample ad unit IDs for development builds.
  static const String _androidHomeBannerTest =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _iosHomeBannerTest =
      'ca-app-pub-3940256099942544/2934735716';
  static const String _androidInterstitialTest =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _iosInterstitialTest =
      'ca-app-pub-3940256099942544/4411468910';
  static const String _androidAppOpenTest =
      'ca-app-pub-3940256099942544/9257395921';
  static const String _iosAppOpenTest =
      'ca-app-pub-3940256099942544/5575463023';

  static String homeBannerAdUnitId() {
    if (!kReleaseMode) {
      return Platform.isIOS ? _iosHomeBannerTest : _androidHomeBannerTest;
    }
    return Platform.isIOS ? _iosHomeBannerRelease : _androidHomeBannerRelease;
  }

  static String refreshInterstitialAdUnitId() {
    if (!kReleaseMode) {
      return Platform.isIOS ? _iosInterstitialTest : _androidInterstitialTest;
    }
    return Platform.isIOS
        ? _iosRefreshInterstitialRelease
        : _androidRefreshInterstitialRelease;
  }

  static String appOpenAdUnitId() {
    if (!kReleaseMode) {
      return Platform.isIOS ? _iosAppOpenTest : _androidAppOpenTest;
    }
    return Platform.isIOS ? _iosAppOpenRelease : _androidAppOpenRelease;
  }
}
