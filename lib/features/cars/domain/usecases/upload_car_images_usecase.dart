import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/car_repository.dart';

@lazySingleton
class UploadCarImagesUseCase implements UseCase<List<String>, UploadCarImagesParams> {
  final CarRepository repository;

  UploadCarImagesUseCase(this.repository);

  @override
  Future<Either<Failure, List<String>>> call(UploadCarImagesParams params) async {
    return await repository.uploadCarImages(params.images);
  }
}

class UploadCarImagesParams {
  final List<File> images;

  const UploadCarImagesParams({required this.images});
}
