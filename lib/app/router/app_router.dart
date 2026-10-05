import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/pads/presentation/pad_section.dart';
import '../../features/pads/presentation/screens/pad_workspace_screen.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/home/presentation/screens/more_screen.dart';
import '../../features/pads/presentation/screens/pad_detail_screen.dart';
import '../../features/pads/presentation/screens/pads_screen.dart';
import '../shell/app_shell.dart';

abstract final class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const signup = '/signup';
  static const forgotPassword = '/forgot-password';
  static const home = '/home';
  static const pads = '/pads';
  static const more = '/more';

  static String padDetail(String padId, {String? section}) =>
      section == null ? '$pads/$padId' : '$pads/$padId?section=$section';
  static const authRoutes = {login, signup, forgotPassword};
}

final appRouterProvider = Provider<GoRouter>((ref) {
  // Re-run redirects whenever auth state changes.
  final refresh = ValueNotifier<int>(0);
  ref.listen(authStateProvider, (_, __) => refresh.value++);
  ref.onDispose(refresh.dispose);

  final router = GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authStateProvider);
      final location = state.matchedLocation;

      // Auth state not known yet (loading or failed): stay on splash.
      if (!auth.hasValue) {
        return location == AppRoutes.splash ? null : AppRoutes.splash;
      }

      final signedIn = auth.userOrNull != null;
      final onAuthPage = AppRoutes.authRoutes.contains(location);

      if (!signedIn) return onAuthPage ? null : AppRoutes.login;
      if (onAuthPage || location == AppRoutes.splash) return AppRoutes.home;
      return null;
    },
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Page not found.'),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Go home'),
            ),
          ],
        ),
      ),
    ),
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          // /pads/<id> -> highlight that Pad in the desktop explorer.
          final segments = state.uri.pathSegments;
          final selectedPadId =
              segments.length >= 2 && segments.first == 'pads'
                  ? segments[1]
                  : null;
          return AppShell(
            navigationShell: navigationShell,
            selectedPadId: selectedPadId,
          );
        },
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => const HomeScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.pads,
              builder: (context, state) => const PadsScreen(),
              routes: [
                GoRoute(
                  path: ':padId',
                  builder: (context, state) {
                    final id = state.pathParameters['padId']!;
                    final section = PadSection.fromKey(
                      state.uri.queryParameters['section'],
                    );
                    return PadWorkspaceScreen(
                      key: ValueKey(id),
                      padId: id,
                      section: section,
                    );
                  },
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.more,
              builder: (context, state) => const MoreScreen(),
            ),
          ]),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});