import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';

import 'app/app_bloc_observer.dart';
import 'app/app_theme.dart';
import 'app/catfolio_app.dart';
import 'core/widgets/status_panel.dart';
import 'features/facts/data/api_facts_repository.dart';
import 'features/facts/data/cat_fact_api.dart';
import 'features/favorites/data/favorites_database.dart';
import 'features/favorites/data/sqlite_favorites_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = AppBlocObserver();
  runApp(const CatfolioBootstrap());
}

/// Owns infrastructure resources. Startup errors have an explicit retry path.
class CatfolioBootstrap extends StatefulWidget {
  const CatfolioBootstrap({super.key});

  @override
  State<CatfolioBootstrap> createState() => _CatfolioBootstrapState();
}

class _CatfolioBootstrapState extends State<CatfolioBootstrap> {
  final _client = http.Client();
  late Future<Database> _database = openFavoritesDatabase();

  @override
  void dispose() {
    _client.close();
    unawaited(
      _database.then<void>((database) async {
        await database.close();
      }, onError: (Object error, StackTrace stackTrace) {}),
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Database>(
    future: _database,
    builder: (context, snapshot) {
      final database = snapshot.data;
      if (database != null) {
        return CatfolioApp(
          factsRepository: ApiFactsRepository(CatFactApi(client: _client)),
          favoritesRepository: SqliteFavoritesRepository(database),
        );
      }
      return MaterialApp(
        title: 'Catfolio',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: Scaffold(
          body: SafeArea(
            child: Center(
              child: snapshot.hasError
                  ? StatusPanel(
                      icon: Icons.storage_rounded,
                      title: 'Unable to open your collection',
                      message: 'Device storage could not be opened. Check available space and try again.',
                      onRetry: () =>
                          setState(() => _database = openFavoritesDatabase()),
                    )
                  : const CircularProgressIndicator(
                      semanticsLabel: 'Opening your collection',
                    ),
            ),
          ),
        ),
      );
    },
  );
}
