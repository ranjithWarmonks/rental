import 'package:flutter/foundation.dart';
import '../models/register_company_model.dart';

@immutable
abstract class AuthEvent {
  const AuthEvent();
}

class LoginPhoneChanged extends AuthEvent {
  final String phone;
  const LoginPhoneChanged(this.phone);
}

class LoginPasswordChanged extends AuthEvent {
  final String password;
  const LoginPasswordChanged(this.password);
}

class TogglePasswordVisibility extends AuthEvent {
  const TogglePasswordVisibility();
}

class ToggleRememberMe extends AuthEvent {
  const ToggleRememberMe();
}

class LoginSubmitted extends AuthEvent {
  const LoginSubmitted();
}

class RegisterCompanySubmitted extends AuthEvent {
  final RegisterCompanyModel model;
  const RegisterCompanySubmitted(this.model);
}

class ResetAuthStatus extends AuthEvent {
  const ResetAuthStatus();
}
