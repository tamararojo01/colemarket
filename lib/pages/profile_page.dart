import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app/state.dart';

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

    return ListView(
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
                      email: email, phone: phone, address: address,
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
            FilledButton(onPressed: () => {}, child: const Text('Ver todo')),
          ],
        ),
        const SizedBox(height: 8),
        ...myListings.map(
          (l) => ListTile(
            leading: const CircleAvatar(child: Icon(Icons.image)),
            title: const Text('\${l.title} · \${l.size}'),
            subtitle: const Text('\${l.price.toStringAsFixed(2)} €'),
            trailing: Switch(value: l.active, onChanged: (_) {}),
          ),
        ),
      ],
    );
  }
}
