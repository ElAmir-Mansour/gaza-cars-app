import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/car_repository.dart';

@lazySingleton
class ToggleFavoriteUseCase implements UseCase<void, ToggleFavoriteParams> {
  final CarRepository repository;

  ToggleFavoriteUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(ToggleFavoriteParams params) async {
    return await repository.toggleFavorite(params.carId, params.userId);
  }
}

class ToggleFavoriteParams extends Equatable {
  final String carId;
  final String userId;

  const ToggleFavoriteParams({required this.carId, required this.userId});

  @override
  List<Object> get props => [carId, userId];
}
