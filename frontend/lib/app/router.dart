import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/local/modo_local.dart';
import '../core/platform/plataforma.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/authors/data/models/autor.dart';
import '../features/authors/presentation/screens/autores_screen.dart';
import '../features/materials/presentation/screens/materials_screen.dart';
import '../features/materials/presentation/screens/materiales_movil_screen.dart';
import '../features/student/presentation/screens/perfil_screen.dart';
import '../features/loans/presentation/screens/loans_screen.dart';
import '../features/reports/presentation/screens/reportes_screen.dart';
import '../features/returns/presentation/screens/devoluciones_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/reset_password_screen.dart';
import '../features/auth/presentation/screens/usuarios_screen.dart';
import '../features/categories/presentation/screens/categorias_screen.dart';
import '../features/sincronizacion/presentation/screens/configuracion_inicial_screen.dart';
import '../features/sincronizacion/presentation/screens/sincronizacion_screen.dart';
import '../features/student/presentation/screens/shell_estudiante.dart';
import '../features/student/presentation/screens/solo_movil_screen.dart';
import 'auth_state.dart';
import 'shell_navegacion.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Navegador raíz: permite mostrar diálogos desde fuera del árbol de pantallas.
GlobalKey<NavigatorState> get navegadorRaizKey => _rootNavigatorKey;

final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// Rutas que se pueden visitar sin haber iniciado sesión.
const _rutasPublicas = {'/login', '/forgot-password', '/reset-password'};

/// Pantalla de inicio de cada tipo de usuario.
const _inicioPersonal = '/';
const _inicioEstudiante = '/estudiante';
const _rutaSoloMovil = '/solo-movil';
const _rutaConfiguracionInicial = '/configuracion-inicial';
const _rutaSincronizacion = '/sync';

/// Pantallas que el personal solo usa desde la web o el escritorio.
const _rutasSoloEscritorio = [
  '/users',
  '/categories',
  '/authors',
  '/reports',
  _rutaSincronizacion,
];

/// Página sin animación de transición, usada dentro del marco de navegación.
Page<void> _paginaSinTransicion(Widget pantalla) {
  return NoTransitionPage(child: pantalla);
}

/// Autor por el que se filtra el inventario: llega como `?autor=<id>&nombre=<nombre>`
/// desde la sección Autores.
Autor? _autorDeLaRuta(GoRouterState state) {
  final id = state.uri.queryParameters['autor'];
  if (id == null || id.isEmpty) return null;
  return Autor(id: id, nombre: state.uri.queryParameters['nombre'] ?? 'Autor');
}

/// Decide a dónde debe ir cada persona según su sesión y rol.
///
/// - Equipo de escritorio sin configurar: solo la pantalla de configuración inicial.
/// - Sin sesión: solo rutas públicas.
/// - Estudiante: únicamente su sección, y solo en móvil.
/// - Personal: todo menos la sección del estudiante.
///
/// Devuelve `null` cuando la ubicación pedida es válida.
String? _redireccionar(BuildContext context, GoRouterState state) {
  final ubicacion = state.matchedLocation;
  final esPublica = _rutasPublicas.contains(ubicacion);

  // Un equipo recién instalado debe configurarse antes de poder iniciar sesión.
  if (modoLocalNotifier.requiereConfiguracion) {
    return ubicacion == _rutaConfiguracionInicial
        ? null
        : _rutaConfiguracionInicial;
  }
  if (ubicacion == _rutaConfiguracionInicial) return '/login';
  // La sincronización existe solo en el ejecutable de escritorio.
  if (ubicacion == _rutaSincronizacion && !modoLocalNotifier.activo)
    return _inicioPersonal;

  if (!authStateNotifier.isAuthenticated) {
    return esPublica ? null : '/login';
  }

  if (authStateNotifier.esEstudiante) {
    if (!estudiantePuedeUsarEstaPlataforma) {
      return ubicacion == _rutaSoloMovil ? null : _rutaSoloMovil;
    }
    return ubicacion.startsWith(_inicioEstudiante) ? null : _inicioEstudiante;
  }

  // En el teléfono el personal solo tiene lo esencial; el resto vuelve al inicio.
  if (esDispositivoMovil && _rutasSoloEscritorio.any(ubicacion.startsWith)) {
    return _inicioPersonal;
  }

  // Personal de la biblioteca
  final esDelEstudiante =
      ubicacion.startsWith(_inicioEstudiante) || ubicacion == _rutaSoloMovil;
  return (esPublica || esDelEstudiante) ? _inicioPersonal : null;
}

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login',
  refreshListenable: Listenable.merge([authStateNotifier, modoLocalNotifier]),
  redirect: _redireccionar,
  routes: [
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: _rutaConfiguracionInicial,
      name: 'configuracion-inicial',
      builder: (context, state) => const ConfiguracionInicialScreen(),
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
          pageBuilder: (context, state) => _paginaSinTransicion(
            // En el teléfono el inventario es solo de consulta.
            esDispositivoMovil
                ? const MaterialesMovilScreen()
                : MaterialsScreen(autorInicial: _autorDeLaRuta(state)),
          ),
        ),
        GoRoute(
          path: '/authors',
          name: 'authors',
          pageBuilder: (context, state) =>
              _paginaSinTransicion(const AutoresScreen()),
        ),
        GoRoute(
          path: '/perfil',
          name: 'perfil',
          pageBuilder: (context, state) =>
              _paginaSinTransicion(const PerfilScreen()),
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
          path: '/reports',
          name: 'reports',
          pageBuilder: (context, state) =>
              _paginaSinTransicion(const ReportesScreen()),
        ),
        GoRoute(
          path: '/users',
          name: 'users',
          pageBuilder: (context, state) =>
              _paginaSinTransicion(const UsuariosScreen()),
        ),
        GoRoute(
          path: _rutaSincronizacion,
          name: 'sync',
          pageBuilder: (context, state) =>
              _paginaSinTransicion(const SincronizacionScreen()),
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
