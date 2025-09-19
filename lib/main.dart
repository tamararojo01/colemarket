import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pages/home_page.dart';
import 'auth/login_page.dart';
import 'theme.dart'; // Importa el theme personalizado
import 'router.dart';

const String kSupabaseUrl = 'https://agoxnjvimmzuzkqwqqrn.supabase.co';
const String kSupabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFnb3huanZpbW16dXprcXdxcXJuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgxOTUwOTYsImV4cCI6MjA3Mzc3MTA5Nn0.IDWDsJHH9ag4c-skw9Q-EHYUVsXigkzjEaBbKMWGW7s';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(url: kSupabaseUrl, anonKey: kSupabaseAnonKey);

  runApp(
    const ProviderScope(
      child: ColeMarketApp(),
    ),
  );
}

class ColeMarketApp extends ConsumerWidget {
  const ColeMarketApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'ColeMarket',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(Brightness.light), // Usa tu tema elegante verde
      darkTheme: buildAppTheme(Brightness.dark), // Opción para modo oscuro
      themeMode: ThemeMode.system, // Usa el modo del sistema
      routerConfig: router,
    );
  }
}