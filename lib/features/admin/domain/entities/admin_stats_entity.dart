import 'package:equatable/equatable.dart';

class AdminStatsEntity extends Equatable {
  final int totalUsers;
  final int totalCars;
  final int totalTraders;
  final int activeCars;
  final int pendingCars;
  final int totalChats;
  final DateTime lastUpdated;

  const AdminStatsEntity({
    required this.totalUsers,
    required this.totalCars,
    required this.totalTraders,
    required this.activeCars,
    required this.pendingCars,
    required this.totalChats,
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [
        totalUsers,
        totalCars,
        totalTraders,
        activeCars,
        pendingCars,
        totalChats,
        lastUpdated,
      ];
}
