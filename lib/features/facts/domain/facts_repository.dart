import 'cat_fact.dart';

final class FactsPage {
  FactsPage({required List<CatFact> facts, required this.nextPage})
    : facts = List.unmodifiable(facts);

  final List<CatFact> facts;
  final int? nextPage;
}

abstract interface class FactsRepository {
  Future<FactsPage> fetchPage({required int page});
}
