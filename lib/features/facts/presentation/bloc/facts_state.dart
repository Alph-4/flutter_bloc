import 'package:equatable/equatable.dart';

import '../../../../core/errors/app_failure.dart';
import '../../domain/cat_fact.dart';

enum FactsStatus { initial, loading, success, failure }

final class FactsState extends Equatable {
  FactsState({
    this.status = FactsStatus.initial,
    List<CatFact> facts = const [],
    this.nextPage,
    this.isRefreshing = false,
    this.isLoadingMore = false,
    this.failure,
  }) : facts = List.unmodifiable(facts);

  final FactsStatus status;
  final List<CatFact> facts;
  final int? nextPage;
  final bool isRefreshing;
  final bool isLoadingMore;
  final AppFailure? failure;

  @override
  List<Object?> get props => [
    status,
    facts,
    nextPage,
    isRefreshing,
    isLoadingMore,
    failure,
  ];
}
