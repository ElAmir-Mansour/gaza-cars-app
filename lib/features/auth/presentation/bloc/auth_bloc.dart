import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/google_login_usecase.dart'; // Added import
import '../../domain/usecases/apple_login_usecase.dart'; // Added import
import '../../domain/usecases/send_password_reset_email_usecase.dart';
import '../../../../core/error/failures.dart'; // Added import for Failure
import '../../domain/usecases/delete_account_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final GoogleLoginUseCase googleLoginUseCase; // Added dependency
  final AppleLoginUseCase appleLoginUseCase; // Added dependency
  final SendPasswordResetEmailUseCase sendPasswordResetEmailUseCase;
  final DeleteAccountUseCase deleteAccountUseCase; // Added dependency

  AuthBloc(
    this.loginUseCase,
    this.registerUseCase,
    this.logoutUseCase,
    this.getCurrentUserUseCase,
    this.googleLoginUseCase, // Added to constructor
    this.appleLoginUseCase, // Added to constructor
    this.sendPasswordResetEmailUseCase,
    this.deleteAccountUseCase, // Added to constructor
  ) : super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<AuthGoogleLogin>(_onAuthGoogleLogin); // Added event handler registration
    on<AuthAppleLogin>(_onAuthAppleLogin); // Added event handler registration
    on<ForgotPasswordEvent>(_onForgotPassword);
  }

  Future<void> _onForgotPassword(ForgotPasswordEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await sendPasswordResetEmailUseCase(event.email);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(AuthPasswordResetSent()),
    );
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await loginUseCase(LoginParams(
      email: event.email,
      password: event.password,
    ));
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    print('🔵 Registration started for: ${event.email}');
    emit(AuthLoading());
    final result = await registerUseCase(RegisterParams(
      email: event.email,
      password: event.password,
      name: event.name,
      phone: event.phone,
      role: event.role,
      businessName: event.businessName,
      businessLicense: event.businessLicense,
      taxId: event.taxId,
      businessAddress: event.businessAddress,
    ));
    result.fold(
      (failure) {
        print('🔴 Registration failed: ${failure.message}');
        emit(AuthError(failure.message));
      },
      (user) {
        print('✅ Registration successful: ${user.name}');
        emit(AuthAuthenticated(user));
      },
    );
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await logoutUseCase(NoParams());
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(AuthUnauthenticated()),
    );
  }

  Future<void> _onCheckAuthStatus(CheckAuthStatusEvent event, Emitter<AuthState> emit) async {
    debugPrint('AuthBloc: Checking auth status...');
    final result = await getCurrentUserUseCase(NoParams());
    result.fold(
      (failure) {
        debugPrint('AuthBloc: No user logged in: ${failure.message}');
        emit(AuthUnauthenticated());
      },
      (user) {
        print('✅ User is logged in: ${user.name}');
        emit(AuthAuthenticated(user));
      },
    );
  }
  Future<void> _onAuthGoogleLogin(
    AuthGoogleLogin event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await googleLoginUseCase(NoParams());
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onAuthAppleLogin(
    AuthAppleLogin event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await appleLoginUseCase(NoParams());
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }
}
