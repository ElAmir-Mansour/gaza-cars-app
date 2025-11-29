import 'package:equatable/equatable.dart';

class ReportEntity extends Equatable {
  final String id;
  final String reporterId;
  final String reportedId; // ID of the user or car being reported
  final String type; // 'listing' or 'user'
  final String reason;
  final DateTime timestamp;

  const ReportEntity({
    required this.id,
    required this.reporterId,
    required this.reportedId,
    required this.type,
    required this.reason,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, reporterId, reportedId, type, reason, timestamp];
}
