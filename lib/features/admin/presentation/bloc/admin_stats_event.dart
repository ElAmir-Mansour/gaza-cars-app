import 'package:equatable/equatable.dart';

abstract class AdminStatsEvent extends Equatable {
  const AdminStatsEvent();

  @override
  List<Object?> get props => [];
}

class LoadAdminStats extends AdminStatsEvent {
  const LoadAdminStats();
}
