import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      Text(
        'Small facts.\nBig curiosity.',
        style: Theme.of(context).textTheme.headlineLarge,
      ),
      const SizedBox(height: 24),
      const Text(
        'Catfolio is your pocket collection of curious cat facts. Discover something new, save what you love, and add your own notes.',
      ),
      const SizedBox(height: 24),
      const _AboutCard(
        icon: Icons.public,
        title: 'Powered by Cat Fact Ninja',
        text: 'Facts are provided in English by catfact.ninja. Community facts may be inaccurate; use a reliable source to verify important claims.',
      ),
      const SizedBox(height: 12),
      const _AboutCard(
        icon: Icons.lock_outline,
        title: 'Your collection stays with you',
        text: 'Favorites and notes are stored in a local SQLite database on this device. They work offline. There is no account, cloud sync, analytics, or advertising. Uninstalling the app or clearing its data may remove your collection. Device backup behavior follows your operating system settings.',
      ),
      const SizedBox(height: 12),
      const _AboutCard(
        icon: Icons.auto_stories_outlined,
        title: 'Built for learning',
        text: 'This app demonstrates Flutter BLoC with an MVI-inspired unidirectional flow. Explore the repository README and architecture guide to follow an intention from a tap to a committed database write.',
      ),
      const SizedBox(height: 16),
      OutlinedButton.icon(
        onPressed: () async {
          await Clipboard.setData(
            const ClipboardData(text: 'https://catfact.ninja'),
          );
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('API address copied.')),
            );
          }
        },
        icon: const Icon(Icons.copy_outlined),
        label: const Text('Copy API address'),
      ),
      const SizedBox(height: 24),
      const Center(
        child: Text(
          'CATFOLIO / 1.0.0',
          style: TextStyle(letterSpacing: 2, fontSize: 11),
        ),
      ),
    ],
  );
}

class _AboutCard extends StatelessWidget {
  const _AboutCard({
    required this.icon,
    required this.title,
    required this.text,
  });
  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(text),
        ],
      ),
    ),
  );
}
