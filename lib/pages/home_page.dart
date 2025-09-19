import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app/state.dart';
import '../theme.dart';
import '../data/supabase_repo.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appProvider);
    final notifier = ref.read(appProvider.notifier);

    final schoolsAsync = ref.watch(schoolsProvider);

    return schoolsAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error cargando colegios: $e'))),
      data: (schoolsDb) {
        if (schoolsDb.isEmpty) {
          return const Scaffold(body: Center(child: Text('No hay colegios disponibles.')));
        }

        final preferred = schoolsDb.firstWhere(
          (s) => s.slug == 'trinity-sanse',
          orElse: () => schoolsDb.first,
        );

        String selectedSlug = state.selectedSchoolId;
        final existsSchool = schoolsDb.any((s) => s.slug == selectedSlug);
        if (selectedSlug.isEmpty || !existsSchool) {
          selectedSlug = preferred.slug;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            notifier.setSchool(selectedSlug);
          });
        }

        final garmentsAsync = ref.watch(garmentsBySchoolProvider(selectedSlug));

        return garmentsAsync.when(
          loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (e, _) => Scaffold(body: Center(child: Text('Error cargando prendas: $e'))),
          data: (garmentsDb) {
            final garmentExists =
                garmentsDb.any((g) => g.slug == state.selectedGarmentId);
            final safeGarmentValue = garmentExists ? state.selectedGarmentId : null;

            final allSizes = <String>{};
            for (final g in garmentsDb) {
              allSizes.addAll(g.sizes);
            }
            final sortedAllSizes = allSizes.toList()
              ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

            final selectedGarment = garmentsDb
                .where((g) => g.slug == safeGarmentValue)
                .cast<GarmentWithSizes?>()
                .firstWhere((_) => true, orElse: () => null);

            final sizesForDropdown = selectedGarment == null
                ? sortedAllSizes
                : (List<String>.from(selectedGarment.sizes)
                  ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase())));

            final sizeExists =
                state.selectedSize != null && sizesForDropdown.contains(state.selectedSize);
            final safeSizeValue = sizeExists ? state.selectedSize : null;

            if (safeGarmentValue != state.selectedGarmentId ||
                safeSizeValue != state.selectedSize) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (safeGarmentValue != state.selectedGarmentId) {
                  notifier.setGarment(safeGarmentValue);
                }
                if (safeSizeValue != state.selectedSize) {
                  notifier.setSize(safeSizeValue);
                }
              });
            }

            final filtered = ref.watch(appProvider).listings.where((l) {
              if (state.showOnlyActive && !l.active) return false;
              if (l.schoolId != selectedSlug) return false;
              if (safeGarmentValue != null && l.garmentId != safeGarmentValue) return false;
              if (safeSizeValue != null && l.size != safeSizeValue) return false;
              if (state.priceUnder10 && l.price > 10.0) return false;
              return true;
            }).toList();

            Widget chip({
              required String text,
              required bool selected,
              required ValueChanged<bool> onSelected,
            }) {
              return FilterChip(
                label: Text(text),
                selected: selected,
                onSelected: onSelected,
                showCheckmark: false,
                backgroundColor: Colors.white,
                selectedColor: kMintSelected,
                side: const BorderSide(color: kGreenSoft),
                shape: const StadiumBorder(),
                labelStyle: const TextStyle(
                  color: Colors.black87, fontWeight: FontWeight.w600,
                ),
              );
            }

            final hasGarments = garmentsDb.isNotEmpty;

            // 🔧 FIX: envolvemos en Scaffold para aportar el Material ancestor
            return Scaffold(
              body: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: selectedSlug.isNotEmpty ? selectedSlug : null,
                                  isExpanded: true,
                                  dropdownColor: Colors.white,
                                  menuMaxHeight: 360,
                                  decoration: const InputDecoration(labelText: 'Colegio'),
                                  items: schoolsDb
                                      .map((s) => DropdownMenuItem(
                                            value: s.slug,
                                            child: Text(s.name),
                                          ))
                                      .toList(),
                                  onChanged: (v) => notifier.setSchool(v!),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: DropdownButtonFormField<String?>(
                                  value: safeGarmentValue,
                                  isExpanded: true,
                                  dropdownColor: Colors.white,
                                  menuMaxHeight: 360,
                                  decoration: const InputDecoration(labelText: 'Prenda'),
                                  items: [
                                    const DropdownMenuItem(value: null, child: Text('Todas')),
                                    ...garmentsDb.map(
                                      (g) => DropdownMenuItem(
                                        value: g.slug,
                                        child: Text(g.name),
                                      ),
                                    ),
                                  ],
                                  onChanged: hasGarments ? notifier.setGarment : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: DropdownButtonFormField<String?>(
                                  value: safeSizeValue,
                                  isExpanded: true,
                                  dropdownColor: Colors.white,
                                  menuMaxHeight: 360,
                                  decoration: const InputDecoration(labelText: 'Talla'),
                                  items: [
                                    const DropdownMenuItem(value: null, child: Text('Todas')),
                                    ...sizesForDropdown.map(
                                      (s) => DropdownMenuItem(value: s, child: Text(s)),
                                    ),
                                  ],
                                  onChanged: hasGarments ? notifier.setSize : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8, runSpacing: 8,
                            children: [
                              chip(
                                text: 'Solo activos',
                                selected: state.showOnlyActive,
                                onSelected: (v) => notifier.toggleShowOnlyActive(v),
                              ),
                              chip(
                                text: 'Precio ≤ 10 €',
                                selected: state.priceUnder10,
                                onSelected: (v) => notifier.togglePriceUnder10(v),
                              ),
                            ],
                          ),
                          if (!hasGarments)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                'Aún no hay catálogo de prendas para este colegio.',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(12),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final l = filtered[index];
                          return Card(
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: Container(
                                    alignment: Alignment.center,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceVariant
                                        .withOpacity(0.4),
                                    child: const Icon(Icons.image, size: 40),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('${l.title} · ${l.size}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context).textTheme.titleMedium),
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '${l.price.toStringAsFixed(2)} €',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall!
                                                .copyWith(fontWeight: FontWeight.w700),
                                          ),
                                          IconButton(
                                            icon: Icon(l.isFavorite
                                                ? Icons.favorite
                                                : Icons.favorite_border),
                                            onPressed: () => ref
                                                .read(appProvider.notifier)
                                                .toggleFavorite(l.id),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        childCount: filtered.length,
                      ),
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 220,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.0,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
