import 'package:flutter/material.dart';

import '../../../../app/app_theme.dart';
import '../../../favorites/presentation/widgets/favorite_button.dart';
import '../../domain/cat_fact.dart';
import '../fact_detail_page.dart';

class FactCard extends StatelessWidget {
  const FactCard({
    super.key,
    required this.fact,
    required this.index,
    this.note,
  });
  final CatFact fact;
  final int index;
  final String? note;

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: () => Navigator.of(context).push<void>(
        MaterialPageRoute(builder: (_) => FactDetailPage(fact: fact)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.paper,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'FACT ${index.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontSize: 11,
                      letterSpacing: 1.6,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                FavoriteButton(fact: fact),
              ],
            ),
            const SizedBox(height: 12),
            Text(fact.text, style: Theme.of(context).textTheme.bodyLarge),
            if (note != null && note!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('YOUR NOTE', style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 4),
              Text(note!, maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
            const SizedBox(height: 16),
            const Row(
              children: [
                Text(
                  'Take a closer look',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_outward_rounded, size: 16),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
