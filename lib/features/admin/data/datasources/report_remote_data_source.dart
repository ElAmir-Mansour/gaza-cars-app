import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/report_entity.dart';
import '../../../../core/error/failures.dart';

abstract class ReportRemoteDataSource {
  Future<void> submitReport(ReportEntity report);
}

@LazySingleton(as: ReportRemoteDataSource)
class ReportRemoteDataSourceImpl implements ReportRemoteDataSource {
  final FirebaseFirestore firestore;

  ReportRemoteDataSourceImpl(this.firestore);

  @override
  Future<void> submitReport(ReportEntity report) async {
    try {
      await firestore.collection('reports').doc(report.id).set({
        'id': report.id,
        'reporterId': report.reporterId,
        'reportedId': report.reportedId,
        'type': report.type,
        'reason': report.reason,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw const ServerFailure('Failed to submit report');
    }
  }
}
