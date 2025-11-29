import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginEvent({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}
class DeleteAccountEvent extends AuthEvent {}
class RegisterEvent extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final String phone;
  final String role;
  // Optional trader fields
  final String? businessName;
  final String? businessLicense;
  final String? taxId;
  final String? businessAddress;

  const RegisterEvent({
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
  List<Object?> get props => [email, password, name, phone, role, businessName, businessLicense, taxId, businessAddress];
}

class LogoutEvent extends AuthEvent {}

class AuthGoogleLogin extends AuthEvent {}

class AuthAppleLogin extends AuthEvent {}

class CheckAuthStatusEvent extends AuthEvent {}

class ForgotPasswordEvent extends AuthEvent {
  final String email;

  const ForgotPasswordEvent(this.email);

  @override
  List<Object?> get props => [email];
}
