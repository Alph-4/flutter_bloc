import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/favorite.dart';
import '../bloc/favorites_bloc.dart';
import '../bloc/favorites_event.dart';
import '../bloc/favorites_state.dart';

class NoteEditor extends StatefulWidget {
  const NoteEditor({super.key, required this.favorite});
  final Favorite favorite;

  @override
  State<NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends State<NoteEditor> {
  late final _controller = TextEditingController(text: widget.favorite.note);
  final _formKey = GlobalKey<FormState>();
  bool _submitted = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<FavoritesBloc, FavoritesState>(
        listenWhen: (previous, current) =>
            previous.isSaving && !current.isSaving,
        listener: (context, state) {
          if (!_submitted) return;
          if (state.failure == null) {
            Navigator.of(context).pop();
          } else {
            setState(() => _submitted = false);
          }
        },
        builder: (context, state) => PopScope(
          canPop: !_submitted,
          child: Dialog(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'A note to remember',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      const Text('What makes this discovery worth keeping?'),
                      const SizedBox(height: 20),
                      TextFormField(
                        key: const Key('note-input'),
                        controller: _controller,
                        autofocus: true,
                        enabled: !_submitted,
                        minLines: 3,
                        maxLines: 6,
                        maxLength: 500,
                        decoration: const InputDecoration(
                          labelText: 'Personal note',
                          hintText: 'Add your thoughts...',
                        ),
                        validator: (value) => (value ?? '').trim().length > 500
                            ? 'Use 500 characters or fewer.'
                            : null,
                      ),
                      if (state.failure != null)
                        Text(
                          state.failure!.message,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      const SizedBox(height: 16),
                      Wrap(
                        alignment: WrapAlignment.end,
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          TextButton(
                            onPressed: _submitted
                                ? null
                                : () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: _submitted || state.isSaving
                                ? null
                                : () {
                                    if (!_formKey.currentState!.validate()) {
                                      return;
                                    }
                                    setState(() => _submitted = true);
                                    context.read<FavoritesBloc>().add(
                                      FavoriteNoteUpdated(
                                        factId: widget.favorite.fact.id,
                                        note: _controller.text,
                                      ),
                                    );
                                  },
                            child: Text(_submitted ? 'Saving...' : 'Save note'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
