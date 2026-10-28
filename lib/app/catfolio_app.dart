import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/facts/domain/facts_repository.dart';
import '../features/facts/presentation/bloc/facts_bloc.dart';
import '../features/facts/presentation/bloc/facts_event.dart';
import '../features/favorites/domain/favorites_repository.dart';
import '../features/favorites/presentation/bloc/favorites_bloc.dart';
import '../features/favorites/presentation/bloc/favorites_event.dart';
import 'app_theme.dart';
import 'home_page.dart';

/// The composition root: interfaces are injected, implementations stay outside
/// the widget tree. Tests can use fakes without HTTP or platform plugins.
class CatfolioApp extends StatelessWidget {
  const CatfolioApp({
    super.key,
    required this.factsRepository,
    required this.favoritesRepository,
  });

  final FactsRepository factsRepository;
  final FavoritesRepository favoritesRepository;

  @override
  Widget build(BuildContext context) => MultiRepositoryProvider(
    providers: [
      RepositoryProvider<FactsRepository>.value(value: factsRepository),
      RepositoryProvider<FavoritesRepository>.value(value: favoritesRepository),
    ],
    child: MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              FactsBloc(repository: context.read<FactsRepository>())
                ..add(const FactsRequested()),
        ),
        BlocProvider(
          create: (context) =>
              FavoritesBloc(repository: context.read<FavoritesRepository>())
                ..add(const FavoritesRequested()),
        ),
      ],
      child: MaterialApp(
        title: 'Catfolio',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const HomePage(),
      ),
    ),
  );
}
