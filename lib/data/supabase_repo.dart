import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SchoolRow {
  final String slug;
  final String name;
  SchoolRow({required this.slug, required this.name});

  factory SchoolRow.fromMap(Map<String, dynamic> m) =>
      SchoolRow(slug: m['slug'] as String, name: m['name'] as String);
}

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
}

// Providers
final supabaseRepoProvider = Provider<SupabaseRepo>((ref) => SupabaseRepo());

final schoolsProvider = FutureProvider<List<SchoolRow>>((ref) async {
  final repo = ref.watch(supabaseRepoProvider);
  return repo.fetchEnabledSchools();
});
