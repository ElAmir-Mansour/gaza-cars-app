// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:cloud_firestore/cloud_firestore.dart' as _i974;
import 'package:firebase_auth/firebase_auth.dart' as _i59;
import 'package:firebase_storage/firebase_storage.dart' as _i457;
import 'package:get_it/get_it.dart' as _i174;
import 'package:google_sign_in/google_sign_in.dart' as _i116;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../../features/admin/data/datasources/admin_remote_data_source.dart'
    as _i517;
import '../../features/admin/data/datasources/report_remote_data_source.dart'
    as _i1043;
import '../../features/admin/data/repositories/admin_repository_impl.dart'
    as _i335;
import '../../features/admin/data/repositories/report_repository_impl.dart'
    as _i742;
import '../../features/admin/domain/repositories/admin_repository.dart'
    as _i583;
import '../../features/admin/domain/repositories/report_repository.dart'
    as _i799;
import '../../features/admin/domain/usecases/approve_car_usecase.dart' as _i946;
import '../../features/admin/domain/usecases/ban_user_usecase.dart' as _i512;
import '../../features/admin/domain/usecases/get_admin_stats_usecase.dart'
    as _i631;
import '../../features/admin/domain/usecases/get_all_users_usecase.dart'
    as _i556;
import '../../features/admin/domain/usecases/get_pending_cars_usecase.dart'
    as _i977;
import '../../features/admin/domain/usecases/reject_car_usecase.dart' as _i866;
import '../../features/admin/domain/usecases/submit_report_usecase.dart'
    as _i307;
import '../../features/admin/domain/usecases/unban_user_usecase.dart' as _i855;
import '../../features/admin/presentation/bloc/admin_stats_bloc.dart' as _i194;
import '../../features/admin/presentation/bloc/car_moderation_bloc.dart'
    as _i732;
import '../../features/admin/presentation/bloc/report_cubit.dart' as _i154;
import '../../features/admin/presentation/bloc/user_management_bloc.dart'
    as _i309;
import '../../features/auth/data/datasources/auth_remote_data_source.dart'
    as _i107;
import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i153;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i787;
import '../../features/auth/domain/usecases/apple_login_usecase.dart' as _i832;
import '../../features/auth/domain/usecases/block_user_usecase.dart' as _i754;
import '../../features/auth/domain/usecases/delete_account_usecase.dart'
    as _i914;
import '../../features/auth/domain/usecases/get_current_user_usecase.dart'
    as _i17;
import '../../features/auth/domain/usecases/google_login_usecase.dart' as _i850;
import '../../features/auth/domain/usecases/login_usecase.dart' as _i188;
import '../../features/auth/domain/usecases/logout_usecase.dart' as _i48;
import '../../features/auth/domain/usecases/register_usecase.dart' as _i941;
import '../../features/auth/domain/usecases/send_password_reset_email_usecase.dart'
    as _i961;
import '../../features/auth/presentation/bloc/auth_bloc.dart' as _i797;
import '../../features/cars/data/datasources/car_remote_data_source.dart'
    as _i434;
import '../../features/cars/data/repositories/car_repository_impl.dart' as _i31;
import '../../features/cars/domain/repositories/car_repository.dart' as _i82;
import '../../features/cars/domain/usecases/add_car_usecase.dart' as _i681;
import '../../features/cars/domain/usecases/delete_car_usecase.dart' as _i433;
import '../../features/cars/domain/usecases/get_cars_usecase.dart' as _i172;
import '../../features/cars/domain/usecases/get_favorites_usecase.dart'
    as _i223;
import '../../features/cars/domain/usecases/toggle_favorite_usecase.dart'
    as _i29;
import '../../features/cars/domain/usecases/update_car_usecase.dart' as _i427;
import '../../features/cars/domain/usecases/upload_car_images_usecase.dart'
    as _i975;
import '../../features/cars/presentation/bloc/car_bloc.dart' as _i539;
import '../../features/cars/presentation/bloc/favorites_bloc.dart' as _i951;
import '../../features/chat/data/datasources/chat_remote_data_source.dart'
    as _i980;
import '../../features/chat/data/repositories/chat_repository_impl.dart'
    as _i504;
import '../../features/chat/domain/repositories/chat_repository.dart' as _i420;
import '../../features/chat/domain/usecases/create_chat_usecase.dart' as _i599;
import '../../features/chat/domain/usecases/get_chats_usecase.dart' as _i692;
import '../../features/chat/domain/usecases/get_messages_usecase.dart' as _i325;
import '../../features/chat/domain/usecases/send_message_usecase.dart' as _i795;
import '../../features/chat/presentation/bloc/chat_bloc.dart' as _i65;
import '../../features/chat/presentation/bloc/message_bloc.dart' as _i239;
import '../../features/profile/presentation/bloc/profile_bloc.dart' as _i469;
import '../../features/settings/presentation/bloc/language_cubit.dart' as _i771;
import '../services/notification_service.dart' as _i941;
import 'register_module.dart' as _i291;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    gh.lazySingleton<_i59.FirebaseAuth>(() => registerModule.firebaseAuth);
    gh.lazySingleton<_i974.FirebaseFirestore>(() => registerModule.firestore);
    gh.lazySingleton<_i457.FirebaseStorage>(() => registerModule.storage);
    gh.lazySingleton<_i116.GoogleSignIn>(() => registerModule.googleSignIn);
    gh.lazySingleton<_i941.NotificationService>(
      () => _i941.NotificationService(),
    );
    gh.lazySingleton<_i1043.ReportRemoteDataSource>(
      () => _i1043.ReportRemoteDataSourceImpl(gh<_i974.FirebaseFirestore>()),
    );
    gh.lazySingleton<_i434.CarRemoteDataSource>(
      () => _i434.CarRemoteDataSourceImpl(
        firestore: gh<_i974.FirebaseFirestore>(),
        storage: gh<_i457.FirebaseStorage>(),
      ),
    );
    gh.lazySingleton<_i799.ReportRepository>(
      () => _i742.ReportRepositoryImpl(gh<_i1043.ReportRemoteDataSource>()),
    );
    gh.lazySingleton<_i107.AuthRemoteDataSource>(
      () => _i107.AuthRemoteDataSourceImpl(
        firebaseAuth: gh<_i59.FirebaseAuth>(),
        firestore: gh<_i974.FirebaseFirestore>(),
        storage: gh<_i457.FirebaseStorage>(),
        googleSignIn: gh<_i116.GoogleSignIn>(),
      ),
    );
    gh.lazySingleton<_i980.ChatRemoteDataSource>(
      () => _i980.ChatRemoteDataSourceImpl(
        firestore: gh<_i974.FirebaseFirestore>(),
      ),
    );
    gh.factory<_i771.LanguageCubit>(
      () =>
          _i771.LanguageCubit(sharedPreferences: gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i517.AdminRemoteDataSource>(
      () => _i517.AdminRemoteDataSourceImpl(
        firestore: gh<_i974.FirebaseFirestore>(),
        auth: gh<_i59.FirebaseAuth>(),
      ),
    );
    gh.lazySingleton<_i583.AdminRepository>(
      () => _i335.AdminRepositoryImpl(
        remoteDataSource: gh<_i517.AdminRemoteDataSource>(),
        auth: gh<_i59.FirebaseAuth>(),
      ),
    );
    gh.lazySingleton<_i307.SubmitReportUseCase>(
      () => _i307.SubmitReportUseCase(gh<_i799.ReportRepository>()),
    );
    gh.lazySingleton<_i82.CarRepository>(
      () => _i31.CarRepositoryImpl(
        remoteDataSource: gh<_i434.CarRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i681.AddCarUseCase>(
      () => _i681.AddCarUseCase(gh<_i82.CarRepository>()),
    );
    gh.lazySingleton<_i433.DeleteCarUseCase>(
      () => _i433.DeleteCarUseCase(gh<_i82.CarRepository>()),
    );
    gh.lazySingleton<_i172.GetCarsUseCase>(
      () => _i172.GetCarsUseCase(gh<_i82.CarRepository>()),
    );
    gh.lazySingleton<_i223.GetFavoritesUseCase>(
      () => _i223.GetFavoritesUseCase(gh<_i82.CarRepository>()),
    );
    gh.lazySingleton<_i29.ToggleFavoriteUseCase>(
      () => _i29.ToggleFavoriteUseCase(gh<_i82.CarRepository>()),
    );
    gh.lazySingleton<_i427.UpdateCarUseCase>(
      () => _i427.UpdateCarUseCase(gh<_i82.CarRepository>()),
    );
    gh.lazySingleton<_i975.UploadCarImagesUseCase>(
      () => _i975.UploadCarImagesUseCase(gh<_i82.CarRepository>()),
    );
    gh.lazySingleton<_i787.AuthRepository>(
      () => _i153.AuthRepositoryImpl(
        remoteDataSource: gh<_i107.AuthRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i420.ChatRepository>(
      () => _i504.ChatRepositoryImpl(
        remoteDataSource: gh<_i980.ChatRemoteDataSource>(),
        auth: gh<_i59.FirebaseAuth>(),
      ),
    );
    gh.lazySingleton<_i946.ApproveCarUseCase>(
      () => _i946.ApproveCarUseCase(gh<_i583.AdminRepository>()),
    );
    gh.lazySingleton<_i512.BanUserUseCase>(
      () => _i512.BanUserUseCase(gh<_i583.AdminRepository>()),
    );
    gh.lazySingleton<_i631.GetAdminStatsUseCase>(
      () => _i631.GetAdminStatsUseCase(gh<_i583.AdminRepository>()),
    );
    gh.lazySingleton<_i556.GetAllUsersUseCase>(
      () => _i556.GetAllUsersUseCase(gh<_i583.AdminRepository>()),
    );
    gh.lazySingleton<_i977.GetPendingCarsUseCase>(
      () => _i977.GetPendingCarsUseCase(gh<_i583.AdminRepository>()),
    );
    gh.lazySingleton<_i866.RejectCarUseCase>(
      () => _i866.RejectCarUseCase(gh<_i583.AdminRepository>()),
    );
    gh.lazySingleton<_i855.UnbanUserUseCase>(
      () => _i855.UnbanUserUseCase(gh<_i583.AdminRepository>()),
    );
    gh.factory<_i951.FavoritesBloc>(
      () => _i951.FavoritesBloc(
        getFavoritesUseCase: gh<_i223.GetFavoritesUseCase>(),
        toggleFavoriteUseCase: gh<_i29.ToggleFavoriteUseCase>(),
      ),
    );
    gh.factory<_i154.ReportCubit>(
      () => _i154.ReportCubit(gh<_i307.SubmitReportUseCase>()),
    );
    gh.factory<_i732.CarModerationBloc>(
      () => _i732.CarModerationBloc(
        getPendingCarsUseCase: gh<_i977.GetPendingCarsUseCase>(),
        approveCarUseCase: gh<_i946.ApproveCarUseCase>(),
        rejectCarUseCase: gh<_i866.RejectCarUseCase>(),
      ),
    );
    gh.lazySingleton<_i832.AppleLoginUseCase>(
      () => _i832.AppleLoginUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i754.BlockUserUseCase>(
      () => _i754.BlockUserUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i914.DeleteAccountUseCase>(
      () => _i914.DeleteAccountUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i17.GetCurrentUserUseCase>(
      () => _i17.GetCurrentUserUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i850.GoogleLoginUseCase>(
      () => _i850.GoogleLoginUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i188.LoginUseCase>(
      () => _i188.LoginUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i48.LogoutUseCase>(
      () => _i48.LogoutUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i941.RegisterUseCase>(
      () => _i941.RegisterUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i961.SendPasswordResetEmailUseCase>(
      () => _i961.SendPasswordResetEmailUseCase(gh<_i787.AuthRepository>()),
    );
    gh.factory<_i469.ProfileBloc>(
      () => _i469.ProfileBloc(gh<_i787.AuthRepository>()),
    );
    gh.factory<_i539.CarBloc>(
      () => _i539.CarBloc(
        gh<_i172.GetCarsUseCase>(),
        gh<_i681.AddCarUseCase>(),
        gh<_i427.UpdateCarUseCase>(),
        gh<_i433.DeleteCarUseCase>(),
        gh<_i975.UploadCarImagesUseCase>(),
      ),
    );
    gh.factory<_i194.AdminStatsBloc>(
      () => _i194.AdminStatsBloc(
        getAdminStatsUseCase: gh<_i631.GetAdminStatsUseCase>(),
      ),
    );
    gh.factory<_i309.UserManagementBloc>(
      () => _i309.UserManagementBloc(
        getAllUsersUseCase: gh<_i556.GetAllUsersUseCase>(),
        banUserUseCase: gh<_i512.BanUserUseCase>(),
        unbanUserUseCase: gh<_i855.UnbanUserUseCase>(),
      ),
    );
    gh.lazySingleton<_i599.CreateChatUseCase>(
      () => _i599.CreateChatUseCase(gh<_i420.ChatRepository>()),
    );
    gh.lazySingleton<_i692.GetChatsUseCase>(
      () => _i692.GetChatsUseCase(gh<_i420.ChatRepository>()),
    );
    gh.lazySingleton<_i325.GetMessagesUseCase>(
      () => _i325.GetMessagesUseCase(gh<_i420.ChatRepository>()),
    );
    gh.lazySingleton<_i795.SendMessageUseCase>(
      () => _i795.SendMessageUseCase(gh<_i420.ChatRepository>()),
    );
    gh.factory<_i797.AuthBloc>(
      () => _i797.AuthBloc(
        gh<_i188.LoginUseCase>(),
        gh<_i941.RegisterUseCase>(),
        gh<_i48.LogoutUseCase>(),
        gh<_i17.GetCurrentUserUseCase>(),
        gh<_i850.GoogleLoginUseCase>(),
        gh<_i832.AppleLoginUseCase>(),
        gh<_i961.SendPasswordResetEmailUseCase>(),
        gh<_i914.DeleteAccountUseCase>(),
      ),
    );
    gh.factory<_i239.MessageBloc>(
      () => _i239.MessageBloc(
        getMessagesUseCase: gh<_i325.GetMessagesUseCase>(),
        sendMessageUseCase: gh<_i795.SendMessageUseCase>(),
      ),
    );
    gh.factory<_i65.ChatBloc>(
      () => _i65.ChatBloc(
        getChatsUseCase: gh<_i692.GetChatsUseCase>(),
        createChatUseCase: gh<_i599.CreateChatUseCase>(),
        blockUserUseCase: gh<_i754.BlockUserUseCase>(),
      ),
    );
    return this;
  }
}

class _$RegisterModule extends _i291.RegisterModule {}
