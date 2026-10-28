import 'package:sqflite/sqflite.dart';

import '../../../core/errors/app_failure.dart';
import '../../facts/domain/cat_fact.dart';
import '../domain/favorite.dart';
import '../domain/favorites_repository.dart';

/// Successful writes are committed before the BLoC publishes a new state.
/// The BLoC serializes operations across add, update, remove, and reload.
final class SqliteFavoritesRepository implements FavoritesRepository {
  const SqliteFavoritesRepository(this._database);

  final Database _database;

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on DatabaseException {
      throw const AppFailure(
        FailureKind.storage,
        'Unable to access saved facts. Please try again.',
      );
    }
  }

  @override
  Future<List<Favorite>> getAll() => _guard(() async {
    final rows = await _database.query(
      'favorites',
      orderBy: 'created_at DESC, id ASC',
    );
    return List.unmodifiable(
      rows.map(
        (row) => Favorite(
          fact: CatFact(id: row['id']! as String, text: row['text']! as String),
          note: row['note']! as String,
          createdAt: DateTime.fromMillisecondsSinceEpoch(
            row['created_at']! as int,
            isUtc: true,
          ),
        ),
      ),
    );
  });

  @override
  Future<void> add(CatFact fact) => _guard(() async {
    // IGNORE keeps an existing note and creation date when a fact is saved twice.
    await _database.insert('favorites', {
      'id': fact.id,
      'text': fact.text,
      'note': '',
      'created_at': DateTime.now().toUtc().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  });

  @override
  Future<void> updateNote({required String factId, required String note}) =>
      _guard(() async {
        final trimmed = note.trim();
        if (trimmed.length > 500) {
          throw const AppFailure(
            FailureKind.invalidData,
            'Notes must be 500 characters or fewer.',
          );
        }
        final changed = await _database.update(
          'favorites',
          {'note': trimmed},
          where: 'id = ?',
          whereArgs: [factId],
        );
        if (changed == 0) {
          throw const AppFailure(
            FailureKind.storage,
            'This favorite no longer exists.',
          );
        }
      });

  @override
  Future<void> remove(String factId) => _guard(() async {
    await _database.delete('favorites', where: 'id = ?', whereArgs: [factId]);
  });
}
