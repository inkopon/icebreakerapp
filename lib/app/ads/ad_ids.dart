import 'dart:io';

import 'package:flutter/foundation.dart';

class AdIds {
  AdIds._();

  static const String applicationId = 'ca-app-pub-8058177413315087~5237827848';

  static const String _androidHomeBannerRelease =
      'ca-app-pub-8058177413315087/4745034483';
  static const String _iosHomeBannerRelease =
      'ca-app-pub-8058177413315087/8323343533';
  static const String _androidRefreshInterstitialRelease =
      'ca-app-pub-8058177413315087/7067945495';
  static const String _iosRefreshInterstitialRelease =
      'ca-app-pub-8058177413315087/4986733755';
  static const String _androidAppOpenRelease =
      'ca-app-pub-8058177413315087/4519829895';
  static const String _iosAppOpenRelease =
      'ca-app-pub-8058177413315087/4384098522';

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
