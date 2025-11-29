import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:gaza_cars/features/cars/data/datasources/car_remote_data_source.dart';
import 'package:gaza_cars/features/cars/domain/entities/car_entity.dart';

void main() {
  late CarRemoteDataSourceImpl dataSource;
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseStorage mockStorage;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    mockStorage = MockFirebaseStorage();
    dataSource = CarRemoteDataSourceImpl(
      firestore: fakeFirestore,
      storage: mockStorage,
    );
  });

  group('CarRemoteDataSource Query Tests', () {
    test('should construct query with single filter correctly', () async {
      // Arrange
      await dataSource.addCar(CarEntity(
        id: '1',
        sellerId: 'user1',
        sellerPhone: '123',
        make: 'Toyota',
        model: 'Camry',
        year: 2020,
        price: 20000,
        mileage: 10000,
        condition: 'Used',
        location: 'Gaza',
        images: [],
        status: 'active',
        createdAt: DateTime.now(),
      ));

      // Act
      final result = await dataSource.getCars(make: 'Toyota');

      // Assert
      expect(result.length, 1);
      expect(result.first.make, 'Toyota');
    });

    test('should construct query with multiple filters correctly', () async {
      // Arrange
      await dataSource.addCar(CarEntity(
        id: '1',
        sellerId: 'user1',
        sellerPhone: '123',
        make: 'Toyota',
        model: 'Camry',
        year: 2020,
        price: 20000,
        mileage: 10000,
        condition: 'Used',
        location: 'Gaza',
        images: [],
        status: 'active',
        createdAt: DateTime.now(),
      ));

      // Act
      final result = await dataSource.getCars(
        make: 'Toyota',
        condition: 'Used',
        minPrice: 15000,
        maxPrice: 25000,
      );

      // Assert
      expect(result.length, 1);
    });

    test('should return empty list when filters do not match', () async {
      // Arrange
      await dataSource.addCar(CarEntity(
        id: '1',
        sellerId: 'user1',
        sellerPhone: '123',
        make: 'Toyota',
        model: 'Camry',
        year: 2020,
        price: 20000,
        mileage: 10000,
        condition: 'Used',
        location: 'Gaza',
        images: [],
        status: 'active',
        createdAt: DateTime.now(),
      ));

      // Act
      final result = await dataSource.getCars(make: 'Honda');

      // Assert
      expect(result.isEmpty, true);
    });
  });
}
