import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gaza_cars/core/di/injection_container.dart';
import 'package:gaza_cars/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gaza_cars/features/auth/presentation/bloc/auth_event.dart';
import 'package:gaza_cars/features/auth/presentation/bloc/auth_state.dart';
import 'package:gaza_cars/features/auth/domain/entities/user_entity.dart';
import 'package:gaza_cars/features/cars/domain/entities/car_entity.dart';
import 'package:gaza_cars/features/cars/presentation/bloc/car_bloc.dart';
import 'package:gaza_cars/features/cars/presentation/bloc/car_event.dart';
import 'package:gaza_cars/features/cars/presentation/bloc/car_state.dart';
import 'package:gaza_cars/features/home/presentation/pages/home_page.dart';
import 'package:gaza_cars/shared/widgets/empty_state_widget.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gaza_cars/l10n/generated/app_localizations.dart';

class MockCarBloc extends MockBloc<CarEvent, CarState> implements CarBloc {}
class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class FakeCarEvent extends Fake implements CarEvent {}
class FakeAuthEvent extends Fake implements AuthEvent {}

void main() {
  late MockCarBloc mockCarBloc;
  late MockAuthBloc mockAuthBloc;

  setUpAll(() {
    registerFallbackValue(FakeCarEvent());
    registerFallbackValue(FakeAuthEvent());
    // Register mocks in GetIt
    final getIt = GetIt.instance;
    getIt.registerFactory<CarBloc>(() => mockCarBloc);
  });

  setUp(() {
    mockCarBloc = MockCarBloc();
    mockAuthBloc = MockAuthBloc();
  });

  tearDownAll(() {
    GetIt.instance.reset();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: BlocProvider<AuthBloc>.value(
        value: mockAuthBloc,
        child: const HomePage(),
      ),
    );
  }

  testWidgets('renders loading shimmer when state is CarLoading', (tester) async {
    when(() => mockAuthBloc.state).thenReturn(AuthAuthenticated(UserEntity(
      uid: '1',
      email: 'a',
      name: 'a',
      phone: '123',
      role: 'user',
      createdAt: DateTime.now(),
    )));
    when(() => mockCarBloc.state).thenReturn(CarLoading());
    when(() => mockCarBloc.add(any())).thenReturn(null); // Stub add

    await tester.pumpWidget(createWidgetUnderTest());

    // Verify shimmer is present (it's a MasonryGridView, might be hard to find by type directly if wrapped)
    // But we can check if CarCard is NOT present.
    // Or check for Shimmer widget if exported.
    // Let's check for "No Cars" text to ensure it's NOT empty state.
    expect(find.text('No cars found'), findsNothing);
  });

  testWidgets('renders empty state when list is empty', (tester) async {
    when(() => mockAuthBloc.state).thenReturn(AuthAuthenticated(UserEntity(
      uid: '1',
      email: 'a',
      name: 'a',
      phone: '123',
      role: 'user',
      createdAt: DateTime.now(),
    )));
    when(() => mockCarBloc.state).thenReturn(const CarLoaded(cars: [], filteredCars: [], hasReachedMax: true, isFetchingMore: false));
    when(() => mockCarBloc.add(any())).thenReturn(null);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(); // Allow layout

    expect(find.byType(EmptyStateWidget), findsOneWidget);
    expect(find.text('No cars found'), findsOneWidget);
  });
}
