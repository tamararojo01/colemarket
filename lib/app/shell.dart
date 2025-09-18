import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../theme.dart';
import '../auth/auth_state.dart';
import '../pages/home_page.dart';
import '../pages/favorites_page.dart';
import '../pages/publish_page.dart';
import '../pages/messages_page.dart';
import '../pages/profile_page.dart';

class BrandTitle extends StatelessWidget {
  const BrandTitle({super.key});
  @override
  Widget build(BuildContext context) {
    final gradient = const LinearGradient(colors: [kGreen, Color(0xFF11C493)]);
    return ShaderMask(
      shaderCallback: (rect) => gradient.createShader(rect),
      blendMode: BlendMode.srcIn,
      child: const Text(
        'ColeMarket',
        style: TextStyle(
            fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: 0.5),
      ),
    );
  }
}

class Shell extends ConsumerStatefulWidget {
  const Shell({super.key});
  @override
  ConsumerState<Shell> createState() => _ShellState();
}

class _ShellState extends ConsumerState<Shell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider).asData?.value;

    return Scaffold(
      appBar: AppBar(
        title: const BrandTitle(),
        actions: [
          if (user != null)
            PopupMenuButton<String>(
              icon: const Icon(Icons.person),
              onSelected: (v) async {
                if (v == 'logout') {
                  await Supabase.instance.client.auth.signOut();
                  if (mounted) context.go('/login');
                }
              },
              itemBuilder: (ctx) => [
                PopupMenuItem(
                  value: 'email',
                  enabled: false,
                  child: Text(user.email ?? 'Usuario'),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(value: 'logout', child: Text('Cerrar sesión')),
              ],
            ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: IndexedStack(
            index: index,
            children: const [
              HomePage(),
              FavoritesPage(),
              PublishPage(),
              MessagesPage(),
              ProfilePage(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Inicio'),
          NavigationDestination(icon: Icon(Icons.favorite_border), selectedIcon: Icon(Icons.favorite), label: 'Favoritos'),
          NavigationDestination(icon: Icon(Icons.add_circle_outline), selectedIcon: Icon(Icons.add_circle), label: 'Vender'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble), label: 'Mensajes'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
