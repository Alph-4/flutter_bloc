import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/widgets/status_panel.dart';
import '../../facts/presentation/widgets/fact_card.dart';
import 'bloc/favorites_bloc.dart';
import 'bloc/favorites_event.dart';
import 'bloc/favorites_state.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<FavoritesBloc, FavoritesState>(
    builder: (context, state) {
      final visible = state.visibleFavorites;
      return ListView(
        key: const PageStorageKey('favorites-scroll'),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        children: [
          Text(
            'Worth keeping.',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 8),
          Text(
            '${state.favorites.length} saved discoveries. Yours to revisit, even offline.',
          ),
          const SizedBox(height: 24),
          TextField(
            key: const Key('favorites-search'),
            decoration: const InputDecoration(
              labelText: 'Search facts and notes',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (query) =>
                context.read<FavoritesBloc>().add(FavoritesQueryChanged(query)),
          ),
          const SizedBox(height: 20),
          if (state.status == FavoritesStatus.initial ||
              state.status == FavoritesStatus.loading)
            const Center(
              child: CircularProgressIndicator(
                semanticsLabel: 'Loading favorites',
              ),
            ),
          if (state.status == FavoritesStatus.failure)
            StatusPanel(
              icon: Icons.error_outline,
              title: 'Unable to open your collection',
              message: state.failure?.message ?? 'Please try again.',
              onRetry: () =>
                  context.read<FavoritesBloc>().add(const FavoritesRequested()),
            ),
          if (state.status == FavoritesStatus.success &&
              state.favorites.isEmpty)
            const StatusPanel(
              icon: Icons.bookmarks_outlined,
              title: 'Start your own little library',
              message: 'Tap the bookmark on any discovery to save it here. Open a saved fact to add a personal note.',
            ),
          if (state.status == FavoritesStatus.success &&
              state.favorites.isNotEmpty &&
              visible.isEmpty)
            const StatusPanel(
              icon: Icons.search_off_rounded,
              title: 'No matching discoveries',
              message: 'Try another word from a fact or your personal notes.',
            ),
          ...visible.indexed.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: FactCard(
                fact: entry.$2.fact,
                note: entry.$2.note,
                index: entry.$1 + 1,
              ),
            ),
          ),
        ],
      );
    },
  );
}
