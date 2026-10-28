import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/app_failure.dart';
import '../../domain/favorites_repository.dart';
import 'favorites_event.dart';
import 'favorites_state.dart';

final class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  FavoritesBloc({required this._repository}) : super(FavoritesState()) {
    // Register the base type once. Separate sequential handlers per subtype
    // would still allow add and remove to run concurrently with each other.
    on<FavoritesEvent>(_onEvent, transformer: sequential());
  }

  final FavoritesRepository _repository;

  Future<void> _onEvent(
    FavoritesEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    if (event is FavoritesQueryChanged) {
      emit(state.copyWith(query: event.query));
      return;
    }
    final loading = event is FavoritesRequested;
    emit(
      state.copyWith(
        status: loading && state.status != FavoritesStatus.success
            ? FavoritesStatus.loading
            : state.status,
        isSaving: !loading,
      ),
    );
    try {
      final String? feedback;
      switch (event) {
        case FavoritesRequested():
          feedback = null;
        case FavoriteAdded(:final fact):
          await _repository.add(fact);
          feedback = 'Added to your collection.';
        case FavoriteNoteUpdated(:final factId, :final note):
          await _repository.updateNote(factId: factId, note: note);
          feedback = 'Note saved.';
        case FavoriteRemoved(:final factId):
          await _repository.remove(factId);
          feedback = 'Removed from your collection.';
        case FavoritesQueryChanged():
          return;
      }
      final favorites = await _repository.getAll();
      emit(
        state.copyWith(
          status: FavoritesStatus.success,
          favorites: favorites,
          isSaving: false,
          feedback: feedback,
          feedbackId: feedback == null
              ? state.feedbackId
              : state.feedbackId + 1,
        ),
      );
    } catch (error, stackTrace) {
      if (error is! AppFailure) addError(error, stackTrace);
      final failure = error is AppFailure
          ? error
          : const AppFailure(
              FailureKind.unexpected,
              'Something went wrong. Please try again.',
            );
      emit(
        state.copyWith(
          status: loading && state.status != FavoritesStatus.success
              ? FavoritesStatus.failure
              : state.status,
          isSaving: false,
          failure: failure,
          feedback: failure.message,
          feedbackId: state.feedbackId + 1,
        ),
      );
    }
  }
}
