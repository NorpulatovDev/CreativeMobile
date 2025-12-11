import 'package:creative/features/attendance/presentation/pages/attendance_page.dart';
import 'package:creative/features/groups/presentation/pages/groups_page.dart';
import 'package:creative/features/payments/presentation/pages/payments_page.dart';
import 'package:creative/features/students/presentation/pages/students_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../di/injection.dart';
import '../storage/token_storage.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/teachers/presentation/pages/teachers_page.dart';

class AppRoutes {
  static const String login = '/login';
  static const String home = '/';
  static const String teachers = '/teachers';
  static const String groups = '/groups';
  static const String students = '/students';
  static const String attendance = '/attendance';
  static const String payments = '/payments';
}

class AppRouter {
  final TokenStorage _tokenStorage;

  AppRouter(this._tokenStorage);

  late final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: true,
    redirect: _redirect,
    routes: [
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            name: 'home',
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: AppRoutes.teachers,
            name: 'teachers',
            builder: (context, state) => const TeachersPage(),
          ),
          GoRoute(
            path: AppRoutes.groups,
            name: 'groups',
            builder: (context, state) => const GroupsPage(),
          ),
          GoRoute(
            path: AppRoutes.students,
            name: 'students',
            builder: (context, state) => const StudentsPage(),
          ),
          GoRoute(
            path: AppRoutes.attendance,
            name: 'attendance',
            builder: (context, state) => const AttendancePage(),
          ),
          GoRoute(
            path: AppRoutes.payments,
            name: 'payments',
            builder: (context, state) => const PaymentsPage(),
          ),
          // TODO: Add more routes
        ],
      ),
    ],
  );

  Future<String?> _redirect(BuildContext context, GoRouterState state) async {
    final isLoggedIn = await _tokenStorage.hasToken();
    final isLoggingIn = state.matchedLocation == AppRoutes.login;

    if (!isLoggedIn && !isLoggingIn) {
      return AppRoutes.login;
    }

    if (isLoggedIn && isLoggingIn) {
      return AppRoutes.home;
    }

    return null;
  }
}

// Main Shell with navigation
class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _calculateSelectedIndex(context),
        onDestinationSelected: (index) => _onItemTapped(index, context),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Teachers',
          ),
          NavigationDestination(
            icon: Icon(Icons.group_outlined),
            selectedIcon: Icon(Icons.group),
            label: 'Groups',
          ),
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school),
            label: 'Students',
          ),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith(AppRoutes.teachers)) return 1;
    if (location.startsWith(AppRoutes.groups)) return 2;
    if (location.startsWith(AppRoutes.students)) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(AppRoutes.home);
        break;
      case 1:
        context.go(AppRoutes.teachers);
        break;
      case 2:
        context.go(AppRoutes.groups);
        break;
      case 3:
        context.go(AppRoutes.students);
        break;
    }
  }
}

// Home Page
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMenuCard(
            context,
            icon: Icons.calendar_today,
            title: 'Attendance',
            subtitle: 'Track attendance',
            onTap: () => context.push(AppRoutes.attendance),
          ),
          _buildMenuCard(
            context,
            icon: Icons.payment,
            title: 'Payments',
            subtitle: 'Record payments',
            onTap: () => context.push(AppRoutes.payments),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  void _logout(BuildContext context) {
    context.read<AuthBloc>().add(const AuthLogout());
  }
}
