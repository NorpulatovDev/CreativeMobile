import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../services/sms_service.dart';
import '../services/sms_queue_processor.dart';

import 'package:creative/features/inquiries/data/models/inquiry_group_model.dart';
import 'package:creative/features/inquiries/presentation/pages/inquiries_page.dart';
import 'package:creative/features/inquiries/presentation/pages/inquiry_group_detail_page.dart';

import '../../features/admins/presentation/pages/admins_page.dart';
import '../../features/attendance/presentation/pages/attendance_page.dart';
import '../../features/attendance_submission/presentation/pages/pending_approvals_page.dart';
import '../../features/sms/presentation/pages/failed_sms_page.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/branches/data/models/branch_model.dart';
import '../../features/branches/data/repositories/branch_repository.dart';
import '../../features/branches/presentation/bloc/branch_bloc.dart';
import '../../features/branches/presentation/pages/branches_page.dart';
import '../../features/groups/presentation/pages/group_detail_page.dart';
import '../../features/groups/presentation/pages/groups_page.dart';
import '../../features/payments/presentation/bloc/payment_bloc.dart';
import '../../features/payments/presentation/dialogs/payment_form_dialog.dart';
import '../../features/payments/presentation/pages/payments_page.dart';
import '../../features/reports/presentation/pages/payment_status_page.dart';
import '../../features/reports/presentation/pages/reports_page.dart';
import '../../features/students/presentation/bloc/student_bloc.dart';
import '../../features/students/presentation/pages/student_detail_page.dart';
import '../../features/students/presentation/pages/students_page.dart';
import '../../features/teachers/presentation/pages/teacher_detail_page.dart';
import '../../features/teachers/presentation/pages/teachers_page.dart';
import '../branch/branch_selection_cubit.dart';
import '../di/injection.dart';
import '../theme/app_theme.dart';
import 'routes.dart';

class AppRouter {
  final AuthBloc _authBloc;
  final BranchSelectionCubit _branchCubit;

  AppRouter(this._authBloc, this._branchCubit);

  late final GoRouter router = GoRouter(
    initialLocation: Routes.splash,
    debugLogDiagnostics: true,
    refreshListenable: GoRouterRefreshStream([_authBloc.stream, _branchCubit.onBranchSwitch]),
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
      GoRoute(
        path: Routes.selectBranch,
        name: 'select-branch',
        builder: (context, state) => const BranchSelectionPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainScaffold(navigationShell: navigationShell),
        branches: [
          // Branch 0 — Home + all secondary pages
          StatefulShellBranch(
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
                path: Routes.inquiries,
                name: 'inquiries',
                builder: (context, state) => const InquiriesPage(),
                routes: [
                  GoRoute(
                    path: 'groups/:id',
                    name: 'inquiry-group-detail',
                    builder: (context, state) {
                      final group = state.extra as InquiryGroupModel;
                      return InquiryGroupDetailPage(group: group);
                    },
                  ),
                ],
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
                routes: [
                  GoRoute(
                    path: 'payment-status',
                    name: 'report-payment-status',
                    builder: (context, state) {
                      final args = state.extra as PaymentStatusPageArgs;
                      return PaymentStatusPage(
                        type: args.type,
                        students: args.students,
                        monthLabel: args.monthLabel,
                      );
                    },
                  ),
                ],
              ),
              GoRoute(
                path: Routes.branches,
                name: 'branches',
                builder: (context, state) => const BranchesPage(),
              ),
              GoRoute(
                path: Routes.admins,
                name: 'admins',
                builder: (context, state) => const AdminsPage(),
              ),
              GoRoute(
                path: Routes.approvals,
                name: 'approvals',
                builder: (context, state) => const PendingApprovalsPage(),
              ),
              GoRoute(
                path: Routes.failedSms,
                name: 'failed-sms',
                builder: (context, state) => const FailedSmsPage(),
              ),
            ],
          ),
          // Branch 1 — Groups
          StatefulShellBranch(
            routes: [
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
            ],
          ),
          // Branch 2 — Students
          StatefulShellBranch(
            routes: [
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
            ],
          ),
          // Branch 3 — Payments
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.payments,
                name: 'payments',
                builder: (context, state) => const PaymentsPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  String? _redirect(BuildContext context, GoRouterState state) {
    final authState = _authBloc.state;
    final loc = state.matchedLocation;

    if (authState is AuthInitial || authState is AuthLoading) {
      return loc == Routes.splash ? null : Routes.splash;
    }

    if (authState is! AuthAuthenticated) {
      return loc == Routes.login ? null : Routes.login;
    }

    // Teachers use the Telegram Mini App, not this admin app. They can't sign in
    // here (their accounts are passwordless), but guard against it defensively.
    if (authState.user.isTeacher) {
      return loc == Routes.login ? null : Routes.login;
    }

    if (authState.user.isSuperAdmin) {
      final branchState = _branchCubit.state;
      if (branchState.isInitialized && branchState.selectedBranchId == null) {
        return loc == Routes.selectBranch ? null : Routes.selectBranch;
      }
      if (loc == Routes.selectBranch) return Routes.home;
    }

    if (loc == Routes.login ||
        loc == Routes.splash ||
        loc == Routes.selectBranch) {
      return Routes.home;
    }

    return null;
  }
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(List<Stream<dynamic>> streams) {
    notifyListeners();
    _subscriptions = streams
        .map((s) => s.asBroadcastStream().listen((_) => notifyListeners()))
        .toList();
  }

  late final List<dynamic> _subscriptions;

  @override
  void dispose() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
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
                          color: Colors.black.withValues(alpha: 0.2),
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
                      color: Colors.white.withValues(alpha: 0.9),
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
                        Colors.white.withValues(alpha: 0.8),
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
  static final scaffoldKey = GlobalKey<ScaffoldState>();

  final StatefulNavigationShell navigationShell;

  const MainScaffold({super.key, required this.navigationShell});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> with WidgetsBindingObserver {
  final SmsQueueProcessor _smsProcessor = getIt<SmsQueueProcessor>();

  @override
  void initState() {
    super.initState();
    // The admin shell is only shown to admins (teachers are routed elsewhere),
    // so this drives centralized SMS sending from the admin device.
    WidgetsBinding.instance.addObserver(this);
    _smsProcessor.start();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _smsProcessor.processQueue();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _smsProcessor.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final isSuperAdmin =
            authState is AuthAuthenticated && authState.user.isSuperAdmin;
        final isHomeTab = widget.navigationShell.currentIndex == 0;
        return Scaffold(
            key: MainScaffold.scaffoldKey,
            drawer: isSuperAdmin ? const _BranchDrawer() : null,
            drawerEnableOpenDragGesture: isSuperAdmin,
            drawerEdgeDragWidth: isSuperAdmin && isHomeTab
                ? MediaQuery.sizeOf(context).width
                : 20,
            body: widget.navigationShell,
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neutral900.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _NavItem(
                        icon: Icons.home_outlined,
                        selectedIcon: Icons.home_rounded,
                        label: 'Bosh sahifa',
                        isSelected: widget.navigationShell.currentIndex == 0,
                        onTap: () => widget.navigationShell.goBranch(0),
                      ),
                      _NavItem(
                        icon: Icons.groups_outlined,
                        selectedIcon: Icons.groups_rounded,
                        label: 'Guruhlar',
                        isSelected: widget.navigationShell.currentIndex == 1,
                        onTap: () => widget.navigationShell.goBranch(1),
                      ),
                      _NavItem(
                        icon: Icons.school_outlined,
                        selectedIcon: Icons.school_rounded,
                        label: "O'quvchilar",
                        isSelected: widget.navigationShell.currentIndex == 2,
                        onTap: () => widget.navigationShell.goBranch(2),
                      ),
                      _NavItem(
                        icon: Icons.payment_outlined,
                        selectedIcon: Icons.payment_rounded,
                        label: "To'lovlar",
                        isSelected: widget.navigationShell.currentIndex == 3,
                        onTap: () => widget.navigationShell.goBranch(3),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        );
      },
    );
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
    return RepaintBoundary(
      child: GestureDetector(
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
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: _HomeHeader()),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const _PageGrid(),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
        ),
      ),
      child: const SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              _HeaderMenuButton(),
              SizedBox(width: 14),
              Expanded(child: _HeaderTitle()),
            ],
          ),
        ),
      ),
    );
  }
}

// Watches AuthBloc only — rebuilds when super-admin status changes.
class _HeaderMenuButton extends StatelessWidget {
  const _HeaderMenuButton();

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final isSuperAdmin =
        authState is AuthAuthenticated && authState.user.isSuperAdmin;
    return GestureDetector(
      onTap: isSuperAdmin
          ? () => MainScaffold.scaffoldKey.currentState?.openDrawer()
          : null,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          isSuperAdmin ? Icons.menu_rounded : Icons.school_rounded,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}

// Watches both AuthBloc and BranchSelectionCubit — only the subtitle text
// and title column rebuild; the surrounding gradient container does not.
class _HeaderTitle extends StatelessWidget {
  const _HeaderTitle();

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final isSuperAdmin =
        authState is AuthAuthenticated && authState.user.isSuperAdmin;
    final branchName =
        context.watch<BranchSelectionCubit>().state.selectedBranchName;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Creative',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.3),
        ),
        Text(
          isSuperAdmin && branchName != null ? branchName : "O'quv Markazi",
          style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
              fontWeight: FontWeight.w400),
        ),
      ],
    );
  }
}


class _BranchDrawer extends StatefulWidget {
  const _BranchDrawer();

  @override
  State<_BranchDrawer> createState() => _BranchDrawerState();
}

class _BranchDrawerState extends State<_BranchDrawer> {
  late final BranchBloc _branchBloc;

  @override
  void initState() {
    super.initState();
    _branchBloc = getIt<BranchBloc>()..add(BranchLoadAll());
  }

  @override
  void dispose() {
    _branchBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _branchBloc,
      child: Drawer(
        backgroundColor: AppColors.backgroundLight,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(28)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _DrawerHeader(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Row(
                children: [
                  const Icon(Icons.apartment_rounded,
                      size: 13, color: AppColors.neutral400),
                  const SizedBox(width: 6),
                  Text(
                    'FILIALLAR',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.neutral400,
                      letterSpacing: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<BranchBloc, BranchState>(
                builder: (context, branchState) {
                  if (branchState is BranchLoading) {
                    return const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  }
                  if (branchState is BranchError) {
                    return Center(child: Text(branchState.message));
                  }
                  final branches =
                      branchState is BranchLoaded ? branchState.branches : <BranchModel>[];
                  return BlocBuilder<BranchSelectionCubit, BranchSelectionState>(
                    builder: (context, selectionState) {
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        itemCount: branches.length,
                        itemBuilder: (context, index) {
                          final branch = branches[index];
                          final isSelected =
                              selectionState.selectedBranchId == branch.id;
                          return _BranchCard(
                            branch: branch,
                            isSelected: isSelected,
                            onTap: () {
                              context
                                  .read<BranchSelectionCubit>()
                                  .selectBranch(
                                    branchId: branch.id,
                                    branchName: branch.name,
                                  );
                              Navigator.of(context).pop();
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
            const Divider(height: 1, indent: 20, endIndent: 20),
            const SizedBox(height: 8),
            _DrawerNavItem(
              icon: Icons.business_rounded,
              label: 'Filiallar',
              color: const Color(0xFF0EA5E9),
              onTap: () {
                Navigator.of(context).pop();
                context.push(Routes.branches);
              },
            ),
            _DrawerNavItem(
              icon: Icons.admin_panel_settings_rounded,
              label: 'Adminlar',
              color: const Color(0xFFEC4899),
              onTap: () {
                Navigator.of(context).pop();
                context.push(Routes.admins);
              },
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              child: GestureDetector(
                onTap: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      title: const Text(
                        'Chiqish',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      content: const Text(
                        'Tizimdan chiqmoqchimisiz?',
                        style: TextStyle(color: AppColors.neutral600),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const Text(
                            'Bekor qilish',
                            style: TextStyle(color: AppColors.neutral500),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: const Text(
                            'Chiqish',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    if (context.mounted) Navigator.of(context).pop();
                    getIt<AuthBloc>().add(AuthLogout());
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                        color: Colors.red.withValues(alpha: 0.15), width: 1.5),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout_rounded, color: Colors.red, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Chiqish',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BranchCard extends StatelessWidget {
  final BranchModel branch;
  final bool isSelected;
  final VoidCallback onTap;

  const _BranchCard({
    required this.branch,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.gradientStart, AppColors.gradientEnd],
                    )
                  : null,
              color: isSelected ? null : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.28)
                      : Colors.black.withValues(alpha: 0.05),
                  blurRadius: isSelected ? 18 : 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.2)
                        : AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.business_rounded,
                    color: isSelected ? Colors.white : AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        branch.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white : AppColors.neutral800,
                        ),
                      ),
                      if (branch.address != null &&
                          branch.address!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          branch.address!,
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.72)
                                : AppColors.neutral500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: isSelected
                      ? Container(
                          key: const ValueKey('check'),
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check_rounded,
                              color: Colors.white, size: 16),
                        )
                      : const SizedBox(key: ValueKey('empty'), width: 28),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DrawerNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _DrawerNavItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader();

  @override
  Widget build(BuildContext context) {
    final branchState = context.watch<BranchSelectionCubit>().state;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.school_rounded,
                        color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Creative',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        "O'quv Markazi",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(height: 1, color: Colors.white.withValues(alpha: 0.15)),
              const SizedBox(height: 16),
              const Text(
                'JORIY FILIAL',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white54,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.greenAccent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.greenAccent.withValues(alpha: 0.6),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    branchState.selectedBranchName ?? 'Tanlanmagan',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PageData {
  final IconData icon;
  final String label;
  final Color color;
  final String? route;
  final bool pushRoute;
  final void Function(BuildContext)? onTap;

  const _PageData({
    required this.icon,
    required this.label,
    required this.color,
    this.route,
    this.pushRoute = true,
    this.onTap,
  });
}

class _PageGrid extends StatelessWidget {
  const _PageGrid();

  static Future<void> _showQuickPayment(BuildContext context) async {
    final bloc = getIt<PaymentBloc>();
    String? successMessage;
    String? errorMessage;
    StreamSubscription<PaymentState>? sub;

    sub = bloc.stream.listen((state) {
      if (state is PaymentActionSuccess) {
        successMessage = state.message;
      } else if (state is PaymentError) {
        errorMessage = state.message;
      }
    });

    final smsResult = await showDialog<SmsResult?>(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: bloc,
        child: const PaymentFormDialog(),
      ),
    );

    sub.cancel();

    if (!context.mounted) return;

    if (errorMessage != null && successMessage == null) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(
          content: Row(children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(errorMessage!)),
          ]),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      return;
    }

    if (successMessage == null) return;

    final (String message, Color color, IconData icon) = switch (smsResult) {
      SmsResult.sent => (
          "To'lov qabul qilindi, SMS yuborildi",
          AppColors.success,
          Icons.check_circle_outline,
        ),
      SmsResult.failed => (
          "To'lov qabul qilindi, SMS yuborilmadi",
          AppColors.warning,
          Icons.warning_amber_rounded,
        ),
      SmsResult.permissionDenied ||
      SmsResult.permissionPermanentlyDenied => (
          "To'lov qabul qilindi, SMS ruxsati yo'q",
          AppColors.warning,
          Icons.warning_amber_rounded,
        ),
      SmsResult.notAvailable => (
          "To'lov qabul qilindi, SMS mumkin emas",
          AppColors.neutral500,
          Icons.sms_failed_rounded,
        ),
      null => (successMessage!, AppColors.success, Icons.check_circle_outline),
    };

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Row(children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
        ]),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
  }

  static Future<void> _showAddStudent(BuildContext context) async {
    final bloc = getIt<StudentBloc>();
    StreamSubscription<StudentState>? sub;

    sub = bloc.stream.listen((state) {
      if (state is StudentActionSuccess || state is StudentError) {
        sub?.cancel();
        if (!context.mounted) return;
        final isSuccess = state is StudentActionSuccess;
        final message = state is StudentActionSuccess
            ? state.message
            : (state as StudentError).message;
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(
            content: Row(children: [
              Icon(
                isSuccess ? Icons.check_circle_outline : Icons.error_outline,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(message)),
            ]),
            backgroundColor: isSuccess ? AppColors.success : AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ));
      }
    });

    await showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: bloc,
        child: const StudentFormDialog(),
      ),
    );

    // Cancel after delay in case user dismissed without submitting
    Future.delayed(const Duration(seconds: 15), () => sub?.cancel());
  }

  List<_PageData> _buildItems(BuildContext context) {
    return [
      _PageData(icon: Icons.contact_phone_rounded, label: "So'rovlar",         color: const Color(0xFF3B82F6), route: Routes.inquiries),
      _PageData(icon: Icons.groups_rounded,         label: "Guruhlar",          color: AppColors.primary,       route: Routes.groups,   pushRoute: false),
      _PageData(icon: Icons.school_rounded,         label: "O'quvchilar",       color: AppColors.success,       route: Routes.students, pushRoute: false),
      _PageData(icon: Icons.person_add_rounded,     label: "O'quvchi qo'shish", color: AppColors.success,       onTap: _showAddStudent),
      _PageData(icon: Icons.analytics_rounded,      label: "Hisobotlar",        color: const Color(0xFF06B6D4), route: Routes.reports),
      _PageData(icon: Icons.fact_check_rounded,     label: "Tasdiqlash",        color: AppColors.warning,       route: Routes.approvals),
      _PageData(icon: Icons.sms_rounded,            label: "SMS",               color: AppColors.error,         route: Routes.failedSms),
      _PageData(icon: Icons.person_rounded,         label: "O'qituvchilar",     color: AppColors.warning,       route: Routes.teachers),
      _PageData(icon: Icons.add_card_rounded,       label: "To'lov qo'shish",   color: const Color(0xFF8B5CF6), onTap: _showQuickPayment),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final items = _buildItems(context);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.88,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => _PageCard(data: items[index]),
    );
  }
}

class _PageCard extends StatelessWidget {
  final _PageData data;

  const _PageCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (data.onTap != null) {
          data.onTap!(context);
        } else if (data.pushRoute) {
          context.push(data.route!);
        } else {
          context.go(data.route!);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: data.color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(data.icon, color: data.color, size: 26),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                data.label,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.neutral700),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BranchSelectionPage extends StatefulWidget {
  const BranchSelectionPage({super.key});

  @override
  State<BranchSelectionPage> createState() => _BranchSelectionPageState();
}

class _BranchSelectionPageState extends State<BranchSelectionPage> {
  late Future<List<BranchModel>> _branchesFuture;

  @override
  void initState() {
    super.initState();
    _branchesFuture = getIt<BranchRepository>().getAll().then((r) => r.$1 ?? []);
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
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.business_rounded, color: Colors.white, size: 40),
                    SizedBox(height: 16),
                    Text(
                      'Filialni tanlang',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Davom etish uchun filialni tanlashingiz shart',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: FutureBuilder<List<BranchModel>>(
                    future: _branchesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final branches = snapshot.data ?? [];
                      if (branches.isEmpty) {
                        return const Center(
                          child: Text(
                            'Filiallar topilmadi',
                            style: TextStyle(color: AppColors.neutral500),
                          ),
                        );
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.all(20),
                        itemCount: branches.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final branch = branches[index];
                          return _BranchTile(branch: branch);
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BranchTile extends StatelessWidget {
  final BranchModel branch;

  const _BranchTile({required this.branch});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<BranchSelectionCubit>().selectBranch(
              branchId: branch.id,
              branchName: branch.name,
            );
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.business_rounded,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    branch.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.neutral900,
                    ),
                  ),
                  if (branch.address != null && branch.address!.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      branch.address!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.neutral500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppColors.neutral400,
            ),
          ],
        ),
      ),
    );
  }
}
