import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/platform/plataforma.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/materials/presentation/screens/materials_screen.dart';
import '../features/loans/presentation/screens/loans_screen.dart';
import '../features/returns/presentation/screens/devoluciones_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/reset_password_screen.dart';
import '../features/auth/presentation/screens/usuarios_screen.dart';
import '../features/categories/presentation/screens/categorias_screen.dart';
import '../features/student/presentation/screens/shell_estudiante.dart';
import '../features/student/presentation/screens/solo_movil_screen.dart';
import 'auth_state.dart';
import 'shell_navegacion.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// Rutas que se pueden visitar sin haber iniciado sesión.
const _rutasPublicas = {'/login', '/forgot-password', '/reset-password'};

/// Pantalla de inicio de cada tipo de usuario.
const _inicioPersonal = '/';
const _inicioEstudiante = '/estudiante';
const _rutaSoloMovil = '/solo-movil';

/// Página sin animación de transición, usada dentro del marco de navegación.
Page<void> _paginaSinTransicion(Widget pantalla) {
  return NoTransitionPage(child: pantalla);
}

/// Decide a dónde debe ir cada persona según su sesión y rol.
///
/// - Sin sesión: solo rutas públicas.
/// - Estudiante: únicamente su sección, y solo en móvil.
/// - Personal: todo menos la sección del estudiante.
///
/// Devuelve `null` cuando la ubicación pedida es válida.
String? _redireccionar(BuildContext context, GoRouterState state) {
  final ubicacion = state.matchedLocation;
  final esPublica = _rutasPublicas.contains(ubicacion);

  if (!authStateNotifier.isAuthenticated) {
    return esPublica ? null : '/login';
  }

  if (authStateNotifier.esEstudiante) {
    if (!estudiantePuedeUsarEstaPlataforma) {
      return ubicacion == _rutaSoloMovil ? null : _rutaSoloMovil;
    }
    return ubicacion.startsWith(_inicioEstudiante) ? null : _inicioEstudiante;
  }

  // Personal de la biblioteca
  final esDelEstudiante =
      ubicacion.startsWith(_inicioEstudiante) || ubicacion == _rutaSoloMovil;
  return (esPublica || esDelEstudiante) ? _inicioPersonal : null;
}

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login',
  refreshListenable: authStateNotifier,
  redirect: _redireccionar,
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
    GoRoute(
      path: _rutaSoloMovil,
      name: 'solo-movil',
      builder: (context, state) => const SoloMovilScreen(),
    ),
    // App móvil del estudiante (la navegación interna la maneja el propio shell).
    GoRoute(
      path: _inicioEstudiante,
      name: 'estudiante',
      builder: (context, state) => const ShellEstudiante(),
    ),
    // Aplicación del personal de la biblioteca.
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
          path: '/returns',
          name: 'returns',
          pageBuilder: (context, state) => _paginaSinTransicion(
            DevolucionesScreen(
              textoInicial: state.uri.queryParameters['q'] ?? '',
            ),
          ),
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
