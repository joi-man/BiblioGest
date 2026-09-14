import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/materials/presentation/screens/materials_screen.dart';
import '../features/loans/presentation/screens/loans_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/usuarios_screen.dart';
import '../features/categories/presentation/screens/categorias_screen.dart';
import 'auth_state.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login',
  refreshListenable: authStateNotifier,
  redirect: (context, state) {
    final isAuthenticated = authStateNotifier.isAuthenticated;
    final isOnLogin = state.matchedLocation == '/login';
    if (!isAuthenticated && !isOnLogin) {
      return '/login';
    }
    if (isAuthenticated && isOnLogin) {
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
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => _ScaffoldWithNavBar(child: child),
      routes: [
        GoRoute(
          path: '/',
          name: 'dashboard',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: DashboardScreen(),
          ),
        ),
        GoRoute(
          path: '/materials',
          name: 'materials',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: MaterialsScreen(),
          ),
        ),
        GoRoute(
          path: '/loans',
          name: 'loans',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: LoansScreen(),
          ),
        ),
        GoRoute(
          path: '/users',
          name: 'users',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: UsuariosScreen(),
          ),
        ),
        GoRoute(
          path: '/categories',
          name: 'categories',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: CategoriasScreen(),
          ),
        ),
      ],
    ),
  ],
);

class _ScaffoldWithNavBar extends StatelessWidget {
  final Widget child;

  const _ScaffoldWithNavBar({required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/materials')) return 1;
    if (location.startsWith('/loans')) return 2;
    if (location.startsWith('/users')) return 3;
    if (location.startsWith('/categories')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/materials');
        break;
      case 2:
        context.go('/loans');
        break;
      case 3:
        context.go('/users');
        break;
      case 4:
        context.go('/categories');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 900) {
          // Desktop/Tablet: NavigationRail
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (index) => _onItemTapped(index, context),
                  labelType: NavigationRailLabelType.all,
                  leading: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Icon(
                      Icons.menu_book,
                      size: 32,
                      color: Color(0xFF2B6CB0),
                    ),
                  ),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.dashboard_outlined),
                      selectedIcon: Icon(Icons.dashboard),
                      label: Text('Dashboard'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.menu_book_outlined),
                      selectedIcon: Icon(Icons.menu_book),
                      label: Text('Materiales'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.assignment_outlined),
                      selectedIcon: Icon(Icons.assignment),
                      label: Text('Prestamos'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.people_outlined),
                      selectedIcon: Icon(Icons.people),
                      label: Text('Usuarios'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.category_outlined),
                      selectedIcon: Icon(Icons.category),
                      label: Text('Categorias'),
                    ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: child),
              ],
            ),
          );
        } else {
          // Mobile: BottomNavigationBar
          return Scaffold(
            body: child,
            bottomNavigationBar: NavigationBar(
              selectedIndex: selectedIndex,
              onDestinationSelected: (index) => _onItemTapped(index, context),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
                NavigationDestination(
                  icon: Icon(Icons.menu_book_outlined),
                  selectedIcon: Icon(Icons.menu_book),
                  label: 'Materiales',
                ),
                NavigationDestination(
                  icon: Icon(Icons.assignment_outlined),
                  selectedIcon: Icon(Icons.assignment),
                  label: 'Prestamos',
                ),
                NavigationDestination(
                  icon: Icon(Icons.people_outlined),
                  selectedIcon: Icon(Icons.people),
                  label: 'Usuarios',
                ),
                NavigationDestination(
                  icon: Icon(Icons.category_outlined),
                  selectedIcon: Icon(Icons.category),
                  label: 'Categorias',
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
