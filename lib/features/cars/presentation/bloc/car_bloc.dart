import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecases/add_car_usecase.dart';
import '../../domain/usecases/delete_car_usecase.dart';
import '../../domain/usecases/get_cars_usecase.dart';
import '../../domain/usecases/update_car_usecase.dart';
import '../../domain/usecases/upload_car_images_usecase.dart';
import 'car_event.dart';
import 'car_state.dart';

@injectable
class CarBloc extends Bloc<CarEvent, CarState> {
  final GetCarsUseCase getCarsUseCase;
  final AddCarUseCase addCarUseCase;
  final UpdateCarUseCase updateCarUseCase;
  final DeleteCarUseCase deleteCarUseCase;
  final UploadCarImagesUseCase uploadCarImagesUseCase;

  CarBloc(
    this.getCarsUseCase,
    this.addCarUseCase,
    this.updateCarUseCase,
    this.deleteCarUseCase,
    this.uploadCarImagesUseCase,
  ) : super(CarInitial()) {
    on<GetCarsEvent>(_onGetCars);
    on<AddCarEvent>(_onAddCar);
    on<UpdateCarEvent>(_onUpdateCar);
    on<DeleteCarEvent>(_onDeleteCar);
    on<UploadCarImagesEvent>(_onUploadCarImages);
    on<FilterCarsEvent>(_onFilterCars);
    on<ApplyFiltersEvent>(_onApplyFilters);
  }

  Future<void> _onGetCars(GetCarsEvent event, Emitter<CarState> emit) async {
    try {
      // Read filters from state
      double? minPrice;
      double? maxPrice;
      String? condition;
      String? location;
      String? query;
      String? transmission;
      String? fuelType;
      String? make;
      int? year;

      if (state is CarLoaded) {
        final currentState = state as CarLoaded;
        minPrice = currentState.minPrice;
        maxPrice = currentState.maxPrice;
        condition = currentState.condition;
        location = currentState.location;
        query = currentState.query;
        transmission = currentState.transmission;
        fuelType = currentState.fuelType;
        make = currentState.make;
        year = currentState.year;
      }

      if (state is CarLoaded && event.loadMore) {
        final currentState = state as CarLoaded;
        if (currentState.hasReachedMax || currentState.isFetchingMore) return;

        emit(currentState.copyWith(isFetchingMore: true));

        final lastCar = currentState.cars.last;
        
        final result = await getCarsUseCase(GetCarsParams(
          startAfterValues: [lastCar.createdAt],
          minPrice: minPrice,
          maxPrice: maxPrice,
          condition: condition,
          location: location,
          query: query,
          transmission: transmission,
          fuelType: fuelType,
          make: make,
          year: year,
        ));
        
        result.fold(
          (failure) => emit(CarError(failure.message)),
          (newCars) {
            if (newCars.isEmpty) {
              emit(currentState.copyWith(hasReachedMax: true, isFetchingMore: false));
            } else {
              emit(currentState.copyWith(
                cars: List.of(currentState.cars)..addAll(newCars),
                filteredCars: List.of(currentState.cars)..addAll(newCars),
                hasReachedMax: newCars.length < 10,
                isFetchingMore: false,
              ));
            }
          },
        );
      } else {
        emit(CarLoading());
        final result = await getCarsUseCase(GetCarsParams(
          minPrice: minPrice,
          maxPrice: maxPrice,
          condition: condition,
          location: location,
          query: query,
          transmission: transmission,
          fuelType: fuelType,
          make: make,
          year: year,
        ));
        result.fold(
          (failure) => emit(CarError(failure.message)),
          (cars) {
            emit(CarLoaded(
              cars: cars, 
              filteredCars: cars,
              hasReachedMax: cars.length < 10,
              isFetchingMore: false,
              minPrice: minPrice,
              maxPrice: maxPrice,
              condition: condition,
              location: location,
              query: query,
              transmission: transmission,
              fuelType: fuelType,
              make: make,
              year: year,
            ));
          },
        );
      }
    } catch (e) {
      print('❌ Unexpected error in _onGetCars: $e');
      emit(CarError(e.toString()));
    }
  }

  Future<void> _onAddCar(AddCarEvent event, Emitter<CarState> emit) async {
    emit(CarLoading());
    final result = await addCarUseCase(event.car);
    result.fold(
      (failure) => emit(CarError(failure.message)),
      (_) => add(const GetCarsEvent()), 
    );
  }

  Future<void> _onUpdateCar(UpdateCarEvent event, Emitter<CarState> emit) async {
    emit(CarLoading());
    final result = await updateCarUseCase(event.car);
    result.fold(
      (failure) => emit(CarError(failure.message)),
      (_) {
        emit(const CarOperationSuccess('Car updated successfully'));
        add(const GetCarsEvent()); 
      },
    );
  }

  Future<void> _onDeleteCar(DeleteCarEvent event, Emitter<CarState> emit) async {
    emit(CarLoading());
    final result = await deleteCarUseCase(event.id);
    result.fold(
      (failure) => emit(CarError(failure.message)),
      (_) {
        emit(const CarOperationSuccess('Car deleted successfully'));
        add(const GetCarsEvent()); 
      },
    );
  }

  Future<void> _onUploadCarImages(UploadCarImagesEvent event, Emitter<CarState> emit) async {
    debugPrint('CarBloc: UploadCarImagesEvent received with ${event.images.length} images');
    emit(CarLoading());
    try {
      final result = await uploadCarImagesUseCase(UploadCarImagesParams(images: event.images));
      result.fold(
        (failure) {
          debugPrint('❌ Image upload failed: ${failure.message}');
          emit(const CarImagesUploaded([])); 
        },
        (imageUrls) {
          print('✅ Images uploaded successfully: $imageUrls');
          emit(CarImagesUploaded(imageUrls));
        },
      );
    } catch (e) {
       print('❌ Unexpected upload error: $e');
       emit(const CarImagesUploaded([])); 
    }
  }

  Future<void> _onLoadMoreCars(LoadMoreCarsEvent event, Emitter<CarState> emit) async {
    if (state is! CarLoaded) return;
    final currentState = state as CarLoaded;
    if (currentState.hasReachedMax) return;

    try {
      final lastCar = currentState.cars.last;
      List<Object> startAfterValues;
      
      // Determine sort order based on filters
      if (currentState.minPrice != null || currentState.maxPrice != null) {
        startAfterValues = [lastCar.price]; // Assuming ID is not needed for uniqueness if price is unique enough, but better to add ID? 
        // Firestore requires the cursor to match the orderBy fields.
        // Our query orders by 'price' then implicitly by document ID? No, we need to be explicit if we want stable pagination.
        // But for now let's try just price. If duplicates exist, we might skip.
        // Actually, usually it's [price, docId] if we orderBy('price').orderBy(FieldPath.documentId).
        // But our query only has orderBy('price').
        // Let's stick to what the query does.
      } else {
        startAfterValues = [lastCar.createdAt];
      }

      final result = await getCarsUseCase(GetCarsParams(
        startAfterValues: startAfterValues,
        minPrice: currentState.minPrice,
        maxPrice: currentState.maxPrice,
        condition: currentState.condition,
        location: currentState.location,
        query: currentState.query,
        transmission: currentState.transmission,
        fuelType: currentState.fuelType,
        make: currentState.make,
        year: currentState.year,
      ));

      result.fold(
        (failure) => emit(CarError(_mapFailureToMessage(failure))),
        (newCars) {
          if (newCars.isEmpty) {
            emit(currentState.copyWith(hasReachedMax: true));
          } else {
            emit(currentState.copyWith(
              cars: List.of(currentState.cars)..addAll(newCars),
              hasReachedMax: newCars.length < 10,
            ));
          }
        },
      );
    } catch (e) {
      // Don't emit error state to avoid replacing the list with an error
      debugPrint('Error loading more cars: $e');
    }
  }

  Future<void> _onFilterCars(FilterCarsEvent event, Emitter<CarState> emit) async {
    // Update query and fetch
    // We need to preserve other filters
    double? minPrice;
    double? maxPrice;
    String? condition;
    String? location;
    String? transmission;
    String? fuelType;
    String? make;
    int? year;

    if (state is CarLoaded) {
      final currentState = state as CarLoaded;
      minPrice = currentState.minPrice;
      maxPrice = currentState.maxPrice;
      condition = currentState.condition;
      location = currentState.location;
      transmission = currentState.transmission;
      fuelType = currentState.fuelType;
      make = currentState.make;
      year = currentState.year;
    }

    emit(CarLoading());
    final result = await getCarsUseCase(GetCarsParams(
      minPrice: minPrice,
      maxPrice: maxPrice,
      condition: condition,
      location: location,
      query: event.query,
      transmission: transmission,
      fuelType: fuelType,
      make: make,
      year: year,
    ));

    result.fold(
      (failure) => emit(CarError(failure.message)),
      (cars) {
        emit(CarLoaded(
          cars: cars,
          filteredCars: cars,
          hasReachedMax: cars.length < 10,
          isFetchingMore: false,
          minPrice: minPrice,
          maxPrice: maxPrice,
          condition: condition,
          location: location,
          query: event.query,
          transmission: transmission,
          fuelType: fuelType,
          make: make,
          year: year,
        ));
      },
    );
  }

  Future<void> _onApplyFilters(ApplyFiltersEvent event, Emitter<CarState> emit) async {
    // Update filters and fetch
    // We need to preserve query
    String? query;

    if (state is CarLoaded) {
      final currentState = state as CarLoaded;
      query = currentState.query;
    }

    emit(CarLoading());
    final result = await getCarsUseCase(GetCarsParams(
      minPrice: event.minPrice,
      maxPrice: event.maxPrice,
      condition: event.condition,
      location: event.location,
      query: query,
      transmission: event.transmission,
      fuelType: event.fuelType,
      make: event.make,
      year: event.year,
    ));

    result.fold(
      (failure) => emit(CarError(_mapFailureToMessage(failure))),
      (cars) => emit(CarLoaded(
        cars: cars,
        filteredCars: cars,
        minPrice: event.minPrice,
        maxPrice: event.maxPrice,
        condition: event.condition,
        location: event.location,
        query: query,
        transmission: event.transmission,
        fuelType: event.fuelType,
        make: event.make,
        year: event.year,
        hasReachedMax: cars.length < 10,
        isFetchingMore: false,
      )),
    );
  }
}
