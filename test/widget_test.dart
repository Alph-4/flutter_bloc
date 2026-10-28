import 'package:cat_facts_mvi/app/catfolio_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fakes.dart';

void main() {
  Future<void> openFact(WidgetTester tester) async {
    await tester.scrollUntilVisible(
      find.text(sampleFact.text),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text(sampleFact.text).first);
    await tester.pumpAndSettle();
  }

  Future<void> tapVisible(WidgetTester tester, String label) async {
    final target = find.text(label).last;
    await tester.ensureVisible(target);
    await tester.tap(target);
    await tester.pumpAndSettle();
  }

  testWidgets('save a fact, create and update a note, search, and remove it', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final favorites = MemoryFavoritesRepository();
    await tester.pumpWidget(
      CatfolioApp(
        factsRepository: FakeFactsRepository(),
        favoritesRepository: favorites,
      ),
    );
    await tester.pumpAndSettle();
    await openFact(tester);
    await tapVisible(tester, 'Save to favorites');
    await tapVisible(tester, 'Add note');
    await tester.enterText(
      find.byKey(const Key('note-input')),
      'A special discovery',
    );
    await tapVisible(tester, 'Save note');
    expect(favorites.items[sampleFact.id]?.note, 'A special discovery');
    await tapVisible(tester, 'Edit note');
    await tester.enterText(
      find.byKey(const Key('note-input')),
      'Updated discovery',
    );
    await tapVisible(tester, 'Save note');
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Favorites'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('favorites-search')),
      'Updated',
    );
    await tester.pumpAndSettle();
    expect(find.text(sampleFact.text), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('favorites-search')),
      'no match',
    );
    await tester.pumpAndSettle();
    expect(find.text('No matching discoveries'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('favorites-search')), '');
    await tester.pumpAndSettle();
    await openFact(tester);
    await tapVisible(tester, 'Remove favorite');
    await tapVisible(tester, 'Remove');
    expect(favorites.items, isEmpty);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Start your own little library'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a failed note save keeps the dialog and draft for retry', (
    tester,
  ) async {
    final favorites = MemoryFavoritesRepository();
    await favorites.add(sampleFact);
    await tester.pumpWidget(
      CatfolioApp(
        factsRepository: FakeFactsRepository(),
        favoritesRepository: favorites,
      ),
    );
    await tester.pumpAndSettle();
    await openFact(tester);
    await tapVisible(tester, 'Add note');
    await tester.enterText(
      find.byKey(const Key('note-input')),
      'Keep my draft',
    );
    favorites.failWrites = true;
    await tapVisible(tester, 'Save note');
    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text('Keep my draft'), findsOneWidget);
    expect(favorites.items[sampleFact.id]?.note, isEmpty);
    favorites.failWrites = false;
    await tapVisible(tester, 'Save note');
    expect(find.byType(Dialog), findsNothing);
    expect(favorites.items[sampleFact.id]?.note, 'Keep my draft');
  });

  testWidgets('narrow screens and large text remain usable', (tester) async {
    tester.view.physicalSize = const Size(320, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.platformDispatcher.textScaleFactorTestValue = 1.8;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(1.8)),
        child: CatfolioApp(
          factsRepository: FakeFactsRepository(),
          favoritesRepository: MemoryFavoritesRepository(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('catfolio'), findsOneWidget);
    expect(MediaQuery.textScalerOf(tester.element(find.text('catfolio'))).scale(10), 18);
    expect(tester.takeException(), isNull);
  });
}
