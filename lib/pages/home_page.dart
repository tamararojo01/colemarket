import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/state.dart';
import '../data/supabase_repo.dart';


class HomePage extends ConsumerWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appProvider);
    final notifier = ref.read(appProvider.notifier);
    final provincesAsync = ref.watch(provincesProvider);
    final schoolsAsync = ref.watch(schoolsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ColeMarket'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            color: Theme.of(context).colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Fila superior: combo de provincias centrado
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: provincesAsync.when(
                          data: (provinces) {
                            if (provinces.isEmpty) {
                              return const Text('No hay provincias disponibles.');
                            }
                            return DropdownButtonFormField<String>(
                              value: state.selectedProvinceId,
                              decoration: const InputDecoration(
                                labelText: 'Provincia',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.location_on),
                              ),
                              items: buildProvinceItems(provinces),
                              onChanged: (id) {
                                if (id != null) notifier.setProvince(id);
                              },
                            );
                          },
                          loading: () => const LinearProgressIndicator(),
                          error: (e, _) => Text('Error cargando provincias: $e'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Contenido principal con scroll si es necesario
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Combo de colegios
                          schoolsAsync.when(
                            data: (schools) => DropdownButtonFormField<String>(
                              value: state.selectedSchoolId.isEmpty ? null : state.selectedSchoolId,
                              decoration: const InputDecoration(
                                labelText: 'Colegio',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.school),
                              ),
                              items: buildSchoolItems(schools),
                              onChanged: (id) {
                                if (id != null) notifier.setSchool(id);
                              },
                            ),
                            loading: () => const LinearProgressIndicator(),
                            error: (e, _) => Text('Error cargando colegios: $e'),
                          ),
                          // Aquí puedes añadir más widgets (grid, etc.)
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Métodos auxiliares fuera de la clase para compatibilidad
List<DropdownMenuItem<String>> buildProvinceItems(List provincesDb) {
  final List<DropdownMenuItem<String>> items = <DropdownMenuItem<String>>[];
  for (var i = 0; i < provincesDb.length; i++) {
    var p = provincesDb[i];
    items.add(DropdownMenuItem(
      value: p.id.toString(),
      enabled: p.enabled,
      child: Text(p.name),
    ));
  }
  return items;
}

List<DropdownMenuItem<String>> buildSchoolItems(List schoolsDb) {
  final List<DropdownMenuItem<String>> items = <DropdownMenuItem<String>>[];
  for (var i = 0; i < schoolsDb.length; i++) {
    var s = schoolsDb[i];
    items.add(DropdownMenuItem(
      value: s.slug,
      child: Text(s.name),
    ));
  }
  return items;
}
// Fin de la clase y métodos auxiliares
