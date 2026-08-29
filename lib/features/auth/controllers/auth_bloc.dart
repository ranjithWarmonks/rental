import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/login_request_model.dart';
import '../services/auth_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;

  AuthBloc({AuthService? authService})
      : _authService = authService ?? AuthService(),
        super(const AuthState()) {
    on<LoginPhoneChanged>(_onPhoneChanged);
    on<LoginPasswordChanged>(_onPasswordChanged);
    on<TogglePasswordVisibility>(_onTogglePasswordVisibility);
    on<ToggleRememberMe>(_onToggleRememberMe);
    on<LoginSubmitted>(_onLoginSubmitted);
    on<RegisterCompanySubmitted>(_onRegisterCompanySubmitted);
    on<ResetAuthStatus>(_onResetAuthStatus);
  }

  void _onPhoneChanged(LoginPhoneChanged event, Emitter<AuthState> emit) {
    emit(state.copyWith(
      phone: event.phone,
      status: AuthStatus.initial,
      errorMessage: null,
    ));
  }

  void _onPasswordChanged(LoginPasswordChanged event, Emitter<AuthState> emit) {
    emit(state.copyWith(
      password: event.password,
      status: AuthStatus.initial,
      errorMessage: null,
    ));
  }

  void _onTogglePasswordVisibility(
      TogglePasswordVisibility event, Emitter<AuthState> emit) {
    emit(state.copyWith(
      isPasswordObscured: !state.isPasswordObscured,
    ));
  }

  void _onToggleRememberMe(ToggleRememberMe event, Emitter<AuthState> emit) {
    emit(state.copyWith(
      rememberMe: !state.rememberMe,
    ));
  }

  void _onResetAuthStatus(ResetAuthStatus event, Emitter<AuthState> emit) {
    emit(state.copyWith(
      status: AuthStatus.initial,
      errorMessage: null,
    ));
  }

  Future<void> _onLoginSubmitted(
      LoginSubmitted event, Emitter<AuthState> emit) async {
    if (state.phone.trim().isEmpty) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: 'Phone number cannot be empty',
      ));
      return;
    }

    if (state.password.isEmpty) {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: 'Password cannot be empty',
      ));
      return;
    }

    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));

    final request = LoginRequestModel(
      phone: state.phone.trim(),
      password: state.password,
      rememberMe: state.rememberMe,
    );

    final response = await _authService.login(request);

    if (response.success) {
      emit(state.copyWith(
        status: AuthStatus.success,
        user: response.user,
      ));
    } else {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: response.message,
      ));
    }
  }

  Future<void> _onRegisterCompanySubmitted(
      RegisterCompanySubmitted event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));

    final response = await _authService.registerCompany(event.model);

    if (response.success) {
      emit(state.copyWith(
        status: AuthStatus.success,
        user: response.user,
      ));
    } else {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: response.message,
      ));
    }
  }
}
