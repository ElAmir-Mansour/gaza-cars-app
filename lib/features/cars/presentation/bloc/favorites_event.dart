part of 'favorites_bloc.dart';

abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object> get props => [];
}

class LoadFavoritesEvent extends FavoritesEvent {
  final String userId;

  const LoadFavoritesEvent({required this.userId});

  @override
  List<Object> get props => [userId];
}

class ToggleFavoriteEvent extends FavoritesEvent {
  final String carId;
  final String userId;

  const ToggleFavoriteEvent({required this.carId, required this.userId});

  @override
  List<Object> get props => [carId, userId];
}
