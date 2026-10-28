import 'package:equatable/equatable.dart';

import '../../../facts/domain/cat_fact.dart';

sealed class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object?> get props => [];
}

final class FavoritesRequested extends FavoritesEvent {
  const FavoritesRequested();
}

final class FavoriteAdded extends FavoritesEvent {
  const FavoriteAdded(this.fact);
  final CatFact fact;

  @override
  List<Object> get props => [fact];
}

final class FavoriteNoteUpdated extends FavoritesEvent {
  const FavoriteNoteUpdated({required this.factId, required this.note});
  final String factId;
  final String note;

  @override
  List<Object> get props => [factId, note];
}

final class FavoriteRemoved extends FavoritesEvent {
  const FavoriteRemoved(this.factId);
  final String factId;

  @override
  List<Object> get props => [factId];
}

final class FavoritesQueryChanged extends FavoritesEvent {
  const FavoritesQueryChanged(this.query);
  final String query;

  @override
  List<Object> get props => [query];
}
