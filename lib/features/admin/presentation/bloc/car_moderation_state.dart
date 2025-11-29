import 'package:equatable/equatable.dart';
import '../../../cars/domain/entities/car_entity.dart';

abstract class CarModerationState extends Equatable {
  const CarModerationState();

  @override
  List<Object?> get props => [];
}

class CarModerationInitial extends CarModerationState {}

class CarModerationLoading extends CarModerationState {}

class CarModerationLoaded extends CarModerationState {
  final List<CarEntity> pendingCars;

  const CarModerationLoaded(this.pendingCars);

  @override
  List<Object?> get props => [pendingCars];
}

class CarModerationActionSuccess extends CarModerationState {
  final String message;

  const CarModerationActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class CarModerationError extends CarModerationState {
  final String message;

  const CarModerationError(this.message);

  @override
  List<Object?> get props => [message];
}
