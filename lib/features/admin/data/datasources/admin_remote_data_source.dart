
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/exceptions.dart';
import '../../../cars/domain/entities/car_entity.dart';
import '../models/admin_stats_model.dart';

abstract class AdminRemoteDataSource {
  Stream<AdminStatsModel> getStats();
  Future<List<CarEntity>> getPendingCars();
  Future<void> approveCar(String carId, String adminId);
  Future<void> rejectCar(String carId, String adminId, String reason);
  Future<List<Map<String, dynamic>>> getAllUsers();
  Future<void> banUser(String userId, String adminId, String reason);
  Future<void> unbanUser(String userId);
}

@LazySingleton(as: AdminRemoteDataSource)
class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  AdminRemoteDataSourceImpl({
    required this.firestore,
    required this.auth,
  });

  @override
  Stream<AdminStatsModel> getStats() {
    // Calculate stats in real-time from collections
    return Stream.periodic(const Duration(seconds: 5)).asyncMap((_) async {
      try {
        debugPrint('📊 Fetching admin stats...');
        final usersSnapshot = await firestore.collection('users').get();
        print('✅ Users fetched: ${usersSnapshot.docs.length}');
        
        final carsSnapshot = await firestore.collection('cars').get();
        print('✅ Cars fetched: ${carsSnapshot.docs.length}');
        
        final chatsSnapshot = await firestore.collection('chats').get();
        print('✅ Chats fetched: ${chatsSnapshot.docs.length}');

        final totalUsers = usersSnapshot.docs.length;
        final totalTraders = usersSnapshot.docs
            .where((doc) => doc.data()['role'] == 'trader')
            .length;

        final cars = carsSnapshot.docs;
        final totalCars = cars.length;
        final activeCars = cars
            .where((doc) => doc.data()['status'] == 'active' || doc.data()['status'] == 'approved')
            .length;
        final pendingCars = cars
            .where((doc) => doc.data()['status'] == 'pending')
            .length;

        final totalChats = chatsSnapshot.docs.length;

        print('✅ Stats calculated successfully');
        return AdminStatsModel(
          totalUsers: totalUsers,
          totalCars: totalCars,
          totalTraders: totalTraders,
          activeCars: activeCars,
          pendingCars: pendingCars,
          totalChats: totalChats,
          lastUpdated: DateTime.now(),
        );
      } catch (e) {
        print('❌ Error fetching admin stats: $e');
        throw ServerException('Failed to fetch stats: ${e.toString()}');
      }
    });
  }

  @override
  Future<List<CarEntity>> getPendingCars() async {
    try {
      print('📋 Fetching pending cars...');
      final snapshot = await firestore
          .collection('cars')
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .get();

      print('✅ Found ${snapshot.docs.length} pending cars');
      return snapshot.docs.map((doc) => _carFromSnapshot(doc)).toList();
    } catch (e) {
      print('❌ Error fetching pending cars: $e');
      throw ServerException('Failed to fetch pending cars: ${e.toString()}');
    }
  }
  
  CarEntity _carFromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CarEntity(
      id: doc.id,
      sellerId: data['sellerId'] ?? '',
      sellerPhone: data['sellerPhone'] ?? '',
      make: data['make'] ?? '',
      model: data['model'] ?? '',
      year: data['year'] ?? 0,
      price: (data['price'] ?? 0).toDouble(),
      mileage: data['mileage'] ?? 0,
      condition: data['condition'] ?? '',
      location: data['location'] ?? '',
      description: data['description'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      status: data['status'] ?? 'active',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  @override
  Future<void> approveCar(String carId, String adminId) async {
    try {
      await firestore.collection('cars').doc(carId).update({
        'status': 'approved',
        'reviewedAt': FieldValue.serverTimestamp(),
        'reviewedBy': adminId,
      });
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> rejectCar(String carId, String adminId, String reason) async {
    try {
      await firestore.collection('cars').doc(carId).update({
        'status': 'rejected',
        'reviewedAt': FieldValue.serverTimestamp(),
        'reviewedBy': adminId,
        'rejectionReason': reason,
      });
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final snapshot = await firestore
          .collection('users')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Add document ID
        return data;
      }).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> banUser(String userId, String adminId, String reason) async {
    try {
      print('🚫 Banning user: $userId by admin: $adminId');
      await firestore.collection('users').doc(userId).update({
        'isBanned': true,
        'bannedAt': FieldValue.serverTimestamp(),
        'bannedBy': adminId,
        'banReason': reason,
      });
      print('✅ User banned successfully');
    } catch (e) {
      print('❌ Error banning user: $e');
      throw ServerException('Failed to ban user: ${e.toString()}');
    }
  }

  @override
  Future<void> unbanUser(String userId) async {
    try {
      await firestore.collection('users').doc(userId).update({
        'isBanned': false,
        'bannedAt': null,
        'bannedBy': null,
        'banReason': null,
      });
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
