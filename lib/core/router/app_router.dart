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
import '../theme/app_theme.dart';
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

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5)),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.gradientStart, AppColors.gradientEnd],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      size: 60,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Creative O\'quv',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Markazi',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w300,
                      color: Colors.white.withOpacity(0.9),
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          boxShadow: [
            BoxShadow(
              color: AppColors.neutral900.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home_rounded,
                  label: 'Bosh sahifa',
                  isSelected: _currentIndex == 0,
                  onTap: () => context.go(Routes.home),
                ),
                _NavItem(
                  icon: Icons.groups_outlined,
                  selectedIcon: Icons.groups_rounded,
                  label: 'Guruhlar',
                  isSelected: _currentIndex == 1,
                  onTap: () => context.go(Routes.groups),
                ),
                _NavItem(
                  icon: Icons.school_outlined,
                  selectedIcon: Icons.school_rounded,
                  label: 'O\'quvchilar',
                  isSelected: _currentIndex == 2,
                  onTap: () => context.go(Routes.students),
                ),
                _NavItem(
                  icon: Icons.fact_check_outlined,
                  selectedIcon: Icons.fact_check_rounded,
                  label: 'Davomat',
                  isSelected: _currentIndex == 3,
                  onTap: () => context.go(Routes.attendance),
                ),
                _NavItem(
                  icon: Icons.payment_outlined,
                  selectedIcon: Icons.payment_rounded,
                  label: 'To\'lovlar',
                  isSelected: _currentIndex == 4,
                  onTap: () => context.go(Routes.payments),
                ),
              ],
            ),
          ),
        ),
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

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              color: isSelected ? AppColors.primary : AppColors.neutral400,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.neutral500,
              ),
            ),
          ],
        ),
      ),
    );
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
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 120,
                floating: false,
                pinned: true,
                backgroundColor: AppColors.surfaceLight,
                surfaceTintColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                  title: const Text(
                    'Boshqaruv paneli',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.neutral900,
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primaryContainer.withOpacity(0.3),
                          AppColors.surfaceLight,
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.neutral100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.person_outline_rounded, size: 20),
                    ),
                    tooltip: 'O\'qituvchilar',
                    onPressed: () => context.push(Routes.teachers),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.errorLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.logout_rounded,
                        size: 20,
                        color: AppColors.error,
                      ),
                    ),
                    tooltip: 'Chiqish',
                    onPressed: () {
                      getIt<AuthBloc>().add(AuthLogout());
                    },
                  ),
                  const SizedBox(width: 16),
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _WelcomeCard(
                      username: user?.username ?? 'Foydalanuvchi',
                      role: user?.role ?? 'N/A',
                    ),
                    const SizedBox(height: 28),
                    const _SectionTitle(title: 'Tezkor amallar'),
                    const SizedBox(height: 16),
                    _QuickActionsGrid(),
                    const SizedBox(height: 28),
                    const _SectionTitle(title: 'Boshqaruv'),
                    const SizedBox(height: 16),
                    _ManagementList(),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.neutral800,
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  final String username;
  final String role;

  const _WelcomeCard({required this.username, required this.role});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                username.isNotEmpty ? username[0].toUpperCase() : 'F',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Xush kelibsiz! 👋',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  username,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    role,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickAction(
        icon: Icons.group_add_rounded,
        label: 'Yangi guruh',
        color: AppColors.primary,
        bgColor: AppColors.cardBlue,
        route: Routes.groups,
      ),
      _QuickAction(
        icon: Icons.person_add_rounded,
        label: 'Yangi o\'quvchi',
        color: AppColors.success,
        bgColor: AppColors.cardGreen,
        route: Routes.students,
      ),
      _QuickAction(
        icon: Icons.fact_check_rounded,
        label: 'Davomat',
        color: AppColors.warning,
        bgColor: AppColors.cardOrange,
        route: Routes.attendance,
      ),
      _QuickAction(
        icon: Icons.add_card_rounded,
        label: 'To\'lov',
        color: const Color(0xFF8B5CF6),
        bgColor: AppColors.cardPurple,
        route: Routes.payments,
      ),
      _QuickAction(
        icon: Icons.analytics_rounded,
        label: 'Hisobotlar',
        color: const Color(0xFF06B6D4),
        bgColor: AppColors.cardCyan,
        route: Routes.reports,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.4,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return _QuickActionCard(action: action);
      },
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;
  final String route;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
    required this.route,
  });
}

class _QuickActionCard extends StatelessWidget {
  final _QuickAction action;

  const _QuickActionCard({required this.action});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.go(action.route),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: action.bgColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: action.color.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: action.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(action.icon, color: action.color, size: 24),
              ),
              Text(
                action.label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutral800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ManagementList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ManagementItem(
          icon: Icons.person_rounded,
          title: 'O\'qituvchilar',
          subtitle: 'O\'qituvchilarni boshqarish',
          color: AppColors.primary,
          onTap: () => context.push(Routes.teachers),
        ),
        const SizedBox(height: 12),
        _ManagementItem(
          icon: Icons.groups_rounded,
          title: 'Guruhlar',
          subtitle: 'Guruhlar va ro\'yxatdan o\'tkazish',
          color: AppColors.success,
          onTap: () => context.go(Routes.groups),
        ),
        const SizedBox(height: 12),
        _ManagementItem(
          icon: Icons.school_rounded,
          title: 'O\'quvchilar',
          subtitle: 'O\'quvchilar ma\'lumotlari',
          color: AppColors.warning,
          onTap: () => context.go(Routes.students),
        ),
      ],
    );
  }
}

class _ManagementItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ManagementItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.neutral200.withOpacity(0.5)),
            boxShadow: [
              BoxShadow(
                color: AppColors.neutral900.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.neutral500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.neutral400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
