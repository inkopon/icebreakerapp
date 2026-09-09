import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_ids.dart';
import 'ads_policy.dart';

class HomeBannerAd extends StatefulWidget {
  const HomeBannerAd({super.key});

  @override
  State<HomeBannerAd> createState() => _HomeBannerAdState();
}

class _HomeBannerAdState extends State<HomeBannerAd> {
  BannerAd? _ad;
  bool _loaded = false;
  bool _requesting = false;
  int? _requestedWidth;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    unawaited(_startLoad());
  }

  Future<void> _startLoad() async {
    if (_requesting) return;
    if (!AdsPolicy.canRequestAds) return;

    final adUnitId = AdIds.homeBannerAdUnitId();
    if (Platform.isIOS && adUnitId.isEmpty) return;
    if (adUnitId.isEmpty) return;

    final width = MediaQuery.sizeOf(context).width.truncate();
    if (width <= 0) return;
    if (_ad != null && _requestedWidth == width) return;

    _requesting = true;
    final size = await AdSize.getLargeAnchoredAdaptiveBannerAdSize(width);

    if (!mounted) return;
    if (size == null || !AdsPolicy.canRequestAds) {
      setState(() => _requesting = false);
      return;
    }

    if (_ad != null && _requestedWidth != width) {
      _ad?.dispose();
      _ad = null;
      _loaded = false;
    }

    final ad = BannerAd(
      adUnitId: adUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) return;
          setState(() {
            _loaded = true;
            _requesting = false;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (!mounted) return;
          setState(() {
            _ad = null;
            _loaded = false;
            _requesting = false;
          });
        },
      ),
    );

    _ad = ad;
    _requestedWidth = width;
    ad.load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!AdsPolicy.canShowAds) return const SizedBox.shrink();
    final ad = _ad;
    if (!_loaded || ad == null) return const SizedBox.shrink();

    return Center(
      child: SizedBox(
        width: ad.size.width.toDouble(),
        height: ad.size.height.toDouble(),
        child: AdWidget(ad: ad),
      ),
    );
  }
}
