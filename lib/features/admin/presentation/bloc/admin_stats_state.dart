import 'package:equatable/equatable.dart';
import '../../domain/entities/admin_stats_entity.dart';

abstract class AdminStatsState extends Equatable {
  const AdminStatsState();

  @override
  List<Object?> get props => [];
}

class AdminStatsInitial extends AdminStatsState {}

class AdminStatsLoading extends AdminStatsState {}

class AdminStatsLoaded extends AdminStatsState {
  final AdminStatsEntity stats;

  const AdminStatsLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}

class AdminStatsError extends AdminStatsState {
  final String message;

  const AdminStatsError(this.message);

  @override
  List<Object?> get props => [message];
}
