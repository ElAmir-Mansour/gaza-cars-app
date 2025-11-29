import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class RegisterUseCase implements UseCase<UserEntity, RegisterParams> {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(RegisterParams params) async {
    return await repository.register(
      email: params.email,
      password: params.password,
      name: params.name,
      phone: params.phone,
      role: params.role,
      businessName: params.businessName,
      businessLicense: params.businessLicense,
      taxId: params.taxId,
      businessAddress: params.businessAddress,
    );
  }
}

class RegisterParams extends Equatable {
  final String email;
  final String password;
  final String name;
  final String phone;
  final String role;
  final String? businessName;
  final String? businessLicense;
  final String? taxId;
  final String? businessAddress;

  const RegisterParams({
    required this.email,
    required this.password,
    required this.name,
    required this.phone,
    required this.role,
    this.businessName,
    this.businessLicense,
    this.taxId,
    this.businessAddress,
  });

  @override
  List<Object?> get props => [
        email,
        password,
        name,
        phone,
        role,
        businessName,
        businessLicense,
        taxId,
        businessAddress,
      ];
}
