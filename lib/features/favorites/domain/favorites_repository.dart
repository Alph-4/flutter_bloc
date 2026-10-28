import '../../facts/domain/cat_fact.dart';
import 'favorite.dart';

abstract interface class FavoritesRepository {
  Future<List<Favorite>> getAll();
  Future<void> add(CatFact fact);
  Future<void> updateNote({required String factId, required String note});
  Future<void> remove(String factId);
}
