import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';


import '../app/state.dart';
import '../models.dart';
import '../mock_data.dart';                // seguimos usando garments/tallas mock por ahora
import '../theme.dart';
import '../data/supabase_repo.dart';      // <-- colegios desde BBDD

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appProvider);
    final notifier = ref.read(appProvider.notifier);
    final schoolsAsync = ref.watch(schoolsProvider);

    // UI en función de carga de colegios (BBDD)
    return schoolsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Error cargando colegios: $e'),
        ),
      ),
      data: (schoolsDb) {
        // Garantiza que el seleccionado exista; si no, selecciona el primero
        final exists = schoolsDb.any((s) => s.slug == state.selectedSchoolId);
        if (!exists && schoolsDb.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(appProvider.notifier).setSchool(schoolsDb.first.slug);
          });
        }
        final selectedSlug = exists && state.selectedSchoolId.isNotEmpty
            ? state.selectedSchoolId
            : (schoolsDb.isNotEmpty ? schoolsDb.first.slug : '');

        // Garments/tallas: de momento, tiramos de mock mapeando por slug
        final mockSchool = schools.firstWhere(
          (s) => s.id == selectedSlug,
          orElse: () => School(id: selectedSlug, name: '', garments: const []),
        );
        final garments = mockSchool.garments;

        // Filtrado de anuncios (mock listings) con el slug seleccionado
        final filtered = state.listings.where((l) {
          if (state.showOnlyActive && !l.active) return false;
          if (l.schoolId != selectedSlug) return false;
          if (state.selectedGarmentId != null && l.garmentId != state.selectedGarmentId) return false;
          if (state.selectedSize != null && l.size != state.selectedSize) return false;
          if (state.priceUnder10 && (l.price > 10.0)) return false;
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
            labelStyle: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
          );
        }

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
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
                            value: state.selectedGarmentId,
                            isExpanded: true,
                            dropdownColor: Colors.white,
                            menuMaxHeight: 360,
                            decoration: const InputDecoration(labelText: 'Prenda'),
                            items: [
                              const DropdownMenuItem(value: null, child: Text('Todas')),
                              ...garments.map((g) => DropdownMenuItem(value: g.id, child: Text(g.label))),
                            ],
                            onChanged: notifier.setGarment,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String?>(
                            value: state.selectedSize,
                            isExpanded: true,
                            dropdownColor: Colors.white,
                            menuMaxHeight: 360,
                            decoration: const InputDecoration(labelText: 'Talla'),
                            items: [
                              const DropdownMenuItem(value: null, child: Text('Todas')),
                              if (state.selectedGarmentId == null)
                                ...garments
                                    .expand((g) => g.sizes)
                                    .toSet()
                                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                              else
                                ...garments
                                    .firstWhere((g) => g.id == state.selectedGarmentId)
                                    .sizes
                                    .map((s) => DropdownMenuItem(value: s, child: Text(s))),
                            ],
                            onChanged: notifier.setSize,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
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
                      child: InkWell(
                        onTap: () => context.go('/details/${l.id}'),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.4),
                                  border: const Border(
                                    left: BorderSide(color: kGreenSoft, width: 3),
                                    right: BorderSide(color: kGreenSoft, width: 3),
                                  ),
                                ),
                                child: const Icon(Icons.image, size: 40),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${l.title} · ${l.size}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${l.price.toStringAsFixed(2)} €',
                                        style: Theme.of(context).textTheme.titleSmall!.copyWith(fontWeight: FontWeight.w700),
                                      ),
                                      IconButton(
                                        icon: Icon(l.isFavorite ? Icons.favorite : Icons.favorite_border),
                                        onPressed: () => ref.read(appProvider.notifier).toggleFavorite(l.id),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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
        );
      },
    );
  }
}
