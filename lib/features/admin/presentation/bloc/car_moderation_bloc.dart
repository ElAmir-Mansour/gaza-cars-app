import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/approve_car_usecase.dart';
import '../../domain/usecases/get_pending_cars_usecase.dart';
import '../../domain/usecases/reject_car_usecase.dart';
import 'car_moderation_event.dart';
import 'car_moderation_state.dart';

@injectable
class CarModerationBloc extends Bloc<CarModerationEvent, CarModerationState> {
  final GetPendingCarsUseCase getPendingCarsUseCase;
  final ApproveCarUseCase approveCarUseCase;
  final RejectCarUseCase rejectCarUseCase;

  CarModerationBloc({
    required this.getPendingCarsUseCase,
    required this.approveCarUseCase,
    required this.rejectCarUseCase,
  }) : super(CarModerationInitial()) {
    on<LoadPendingCars>(_onLoadPendingCars);
    on<ApproveCar>(_onApproveCar);
    on<RejectCar>(_onRejectCar);
  }

  Future<void> _onLoadPendingCars(
      LoadPendingCars event, Emitter<CarModerationState> emit) async {
    emit(CarModerationLoading());
    final result = await getPendingCarsUseCase();
    result.fold(
      (failure) => emit(CarModerationError(failure.message)),
      (cars) => emit(CarModerationLoaded(cars)),
    );
  }

  Future<void> _onApproveCar(
      ApproveCar event, Emitter<CarModerationState> emit) async {
    final result = await approveCarUseCase(event.carId);
    result.fold(
      (failure) => emit(CarModerationError(failure.message)),
      (_) {
        emit(const CarModerationActionSuccess('Car approved successfully'));
        add(LoadPendingCars()); // Reload pending cars
      },
    );
  }

  Future<void> _onRejectCar(
      RejectCar event, Emitter<CarModerationState> emit) async {
    final result = await rejectCarUseCase(event.carId, event.reason);
    result.fold(
      (failure) => emit(CarModerationError(failure.message)),
      (_) {
        emit(const CarModerationActionSuccess('Car rejected'));
        add(LoadPendingCars()); // Reload pending cars
      },
    );
  }
}
