// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:creative/core/router/app_router.dart' as _i959;
import 'package:creative/core/router/router_module.dart' as _i127;
import 'package:creative/core/storage/token_storage.dart' as _i812;
import 'package:creative/features/attendance/data/datasources/attendance_remote_datasource.dart'
    as _i93;
import 'package:creative/features/attendance/data/repositories/attendance_repository.dart'
    as _i711;
import 'package:creative/features/attendance/presentation/bloc/attendance_bloc.dart'
    as _i897;
import 'package:creative/features/auth/data/datasources/auth_remote_datasource.dart'
    as _i360;
import 'package:creative/features/auth/data/repositories/auth_repository.dart'
    as _i539;
import 'package:creative/features/auth/presentation/bloc/auth_bloc.dart'
    as _i103;
import 'package:creative/features/groups/data/datasources/group_remote_datasource.dart'
    as _i777;
import 'package:creative/features/groups/data/repositories/group_repository.dart'
    as _i912;
import 'package:creative/features/groups/presentation/bloc/group_bloc.dart'
    as _i734;
import 'package:creative/features/payments/data/datasources/payment_remote_datasource.dart'
    as _i87;
import 'package:creative/features/payments/data/repositories/payment_repository.dart'
    as _i461;
import 'package:creative/features/payments/presentation/bloc/payment_bloc.dart'
    as _i429;
import 'package:creative/features/students/data/repositories/student_repository.dart'
    as _i553;
import 'package:creative/features/teachers/data/datasources/teacher_remote_datasource.dart'
    as _i959;
import 'package:creative/features/teachers/data/repositories/teacher_repository.dart'
    as _i1031;
import 'package:creative/features/teachers/presentation/bloc/teacher_bloc.dart'
    as _i1050;
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final storageModule = _$StorageModule();
    final routerModule = _$RouterModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => storageModule.prefs,
      preResolve: true,
    );
    gh.lazySingleton<_i87.PaymentRemoteDataSource>(
      () => _i87.PaymentRemoteDataSourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i360.AuthRemoteDataSource>(
      () => _i360.AuthRemoteDataSourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i812.TokenStorage>(
      () => _i812.TokenStorage(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i93.AttendanceRemoteDataSource>(
      () => _i93.AttendanceRemoteDataSourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i777.GroupRemoteDataSource>(
      () => _i777.GroupRemoteDataSourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i959.AppRouter>(
      () => routerModule.appRouter(gh<_i812.TokenStorage>()),
    );
    gh.lazySingleton<_i461.PaymentRepository>(
      () => _i461.PaymentRepositoryImpl(gh<_i87.PaymentRemoteDataSource>()),
    );
    gh.lazySingleton<_i959.TeacherRemoteDataSource>(
      () => _i959.TeacherRemoteDataSourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i711.AttendanceRepository>(
      () =>
          _i711.AttendanceRepositoryImpl(gh<_i93.AttendanceRemoteDataSource>()),
    );
    gh.lazySingleton<_i1031.TeacherRepository>(
      () => _i1031.TeacherRepositoryImpl(gh<_i959.TeacherRemoteDataSource>()),
    );
    gh.lazySingleton<_i539.AuthRepository>(
      () => _i539.AuthRepositoryImpl(
        gh<_i360.AuthRemoteDataSource>(),
        gh<_i812.TokenStorage>(),
      ),
    );
    gh.lazySingleton<_i912.GroupRepository>(
      () => _i912.GroupRepositoryImpl(gh<_i777.GroupRemoteDataSource>()),
    );
    gh.factory<_i103.AuthBloc>(
      () => _i103.AuthBloc(gh<_i539.AuthRepository>()),
    );
    gh.factory<_i1050.TeacherBloc>(
      () => _i1050.TeacherBloc(gh<_i1031.TeacherRepository>()),
    );
    gh.factory<_i734.GroupBloc>(
      () => _i734.GroupBloc(
        gh<_i912.GroupRepository>(),
        gh<_i1031.TeacherRepository>(),
      ),
    );
    gh.factory<_i429.PaymentBloc>(
      () => _i429.PaymentBloc(
        gh<_i461.PaymentRepository>(),
        gh<_i553.StudentRepository>(),
        gh<_i912.GroupRepository>(),
      ),
    );
    gh.factory<_i897.AttendanceBloc>(
      () => _i897.AttendanceBloc(
        gh<_i711.AttendanceRepository>(),
        gh<_i912.GroupRepository>(),
        gh<_i553.StudentRepository>(),
      ),
    );
    return this;
  }
}

class _$StorageModule extends _i812.StorageModule {}

class _$RouterModule extends _i127.RouterModule {}
