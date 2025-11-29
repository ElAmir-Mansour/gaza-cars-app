import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/car_entity.dart';
import '../../domain/usecases/get_favorites_usecase.dart';
import '../../domain/usecases/toggle_favorite_usecase.dart';

part 'favorites_event.dart';
part 'favorites_state.dart';

@injectable
class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final GetFavoritesUseCase getFavoritesUseCase;
  final ToggleFavoriteUseCase toggleFavoriteUseCase;

  FavoritesBloc({
    required this.getFavoritesUseCase,
    required this.toggleFavoriteUseCase,
  }) : super(FavoritesInitial()) {
    on<LoadFavoritesEvent>(_onLoadFavorites);
    on<ToggleFavoriteEvent>(_onToggleFavorite);
  }

  Future<void> _onLoadFavorites(
    LoadFavoritesEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(FavoritesLoading());
    final result = await getFavoritesUseCase(GetFavoritesParams(userId: event.userId));
    result.fold(
      (failure) => emit(FavoritesError(message: failure.message)),
      (cars) => emit(FavoritesLoaded(favorites: cars)),
    );
  }

  Future<void> _onToggleFavorite(
    ToggleFavoriteEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    // Optimistic update could be done here, but for simplicity we'll just reload or handle success
    // Ideally, we should update the list locally if it's already loaded.
    
    final result = await toggleFavoriteUseCase(
      ToggleFavoriteParams(carId: event.carId, userId: event.userId),
    );

    result.fold(
      (failure) => emit(FavoritesError(message: failure.message)),
      (_) {
        // After toggling, reload the favorites list to ensure consistency
        add(LoadFavoritesEvent(userId: event.userId));
      },
    );
  }
}
