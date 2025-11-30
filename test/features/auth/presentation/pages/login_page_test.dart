import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gaza_cars/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gaza_cars/features/auth/presentation/bloc/auth_event.dart';
import 'package:gaza_cars/features/auth/presentation/bloc/auth_state.dart';
import 'package:gaza_cars/features/auth/presentation/pages/login_page.dart';
import 'package:gaza_cars/core/di/injection_container.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gaza_cars/l10n/generated/app_localizations.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;

  setUpAll(() {
    // Setup GetIt for dependency injection if needed, or just mock BlocProvider
    // Since LoginPage uses context.read<AuthBloc>(), we can provide it via BlocProvider
    // But if it uses sl<AuthBloc>(), we need GetIt.
    // Checking LoginPage code... it uses BlocProvider in main.dart usually, but let's see.
    // If LoginPage is just a widget, we wrap it.
  });

  setUp(() {
    mockAuthBloc = MockAuthBloc();
  });

  Widget createWidgetUnderTest() {
    return MediaQuery(
      data: const MediaQueryData(size: Size(800, 600)),
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en')],
        home: BlocProvider<AuthBloc>.value(
          value: mockAuthBloc,
          child: const LoginPage(),
        ),
      ),
    );
  }

  testWidgets('renders login form', (tester) async {
    when(() => mockAuthBloc.state).thenReturn(AuthInitial());

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byType(TextFormField), findsNWidgets(2)); // Email & Password
    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
  });

  testWidgets('shows loading indicator when state is AuthLoading', (tester) async {
    when(() => mockAuthBloc.state).thenReturn(AuthLoading());

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows error snackbar when state is AuthError', (tester) async {
    when(() => mockAuthBloc.state).thenReturn(AuthInitial());
    whenListen(
      mockAuthBloc,
      Stream.fromIterable([AuthError('Login Failed')]),
    );

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(); // Trigger listener

    expect(find.text('Login Failed'), findsOneWidget);
  });
}
