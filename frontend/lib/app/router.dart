import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/materials/presentation/screens/materials_screen.dart';
import '../features/loans/presentation/screens/loans_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/reset_password_screen.dart';
import '../features/auth/presentation/screens/usuarios_screen.dart';
import '../features/categories/presentation/screens/categorias_screen.dart';
import 'auth_state.dart';
import 'shell_navegacion.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// Rutas que se pueden visitar sin haber iniciado sesión.
const _rutasPublicas = {'/login', '/forgot-password', '/reset-password'};

/// Página sin animación de transición, usada dentro del marco de navegación.
Page<void> _paginaSinTransicion(Widget pantalla) {
  return NoTransitionPage(child: pantalla);
}

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login',
  refreshListenable: authStateNotifier,
  redirect: (context, state) {
    final autenticado = authStateNotifier.isAuthenticated;
    final ubicacion = state.matchedLocation;

    if (!autenticado && !_rutasPublicas.contains(ubicacion)) {
      return '/login';
    }
    if (autenticado && ubicacion == '/login') {
      return '/';
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      name: 'forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/reset-password',
      name: 'reset-password',
      builder: (context, state) =>
          ResetPasswordScreen(correoInicial: state.extra as String?),
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => ShellNavegacion(hijo: child),
      routes: [
        GoRoute(
          path: '/',
          name: 'dashboard',
          pageBuilder: (context, state) =>
              _paginaSinTransicion(const DashboardScreen()),
        ),
        GoRoute(
          path: '/materials',
          name: 'materials',
          pageBuilder: (context, state) =>
              _paginaSinTransicion(const MaterialsScreen()),
        ),
        GoRoute(
          path: '/loans',
          name: 'loans',
          pageBuilder: (context, state) =>
              _paginaSinTransicion(const LoansScreen()),
        ),
        GoRoute(
          path: '/users',
          name: 'users',
          pageBuilder: (context, state) =>
              _paginaSinTransicion(const UsuariosScreen()),
        ),
        GoRoute(
          path: '/categories',
          name: 'categories',
          pageBuilder: (context, state) =>
              _paginaSinTransicion(const CategoriasScreen()),
        ),
      ],
    ),
  ],
);
