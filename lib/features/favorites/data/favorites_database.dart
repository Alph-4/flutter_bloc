import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

/// The factory and path are injected so the same schema can run in real SQLite
/// tests. Schema changes belong in a new version and an onUpgrade migration.
Future<Database> openFavoritesDatabase({
  DatabaseFactory? factory,
  String? databasePath,
}) async {
  final resolvedFactory = factory ?? databaseFactory;
  final resolvedPath =
      databasePath ??
      path.join(await resolvedFactory.getDatabasesPath(), 'catfolio.db');
  return resolvedFactory.openDatabase(
    resolvedPath,
    options: OpenDatabaseOptions(
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE favorites (
          id TEXT PRIMARY KEY NOT NULL,
          text TEXT NOT NULL,
          note TEXT NOT NULL DEFAULT '' CHECK(length(note) <= 500),
          created_at INTEGER NOT NULL
        )
      ''');
      },
    ),
  );
}
