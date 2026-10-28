import 'package:equatable/equatable.dart';

enum FailureKind { network, server, invalidData, storage, unexpected }

/// A safe, user-facing failure. Technical errors belong in the observer.
final class AppFailure extends Equatable implements Exception {
  const AppFailure(this.kind, this.message);

  final FailureKind kind;
  final String message;

  @override
  List<Object> get props => [kind, message];

  @override
  String toString() => 'AppFailure($kind)';
}
