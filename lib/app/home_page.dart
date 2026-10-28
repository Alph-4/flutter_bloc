import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/facts/presentation/facts_page.dart';
import '../features/favorites/presentation/bloc/favorites_bloc.dart';
import '../features/favorites/presentation/bloc/favorites_state.dart';
import '../features/favorites/presentation/favorites_page.dart';
import 'about_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Navigation selection is ephemeral UI state, not domain state.
  int _index = 0;

  @override
  Widget build(
    BuildContext context,
  ) => BlocListener<FavoritesBloc, FavoritesState>(
    listenWhen: (previous, current) =>
        previous.feedbackId != current.feedbackId,
    listener: (context, state) {
      final message = state.feedback;
      if (message == null) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
        );
    },
    child: LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 800;
        final content = IndexedStack(
          index: _index,
          children: const [FactsPageView(), FavoritesPage(), AboutPage()],
        );
        return Scaffold(
          appBar: AppBar(
            title: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.pets_rounded),
                SizedBox(width: 10),
                Text(
                  'catfolio',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.8,
                  ),
                ),
              ],
            ),
            actions: wide
                ? const [
                    Padding(
                      padding: EdgeInsets.only(right: 20),
                      child: Chip(label: Text('A little curiosity, daily.')),
                    ),
                  ]
                : null,
          ),
          body: SafeArea(
            child: Row(
              children: [
                if (wide)
                  NavigationRail(
                    selectedIndex: _index,
                    onDestinationSelected: (index) =>
                        setState(() => _index = index),
                    labelType: NavigationRailLabelType.all,
                    destinations: const [
                      NavigationRailDestination(
                        icon: Icon(Icons.explore_outlined),
                        selectedIcon: Icon(Icons.explore),
                        label: Text('Discover'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.bookmark_border_rounded),
                        selectedIcon: Icon(Icons.bookmark_rounded),
                        label: Text('Favorites'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.info_outline),
                        selectedIcon: Icon(Icons.info),
                        label: Text('About'),
                      ),
                    ],
                  ),
                Expanded(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 900),
                      child: content,
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: wide
              ? null
              : NavigationBar(
                  selectedIndex: _index,
                  onDestinationSelected: (index) =>
                      setState(() => _index = index),
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.explore_outlined),
                      selectedIcon: Icon(Icons.explore),
                      label: 'Discover',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.bookmark_border_rounded),
                      selectedIcon: Icon(Icons.bookmark_rounded),
                      label: 'Favorites',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.info_outline),
                      selectedIcon: Icon(Icons.info),
                      label: 'About',
                    ),
                  ],
                ),
        );
      },
    ),
  );
}
