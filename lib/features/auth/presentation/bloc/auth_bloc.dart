import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import '../../data/repositories/auth_repository.dart';

part 'auth_bloc.freezed.dart';

// Events
@freezed
class AuthEvent with _$AuthEvent {
  const factory AuthEvent.checkStatus() = AuthCheckStatus;
  const factory AuthEvent.login({
    required String username,
    required String password,
  }) = AuthLogin;
  const factory AuthEvent.logout() = AuthLogout;
}

// States
@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = AuthInitial;
  const factory AuthState.loading() = AuthLoading;
  const factory AuthState.authenticated({required String username}) = AuthAuthenticated;
  const factory AuthState.unauthenticated() = AuthUnauthenticated;
  const factory AuthState.error({required String message}) = AuthError;
}

// Bloc
@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(const AuthState.initial()) {
    on<AuthCheckStatus>(_onCheckStatus);
    on<AuthLogin>(_onLogin);
    on<AuthLogout>(_onLogout);
  }

  Future<void> _onCheckStatus(
    AuthCheckStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    final isLoggedIn = await _authRepository.isLoggedIn();
    if (isLoggedIn) {
      emit(const AuthState.authenticated(username: 'User'));
    } else {
      emit(const AuthState.unauthenticated());
    }
  }

  Future<void> _onLogin(
    AuthLogin event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    try {
      final response = await _authRepository.login(event.username, event.password);
      emit(AuthState.authenticated(username: response.username));
    } catch (e) {
      emit(AuthState.error(message: _mapError(e)));
    }
  }

  Future<void> _onLogout(
    AuthLogout event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.logout();
    emit(const AuthState.unauthenticated());
  }

  String _mapError(dynamic error) {
    if (error.toString().contains('401')) {
      return 'Invalid username or password';
    }
    if (error.toString().contains('SocketException')) {
      return 'No internet connection';
    }
    return 'Something went wrong. Please try again.';
  }
}