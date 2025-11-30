import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gaza_cars/core/error/failures.dart';
import 'package:gaza_cars/features/cars/domain/entities/car_entity.dart';
import 'package:gaza_cars/features/cars/domain/usecases/get_cars_usecase.dart';
import 'package:gaza_cars/features/cars/presentation/bloc/car_bloc.dart';
import 'package:gaza_cars/features/cars/presentation/bloc/car_event.dart';
import 'package:gaza_cars/features/cars/presentation/bloc/car_state.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_helper.dart';

void main() {
  late CarBloc carBloc;
  late MockGetCarsUseCase mockGetCarsUseCase;
  late MockAddCarUseCase mockAddCarUseCase;
  late MockUpdateCarUseCase mockUpdateCarUseCase;
  late MockDeleteCarUseCase mockDeleteCarUseCase;
  late MockUploadCarImagesUseCase mockUploadCarImagesUseCase;
  late MockRateAppService mockRateAppService;

  setUpAll(() {
    registerFallbackValue(MockGetCarsParams());
  });

  setUp(() {
    mockGetCarsUseCase = MockGetCarsUseCase();
    mockAddCarUseCase = MockAddCarUseCase();
    mockUpdateCarUseCase = MockUpdateCarUseCase();
    mockDeleteCarUseCase = MockDeleteCarUseCase();
    mockUploadCarImagesUseCase = MockUploadCarImagesUseCase();
    mockRateAppService = MockRateAppService();

    carBloc = CarBloc(
      mockGetCarsUseCase,
      mockAddCarUseCase,
      mockUpdateCarUseCase,
      mockDeleteCarUseCase,
      mockUploadCarImagesUseCase,
      mockRateAppService,
    );
  });

  tearDown(() {
    carBloc.close();
  });

  final tCar = CarEntity(
    id: '1',
    make: 'Toyota',
    model: 'Corolla',
    year: 2020,
    price: 20000,
    mileage: 50000,
    condition: 'Used',
    location: 'Gaza',
    description: 'Good car',
    images: const ['image1.jpg'],
    sellerId: 'user1',
    sellerPhone: '123456789',
    createdAt: DateTime.now(),
    transmission: 'Automatic',
    fuelType: 'Petrol',
    status: 'active',
  );

  test('initial state should be CarInitial', () {
    expect(carBloc.state, CarInitial());
  });

  group('GetCarsEvent', () {
    blocTest<CarBloc, CarState>(
      'emits [CarLoading, CarLoaded] when data is gotten successfully',
      build: () {
        when(() => mockGetCarsUseCase(any()))
            .thenAnswer((_) async => Right([tCar]));
        return carBloc;
      },
      act: (bloc) => bloc.add(const GetCarsEvent()),
      expect: () => [
        CarLoading(),
        CarLoaded(
          cars: [tCar],
          filteredCars: [tCar],
          hasReachedMax: true, // < 10 items
          isFetchingMore: false,
        ),
      ],
    );

    blocTest<CarBloc, CarState>(
      'emits [CarLoading, CarError] when getting data fails',
      build: () {
        when(() => mockGetCarsUseCase(any()))
            .thenAnswer((_) async => Left(ServerFailure('Server Error')));
        return carBloc;
      },
      act: (bloc) => bloc.add(const GetCarsEvent()),
      expect: () => [
        CarLoading(),
        CarError('Server Error'),
      ],
    );
  });

  group('FilterCarsEvent', () {
    blocTest<CarBloc, CarState>(
      'emits [CarLoading, CarLoaded] with query when filtering',
      build: () {
        when(() => mockGetCarsUseCase(any()))
            .thenAnswer((_) async => Right([tCar]));
        return carBloc;
      },
      act: (bloc) => bloc.add(const FilterCarsEvent('Toyota')),
      expect: () => [
        CarLoading(),
        CarLoaded(
          cars: [tCar],
          filteredCars: [tCar],
          hasReachedMax: true,
          isFetchingMore: false,
          query: 'Toyota',
        ),
      ],
    );
  });
}
