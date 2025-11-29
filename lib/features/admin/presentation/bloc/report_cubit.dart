import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/report_entity.dart';
import '../../domain/usecases/submit_report_usecase.dart';
import 'report_state.dart';

@injectable
class ReportCubit extends Cubit<ReportState> {
  final SubmitReportUseCase submitReportUseCase;

  ReportCubit(this.submitReportUseCase) : super(ReportInitial());

  Future<void> submitReport({
    required String reporterId,
    required String reportedId,
    required String type,
    required String reason,
  }) async {
    emit(ReportLoading());
    final report = ReportEntity(
      id: const Uuid().v4(),
      reporterId: reporterId,
      reportedId: reportedId,
      type: type,
      reason: reason,
      timestamp: DateTime.now(),
    );

    final result = await submitReportUseCase(report);
    result.fold(
      (failure) => emit(ReportError(failure.message)),
      (_) => emit(ReportSuccess()),
    );
  }
}
