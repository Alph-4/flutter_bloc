import 'package:cat_facts_mvi/app/catfolio_app.dart';
import 'package:cat_facts_mvi/features/favorites/data/favorites_database.dart';
import 'package:cat_facts_mvi/features/favorites/data/sqlite_favorites_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import '../test/support/fakes.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('native SQLite favorites survive a reopen and support the UI workflow', (tester) async {
    final databasePath = path.join(await getDatabasesPath(), 'catfolio_integration_${DateTime.now().microsecondsSinceEpoch}.db');
    var database = await openFavoritesDatabase(databasePath: databasePath);
    addTearDown(() async {
      await database.close();
      await deleteDatabase(databasePath);
    });
    var repository = SqliteFavoritesRepository(database);
    await tester.pumpWidget(CatfolioApp(factsRepository: FakeFactsRepository(), favoritesRepository: repository));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text(sampleFact.text), 250, scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text(sampleFact.text));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Save to favorites'));
    await tester.tap(find.text('Save to favorites'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Add note'));
    await tester.tap(find.text('Add note'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('note-input')), 'Saved through native SQLite');
    await tester.tap(find.text('Save note'));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await database.close();
    database = await openFavoritesDatabase(databasePath: databasePath);
    repository = SqliteFavoritesRepository(database);
    final saved = (await repository.getAll()).single;
    expect(saved.fact, sampleFact);
    expect(saved.note, 'Saved through native SQLite');
    await repository.updateNote(factId: sampleFact.id, note: 'Updated on Android');
    expect((await repository.getAll()).single.note, 'Updated on Android');
    await repository.remove(sampleFact.id);
    expect(await repository.getAll(), isEmpty);
  });
}
