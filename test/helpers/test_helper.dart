import 'package:mocktail/mocktail.dart';
import 'package:gaza_cars/features/auth/domain/usecases/login_usecase.dart';
import 'package:gaza_cars/features/auth/domain/usecases/register_usecase.dart';
import 'package:gaza_cars/features/auth/domain/usecases/logout_usecase.dart';
import 'package:gaza_cars/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:gaza_cars/features/auth/domain/usecases/google_login_usecase.dart';
import 'package:gaza_cars/features/auth/domain/usecases/apple_login_usecase.dart';
import 'package:gaza_cars/features/auth/domain/usecases/send_password_reset_email_usecase.dart';
import 'package:gaza_cars/features/auth/domain/usecases/delete_account_usecase.dart';
import 'package:gaza_cars/features/cars/domain/usecases/get_cars_usecase.dart';
import 'package:gaza_cars/features/cars/domain/usecases/add_car_usecase.dart';
import 'package:gaza_cars/features/cars/domain/usecases/update_car_usecase.dart';
import 'package:gaza_cars/features/cars/domain/usecases/delete_car_usecase.dart';
import 'package:gaza_cars/features/cars/domain/usecases/upload_car_images_usecase.dart';
import 'package:gaza_cars/core/services/rate_app_service.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}
class MockRegisterUseCase extends Mock implements RegisterUseCase {}
class MockLogoutUseCase extends Mock implements LogoutUseCase {}
class MockGetCurrentUserUseCase extends Mock implements GetCurrentUserUseCase {}
class MockGoogleLoginUseCase extends Mock implements GoogleLoginUseCase {}
class MockAppleLoginUseCase extends Mock implements AppleLoginUseCase {}
class MockSendPasswordResetEmailUseCase extends Mock implements SendPasswordResetEmailUseCase {}
class MockDeleteAccountUseCase extends Mock implements DeleteAccountUseCase {}

class MockGetCarsUseCase extends Mock implements GetCarsUseCase {}
class MockAddCarUseCase extends Mock implements AddCarUseCase {}
class MockUpdateCarUseCase extends Mock implements UpdateCarUseCase {}
class MockDeleteCarUseCase extends Mock implements DeleteCarUseCase {}
class MockUploadCarImagesUseCase extends Mock implements UploadCarImagesUseCase {}
class MockRateAppService extends Mock implements RateAppService {}

class MockLoginParams extends Fake implements LoginParams {}
class MockRegisterParams extends Fake implements RegisterParams {}
class MockGetCarsParams extends Fake implements GetCarsParams {}
class MockUploadCarImagesParams extends Fake implements UploadCarImagesParams {}
