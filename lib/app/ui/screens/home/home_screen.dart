import 'dart:async';
import 'dart:math' as math;

import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ice_breaker_app/l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';

import '../../../ads/ad_banner.dart';
import '../../../ads/interstitial_ad_service.dart';
import '../../../constants/general_constants.dart';
import '../../../models/categoria_model.dart';
import '../../../models/papo_model.dart';
import '../../../services/papo_catalog_service.dart';
import '../../widgets/spinner.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.title = 'Home', this.enableAds = true});

  final String title;
  final bool enableAds;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PapoCatalogService _catalogService = PapoCatalogService();
  final InterstitialAdService _interstitialAdService = InterstitialAdService();

  String? _currentItemSelected;
  String? _loadedLanguageCode;
  List<CategoriaModel> _categorias = const [];
  List<PapoModel>? _papos;
  int _refreshActionCount = 0;

  @override
  void initState() {
    super.initState();
    if (widget.enableAds) {
      unawaited(_interstitialAdService.loadRefreshAd());
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context);
    final languageCode = PapoCatalogService.languageCodeFor(locale);
    final allCategoriesLabel = AppLocalizations.of(context)!.allCategories;

    if (_loadedLanguageCode == languageCode) return;

    _loadedLanguageCode = languageCode;
    _currentItemSelected = allCategoriesLabel;
    unawaited(_loadCatalog(locale, allCategoriesLabel));
  }

  Future<void> _loadCatalog(Locale locale, String allCategoriesLabel) async {
    setState(() {
      _categorias = const [];
      _papos = null;
    });

    final results = await Future.wait([
      _catalogService.getCategorias(locale, allCategoriesLabel),
      _catalogService.getPapos(allCategoriesLabel, locale, allCategoriesLabel),
    ]);

    if (!mounted) return;
    setState(() {
      _categorias = results[0] as List<CategoriaModel>;
      _papos = results[1] as List<PapoModel>;
    });
  }

  Future<void> _refreshPapos(
    String categoria,
    Locale locale,
    String allCategoriesLabel,
  ) async {
    setState(() {
      _papos = null;
    });

    final papos = await _catalogService.getPapos(
      categoria,
      locale,
      allCategoriesLabel,
    );
    if (!mounted) return;
    setState(() {
      _papos = papos;
    });
  }

  Future<void> _handleRefresh(
    String categoria,
    Locale locale,
    String allCategoriesLabel,
  ) async {
    await _refreshPapos(categoria, locale, allCategoriesLabel);
    await _maybeShowRefreshAd();
  }

  Future<void> _maybeShowRefreshAd() async {
    if (!widget.enableAds) return;

    _refreshActionCount++;
    if (_refreshActionCount < InterstitialAdService.refreshesBeforeAd) {
      unawaited(_interstitialAdService.loadRefreshAd());
      return;
    }

    _refreshActionCount = 0;
    await _interstitialAdService.showRefreshAd();
  }

  Future<void> _copyText(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context)!.textCopied,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: gradientStartColor,
      ),
    );
  }

  Future<void> _shareText(String text) async {
    await SharePlus.instance.share(ShareParams(text: text));
  }

  @override
  void dispose() {
    _interstitialAdService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);

    return Scaffold(
      backgroundColor: gradientEndColor,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [gradientStartColor, gradientEndColor],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.3, 0.7],
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 32.0,
                      horizontal: 32.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.homeTitle,
                              style: const TextStyle(
                                fontFamily: inkDefaultFont,
                                fontSize: 44,
                                color: Color(0xffffffff),
                                fontWeight: FontWeight.w900,
                              ),
                              textAlign: TextAlign.left,
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.refresh,
                                size: 36,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                final categoria =
                                    _currentItemSelected ?? l10n.allCategories;
                                unawaited(
                                  _handleRefresh(
                                    categoria,
                                    locale,
                                    l10n.allCategories,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        _buildCategoryDropdown(locale, l10n.allCategories),
                      ],
                    ),
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SizedBox(
                          height: math.min(500.0, constraints.maxHeight),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: _buildPapoSwiper(
                              context,
                              constraints.maxHeight,
                              l10n.copyText,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (widget.enableAds)
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(top: false, child: HomeBannerAd()),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown(Locale locale, String allCategoriesLabel) {
    final selected = _currentItemSelected;
    if (_categorias.isEmpty || selected == null) return Container();

    final value = _categorias.any((categoria) => categoria.nome == selected)
        ? selected
        : allCategoriesLabel;

    return DropdownButton<String>(
      value: value,
      isExpanded: true,
      style: const TextStyle(
        fontFamily: inkDefaultFont,
        fontSize: 24,
        color: Color(0x7cdbf1ff),
        fontWeight: FontWeight.w500,
      ),
      items: _categorias.map((categoria) {
        return DropdownMenuItem(
          value: categoria.nome,
          child: Text(
            categoria.nome,
            style: const TextStyle(
              fontFamily: inkDefaultFont,
              fontSize: 24,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.left,
          ),
        );
      }).toList(),
      onChanged: (value) async {
        if (value == null) return;
        setState(() {
          _currentItemSelected = value;
        });
        await _handleRefresh(value, locale, allCategoriesLabel);
      },
      icon: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: Image.asset('assets/images/drop_down_icon.png'),
      ),
      underline: const SizedBox(),
    );
  }

  Widget _buildPapoSwiper(
    BuildContext context,
    double availableHeight,
    String copyText,
  ) {
    final papos = _papos;
    if (papos == null) return const Spinner();
    if (papos.isEmpty) return Container();

    return Swiper(
      itemCount: papos.length,
      itemWidth: MediaQuery.of(context).size.width - 2 * 32,
      itemHeight: math.min(450.0, availableHeight),
      layout: SwiperLayout.STACK,
      pagination: const SwiperPagination(
        builder: DotSwiperPaginationBuilder(activeSize: 15, space: 8),
      ),
      itemBuilder: (context, index) {
        return _PapoCard(
          papo: papos[index],
          copyText: copyText,
          onCopy: () => _copyText(papos[index].assunto),
          onShare: () => _shareText(papos[index].assunto),
        );
      },
    );
  }
}

class _PapoCard extends StatelessWidget {
  const _PapoCard({
    required this.papo,
    required this.copyText,
    required this.onCopy,
    required this.onShare,
  });

  final PapoModel papo;
  final String copyText;
  final VoidCallback onCopy;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Column(
          children: <Widget>[
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      papo.assunto,
                      style: const TextStyle(
                        fontFamily: inkDefaultFont,
                        fontSize: 28,
                        color: Color(0xff47455f),
                        fontWeight: FontWeight.w900,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        GestureDetector(
                          onTap: onCopy,
                          child: Text(
                            copyText,
                            style: const TextStyle(
                              fontFamily: inkDefaultFont,
                              fontSize: 18,
                              color: secondaryTextColor,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.share),
                          color: secondaryTextColor,
                          onPressed: onShare,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
