import 'dart:io';

import 'package:cat_facts_mvi/core/errors/app_failure.dart';
import 'package:cat_facts_mvi/features/favorites/data/favorites_database.dart';
import 'package:cat_facts_mvi/features/favorites/data/sqlite_favorites_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../support/fakes.dart';

void main() {
  sqfliteFfiInit();
  late Directory directory;
  late String databasePath;
  late Database database;
  late SqliteFavoritesRepository repository;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('catfolio_test_');
    databasePath = '${directory.path}/favorites.db';
    database = await openFavoritesDatabase(
      factory: databaseFactoryFfi,
      databasePath: databasePath,
    );
    repository = SqliteFavoritesRepository(database);
  });
  tearDown(() async {
    await database.close();
    await directory.delete(recursive: true);
  });

  test('real SQLite CRUD survives a database close and reopen', () async {
    await repository.add(sampleFact);
    await repository.updateNote(factId: sampleFact.id, note: '  My note  ');
    final createdAt = (await repository.getAll()).single.createdAt;
    await repository.add(sampleFact);
    expect((await repository.getAll()).single.note, 'My note');
    expect((await repository.getAll()).single.createdAt, createdAt);
    await database.close();
    database = await openFavoritesDatabase(
      factory: databaseFactoryFfi,
      databasePath: databasePath,
    );
    repository = SqliteFavoritesRepository(database);
    final favorite = (await repository.getAll()).single;
    expect(favorite.fact, sampleFact);
    expect(favorite.note, 'My note');
    await repository.updateNote(factId: sampleFact.id, note: '');
    expect((await repository.getAll()).single.note, isEmpty);
    await repository.remove(sampleFact.id);
    expect(await repository.getAll(), isEmpty);
  });

  test('validates note length and missing favorites', () async {
    await repository.add(sampleFact);
    await expectLater(
      repository.updateNote(factId: sampleFact.id, note: 'a' * 501),
      throwsA(isA<AppFailure>()),
    );
    await expectLater(
      repository.updateNote(factId: 'missing', note: 'note'),
      throwsA(isA<AppFailure>()),
    );
    expect((await repository.getAll()).single.note, isEmpty);
  });

  test('SQL parameters preserve quotes without executing user input', () async {
    await repository.add(sampleFact);
    const note = "'; DROP TABLE favorites; --";
    await repository.updateNote(factId: sampleFact.id, note: note);
    expect((await repository.getAll()).single.note, note);
  });
}
