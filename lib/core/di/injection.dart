import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/api_client.dart';
import '../router/app_router.dart';
import '../storage/token_storage.dart';

// Auth
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

// Teachers
import '../../features/teachers/data/datasources/teacher_remote_datasource.dart';
import '../../features/teachers/data/repositories/teacher_repository.dart';
import '../../features/teachers/presentation/bloc/teacher_bloc.dart';

// Groups
import '../../features/groups/data/datasources/group_remote_datasource.dart';
import '../../features/groups/data/repositories/group_repository.dart';
import '../../features/groups/presentation/bloc/group_bloc.dart';

// Students
import '../../features/students/data/datasources/student_remote_datasource.dart';
import '../../features/students/data/repositories/student_repository.dart';
import '../../features/students/presentation/bloc/student_bloc.dart';

// Enrollments
import '../../features/enrollments/data/datasources/enrollment_remote_datasource.dart';
import '../../features/enrollments/data/repositories/enrollment_repository.dart';

// Payments
import '../../features/payments/data/datasources/payment_remote_datasource.dart';
import '../../features/payments/data/repositories/payment_repository.dart';
import '../../features/payments/presentation/bloc/payment_bloc.dart';

// Attendance
import '../../features/attendance/data/datasources/attendance_remote_datasource.dart';
import '../../features/attendance/data/repositories/attendance_repository.dart';
import '../../features/attendance/presentation/bloc/attendance_bloc.dart';

// Reports - CORRECTED IMPORTS
import '../../features/reports/data/datasources/report_remote_datasource.dart';
import '../../features/reports/data/repositories/report_repository.dart';
import '../../features/reports/presentation/bloc/report_bloc.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // External
  final sharedPrefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPrefs);

  // Core
  getIt.registerSingleton<TokenStorage>(TokenStorageImpl(getIt()));
  getIt.registerSingleton<ApiClient>(ApiClient(getIt()));

  // Auth Feature
  getIt.registerSingleton<AuthRemoteDataSource>(
    AuthRemoteDataSourceImpl(getIt()),
  );
  getIt.registerSingleton<AuthRepository>(
    AuthRepositoryImpl(getIt(), getIt()),
  );
  getIt.registerSingleton<AuthBloc>(AuthBloc(getIt())..add(AuthCheckStatus()));

  // Teachers Feature
  getIt.registerSingleton<TeacherRemoteDataSource>(
    TeacherRemoteDataSourceImpl(getIt()),
  );
  getIt.registerSingleton<TeacherRepository>(
    TeacherRepositoryImpl(getIt()),
  );
  getIt.registerFactory<TeacherBloc>(() => TeacherBloc(getIt()));

  // Groups Feature
  getIt.registerSingleton<GroupRemoteDataSource>(
    GroupRemoteDataSourceImpl(getIt()),
  );
  getIt.registerSingleton<GroupRepository>(
    GroupRepositoryImpl(getIt()),
  );
  getIt.registerFactory<GroupBloc>(() => GroupBloc(getIt()));

  // Students Feature
  getIt.registerSingleton<StudentRemoteDataSource>(
    StudentRemoteDataSourceImpl(getIt()),
  );
  getIt.registerSingleton<StudentRepository>(
    StudentRepositoryImpl(getIt()),
  );
  getIt.registerFactory<StudentBloc>(() => StudentBloc(getIt()));

  // Enrollments Feature
  getIt.registerSingleton<EnrollmentRemoteDataSource>(
    EnrollmentRemoteDataSourceImpl(getIt()),
  );
  getIt.registerSingleton<EnrollmentRepository>(
    EnrollmentRepositoryImpl(getIt()),
  );

  // Payments Feature
  getIt.registerSingleton<PaymentRemoteDataSource>(
    PaymentRemoteDataSourceImpl(getIt()),
  );
  getIt.registerSingleton<PaymentRepository>(
    PaymentRepositoryImpl(getIt()),
  );
  getIt.registerFactory<PaymentBloc>(() => PaymentBloc(getIt()));

  // Attendance Feature
  getIt.registerSingleton<AttendanceRemoteDataSource>(
    AttendanceRemoteDataSourceImpl(getIt()),
  );
  getIt.registerSingleton<AttendanceRepository>(
    AttendanceRepositoryImpl(getIt()),
  );
  getIt.registerFactory<AttendanceBloc>(() => AttendanceBloc(getIt()));

  // Reports Feature - PROPERLY REGISTERED
  getIt.registerSingleton<ReportRemoteDataSource>(
    ReportRemoteDataSourceImpl(getIt()),
  );
  getIt.registerSingleton<ReportRepository>(
    ReportRepositoryImpl(getIt()),
  );
  // Register as Factory so each page gets a fresh instance
  getIt.registerFactory<ReportBloc>(() => ReportBloc(getIt()));

  // Router
  getIt.registerSingleton<AppRouter>(AppRouter(getIt()));
}