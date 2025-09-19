import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // <- NUEVO
import 'pages/home_page.dart';

const String kSupabaseUrl = 'https://agoxnjvimmzuzkqwqqrn.supabase.co';
const String kSupabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFnb3huanZpbW16dXprcXdxcXJuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgxOTUwOTYsImV4cCI6MjA3Mzc3MTA5Nn0.IDWDsJHH9ag4c-skw9Q-EHYUVsXigkzjEaBbKMWGW7s';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(url: kSupabaseUrl, anonKey: kSupabaseAnonKey);

  runApp(
    const ProviderScope( // <- ENVOLTORIO RIVERPOD
      child: ColeMarketApp(),
    ),
  );
}

class ColeMarketApp extends StatelessWidget {
  const ColeMarketApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorSchemeSeed: const Color(0xFF1FBF8F),
      scaffoldBackgroundColor: Colors.white,
      inputDecorationTheme: const InputDecorationTheme(
        filled: true, fillColor: Colors.white, border: OutlineInputBorder(),
      ),
      dropdownMenuTheme: const DropdownMenuThemeData(
        textStyle: TextStyle(color: Colors.black87),
      ),
    );

    return MaterialApp(
      title: 'ColeMarket',
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: const HomePage(), // seguimos arrancando en Home para agilizar
    );
  }
}
