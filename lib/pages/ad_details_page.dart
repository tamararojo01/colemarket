import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app/state.dart';
import '../models.dart';
import '../theme.dart';

class AdDetailsPage extends ConsumerWidget {
  final String listingId;
  const AdDetailsPage({super.key, required this.listingId});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listing = ref.watch(appProvider).listings.firstWhere((l) => l.id == listingId);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
              border: const Border(
                left: BorderSide(color: kGreenSoft, width: 3),
                right: BorderSide(color: kGreenSoft, width: 3),
              ),
            ),
            child: const Icon(Icons.image, size: 72),
          ),
        ),
        const SizedBox(height: 12),
        Text('\${listing.title} · \${listing.size}', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 6),
        Row(
          children: [
            Chip(label: Text(conditionLabels[listing.condition]!)),
            const SizedBox(width: 8),
            if (listing.defects.isNotEmpty)
              ...listing.defects.map(
                (d) => Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Chip(label: Text(d)),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text('Precio: \${listing.price.toStringAsFixed(2)} €', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Abrir chat con vendedor (demo)')));
          },
          icon: const Icon(Icons.chat_bubble),
          label: const Text('Chatear con el vendedor'),
        ),
      ],
    );
  }
}
