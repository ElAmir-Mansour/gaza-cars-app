import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/ban_user_usecase.dart';
import '../../domain/usecases/get_all_users_usecase.dart';
import '../../domain/usecases/unban_user_usecase.dart';
import 'user_management_event.dart';
import 'user_management_state.dart';

@injectable
class UserManagementBloc
    extends Bloc<UserManagementEvent, UserManagementState> {
  final GetAllUsersUseCase getAllUsersUseCase;
  final BanUserUseCase banUserUseCase;
  final UnbanUserUseCase unbanUserUseCase;

  UserManagementBloc({
    required this.getAllUsersUseCase,
    required this.banUserUseCase,
    required this.unbanUserUseCase,
  }) : super(UserManagementInitial()) {
    on<LoadAllUsers>(_onLoadAllUsers);
    on<BanUser>(_onBanUser);
    on<UnbanUser>(_onUnbanUser);
  }

  Future<void> _onLoadAllUsers(
      LoadAllUsers event, Emitter<UserManagementState> emit) async {
    emit(UserManagementLoading());
    final result = await getAllUsersUseCase();
    result.fold(
      (failure) => emit(UserManagementError(failure.message)),
      (users) => emit(UserManagementLoaded(users)),
    );
  }

  Future<void> _onBanUser(
      BanUser event, Emitter<UserManagementState> emit) async {
    print('🔄 Bloc: Banning user ${event.userId}, reason: ${event.reason}');
    final result = await banUserUseCase(event.userId, event.reason);
    await result.fold(
      (failure) async {
        print('❌ Bloc: Ban failed - ${failure.message}');
        emit(UserManagementError(failure.message));
      },
      (_) async {
        print('✅ Bloc: Ban successful, reloading users');
        // Reload users first
        emit(UserManagementLoading());
        final usersResult = await getAllUsersUseCase();
        usersResult.fold(
          (failure) => emit(UserManagementError(failure.message)),
          (users) {
            emit(UserManagementLoaded(users));
            // Show success message after users are loaded (with users list)
            emit(UserManagementActionSuccess('User banned successfully', users));
          },
        );
      },
    );
  }

  Future<void> _onUnbanUser(
      UnbanUser event, Emitter<UserManagementState> emit) async {
    print('🔄 Bloc: Unbanning user ${event.userId}');
    final result = await unbanUserUseCase(event.userId);
    await result.fold(
      (failure) async {
        print('❌ Bloc: Unban failed - ${failure.message}');
        emit(UserManagementError(failure.message));
      },
      (_) async {
        print('✅ Bloc: Unban successful, reloading users');
        // Reload users first
        emit(UserManagementLoading());
        final usersResult = await getAllUsersUseCase();
        usersResult.fold(
          (failure) => emit(UserManagementError(failure.message)),
          (users) {
            emit(UserManagementLoaded(users));
            // Show success message after users are loaded (with users list)
            emit(UserManagementActionSuccess('User unbanned successfully', users));
          },
        );
      },
    );
  }
}
