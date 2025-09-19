import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ----------------------
// MODELOS DTO
// ----------------------
class SchoolRow {
  final String slug;
  final String name;
  SchoolRow({required this.slug, required this.name});

  factory SchoolRow.fromMap(Map<String, dynamic> m) =>
      SchoolRow(slug: m['slug'] as String, name: m['name'] as String);
}

class GarmentWithSizes {
  final String slug;
  final String name;
  final String? category;
  final List<String> sizes;

  GarmentWithSizes({
    required this.slug,
    required this.name,
    required this.category,
    required this.sizes,
  });
}

// ----------------------
// REPOSITORIO
// ----------------------
class SupabaseRepo {
  final _db = Supabase.instance.client;

  Future<List<SchoolRow>> fetchEnabledSchools() async {
    final rows = await _db
        .from('schools')
        .select('slug,name')
        .eq('enabled', true)
        .order('name');

    return (rows as List)
        .map((e) => SchoolRow.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Prendas + tallas vía RPC (RETURNS TABLE) -> OJO: encadenar .select()
  Future<List<GarmentWithSizes>> fetchGarmentsWithSizes(String schoolSlug) async {
    try {
      final rows = await Supabase.instance.client
          .rpc('list_garments_with_sizes', params: {'p_school_slug': schoolSlug})
          .select(); // <- imprescindible en supabase-dart 2.x

      final list = (rows as List);

      return list.map((e) {
        final m = (e as Map<String, dynamic>);
        final sizesDyn = m['sizes'];
        final sizes = (sizesDyn is List)
            ? sizesDyn.map((x) => x.toString()).toList()
            : <String>[];
        sizes.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

        return GarmentWithSizes(
          slug: m['slug'] as String,
          name: m['name'] as String,
          category: m['category'] as String?,
          sizes: sizes,
        );
      }).toList();
    } catch (e, st) {
      // En Flutter Web, mira la consola del navegador (F12 -> Console)
      // ignore: avoid_print
      print('RPC error list_garments_with_sizes: $e\n$st');
      return [];
    }
  }
}

// ----------------------
// PROVIDERS
// ----------------------
final supabaseRepoProvider = Provider<SupabaseRepo>((ref) => SupabaseRepo());

final schoolsProvider = FutureProvider<List<SchoolRow>>((ref) async {
  final repo = ref.watch(supabaseRepoProvider);
  return repo.fetchEnabledSchools();
});

/// Provider "family": prendas + tallas del colegio indicado
final garmentsBySchoolProvider =
    FutureProvider.family<List<GarmentWithSizes>, String>((ref, schoolSlug) async {
  final repo = ref.watch(supabaseRepoProvider);
  if (schoolSlug.isEmpty) return [];
  return repo.fetchGarmentsWithSizes(schoolSlug);
});
