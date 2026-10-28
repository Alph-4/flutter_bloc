import 'package:equatable/equatable.dart';

import '../../facts/domain/cat_fact.dart';

final class Favorite extends Equatable {
  const Favorite({required this.fact, required this.createdAt, this.note = ''});

  final CatFact fact;
  final DateTime createdAt;
  final String note;

  @override
  List<Object> get props => [fact, createdAt, note];
}
