import 'dart:async';

import 'package:cat_facts_mvi/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:cat_facts_mvi/features/favorites/presentation/bloc/favorites_event.dart';
import 'package:cat_facts_mvi/features/favorites/presentation/bloc/favorites_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fakes.dart';

void main() {
  late MemoryFavoritesRepository repository;
  late FavoritesBloc bloc;

  setUp(() {
    repository = MemoryFavoritesRepository();
    bloc = FavoritesBloc(repository: repository);
  });
  tearDown(() => bloc.close());

  Future<void> dispatch(FavoritesEvent event) async {
    final complete = bloc.stream.firstWhere(
      (state) => !state.isSaving && state.status != FavoritesStatus.loading,
    );
    bloc.add(event);
    await complete;
  }

  test('create, read, update, search, delete', () async {
    await dispatch(const FavoritesRequested());
    await dispatch(FavoriteAdded(sampleFact));
    expect(bloc.state.favorites.single.fact, sampleFact);
    await dispatch(
      FavoriteNoteUpdated(factId: sampleFact.id, note: 'Remember whiskers'),
    );
    expect(bloc.state.favorites.single.note, 'Remember whiskers');
    await dispatch(const FavoritesQueryChanged('REMEMBER'));
    expect(bloc.state.visibleFavorites, hasLength(1));
    await dispatch(const FavoritesQueryChanged('unmatched'));
    expect(bloc.state.visibleFavorites, isEmpty);
    await dispatch(FavoriteRemoved(sampleFact.id));
    expect(bloc.state.favorites, isEmpty);
    expect(bloc.state.feedbackId, 3);
  });

  test('failed mutation retains the last committed state', () async {
    await dispatch(const FavoritesRequested());
    await dispatch(FavoriteAdded(sampleFact));
    repository.failWrites = true;
    await dispatch(FavoriteRemoved(sampleFact.id));
    expect(bloc.state.favorites.single.fact, sampleFact);
    expect(bloc.state.failure, isNotNull);
    repository.failWrites = false;
    await dispatch(FavoriteRemoved(sampleFact.id));
    expect(bloc.state.favorites, isEmpty);
    expect(bloc.state.failure, isNull);
  });

  test('add and remove are serialized across different event types', () async {
    await dispatch(const FavoritesRequested());
    final gate = Completer<void>();
    repository.beforeAdd = () => gate.future;
    final saving = bloc.stream.firstWhere((s) => s.isSaving);
    bloc.add(FavoriteAdded(sampleFact));
    await saving;
    bloc.add(FavoriteRemoved(sampleFact.id));
    await Future<void>.delayed(Duration.zero);
    expect(repository.writes, isEmpty);
    final removed = bloc.stream.firstWhere((s) => s.feedbackId == 2);
    gate.complete();
    await removed;
    expect(repository.writes, ['add', 'remove']);
    expect(bloc.state.favorites, isEmpty);
  });

  test('read failures can be retried', () async {
    repository.failReads = true;
    await dispatch(const FavoritesRequested());
    expect(bloc.state.status, FavoritesStatus.failure);
    repository.failReads = false;
    await dispatch(const FavoritesRequested());
    expect(bloc.state.status, FavoritesStatus.success);
    expect(bloc.state.failure, isNull);
  });
}
