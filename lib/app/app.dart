import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ice_breaker_app/l10n/app_localizations.dart';

import 'navigation/app_navigator.dart';
import 'theme/app_theme.dart';
import 'ui/screens/home/home_screen.dart';

class IceBreakerApp extends StatelessWidget {
  const IceBreakerApp({super.key, this.enableAds = true, this.locale});

  final bool enableAds;
  final Locale? locale;

  static Locale resolveLocale(
    Locale? locale,
    Iterable<Locale> supportedLocales,
  ) {
    if (locale == null) return const Locale('en');
    for (final supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return supportedLocale;
      }
    }
    return const Locale('en');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appName,
      debugShowCheckedModeBanner: false,
      navigatorKey: AppNavigator.key,
      theme: AppTheme.light,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      localeResolutionCallback: resolveLocale,
      home: HomeScreen(enableAds: enableAds),
      routes: {'/home': (_) => HomeScreen(enableAds: enableAds)},
    );
  }
}
