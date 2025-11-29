import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/admin_stats_entity.dart';

class AdminStatsModel extends AdminStatsEntity {
  const AdminStatsModel({
    required super.totalUsers,
    required super.totalCars,
    required super.totalTraders,
    required super.activeCars,
    required super.pendingCars,
    required super.totalChats,
    required super.lastUpdated,
  });

  factory AdminStatsModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AdminStatsModel(
      totalUsers: data['totalUsers'] ?? 0,
      totalCars: data['totalCars'] ?? 0,
      totalTraders: data['totalTraders'] ?? 0,
      activeCars: data['activeCars'] ?? 0,
      pendingCars: data['pendingCars'] ?? 0,
      totalChats: data['totalChats'] ?? 0,
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalUsers': totalUsers,
      'totalCars': totalCars,
      'totalTraders': totalTraders,
      'activeCars': activeCars,
      'pendingCars': pendingCars,
      'totalChats': totalChats,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }
}
