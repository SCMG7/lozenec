part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuth extends AuthEvent {
  const CheckAuth();
}

class Login extends AuthEvent {
  final String email;
  final String password;
  final bool rememberMe;

  const Login({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });

  @override
  List<Object?> get props => [email, password, rememberMe];
}

class Register extends AuthEvent {
  final String fullName;
  final String email;
  final String password;
  final String studioName;
  final String? studioAddress;

  const Register({
    required this.fullName,
    required this.email,
    required this.password,
    required this.studioName,
    this.studioAddress,
  });

  @override
  List<Object?> get props => [fullName, email, password, studioName, studioAddress];
}

class ForgotPassword extends AuthEvent {
  final String email;

  const ForgotPassword({required this.email});

  @override
  List<Object?> get props => [email];
}

class Logout extends AuthEvent {
  const Logout();
}
