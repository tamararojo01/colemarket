import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'env.dart';
import 'theme.dart';
import 'router.dart';

Future<void> _initSupabase() async {
  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initSupabase();
  runApp(const ProviderScope(child: ColeMarketApp()));
}

class ColeMarketApp extends ConsumerWidget {
  const ColeMarketApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'ColeMarket',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(Brightness.light),
      darkTheme: buildAppTheme(Brightness.dark),
      themeMode: ThemeMode.light,
      routerConfig: router,
    );
  }
}
