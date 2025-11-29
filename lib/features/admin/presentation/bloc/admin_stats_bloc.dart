import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/admin_stats_entity.dart';
import '../../domain/usecases/get_admin_stats_usecase.dart';
import 'admin_stats_event.dart';
import 'admin_stats_state.dart';

@injectable
class AdminStatsBloc extends Bloc<AdminStatsEvent, AdminStatsState> {
  final GetAdminStatsUseCase getAdminStatsUseCase;
  StreamSubscription? _statsSubscription;

  AdminStatsBloc({required this.getAdminStatsUseCase})
      : super(AdminStatsInitial()) {
    on<LoadAdminStats>(_onLoadAdminStats);
    on<_StatsUpdated>(_onStatsUpdated);
    on<_StatsError>(_onStatsError);
  }

  Future<void> _onLoadAdminStats(
      LoadAdminStats event, Emitter<AdminStatsState> emit) async {
    emit(AdminStatsLoading());
    await _statsSubscription?.cancel();
    _statsSubscription = getAdminStatsUseCase().listen(
      (stats) => add(_StatsUpdated(stats)),
      onError: (error) => add(_StatsError(error.toString())),
    );
  }

  void _onStatsUpdated(_StatsUpdated event, Emitter<AdminStatsState> emit) {
    emit(AdminStatsLoaded(event.stats));
  }

  void _onStatsError(_StatsError event, Emitter<AdminStatsState> emit) {
    emit(AdminStatsError(event.message));
  }

  @override
  Future<void> close() {
    _statsSubscription?.cancel();
    return super.close();
  }
}

class _StatsUpdated extends AdminStatsEvent {
  final AdminStatsEntity stats;
  const _StatsUpdated(this.stats);
  @override
  List<Object?> get props => [stats];
}

class _StatsError extends AdminStatsEvent {
  final String message;
  const _StatsError(this.message);
  @override
  List<Object?> get props => [message];
}
