import 'package:injectable/injectable.dart';
import '../entities/admin_stats_entity.dart';
import '../repositories/admin_repository.dart';

@lazySingleton
class GetAdminStatsUseCase {
  final AdminRepository repository;

  GetAdminStatsUseCase(this.repository);

  Stream<AdminStatsEntity> call() {
    return repository.getStats();
  }
}
