import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'auth/auth_state.dart';
import 'auth/login_page.dart';
import 'app/shell.dart';
import 'pages/ad_details_page.dart';
import 'pages/messages_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(authNotifierProvider);
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final user = authNotifier.user;
      final loggingIn = state.uri.path == '/login';

      if (user == null) return loggingIn ? null : '/login';
      if (loggingIn) return '/';

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (ctx, s) => const LoginPage(),
      ),
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
