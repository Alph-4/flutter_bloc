import '../domain/facts_repository.dart';
import 'cat_fact_api.dart';

final class ApiFactsRepository implements FactsRepository {
  const ApiFactsRepository(this._api);

  final CatFactApi _api;

  @override
  Future<FactsPage> fetchPage({required int page}) =>
      _api.fetchPage(page: page);
}
