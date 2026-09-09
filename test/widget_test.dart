import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ice_breaker_app/l10n/app_localizations.dart';

import 'package:ice_breaker_app/app/app.dart';
import 'package:ice_breaker_app/app/services/papo_catalog_service.dart';

void main() {
  testWidgets('renders the daopapo home layout in Portuguese', (tester) async {
    await tester.pumpWidget(
      const IceBreakerApp(enableAds: false, locale: Locale('pt')),
    );
    await pumpUntilFound(tester, find.text('Copiar texto'));

    expect(find.text('Dá o papo!'), findsOneWidget);
    expect(find.byType(DropdownButton<String>), findsOneWidget);
    expect(find.text('Copiar texto'), findsWidgets);
    expect(find.byIcon(Icons.refresh), findsOneWidget);
  });

  testWidgets('renders localized home strings in English', (tester) async {
    await tester.pumpWidget(
      const IceBreakerApp(enableAds: false, locale: Locale('en')),
    );
    await pumpUntilFound(tester, find.text('Copy text'));

    expect(find.text('Ice Breaker'), findsOneWidget);
    expect(find.text('All categories'), findsOneWidget);
    expect(find.text('Copy text'), findsWidgets);
  });

  test('falls back to English for unsupported locales', () {
    final resolvedLocale = IceBreakerApp.resolveLocale(
      const Locale('fr'),
      AppLocalizations.supportedLocales,
    );

    expect(resolvedLocale, const Locale('en'));
    expect(PapoCatalogService.languageCodeFor(const Locale('fr')), 'en');
  });
}

Future<void> pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  int maxPumps = 100,
}) async {
  for (var i = 0; i < maxPumps; i++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) return;
  }
  throw TestFailure('Timed out waiting for $finder');
}
