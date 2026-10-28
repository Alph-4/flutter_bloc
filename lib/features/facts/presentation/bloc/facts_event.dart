import 'package:equatable/equatable.dart';

sealed class FactsEvent extends Equatable {
  const FactsEvent();

  @override
  List<Object?> get props => [];
}

/// Also used for explicit refresh and retry: always starts at page one.
final class FactsRequested extends FactsEvent {
  const FactsRequested();
}

final class FactsNextPageRequested extends FactsEvent {
  const FactsNextPageRequested();
}
