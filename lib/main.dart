import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'models.dart';
import 'mock_data.dart';

void main() {
  runApp(const ProviderScope(child: ColeMarketApp()));
}

ThemeData _buildTheme(Brightness brightness) {
  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorSchemeSeed: const Color(0xFF21C1B1),
  );
  return base.copyWith(
    textTheme: GoogleFonts.poppinsTextTheme(base.textTheme),
    visualDensity: VisualDensity.standard,
  );
}

class AppState {
  final List<Listing> listings;
  final List<Conversation> conversations;
  final AppUser user;
  final String selectedSchoolId;
  final String? selectedGarmentId;
  final String? selectedSize;

  AppState({
    required this.listings,
    required this.conversations,
    required this.user,
    required this.selectedSchoolId,
    this.selectedGarmentId,
    this.selectedSize,
  });

  AppState copyWith({
    List<Listing>? listings,
    List<Conversation>? conversations,
    AppUser? user,
    String? selectedSchoolId,
    String? selectedGarmentId,
    String? selectedSize,
  }) {
    return AppState(
      listings: listings ?? this.listings,
      conversations: conversations ?? this.conversations,
      user: user ?? this.user,
      selectedSchoolId: selectedSchoolId ?? this.selectedSchoolId,
      selectedGarmentId: selectedGarmentId ?? this.selectedGarmentId,
      selectedSize: selectedSize ?? this.selectedSize,
    );
  }
}

/// Riverpod 2.x: Notifier en lugar de StateNotifier
class AppNotifier extends Notifier<AppState> {
  @override
  AppState build() {
    return AppState(
      listings: List<Listing>.of(mockListings),
      conversations: List<Conversation>.of(mockConversations),
      user: AppUser(
        id: 'u1',
        email: 'demo@colemaket.app',
        phone: null,
        address: null,
        defaultSchoolId: 'trinity',
      ),
      selectedSchoolId: 'trinity',
    );
  }

  void setSchool(String id) =>
      state = state.copyWith(selectedSchoolId: id, selectedGarmentId: null, selectedSize: null);

  void setGarment(String? id) =>
      state = state.copyWith(selectedGarmentId: id, selectedSize: null);

  void setSize(String? size) =>
      state = state.copyWith(selectedSize: size);

  void toggleFavorite(String listingId) {
    final updated = state.listings
        .map((l) => l.id == listingId ? l.copyWith(isFavorite: !l.isFavorite) : l)
        .toList();
    state = state.copyWith(listings: updated);
  }

  void addListing(Listing listing) =>
      state = state.copyWith(listings: <Listing>[listing, ...state.listings]);

  void updateProfile({String? email, String? phone, String? address}) =>
      state = state.copyWith(
        user: state.user.copyWith(email: email, phone: phone, address: address),
      );
}

final appProvider = NotifierProvider<AppNotifier, AppState>(AppNotifier.new);

final _routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (ctx, s) => const Shell(),
        routes: [
          GoRoute(
            path: 'details/:id',
            builder: (ctx, s) => AdDetailsPage(listingId: s.pathParameters['id']!),
          ),
          GoRoute(
            path: 'chat/:id',
            builder: (ctx, s) => ChatPage(conversationId: s.pathParameters['id']!),
          ),
        ],
      ),
    ],
  );
});

class ColeMarketApp extends ConsumerWidget {
  const ColeMarketApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(_routerProvider);
    return MaterialApp.router(
      title: 'ColeMarket',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      routerConfig: router,
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
    final pages = const [
      HomePage(),
      FavoritesPage(),
      PublishPage(),
      MessagesPage(),
      ProfilePage(),
    ];
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Inicio'),
          NavigationDestination(icon: Icon(Icons.favorite_border), selectedIcon: Icon(Icons.favorite), label: 'Favoritos'),
          NavigationDestination(icon: Icon(Icons.add_circle_outline), selectedIcon: Icon(Icons.add_circle), label: 'Publicar'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble), label: 'Mensajes'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
      floatingActionButton: index == 2
          ? null
          : FloatingActionButton.extended(
              onPressed: () => setState(() => index = 2),
              icon: const Icon(Icons.add),
              label: const Text('Publicar en 15 s'),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class HomePage extends ConsumerWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appProvider);
    final notifier = ref.read(appProvider.notifier);
    final school = schools.firstWhere((s) => s.id == state.selectedSchoolId);
    final garments = school.garments;
    final filtered = state.listings.where((l) {
      if (!l.active) return false;
      if (l.schoolId != state.selectedSchoolId) return false;
      if (state.selectedGarmentId != null && l.garmentId != state.selectedGarmentId) return false;
      if (state.selectedSize != null && l.size != state.selectedSize) return false;
      return true;
    }).toList();

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            title: const Text('ColeMarket'),
            centerTitle: true,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: state.selectedSchoolId,
                          decoration: const InputDecoration(labelText: 'Colegio'),
                          items: schools.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                          onChanged: (v) => notifier.setSchool(v!),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String?>(
                          value: state.selectedGarmentId,
                          decoration: const InputDecoration(labelText: 'Prenda'),
                          items: [
                            const DropdownMenuItem(value: null, child: Text('Todas')),
                            ...garments.map((g) => DropdownMenuItem(value: g.id, child: Text(g.label))),
                          ],
                          onChanged: notifier.setGarment,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String?>(
                          value: state.selectedSize,
                          decoration: const InputDecoration(labelText: 'Talla'),
                          items: [
                            const DropdownMenuItem(value: null, child: Text('Todas')),
                            if (state.selectedGarmentId == null)
                              ...garments
                                  .expand((g) => g.sizes)
                                  .toSet()
                                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                            else
                              ...garments
                                  .firstWhere((g) => g.id == state.selectedGarmentId)
                                  .sizes
                                  .map((s) => DropdownMenuItem(value: s, child: Text(s))),
                          ],
                          onChanged: notifier.setSize,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilterChip(label: Text('Solo activos'), selected: true, onSelected: null),
                      FilterChip(label: Text('Precio ≤ 10 €'), selected: false, onSelected: null),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(12),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final l = filtered[index];
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: InkWell(
                      onTap: () => context.go('/details/${l.id}'),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Expanded(
                            child: Center(child: Icon(Icons.image, size: 48)),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${l.title} · ${l.size}', style: Theme.of(context).textTheme.titleMedium),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('${l.price.toStringAsFixed(2)} €', style: Theme.of(context).textTheme.titleSmall),
                                    IconButton(
                                      icon: Icon(l.isFavorite ? Icons.favorite : Icons.favorite_border),
                                      onPressed: () => ref.read(appProvider.notifier).toggleFavorite(l.id),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: filtered.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 3 / 4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favs = ref.watch(appProvider).listings.where((l) => l.isFavorite).toList();
    if (favs.isEmpty) {
      return const Center(child: Text('Aún no tienes favoritos.'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: favs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final l = favs[i];
        return ListTile(
          onTap: () => context.go('/details/${l.id}'),
          leading: const CircleAvatar(child: Icon(Icons.image)),
          title: Text('${l.title} · ${l.size}'),
          subtitle: Text('${l.price.toStringAsFixed(2)} €'),
          trailing: IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () => ref.read(appProvider.notifier).toggleFavorite(l.id),
          ),
        );
      },
    );
  }
}

class PublishPage extends ConsumerStatefulWidget {
  const PublishPage({super.key});
  @override
  ConsumerState<PublishPage> createState() => _PublishPageState();
}

class _PublishPageState extends ConsumerState<PublishPage> {
  final _formKey = GlobalKey<FormState>();
  String? schoolId;
  String? garmentId;
  String? size;
  Condition condition = Condition.good;
  double price = 8.0;
  bool confirmGood = false;
  bool hasFix = false;
  String? fixText;
  bool hasInfo = false;
  String? extraInfo;
  String title = '';

  @override
  void initState() {
    super.initState();
    final user = ref.read(appProvider).user;
    schoolId = user.defaultSchoolId;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appProvider);
    final school = schools.firstWhere((s) => s.id == (schoolId ?? state.selectedSchoolId));
    final garments = school.garments;

    return Scaffold(
      appBar: AppBar(title: const Text('Publicar prenda')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String>(
              value: schoolId,
              decoration: const InputDecoration(labelText: 'Colegio'),
              items: schools.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
              onChanged: (v) => setState(() => schoolId = v),
            ),
            const SizedBox(height: 12),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Título (ej. Polo)'),
              onChanged: (v) => title = v,
              validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: garmentId,
              decoration: const InputDecoration(labelText: 'Prenda'),
              items: garments.map((g) => DropdownMenuItem(value: g.id, child: Text(g.label))).toList(),
              onChanged: (v) => setState(() {
                garmentId = v;
                size = null;
              }),
              validator: (v) => v == null ? 'Selecciona una prenda' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: size,
              decoration: const InputDecoration(labelText: 'Talla'),
              items: (garmentId == null ? <String>[] : garments.firstWhere((g) => g.id == garmentId).sizes)
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) => setState(() => size = v),
              validator: (v) => v == null ? 'Selecciona una talla' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<Condition>(
              value: condition,
              decoration: const InputDecoration(labelText: 'Estado'),
              items: Condition.values
                  .map((c) => DropdownMenuItem(value: c, child: Text(conditionLabels[c]!)))
                  .toList(),
              onChanged: (v) => setState(() => condition = v ?? Condition.good),
            ),
            const SizedBox(height: 12),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Precio (€)'),
              initialValue: price.toStringAsFixed(2),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (v) => price = double.tryParse(v.replaceAll(',', '.')) ?? price,
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Confirmo que la prenda está en buenas condiciones'),
              value: confirmGood,
              onChanged: (v) => setState(() => confirmGood = v),
            ),
            const SizedBox(height: 4),
            CheckboxListTile(
              title: const Text('La prenda tiene algún arreglo (bajos, gomas, etc.)'),
              value: hasFix,
              onChanged: (v) => setState(() => hasFix = v ?? false),
            ),
            if (hasFix)
              TextFormField(
                decoration: const InputDecoration(labelText: 'Describe el arreglo'),
                onChanged: (v) => fixText = v,
              ),
            const SizedBox(height: 4),
            CheckboxListTile(
              title: const Text('¿Algo que informar al comprador?'),
              value: hasInfo,
              onChanged: (v) => setState(() => hasInfo = v ?? false),
            ),
            if (hasInfo)
              TextFormField(
                decoration: const InputDecoration(labelText: 'Información adicional (ej. pequeña mancha)'),
                onChanged: (v) => extraInfo = v,
              ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('¿Quieres subir una foto del artículo?'),
              subtitle: const Text('Si no, usaremos una imagen de catálogo por ti.'),
              onTap: () {},
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                if ((_formKey.currentState?.validate() ?? false) && confirmGood) {
                  final listing = Listing.sample(
                    title: title,
                    schoolId: schoolId!,
                    garmentId: garmentId!,
                    size: size!,
                    price: price,
                    condition: condition,
                    defects: [
                      if (hasFix && (fixText?.isNotEmpty ?? false)) 'Arreglo: ${fixText!}',
                      if (hasInfo && (extraInfo?.isNotEmpty ?? false)) extraInfo!,
                    ],
                  );
                  ref.read(appProvider.notifier).addListing(listing);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text('Anuncio publicado')));
                    Navigator.of(context).pop();
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Completa el formulario y confirma la calidad')),
                  );
                }
              },
              icon: const Icon(Icons.cloud_upload),
              label: const Text('Publicar'),
            )
          ],
        ),
      ),
    );
  }
}

class MessagesPage extends ConsumerWidget {
  const MessagesPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final convos = ref.watch(appProvider).conversations;
    if (convos.isEmpty) {
      return const Center(child: Text('Sin conversaciones aún.'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: convos.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final c = convos[i];
        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: Text(c.otherUserName),
          subtitle: Text(c.lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
          onTap: () => context.go('/chat/${c.id}'),
        );
      },
    );
  }
}

class ChatPage extends StatelessWidget {
  final String conversationId;
  const ChatPage({super.key, required this.conversationId});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Column(
        children: [
          const Expanded(child: Center(child: Text('Mensajes de demo…'))),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(hintText: 'Escribe un mensaje...'),
                  ),
                ),
                IconButton(onPressed: () {}, icon: const Icon(Icons.send)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});
  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late String email;
  String? phone;
  String? address;

  @override
  void initState() {
    super.initState();
    final u = ref.read(appProvider).user;
    email = u.email ?? '';
    phone = u.phone;
    address = u.address;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appProvider);
    final myListings = state.listings.where((l) => l.userId == state.user.id).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Mi perfil')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  initialValue: email,
                  decoration: const InputDecoration(labelText: 'Correo'),
                  validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
                  onChanged: (v) => email = v,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: phone,
                  decoration: const InputDecoration(labelText: 'Teléfono'),
                  keyboardType: TextInputType.phone,
                  onChanged: (v) => phone = v,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: address,
                  decoration: const InputDecoration(labelText: 'Dirección de entrega (obligatoria)'),
                  validator: (v) => (v == null || v.isEmpty) ? 'Obligatoria' : null,
                  onChanged: (v) => address = v,
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      ref.read(appProvider.notifier).updateProfile(
                            email: email,
                            phone: phone,
                            address: address,
                          );
                      ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(content: Text('Perfil actualizado')));
                    }
                  },
                  child: const Text('Guardar perfil'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Text('Mis anuncios', style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              FilledButton.tonal(onPressed: () {}, child: const Text('Ver todo')),
            ],
          ),
          const SizedBox(height: 8),
          ...myListings.map(
            (l) => ListTile(
              leading: const CircleAvatar(child: Icon(Icons.image)),
              title: Text('${l.title} · ${l.size}'),
              subtitle: Text('${l.price.toStringAsFixed(2)} €'),
              trailing: Switch(value: l.active, onChanged: (_) {}),
            ),
          ),
        ],
      ),
    );
  }
}

class AdDetailsPage extends ConsumerWidget {
  final String listingId;
  const AdDetailsPage({super.key, required this.listingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listing = ref.watch(appProvider).listings.firstWhere((l) => l.id == listingId);
    return Scaffold(
      appBar: AppBar(title: Text(listing.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              alignment: Alignment.center,
              color: Theme.of(context).colorScheme.surfaceVariant,
              child: const Icon(Icons.image, size: 72),
            ),
          ),
          const SizedBox(height: 12),
          Text('${listing.title} · ${listing.size}', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 6),
          Row(
            children: [
              Chip(label: Text(conditionLabels[listing.condition]!)),
              const SizedBox(width: 8),
              if (listing.defects.isNotEmpty)
                ...listing.defects.map(
                  (d) => Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Chip(label: Text(d)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text('Precio: ${listing.price.toStringAsFixed(2)} €',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Abrir chat con vendedor (demo)')));
            },
            icon: const Icon(Icons.chat_bubble),
            label: const Text('Chatear con el vendedor'),
          ),
        ],
      ),
    );
  }
}