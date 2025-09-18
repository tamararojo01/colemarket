import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailCtrl = TextEditingController();
  final passCtrl  = TextEditingController();
  bool loading = false;

  @override
  void dispose() { emailCtrl.dispose(); passCtrl.dispose(); super.dispose(); }

  String _redirect() {
    final host = Uri.base.host;
    if (host == 'localhost' || host == '127.0.0.1') return 'http://localhost:5173/';
    return Uri.base.origin + (Uri.base.path.endsWith('/') ? Uri.base.path : '\${Uri.base.path}/');
  }

  Future<void> _signin() async {
    setState(() => loading = true);
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: emailCtrl.text.trim(),
        password: passCtrl.text,
      );
      if (!mounted) return;
      // Router redirige automáticamente a '/'
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally { if (mounted) setState(() => loading = false); }
  }

  Future<void> _signup() async {
    setState(() => loading = true);
    try {
      await Supabase.instance.client.auth.signUp(
        email: emailCtrl.text.trim(),
        password: passCtrl.text,
        emailRedirectTo: _redirect(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Revisa tu correo para verificar la cuenta')),
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally { if (mounted) setState(() => loading = false); }
  }

  Future<void> _magicLink() async {
    setState(() => loading = true);
    try {
      await Supabase.instance.client.auth.signInWithOtp(
        email: emailCtrl.text.trim(),
        emailRedirectTo: _redirect(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Te enviamos un enlace de acceso')),
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally { if (mounted) setState(() => loading = false); }
  }

  Future<void> _google() async {
    setState(() => loading = true);
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: _redirect(),
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Entrar')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
              const SizedBox(height: 12),
              TextField(controller: passCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Contraseña')),
              const SizedBox(height: 16),
              FilledButton(onPressed: loading ? null : _signin, child: const Text('Entrar')),
              const SizedBox(height: 8),
              TextButton(onPressed: loading ? null : _signup, child: const Text('Crear cuenta')),
              TextButton(onPressed: loading ? null : _magicLink, child: const Text('Entrar con Magic Link')),
              const Divider(height: 32),
              OutlinedButton.icon(
                onPressed: loading ? null : _google,
                icon: const Icon(Icons.login),
                label: const Text('Entrar con Google'),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
