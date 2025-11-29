import 'package:equatable/equatable.dart';

abstract class UserManagementEvent extends Equatable {
  const UserManagementEvent();

  @override
  List<Object?> get props => [];
}

class LoadAllUsers extends UserManagementEvent {}

class BanUser extends UserManagementEvent {
  final String userId;
  final String reason;

  const BanUser(this.userId, this.reason);

  @override
  List<Object?> get props => [userId, reason];
}

class UnbanUser extends UserManagementEvent {
  final String userId;

  const UnbanUser(this.userId);

  @override
  List<Object?> get props => [userId];
}
