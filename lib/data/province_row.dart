class ProvinceRow {
  final int id;
  final String name;
  final bool enabled;

  ProvinceRow({required this.id, required this.name, required this.enabled});

  factory ProvinceRow.fromMap(Map<String, dynamic> m) => ProvinceRow(
        id: m['id'] as int,
        name: m['name'] as String,
        enabled: m['enabled'] as bool,
      );
}
