import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pages/home_page.dart';
import 'theme.dart'; // Importa el theme personalizado

import 'app/shell.dart';

// Rellena con tus credenciales reales si no las tienes ya en otro sitio
const String kSupabaseUrl = 'https://agoxnjvimmzuzkqwqqrn.supabase.co'; // <-- CAMBIA
const String kSupabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFnb3huanZpbW16dXprcXdxcXJuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgxOTUwOTYsImV4cCI6MjA3Mzc3MTA5Nn0.IDWDsJHH9ag4c-skw9Q-EHYUVsXigkzjEaBbKMWGW7s'; // <-- CAMBIA

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: kSupabaseUrl,
    anonKey: kSupabaseAnonKey,
  );

  runApp(
    const ProviderScope(
      child: ColeMarketApp(),
    ),
  );
}

class ColeMarketApp extends StatelessWidget {
  const ColeMarketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ColeMarket',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(Brightness.light), // Usa tu tema elegante verde
      darkTheme: buildAppTheme(Brightness.dark), // Opción para modo oscuro
      themeMode: ThemeMode.system, // Usa el modo del sistema
      home: const Shell(), // recupera el menú inferior
    );
  }
}