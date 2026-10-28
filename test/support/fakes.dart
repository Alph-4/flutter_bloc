import 'package:cat_facts_mvi/core/errors/app_failure.dart';
import 'package:cat_facts_mvi/features/facts/domain/cat_fact.dart';
import 'package:cat_facts_mvi/features/facts/domain/facts_repository.dart';
import 'package:cat_facts_mvi/features/favorites/domain/favorite.dart';
import 'package:cat_facts_mvi/features/favorites/domain/favorites_repository.dart';

final sampleFact = CatFact.fromText(
  'Cats use their whiskers to explore the world.',
);
final anotherFact = CatFact.fromText('Cats have excellent hearing.');

final class FakeFactsRepository implements FactsRepository {
  FakeFactsRepository({this.fetch});
  Future<FactsPage> Function(int page)? fetch;
  final calls = <int>[];

  @override
  Future<FactsPage> fetchPage({required int page}) async {
    calls.add(page);
    return fetch != null
        ? fetch!(page)
        : FactsPage(facts: [sampleFact], nextPage: null);
  }
}

final class MemoryFavoritesRepository implements FavoritesRepository {
  final items = <String, Favorite>{};
  final writes = <String>[];
  bool failWrites = false;
  bool failReads = false;
  Future<void> Function()? beforeAdd;

  void _checkWrite() {
    if (failWrites) {
      throw const AppFailure(
        FailureKind.storage,
        'Unable to save. Please try again.',
      );
    }
  }

  @override
  Future<List<Favorite>> getAll() async {
    if (failReads) {
      throw const AppFailure(FailureKind.storage, 'Unable to read favorites.');
    }
    return List.unmodifiable(items.values);
  }

  @override
  Future<void> add(CatFact fact) async {
    await beforeAdd?.call();
    _checkWrite();
    writes.add('add');
    items.putIfAbsent(
      fact.id,
      () => Favorite(fact: fact, createdAt: DateTime.utc(2026)),
    );
  }

  @override
  Future<void> updateNote({
    required String factId,
    required String note,
  }) async {
    _checkWrite();
    final current = items[factId];
    if (current == null) {
      throw const AppFailure(FailureKind.storage, 'Favorite not found.');
    }
    items[factId] = Favorite(
      fact: current.fact,
      createdAt: current.createdAt,
      note: note.trim(),
    );
    writes.add('update');
  }

  @override
  Future<void> remove(String factId) async {
    _checkWrite();
    writes.add('remove');
    items.remove(factId);
  }
}
