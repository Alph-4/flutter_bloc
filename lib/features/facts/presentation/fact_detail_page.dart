import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/app_theme.dart';
import '../../favorites/presentation/bloc/favorites_bloc.dart';
import '../../favorites/presentation/bloc/favorites_event.dart';
import '../../favorites/presentation/bloc/favorites_state.dart';
import '../../favorites/presentation/widgets/favorite_button.dart';
import '../../favorites/presentation/widgets/note_editor.dart';
import '../domain/cat_fact.dart';

class FactDetailPage extends StatelessWidget {
  const FactDetailPage({super.key, required this.fact});
  final CatFact fact;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('A closer look'),
      actions: [
        FavoriteButton(fact: fact),
        const SizedBox(width: 16),
      ],
    ),
    body: SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 12),
              const Align(
                alignment: Alignment.centerLeft,
                child: CircleAvatar(
                  radius: 32,
                  backgroundColor: AppTheme.accent,
                  child: Icon(
                    Icons.pets_rounded,
                    size: 32,
                    color: AppTheme.ink,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'DID YOU KNOW?',
                style: Theme.of(context).textTheme.labelMedium!
                    .copyWith(letterSpacing: 2),
              ),
              const SizedBox(height: 16),
              SelectableText(
                fact.text,
                style: Theme.of(context).textTheme.headlineMedium!
                    .copyWith(height: 1.5),
              ),
              const SizedBox(height: 24),
              const Text('Source: Cat Fact Ninja / catfact.ninja'),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(
                      ClipboardData(
                        text: '${fact.text}\n\nSource: https://catfact.ninja',
                      ),
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Fact copied.')),
                      );
                    }
                  },
                  icon: const Icon(Icons.copy_outlined, size: 18),
                  label: const Text('Copy fact'),
                ),
              ),
              const SizedBox(height: 24),
              BlocBuilder<FavoritesBloc, FavoritesState>(
                builder: (context, state) {
                  final favorite = state.find(fact.id);
                  if (favorite == null) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Make it part of your collection',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Save this fact to keep it offline and add your own notes.',
                            ),
                            const SizedBox(height: 16),
                            FilledButton.icon(
                              onPressed:
                                  state.status == FavoritesStatus.success &&
                                      !state.isSaving
                                  ? () => context.read<FavoritesBloc>().add(
                                      FavoriteAdded(fact),
                                    )
                                  : null,
                              icon: const Icon(Icons.bookmark_add_outlined),
                              label: const Text('Save to favorites'),
                            ),
                            if (state.status == FavoritesStatus.failure)
                              TextButton(
                                onPressed: () => context
                                    .read<FavoritesBloc>()
                                    .add(const FavoritesRequested()),
                                child: const Text('Retry opening favorites'),
                              ),
                          ],
                        ),
                      ),
                    );
                  }
                  final date = favorite.createdAt.toLocal();
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.edit_note_rounded, size: 28),
                          const SizedBox(height: 12),
                          Text(
                            'Your personal note',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            favorite.note.isEmpty
                                ? 'A blank page for your thoughts.'
                                : favorite.note,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Saved ${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            children: [
                              FilledButton.icon(
                                onPressed: state.isSaving
                                    ? null
                                    : () => showDialog<void>(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (_) =>
                                            NoteEditor(favorite: favorite),
                                      ),
                                icon: const Icon(Icons.edit_outlined, size: 18),
                                label: Text(
                                  favorite.note.isEmpty
                                      ? 'Add note'
                                      : 'Edit note',
                                ),
                              ),
                              TextButton.icon(
                                onPressed: state.isSaving
                                    ? null
                                    : () async {
                                        final confirmed =
                                            await showDialog<bool>(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: const Text(
                                                  'Remove this favorite?',
                                                ),
                                                content: const Text(
                                                  'The saved fact and your personal note will be removed from this device.',
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                          context,
                                                          false,
                                                        ),
                                                    child: const Text(
                                                      'Keep it',
                                                    ),
                                                  ),
                                                  FilledButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                          context,
                                                          true,
                                                        ),
                                                    child: const Text('Remove'),
                                                  ),
                                                ],
                                              ),
                                            );
                                        if (confirmed == true &&
                                            context.mounted) {
                                          context.read<FavoritesBloc>().add(
                                            FavoriteRemoved(fact.id),
                                          );
                                        }
                                      },
                                icon: const Icon(
                                  Icons.delete_outline,
                                  size: 18,
                                ),
                                label: const Text('Remove favorite'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
