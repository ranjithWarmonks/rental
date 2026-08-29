import 'package:flutter/foundation.dart';
import '../models/login_request_model.dart';

enum AuthStatus { initial, loading, success, failure }

@immutable
class AuthState {
  final String phone;
  final String password;
  final bool isPasswordObscured;
  final bool rememberMe;
  final AuthStatus status;
  final String? errorMessage;
  final UserModel? user;

  const AuthState({
    this.phone = '',
    this.password = '',
    this.isPasswordObscured = true,
    this.rememberMe = false,
    this.status = AuthStatus.initial,
    this.errorMessage,
    this.user,
  });

  AuthState copyWith({
    String? phone,
    String? password,
    bool? isPasswordObscured,
    bool? rememberMe,
    AuthStatus? status,
    String? errorMessage,
    UserModel? user,
  }) {
    return AuthState(
      phone: phone ?? this.phone,
      password: password ?? this.password,
      isPasswordObscured: isPasswordObscured ?? this.isPasswordObscured,
      rememberMe: rememberMe ?? this.rememberMe,
      status: status ?? this.status,
      errorMessage: errorMessage,
      user: user ?? this.user,
    );
  }
}
