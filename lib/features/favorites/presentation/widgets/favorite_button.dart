import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../facts/domain/cat_fact.dart';
import '../bloc/favorites_bloc.dart';
import '../bloc/favorites_event.dart';
import '../bloc/favorites_state.dart';
import 'confirm_removal.dart';

class FavoriteButton extends StatelessWidget {
  const FavoriteButton({super.key, required this.fact});
  final CatFact fact;

  @override
  Widget build(BuildContext context) =>
      BlocSelector<FavoritesBloc, FavoritesState, ({bool saved, bool enabled})>(
        selector: (state) => (
          saved: state.find(fact.id) != null,
          enabled: state.status == FavoritesStatus.success && !state.isSaving,
        ),
        builder: (context, selection) => IconButton.filledTonal(
          tooltip: selection.saved
              ? 'Remove from favorites'
              : 'Add to favorites',
          isSelected: selection.saved,
          onPressed: selection.enabled
              ? () async {
                  if (selection.saved) {
                    final confirmed = await confirmFavoriteRemoval(context);
                    if (confirmed && context.mounted) {
                      context.read<FavoritesBloc>().add(FavoriteRemoved(fact.id));
                    }
                  } else {
                    context.read<FavoritesBloc>().add(FavoriteAdded(fact));
                  }
                }
              : null,
          icon: const Icon(Icons.bookmark_add_outlined),
          selectedIcon: const Icon(Icons.bookmark_added_rounded),
        ),
      );
}
