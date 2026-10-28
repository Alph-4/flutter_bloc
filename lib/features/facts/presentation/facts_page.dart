import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/app_theme.dart';
import '../../../core/widgets/status_panel.dart';
import 'bloc/facts_bloc.dart';
import 'bloc/facts_event.dart';
import 'bloc/facts_state.dart';
import 'widgets/fact_card.dart';

class FactsPageView extends StatelessWidget {
  const FactsPageView({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<FactsBloc, FactsState>(
    builder: (context, state) => ListView(
      key: const PageStorageKey('discover-scroll'),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        const _DiscoveryHeader(),
        const SizedBox(height: 28),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 16,
          children: [
            Text(
              'The curiosity collection',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextButton.icon(
              onPressed: state.isRefreshing || state.isLoadingMore
                  ? null
                  : () => context.read<FactsBloc>().add(const FactsRequested()),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Refresh'),
            ),
          ],
        ),
        const Text(
          'Real cat facts. A few delightful surprises. Source: catfact.ninja.',
        ),
        const SizedBox(height: 20),
        if (state.status == FactsStatus.loading ||
            state.status == FactsStatus.initial)
          const Padding(
            padding: EdgeInsets.all(48),
            child: Center(
              child: CircularProgressIndicator(
                semanticsLabel: 'Loading cat facts',
              ),
            ),
          ),
        if (state.status == FactsStatus.failure)
          StatusPanel(
            icon: Icons.cloud_off_rounded,
            title: 'Curiosity will have to wait',
            message: state.failure!.message,
            onRetry: () =>
                context.read<FactsBloc>().add(const FactsRequested()),
          ),
        if (state.isRefreshing && state.facts.isNotEmpty)
          const LinearProgressIndicator(semanticsLabel: 'Refreshing facts'),
        if (state.failure != null && state.facts.isNotEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(state.failure!.message),
                  TextButton(
                    onPressed: () =>
                        context.read<FactsBloc>().add(const FactsRequested()),
                    child: const Text('Refresh from the start'),
                  ),
                ],
              ),
            ),
          ),
        if (state.status == FactsStatus.success && state.facts.isEmpty)
          const StatusPanel(
            icon: Icons.search_off,
            title: 'No facts yet',
            message: 'Try refreshing the collection.',
          ),
        ...state.facts.indexed.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: FactCard(fact: entry.$2, index: entry.$1 + 1),
          ),
        ),
        if (state.nextPage != null && state.facts.isNotEmpty)
          OutlinedButton.icon(
            onPressed: state.isLoadingMore || state.isRefreshing
                ? null
                : () => context.read<FactsBloc>().add(
                    const FactsNextPageRequested(),
                  ),
            icon: state.isLoadingMore
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.add_rounded),
            label: Text(
              state.isLoadingMore
                  ? 'Finding more facts...'
                  : 'Discover more facts',
            ),
          ),
        if (state.status == FactsStatus.success &&
            state.facts.isNotEmpty &&
            state.nextPage == null)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: Text('You have explored the entire collection.'),
            ),
          ),
      ],
    ),
  );
}

class _DiscoveryHeader extends StatelessWidget {
  const _DiscoveryHeader();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(28),
    decoration: BoxDecoration(
      color: AppTheme.ink,
      borderRadius: BorderRadius.circular(30),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.auto_awesome, color: AppTheme.accent, size: 18),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                'FOR THE CAT-CURIOUS',
                style: TextStyle(
                  color: AppTheme.accent,
                  letterSpacing: 2,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'A world of wonder.\nWith whiskers.',
          style: Theme.of(context).textTheme.headlineLarge!
              .copyWith(color: Colors.white),
        ),
        const SizedBox(height: 16),
        const Text(
          'Collect a little knowledge.\nKeep your favorite discoveries close.',
          style: TextStyle(color: Color(0xFFD9E2D6), height: 1.6),
        ),
        const SizedBox(height: 24),
        const Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppTheme.accent,
              child: Icon(Icons.pets_rounded, color: AppTheme.ink),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Tiny reads. Lasting favorites.',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
