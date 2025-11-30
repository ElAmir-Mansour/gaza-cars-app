import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gaza_cars/core/error/failures.dart';
import 'package:gaza_cars/core/usecases/usecase.dart';
import 'package:gaza_cars/features/auth/domain/entities/user_entity.dart';
import 'package:gaza_cars/features/auth/domain/usecases/login_usecase.dart';
import 'package:gaza_cars/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gaza_cars/features/auth/presentation/bloc/auth_event.dart';
import 'package:gaza_cars/features/auth/presentation/bloc/auth_state.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_helper.dart';

void main() {
  late AuthBloc authBloc;
  late MockLoginUseCase mockLoginUseCase;
  late MockRegisterUseCase mockRegisterUseCase;
  late MockLogoutUseCase mockLogoutUseCase;
  late MockGetCurrentUserUseCase mockGetCurrentUserUseCase;
  late MockGoogleLoginUseCase mockGoogleLoginUseCase;
  late MockAppleLoginUseCase mockAppleLoginUseCase;
  late MockSendPasswordResetEmailUseCase mockSendPasswordResetEmailUseCase;
  late MockDeleteAccountUseCase mockDeleteAccountUseCase;

  setUpAll(() {
    registerFallbackValue(MockLoginParams());
    registerFallbackValue(MockRegisterParams());
    registerFallbackValue(NoParams());
  });

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    mockRegisterUseCase = MockRegisterUseCase();
    mockLogoutUseCase = MockLogoutUseCase();
    mockGetCurrentUserUseCase = MockGetCurrentUserUseCase();
    mockGoogleLoginUseCase = MockGoogleLoginUseCase();
    mockAppleLoginUseCase = MockAppleLoginUseCase();
    mockSendPasswordResetEmailUseCase = MockSendPasswordResetEmailUseCase();
    mockDeleteAccountUseCase = MockDeleteAccountUseCase();

    authBloc = AuthBloc(
      mockLoginUseCase,
      mockRegisterUseCase,
      mockLogoutUseCase,
      mockGetCurrentUserUseCase,
      mockGoogleLoginUseCase,
      mockAppleLoginUseCase,
      mockSendPasswordResetEmailUseCase,
      mockDeleteAccountUseCase,
    );
  });

  tearDown(() {
    authBloc.close();
  });

  final tUser = UserEntity(
    uid: '123',
    email: 'test@example.com',
    name: 'Test User',
    phone: '1234567890',
    role: 'user',
    createdAt: DateTime.now(),
  );

  test('initial state should be AuthInitial', () {
    expect(authBloc.state, AuthInitial());
  });

  group('CheckAuthStatusEvent', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthAuthenticated] when user is logged in',
      build: () {
        when(() => mockGetCurrentUserUseCase(any()))
            .thenAnswer((_) async => const Right(tUser));
        return authBloc;
      },
      act: (bloc) => bloc.add(CheckAuthStatusEvent()),
      expect: () => [AuthAuthenticated(tUser)],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthUnauthenticated] when no user is logged in',
      build: () {
        when(() => mockGetCurrentUserUseCase(any()))
            .thenAnswer((_) async => Left(CacheFailure('No user')));
        return authBloc;
      },
      act: (bloc) => bloc.add(CheckAuthStatusEvent()),
      expect: () => [AuthUnauthenticated()],
    );
  });

  group('LoginEvent', () {
    const tEmail = 'test@example.com';
    const tPassword = 'password';

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when login is successful',
      build: () {
        when(() => mockLoginUseCase(any()))
            .thenAnswer((_) async => const Right(tUser));
        return authBloc;
      },
      act: (bloc) => bloc.add(LoginEvent(email: tEmail, password: tPassword)),
      expect: () => [
        AuthLoading(),
        AuthAuthenticated(tUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when login fails',
      build: () {
        when(() => mockLoginUseCase(any()))
            .thenAnswer((_) async => Left(ServerFailure('Login failed')));
        return authBloc;
      },
      act: (bloc) => bloc.add(LoginEvent(email: tEmail, password: tPassword)),
      expect: () => [
        AuthLoading(),
        AuthError('Login failed'),
      ],
    );
  });

  group('LogoutEvent', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] when logout is successful',
      build: () {
        when(() => mockLogoutUseCase(any()))
            .thenAnswer((_) async => const Right(null));
        return authBloc;
      },
      act: (bloc) => bloc.add(LogoutEvent()),
      expect: () => [
        AuthLoading(),
        AuthUnauthenticated(),
      ],
    );
  });
}
