import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../cars/domain/entities/car_entity.dart';
import '../../domain/entities/admin_stats_entity.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_remote_data_source.dart';

@LazySingleton(as: AdminRepository)
class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource remoteDataSource;
  final FirebaseAuth auth;

  AdminRepositoryImpl({
    required this.remoteDataSource,
    required this.auth,
  });

  @override
  Stream<AdminStatsEntity> getStats() {
    return remoteDataSource.getStats();
  }

  @override
  Future<Either<Failure, List<CarEntity>>> getPendingCars() async {
    try {
      final cars = await remoteDataSource.getPendingCars();
      return Right(cars);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> approveCar(String carId) async {
    try {
      final adminId = auth.currentUser?.uid;
      if (adminId == null) {
        return const Left(ServerFailure('Not authenticated'));
      }
      await remoteDataSource.approveCar(carId, adminId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> rejectCar(String carId, String reason) async {
    try {
      final adminId = auth.currentUser?.uid;
      if (adminId == null) {
        return const Left(ServerFailure('Not authenticated'));
      }
      await remoteDataSource.rejectCar(carId, adminId, reason);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<UserEntity>>> getAllUsers() async {
    try {
      final usersData = await remoteDataSource.getAllUsers();
      final users = usersData.map((data) => UserEntity(
        uid: data['id'] ?? '',
        name: data['name'] ?? '',
        email: data['email'] ?? '',
        phone: data['phone'] ?? '',
        role: data['role'] ?? 'buyer',
        createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
        businessName: data['businessName'],
        businessLicense: data['businessLicense'],
        taxId: data['taxId'],
        businessAddress: data['businessAddress'],
        isBanned: data['isBanned'] ?? false,
        bannedAt: data['bannedAt']?.toDate(),
        bannedBy: data['bannedBy'],
        banReason: data['banReason'],
      )).toList();
      return Right(users);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> banUser(String userId, String reason) async {
    try {
      print('📦 Repo: Getting admin ID...');
      final adminId = auth.currentUser?.uid;
      if (adminId == null) {
        print('❌ Repo: Not authenticated');
        return const Left(ServerFailure('Not authenticated'));
      }
      print('📦 Repo: Admin ID: $adminId, calling data source...');
      await remoteDataSource.banUser(userId, adminId, reason);
      print('✅ Repo: Ban user completed');
      return const Right(null);
    } on ServerException catch (e) {
      print('❌ Repo: Ban user failed - ${e.message}');
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> unbanUser(String userId) async {
    try {
      await remoteDataSource.unbanUser(userId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
