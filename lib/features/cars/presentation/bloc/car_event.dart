import 'dart:io';
import 'package:equatable/equatable.dart';
import '../../domain/entities/car_entity.dart';

abstract class CarEvent extends Equatable {
  const CarEvent();

  @override
  List<Object?> get props => [];
}

class GetCarsEvent extends CarEvent {
  final bool loadMore;

  const GetCarsEvent({this.loadMore = false});

  @override
  List<Object?> get props => [loadMore];
}

class AddCarEvent extends CarEvent {
  final CarEntity car;

  const AddCarEvent(this.car);

  @override
  List<Object?> get props => [car];
}

class UpdateCarEvent extends CarEvent {
  final CarEntity car;

  const UpdateCarEvent(this.car);

  @override
  List<Object?> get props => [car];
}

class DeleteCarEvent extends CarEvent {
  final String id;

  const DeleteCarEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class UploadCarImagesEvent extends CarEvent {
  final List<File> images;

  const UploadCarImagesEvent(this.images);

  @override
  List<Object?> get props => [images];
}

class FilterCarsEvent extends CarEvent {
  final String query;

  const FilterCarsEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class LoadMoreCarsEvent extends CarEvent {}

class ApplyFiltersEvent extends CarEvent {
  final double? minPrice;
  final double? maxPrice;
  final String? condition;
  final String? location;
  final String? query;
  final String? transmission;
  final String? fuelType;
  final String? make;
  final int? year;

  const ApplyFiltersEvent({
    this.minPrice,
    this.maxPrice,
    this.condition,
    this.location,
    this.query,
    this.transmission,
    this.fuelType,
    this.make,
    this.year,
  });

  @override
  List<Object?> get props => [
    minPrice,
    maxPrice,
    condition,
    location,
    query,
    transmission,
    fuelType,
    make,
    year,
  ];
}
