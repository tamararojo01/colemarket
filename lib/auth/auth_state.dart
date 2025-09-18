import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final userProvider = StreamProvider<User?>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange
      .map((event) => event.session?.user);
});

class AuthStateNotifier extends ChangeNotifier {
  AuthStateNotifier() {
    _sub = Supabase.instance.client.auth.onAuthStateChange.listen((_) {
      notifyListeners();
    });
  }
  late final StreamSubscription<AuthState> _sub;
  User? get user => Supabase.instance.client.auth.currentUser;
  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

final authNotifierProvider = Provider<AuthStateNotifier>((ref) {
  final n = AuthStateNotifier();
  ref.onDispose(n.dispose);
  return n;
});
