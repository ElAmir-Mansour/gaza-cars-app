import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/car_entity.dart';
import '../repositories/car_repository.dart';

@lazySingleton
class GetFavoritesUseCase implements UseCase<List<CarEntity>, GetFavoritesParams> {
  final CarRepository repository;

  GetFavoritesUseCase(this.repository);

  @override
  Future<Either<Failure, List<CarEntity>>> call(GetFavoritesParams params) async {
    return await repository.getFavorites(params.userId);
  }
}

class GetFavoritesParams extends Equatable {
  final String userId;

  const GetFavoritesParams({required this.userId});

  @override
  List<Object> get props => [userId];
}
