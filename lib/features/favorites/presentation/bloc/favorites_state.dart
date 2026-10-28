import 'package:equatable/equatable.dart';

import '../../../../core/errors/app_failure.dart';
import '../../domain/favorite.dart';

enum FavoritesStatus { initial, loading, success, failure }

/// A monotonically increasing feedbackId makes repeated notifications distinct.
/// BlocListener reacts to that ID; builders remain free of side effects.
final class FavoritesState extends Equatable {
  FavoritesState({
    this.status = FavoritesStatus.initial,
    List<Favorite> favorites = const [],
    this.query = '',
    this.isSaving = false,
    this.failure,
    this.feedback,
    this.feedbackId = 0,
  }) : favorites = List.unmodifiable(favorites);

  final FavoritesStatus status;
  final List<Favorite> favorites;
  final String query;
  final bool isSaving;
  final AppFailure? failure;
  final String? feedback;
  final int feedbackId;

  List<Favorite> get visibleFavorites {
    final normalized = query.trim().toLowerCase();
    return List.unmodifiable(
      favorites.where(
        (favorite) =>
            favorite.fact.text.toLowerCase().contains(normalized) ||
            favorite.note.toLowerCase().contains(normalized),
      ),
    );
  }

  Favorite? find(String id) {
    for (final favorite in favorites) {
      if (favorite.fact.id == id) return favorite;
    }
    return null;
  }

  FavoritesState copyWith({
    FavoritesStatus? status,
    List<Favorite>? favorites,
    String? query,
    bool? isSaving,
    AppFailure? failure,
    String? feedback,
    int? feedbackId,
  }) => FavoritesState(
    status: status ?? this.status,
    favorites: favorites ?? this.favorites,
    query: query ?? this.query,
    isSaving: isSaving ?? this.isSaving,
    failure: failure,
    feedback: feedback,
    feedbackId: feedbackId ?? this.feedbackId,
  );

  @override
  List<Object?> get props => [
    status,
    favorites,
    query,
    isSaving,
    failure,
    feedback,
    feedbackId,
  ];
}
