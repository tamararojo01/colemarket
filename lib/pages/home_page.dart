import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class Province {
  final String id;
  final String name;
  Province({required this.id, required this.name});
}

class School {
  final String id;
  final String name;
  School({required this.id, required this.name});
}

class _HomePageState extends State<HomePage> {
  Province? selectedProvince;
  School? selectedSchool;

  List<Province> provinces = [];
  List<School> schools = [];

  @override
  void initState() {
    super.initState();
    loadProvinces();
  }

  Future<void> loadProvinces() async {
    final response = await Supabase.instance.client
        .from('provinces')
        .select('id, name')
        .eq('enabled', true)
        .order('name')
        .execute();

    if (response.error == null && response.data != null) {
      setState(() {
        provinces = (response.data as List)
            .map((p) => Province(id: p['id'], name: p['name']))
            .toList();
        // Si hay alguna, seleccionamos la primera y cargamos sus colegios
        if (provinces.isNotEmpty) {
          selectedProvince = provinces.first;
          loadSchools(provinceId: selectedProvince!.id);
        }
      });
    }
  }

  Future<void> loadSchools({required String provinceId}) async {
    final response = await Supabase.instance.client
        .from('schools')
        .select('id, name')
        .eq('enabled', true)
        .eq('province_id', provinceId)
        .order('name')
        .execute();

    if (response.error == null && response.data != null) {
      setState(() {
        schools = (response.data as List)
            .map((s) => School(id: s['id'], name: s['name']))
            .toList();
        selectedSchool = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inicio')), 
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Combo de provincias
            DropdownButtonFormField<Province>(
              value: selectedProvince,
              decoration: const InputDecoration(
                labelText: 'Provincia',
              ),
              items: provinces
                  .map((p) => DropdownMenuItem(
                        value: p,
                        child: Text(p.name),
                      ))
                  .toList(),
              onChanged: (Province? province) {
                setState(() {
                  selectedProvince = province;
                  selectedSchool = null;
                  schools = [];
                });
                if (province != null) {
                  loadSchools(provinceId: province.id);
                }
              },
            ),
            const SizedBox(height: 16),
            // Combo de colegios
            DropdownButtonFormField<School>(
              value: selectedSchool,
              decoration: const InputDecoration(
                labelText: 'Colegio',
              ),
              items: schools
                  .map((s) => DropdownMenuItem(
                        value: s,
                        child: Text(s.name),
                      ))
                  .toList(),
              onChanged: (School? school) {
                setState(() {
                  selectedSchool = school;
                });
              },
            ),
            // ... el resto de tu página ...
          ],
        ),
      ),
    );
  }
}