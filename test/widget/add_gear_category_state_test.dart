// Widget test stavového automatu sekce Kategorie na obrazovce Nové vybavení.
//
// V test prostředí není DB plugin → getCategories() vyhodí výjimku.
// Ověřujeme, že sekce Kategorie přejde ze stavu loading do error stavu
// (a nezůstane viset spinner — to byl reportovaný bug).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:outdoor_gear_tracker/l10n/app_localizations.dart';
import 'package:outdoor_gear_tracker/screens/add_gear_screen.dart';

void main() {
  testWidgets(
      'selhání načtení kategorií přepne sekci z loading do error stavu',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      locale: Locale('cs'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: AddGearScreen(),
    ));

    // Dokončí mikrotasky z initState/_loadCategories — getCategories()
    // selže (chybí DB plugin), takže se nastaví _categoryLoadError.
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Žádný věčný spinner — místo něj srozumitelná chyba s recovery akcemi.
    expect(find.text('Nepodařilo se načíst kategorie.'), findsOneWidget);
    expect(find.text('Zkusit znovu'), findsOneWidget);
    expect(find.text('Obnovit výchozí kategorie'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
