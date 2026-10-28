import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:cat_facts_mvi/core/errors/app_failure.dart';
import 'package:cat_facts_mvi/features/facts/domain/facts_repository.dart';
import 'package:cat_facts_mvi/features/facts/presentation/bloc/facts_bloc.dart';
import 'package:cat_facts_mvi/features/facts/presentation/bloc/facts_event.dart';
import 'package:cat_facts_mvi/features/facts/presentation/bloc/facts_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fakes.dart';

void main() {
  blocTest<FactsBloc, FactsState>(
    'loads facts through the repository',
    build: () => FactsBloc(repository: FakeFactsRepository()),
    act: (bloc) => bloc.add(const FactsRequested()),
    expect: () => [
      FactsState(status: FactsStatus.loading, isRefreshing: true),
      FactsState(status: FactsStatus.success, facts: [sampleFact]),
    ],
  );

  blocTest<FactsBloc, FactsState>(
    'reports an initial failure',
    build: () => FactsBloc(
      repository: FakeFactsRepository(
        fetch: (_) async =>
            throw const AppFailure(FailureKind.network, 'Offline'),
      ),
    ),
    act: (bloc) => bloc.add(const FactsRequested()),
    expect: () => [
      isA<FactsState>().having((s) => s.status, 'status', FactsStatus.loading),
      isA<FactsState>()
          .having((s) => s.status, 'status', FactsStatus.failure)
          .having((s) => s.failure?.kind, 'kind', FailureKind.network),
    ],
  );

  test('pagination deduplicates, preserves data on failure, and retries the same page', () async {
    var fail = true;
    final repository = FakeFactsRepository(
      fetch: (page) async {
        if (page == 1) return FactsPage(facts: [sampleFact], nextPage: 2);
        if (fail) throw const AppFailure(FailureKind.network, 'Offline');
        return FactsPage(facts: [sampleFact, anotherFact], nextPage: null);
      },
    );
    final bloc = FactsBloc(repository: repository);
    addTearDown(bloc.close);
    var complete = bloc.stream.firstWhere(
      (s) => s.status == FactsStatus.success,
    );
    bloc.add(const FactsRequested());
    await complete;
    complete = bloc.stream.firstWhere((s) => s.failure != null);
    bloc.add(const FactsNextPageRequested());
    await complete;
    expect(bloc.state.facts, [sampleFact]);
    expect(bloc.state.nextPage, 2);
    fail = false;
    complete = bloc.stream.firstWhere(
      (s) => !s.isLoadingMore && s.failure == null,
    );
    bloc.add(const FactsNextPageRequested());
    await complete;
    expect(bloc.state.facts, [sampleFact, anotherFact]);
    expect(repository.calls, [1, 2, 2]);
    expect(bloc.state.nextPage, isNull);
  });

  test(
    'refresh and pagination share a single droppable event bucket',
    () async {
      final gate = Completer<FactsPage>();
      final repository = FakeFactsRepository(fetch: (_) => gate.future);
      final bloc = FactsBloc(repository: repository);
      addTearDown(bloc.close);
      final loading = bloc.stream.firstWhere((s) => s.isRefreshing);
      bloc.add(const FactsRequested());
      await loading;
      bloc
        ..add(const FactsRequested())
        ..add(const FactsNextPageRequested());
      await Future<void>.delayed(Duration.zero);
      expect(repository.calls, [1]);
      final complete = bloc.stream.firstWhere(
        (s) => s.status == FactsStatus.success,
      );
      gate.complete(FactsPage(facts: [sampleFact], nextPage: null));
      await complete;
      expect(repository.calls, [1]);
    },
  );

  test('refresh replaces the previous collection', () async {
    final repository = FakeFactsRepository(
      fetch: (_) async => FactsPage(facts: [sampleFact], nextPage: 2),
    );
    final bloc = FactsBloc(repository: repository);
    addTearDown(bloc.close);
    var complete = bloc.stream.firstWhere(
      (s) => s.status == FactsStatus.success,
    );
    bloc.add(const FactsRequested());
    await complete;
    repository.fetch = (_) async =>
        FactsPage(facts: [anotherFact], nextPage: null);
    complete = bloc.stream.firstWhere(
      (s) => !s.isRefreshing && s.facts.contains(anotherFact),
    );
    bloc.add(const FactsRequested());
    await complete;
    expect(bloc.state.facts, [anotherFact]);
    expect(repository.calls, [1, 1]);
  });
}
