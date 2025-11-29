import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../cars/domain/entities/car_entity.dart';
import '../entities/admin_stats_entity.dart';

abstract class AdminRepository {
  // Analytics
  Stream<AdminStatsEntity> getStats();

  // Car Moderation
  Future<Either<Failure, List<CarEntity>>> getPendingCars();
  Future<Either<Failure, void>> approveCar(String carId);
  Future<Either<Failure, void>> rejectCar(String carId, String reason);

  // User Management
  Future<Either<Failure, List<UserEntity>>> getAllUsers();
  Future<Either<Failure, void>> banUser(String userId, String reason);
  Future<Either<Failure, void>> unbanUser(String userId);
}
