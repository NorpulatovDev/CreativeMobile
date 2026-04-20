import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/api_client.dart';
import '../network/connectivity_service.dart';
import '../offline/id_mapping.dart';
import '../offline/sync_engine.dart';
import '../offline/sync_queue.dart';
import '../offline/sync_status_cubit.dart';
import '../offline/temp_id_generator.dart';
import '../router/app_router.dart';
import '../services/sms_service.dart';
import '../storage/token_storage.dart';

// Auth
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

// Teachers
import '../../features/teachers/data/datasources/teacher_remote_datasource.dart';
import '../../features/teachers/data/datasources/teacher_local_datasource.dart';
import '../../features/teachers/data/datasources/teacher_sync_handler.dart';
import '../../features/teachers/data/repositories/teacher_repository.dart';
import '../../features/teachers/presentation/bloc/teacher_bloc.dart';

// Groups
import '../../features/groups/data/datasources/group_remote_datasource.dart';
import '../../features/groups/data/datasources/group_local_datasource.dart';
import '../../features/groups/data/datasources/group_sync_handler.dart';
import '../../features/groups/data/repositories/group_repository.dart';
import '../../features/groups/presentation/bloc/group_bloc.dart';

// Students
import '../../features/students/data/datasources/student_remote_datasource.dart';
import '../../features/students/data/datasources/student_local_datasource.dart';
import '../../features/students/data/datasources/student_sync_handler.dart';
import '../../features/students/data/repositories/student_repository.dart';
import '../../features/students/presentation/bloc/student_bloc.dart';

// Enrollments
import '../../features/enrollments/data/datasources/enrollment_remote_datasource.dart';
import '../../features/enrollments/data/datasources/enrollment_local_datasource.dart';
import '../../features/enrollments/data/datasources/enrollment_sync_handler.dart';
import '../../features/enrollments/data/repositories/enrollment_repository.dart';

// Payments
import '../../features/payments/data/datasources/payment_remote_datasource.dart';
import '../../features/payments/data/datasources/payment_local_datasource.dart';
import '../../features/payments/data/datasources/payment_sync_handler.dart';
import '../../features/payments/data/repositories/payment_repository.dart';
import '../../features/payments/presentation/bloc/payment_bloc.dart';

// Attendance
import '../../features/attendance/data/datasources/attendance_remote_datasource.dart';
import '../../features/attendance/data/datasources/attendance_local_datasource.dart';
import '../../features/attendance/data/datasources/attendance_sync_handler.dart';
import '../../features/attendance/data/repositories/attendance_repository.dart';
import '../../features/attendance/presentation/bloc/attendance_bloc.dart';

// Reports
import '../../features/reports/data/datasources/report_remote_datasource.dart';
import '../../features/reports/data/datasources/report_local_datasource.dart';
import '../../features/reports/data/repositories/report_repository.dart';
import '../../features/reports/presentation/bloc/report_bloc.dart';

// Inquiries
import '../../features/inquiries/data/datasources/inquiry_remote_datasource.dart';
import '../../features/inquiries/data/datasources/inquiry_local_datasource.dart';
import '../../features/inquiries/data/datasources/inquiry_sync_handler.dart';
import '../../features/inquiries/data/repositories/inquiry_repository.dart';
import '../../features/inquiries/presentation/bloc/inquiry_bloc.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // External
  final sharedPrefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPrefs);

  // Core
  getIt.registerSingleton<TokenStorage>(TokenStorageImpl(getIt()));
  getIt.registerSingleton<ApiClient>(ApiClient(getIt()));

  // Offline Infrastructure
  final connectivityService = ConnectivityService();
  await connectivityService.initialize();
  getIt.registerSingleton<ConnectivityService>(connectivityService);

  final syncQueue = SyncQueue();
  await syncQueue.initialize();
  getIt.registerSingleton<SyncQueue>(syncQueue);

  final idMapping = IdMappingService();
  await idMapping.initialize();
  getIt.registerSingleton<IdMappingService>(idMapping);

  getIt.registerSingleton<TempIdGenerator>(TempIdGenerator());

  // Local Data Sources
  final studentLocal = StudentLocalDataSource();
  await studentLocal.initialize();
  getIt.registerSingleton<StudentLocalDataSource>(studentLocal);

  final teacherLocal = TeacherLocalDataSource();
  await teacherLocal.initialize();
  getIt.registerSingleton<TeacherLocalDataSource>(teacherLocal);

  final groupLocal = GroupLocalDataSource();
  await groupLocal.initialize();
  getIt.registerSingleton<GroupLocalDataSource>(groupLocal);

  final paymentLocal = PaymentLocalDataSource();
  await paymentLocal.initialize();
  getIt.registerSingleton<PaymentLocalDataSource>(paymentLocal);

  final attendanceLocal = AttendanceLocalDataSource();
  await attendanceLocal.initialize();
  getIt.registerSingleton<AttendanceLocalDataSource>(attendanceLocal);

  final enrollmentLocal = EnrollmentLocalDataSource();
  await enrollmentLocal.initialize();
  getIt.registerSingleton<EnrollmentLocalDataSource>(enrollmentLocal);

  final inquiryLocal = InquiryLocalDataSource();
  await inquiryLocal.initialize();
  getIt.registerSingleton<InquiryLocalDataSource>(inquiryLocal);

  final reportLocal = ReportLocalDataSource();
  await reportLocal.initialize();
  getIt.registerSingleton<ReportLocalDataSource>(reportLocal);

  // Auth Feature (no offline writes)
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
    TeacherRepositoryImpl(getIt(), getIt(), getIt(), getIt(), getIt()),
  );
  getIt.registerFactory<TeacherBloc>(() => TeacherBloc(getIt()));

  // Groups Feature
  getIt.registerSingleton<GroupRemoteDataSource>(
    GroupRemoteDataSourceImpl(getIt()),
  );
  getIt.registerSingleton<GroupRepository>(
    GroupRepositoryImpl(getIt(), getIt(), getIt(), getIt(), getIt()),
  );
  getIt.registerFactory<GroupBloc>(() => GroupBloc(getIt()));

  // Students Feature
  getIt.registerSingleton<StudentRemoteDataSource>(
    StudentRemoteDataSourceImpl(getIt()),
  );
  getIt.registerSingleton<StudentRepository>(
    StudentRepositoryImpl(getIt(), getIt(), getIt(), getIt(), getIt()),
  );
  getIt.registerFactory<StudentBloc>(() => StudentBloc(getIt()));

  // Enrollments Feature
  getIt.registerSingleton<EnrollmentRemoteDataSource>(
    EnrollmentRemoteDataSourceImpl(getIt()),
  );
  getIt.registerSingleton<EnrollmentRepository>(
    EnrollmentRepositoryImpl(getIt(), getIt(), getIt(), getIt(), getIt()),
  );

  // Payments Feature
  getIt.registerSingleton<PaymentRemoteDataSource>(
    PaymentRemoteDataSourceImpl(getIt()),
  );
  getIt.registerSingleton<PaymentRepository>(
    PaymentRepositoryImpl(getIt(), getIt(), getIt(), getIt(), getIt()),
  );
  getIt.registerFactory<PaymentBloc>(() => PaymentBloc(getIt()));

  // Attendance Feature
  getIt.registerSingleton<AttendanceRemoteDataSource>(
    AttendanceRemoteDataSourceImpl(getIt()),
  );
  getIt.registerSingleton<AttendanceRepository>(
    AttendanceRepositoryImpl(getIt(), getIt(), getIt(), getIt(), getIt()),
  );
  getIt.registerFactory<AttendanceBloc>(() => AttendanceBloc(getIt()));

  // Reports Feature (read-only cache, no sync)
  getIt.registerSingleton<ReportRemoteDataSource>(
    ReportRemoteDataSourceImpl(getIt()),
  );
  getIt.registerSingleton<ReportRepository>(
    ReportRepositoryImpl(getIt(), getIt(), getIt()),
  );
  getIt.registerFactory<ReportBloc>(() => ReportBloc(getIt()));

  // Inquiries Feature
  getIt.registerSingleton<InquiryRemoteDataSource>(
    InquiryRemoteDataSourceImpl(getIt()),
  );
  getIt.registerSingleton<InquiryRepository>(
    InquiryRepositoryImpl(getIt(), getIt(), getIt(), getIt(), getIt()),
  );
  getIt.registerFactory<InquiryBloc>(() => InquiryBloc(getIt()));

  // Sync Engine
  final syncEngine = SyncEngine(
    queue: getIt(),
    connectivity: getIt(),
    idMapping: getIt(),
  );
  syncEngine.registerHandler(
      StudentSyncHandler(getIt(), getIt()));
  syncEngine.registerHandler(
      TeacherSyncHandler(getIt(), getIt()));
  syncEngine.registerHandler(
      GroupSyncHandler(getIt(), getIt()));
  syncEngine.registerHandler(
      PaymentSyncHandler(getIt(), getIt()));
  syncEngine.registerHandler(
      AttendanceSyncHandler(getIt(), getIt()));
  syncEngine.registerHandler(
      EnrollmentSyncHandler(getIt(), getIt()));
  syncEngine.registerHandler(
      InquirySyncHandler(getIt(), getIt()));
  syncEngine.start();
  getIt.registerSingleton<SyncEngine>(syncEngine);

  // Sync Status Cubit
  getIt.registerSingleton<SyncStatusCubit>(
    SyncStatusCubit(connectivity: getIt(), syncEngine: getIt()),
  );

  // SMS
  getIt.registerSingleton<SmsService>(SmsService());

  // Router
  getIt.registerSingleton<AppRouter>(AppRouter(getIt()));
}
