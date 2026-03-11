import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(const AuthInitial()) {
    on<CheckAuth>(_onCheckAuth);
    on<Login>(_onLogin);
    on<Register>(_onRegister);
    on<ForgotPassword>(_onForgotPassword);
    on<Logout>(_onLogout);
  }

  Future<void> _onCheckAuth(CheckAuth event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    // Check if user chose "remember me"
    final remembered = await authRepository.isRemembered();
    if (!remembered) {
      emit(const Unauthenticated());
      return;
    }

    // Try to verify the token with the backend
    try {
      final user = await authRepository.verifyToken();
      emit(Authenticated(user: user));
    } on DioException catch (_) {
      // Network error or expired token — try cached user as fallback
      final cachedUser = await authRepository.getCachedUser();
      if (cachedUser != null) {
        emit(Authenticated(user: cachedUser));
      } else {
        emit(const Unauthenticated());
      }
    } catch (_) {
      emit(const Unauthenticated());
    }
  }

  Future<void> _onLogin(Login event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final user = await authRepository.login(
        email: event.email,
        password: event.password,
        rememberMe: event.rememberMe,
      );
      emit(Authenticated(user: user));
    } on DioException catch (e) {
      final message = _extractErrorMessage(e);
      emit(AuthError(message: message));
    } catch (_) {
      emit(const AuthError(message: 'network_error'));
    }
  }

  Future<void> _onRegister(Register event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final user = await authRepository.register(
        fullName: event.fullName,
        email: event.email,
        password: event.password,
      );
      emit(Authenticated(user: user));
    } on DioException catch (e) {
      final message = _extractErrorMessage(e);
      emit(AuthError(message: message));
    } catch (_) {
      emit(const AuthError(message: 'network_error'));
    }
  }

  Future<void> _onForgotPassword(
      ForgotPassword event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      await authRepository.forgotPassword(email: event.email);
      emit(const ForgotPasswordSuccess());
    } on DioException catch (e) {
      final message = _extractErrorMessage(e);
      emit(AuthError(message: message));
    } catch (_) {
      emit(const AuthError(message: 'network_error'));
    }
  }

  Future<void> _onLogout(Logout event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    await authRepository.logout();
    emit(const Unauthenticated());
  }

  String _extractErrorMessage(DioException e) {
    if (e.response?.data != null && e.response!.data is Map) {
      final data = e.response!.data as Map<String, dynamic>;
      if (data.containsKey('error')) {
        return data['error'] as String;
      }
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return 'network_error';
    }
    return 'unknown_error';
  }
}
