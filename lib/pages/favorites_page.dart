import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app/state.dart';

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favs = ref.watch(appProvider).listings.where((l) => l.isFavorite).toList();
    if (favs.isEmpty) return const Center(child: Text('Aún no tienes favoritos.'));
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: favs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final l = favs[i];
        return ListTile(
          onTap: () {},
          leading: const CircleAvatar(child: Icon(Icons.image)),
          title: Text('\${l.title} · \${l.size}'),
          subtitle: Text('\${l.price.toStringAsFixed(2)} €'),
          trailing: IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () => ref.read(appProvider.notifier).toggleFavorite(l.id),
          ),
        );
      },
    );
  }
}
