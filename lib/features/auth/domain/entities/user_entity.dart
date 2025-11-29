import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String role; // 'buyer', 'trader', 'admin'
  final bool isVerified;
  final DateTime createdAt;
  
  // Trader-specific fields (optional)
  final String? businessName;
  final String? businessLicense;
  final String? taxId;
  final String? businessAddress;

  // Ban-related fields
  final bool isBanned;
  final DateTime? bannedAt;
  final String? bannedBy;
  final String? banReason;
  
  // Profile fields
  final String? photoUrl;

  const UserEntity({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.createdAt,
    this.isVerified = false,
    this.businessName,
    this.businessLicense,
    this.taxId,
    this.businessAddress,
    this.isBanned = false,
    this.bannedAt,
    this.bannedBy,
    this.banReason,
    this.photoUrl,
    this.blockedUsers = const [],
  });

  final List<String> blockedUsers;

  @override
  List<Object?> get props => [
        uid,
        name,
        email,
        phone,
        role,
        isVerified,
        createdAt,
        businessName,
        businessLicense,
        taxId,
        businessAddress,
        isBanned,
        bannedAt,
        bannedBy,
        banReason,
        photoUrl,
        blockedUsers,
      ];
}
