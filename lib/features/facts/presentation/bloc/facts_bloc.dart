import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/app_failure.dart';
import '../../domain/facts_repository.dart';
import 'facts_event.dart';
import 'facts_state.dart';

final class FactsBloc extends Bloc<FactsEvent, FactsState> {
  FactsBloc({required this._repository}) : super(FactsState()) {
    // One event bucket is intentional: refresh and pagination cannot overlap.
    // Repeated taps while a request is running are ignored.
    on<FactsEvent>(_onEvent, transformer: droppable());
  }

  final FactsRepository _repository;

  Future<void> _onEvent(FactsEvent event, Emitter<FactsState> emit) async {
    final append = event is FactsNextPageRequested;
    if (append &&
        (state.status != FactsStatus.success || state.nextPage == null)) {
      return;
    }
    final previous = state;
    emit(
      FactsState(
        status: previous.facts.isEmpty
            ? FactsStatus.loading
            : FactsStatus.success,
        facts: previous.facts,
        nextPage: previous.nextPage,
        isRefreshing: !append,
        isLoadingMore: append,
      ),
    );
    try {
      final page = await _repository.fetchPage(
        page: append ? previous.nextPage! : 1,
      );
      final facts = {
        for (final fact in [if (append) ...previous.facts, ...page.facts])
          fact.id: fact,
      };
      emit(
        FactsState(
          status: FactsStatus.success,
          facts: facts.values.toList(),
          nextPage: page.nextPage,
        ),
      );
    } catch (error, stackTrace) {
      if (error is! AppFailure) addError(error, stackTrace);
      emit(
        FactsState(
          status: previous.facts.isEmpty
              ? FactsStatus.failure
              : FactsStatus.success,
          facts: previous.facts,
          nextPage: previous.nextPage,
          failure: error is AppFailure
              ? error
              : const AppFailure(
                  FailureKind.unexpected,
                  'Something went wrong. Please try again.',
                ),
        ),
      );
    }
  }
}
