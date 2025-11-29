import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/report_entity.dart';
import '../repositories/report_repository.dart';

@lazySingleton
class SubmitReportUseCase {
  final ReportRepository repository;

  SubmitReportUseCase(this.repository);

  Future<Either<Failure, void>> call(ReportEntity report) async {
    return await repository.submitReport(report);
  }
}
