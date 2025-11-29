import 'package:equatable/equatable.dart';

abstract class CarModerationEvent extends Equatable {
  const CarModerationEvent();

  @override
  List<Object?> get props => [];
}

class LoadPendingCars extends CarModerationEvent {}

class ApproveCar extends CarModerationEvent {
  final String carId;

  const ApproveCar(this.carId);

  @override
  List<Object?> get props => [carId];
}

class RejectCar extends CarModerationEvent {
  final String carId;
  final String reason;

  const RejectCar(this.carId, this.reason);

  @override
  List<Object?> get props => [carId, reason];
}
