import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/attendance/presentation/pages/attendance_page.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/groups/presentation/pages/group_detail_page.dart';
import '../../features/groups/presentation/pages/groups_page.dart';
import '../../features/payments/presentation/pages/payments_page.dart';
import '../../features/reports/presentation/pages/reports_page.dart';
import '../../features/students/presentation/pages/student_detail_page.dart';
import '../../features/students/presentation/pages/students_page.dart';
import '../../features/teachers/presentation/pages/teacher_detail_page.dart';
import '../../features/teachers/presentation/pages/teachers_page.dart';
import '../di/injection.dart';
import 'routes.dart';

class AppRouter {
  final AuthBloc _authBloc;

  AppRouter(this._authBloc);

  late final GoRouter router = GoRouter(
    initialLocation: Routes.splash,
    debugLogDiagnostics: true,
    refreshListenable: GoRouterRefreshStream(_authBloc.stream),
    redirect: _redirect,
    routes: [
      GoRoute(
        path: Routes.splash,
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: Routes.login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: Routes.home,
            name: 'home',
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: Routes.teachers,
            name: 'teachers',
            builder: (context, state) => const TeachersPage(),
            routes: [
              GoRoute(
                path: ':id',
                name: 'teacher-detail',
                builder: (context, state) {
                  final id = int.parse(state.pathParameters['id']!);
                  return TeacherDetailPage(teacherId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: Routes.groups,
            name: 'groups',
            builder: (context, state) => const GroupsPage(),
            routes: [
              GoRoute(
                path: ':id',
                name: 'group-detail',
                builder: (context, state) {
                  final id = int.parse(state.pathParameters['id']!);
                  return GroupDetailPage(groupId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: Routes.students,
            name: 'students',
            builder: (context, state) => const StudentsPage(),
            routes: [
              GoRoute(
                path: ':id',
                name: 'student-detail',
                builder: (context, state) {
                  final id = int.parse(state.pathParameters['id']!);
                  return StudentDetailPage(studentId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: Routes.payments,
            name: 'payments',
            builder: (context, state) => const PaymentsPage(),
          ),
          GoRoute(
            path: Routes.attendance,
            name: 'attendance',
            builder: (context, state) => const AttendancePage(),
          ),
          GoRoute(
            path: Routes.reports,
            name: 'reports',
            builder: (context, state) => const ReportsPage(),
          ),
        ],
      ),
    ],
  );

  String? _redirect(BuildContext context, GoRouterState state) {
    final authState = _authBloc.state;
    final isAuthenticated = authState is AuthAuthenticated;
    final isLoggingIn = state.matchedLocation == Routes.login;
    final isSplash = state.matchedLocation == Routes.splash;

    if (authState is AuthInitial || authState is AuthLoading) {
      return isSplash ? null : Routes.splash;
    }

    if (!isAuthenticated) {
      return isLoggingIn ? null : Routes.login;
    }

    if (isLoggingIn || isSplash) {
      return Routes.home;
    }

    return null;
  }
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final dynamic _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_rounded,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

class MainScaffold extends StatefulWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    _currentIndex = _getIndexFromLocation(location);

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go(Routes.home);
              break;
            case 1:
              context.go(Routes.groups);
              break;
            case 2:
              context.go(Routes.students);
              break;
            case 3:
              context.go(Routes.attendance);
              break;
            case 4:
              context.go(Routes.payments);
              break;
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'Groups',
          ),
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school),
            label: 'Students',
          ),
          NavigationDestination(
            icon: Icon(Icons.fact_check_outlined),
            selectedIcon: Icon(Icons.fact_check),
            label: 'Attendance',
          ),
          NavigationDestination(
            icon: Icon(Icons.payment_outlined),
            selectedIcon: Icon(Icons.payment),
            label: 'Payments',
          ),
        ],
      ),
    );
  }

  int _getIndexFromLocation(String location) {
    if (location.startsWith(Routes.groups)) return 1;
    if (location.startsWith(Routes.students)) return 2;
    if (location.startsWith(Routes.attendance)) return 3;
    if (location.startsWith(Routes.payments)) return 4;
    return 0;
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state is AuthAuthenticated ? state.user : null;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Creative Learning Center'),
            actions: [
              IconButton(
                icon: const Icon(Icons.person_outline),
                tooltip: 'Teachers',
                onPressed: () => context.push(Routes.teachers),
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Logout',
                onPressed: () {
                  getIt<AuthBloc>().add(AuthLogout());
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          child: Icon(
                            Icons.person,
                            size: 30,
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back!',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              user?.username ?? 'User',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                user?.role ?? 'N/A',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.2,
                  children: [
                    _QuickActionCard(
                      icon: Icons.group_add,
                      label: 'New Group',
                      color: Colors.blue,
                      onTap: () => context.go(Routes.groups),
                    ),
                    _QuickActionCard(
                      icon: Icons.person_add,
                      label: 'New Student',
                      color: Colors.green,
                      onTap: () => context.go(Routes.students),
                    ),
                    _QuickActionCard(
                      icon: Icons.fact_check,
                      label: 'Take Attendance',
                      color: Colors.orange,
                      onTap: () => context.go(Routes.attendance),
                    ),
                    _QuickActionCard(
                      icon: Icons.add_card,
                      label: 'Record Payment',
                      color: Colors.purple,
                      onTap: () => context.go(Routes.payments),
                    ),
                    _QuickActionCard(
                      icon: Icons.analytics,
                      label: 'View Reports',
                      color: Colors.teal,
                      onTap: () => context.go(Routes.reports),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Management',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                _MenuCard(
                  icon: Icons.person,
                  title: 'Teachers',
                  subtitle: 'Manage teaching staff',
                  onTap: () => context.push(Routes.teachers),
                ),
                _MenuCard(
                  icon: Icons.groups,
                  title: 'Groups',
                  subtitle: 'Manage classes and enrollments',
                  onTap: () => context.go(Routes.groups),
                ),
                _MenuCard(
                  icon: Icons.school,
                  title: 'Students',
                  subtitle: 'Manage student information',
                  onTap: () => context.go(Routes.students),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}