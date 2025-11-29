import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p; // For path manipulation
import '../../domain/entities/car_entity.dart';
import '../../../../core/error/failures.dart';

abstract class CarRemoteDataSource {
  Future<List<CarEntity>> getCars({
    List<Object>? startAfterValues,
    double? minPrice,
    double? maxPrice,
    String? condition,
    String? location,
    String? query,
    String? transmission,
    String? fuelType,
    String? make,
    int? year,
  });
  Future<CarEntity> getCarById(String id);
  Future<void> addCar(CarEntity car);
  Future<void> updateCar(CarEntity car);
  Future<void> deleteCar(String id);
  Future<List<String>> uploadCarImages(List<File> images);
  Future<void> toggleFavorite(String carId, String userId);
  Future<List<CarEntity>> getFavorites(String userId);
}

@LazySingleton(as: CarRemoteDataSource)
class CarRemoteDataSourceImpl implements CarRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  CarRemoteDataSourceImpl({required this.firestore, required this.storage});

  @override
  Future<List<CarEntity>> getCars({
    List<Object>? startAfterValues,
    double? minPrice,
    double? maxPrice,
    String? condition,
    String? location,
    String? query,
    String? transmission,
    String? fuelType,
    String? make,
    int? year,
  }) async {
    try {
      Query collectionReference = firestore.collection('cars');

      // Apply filters
      if (condition != null && condition.isNotEmpty) {
        collectionReference = collectionReference.where('condition', isEqualTo: condition);
      }
      if (location != null && location.isNotEmpty) {
        collectionReference = collectionReference.where('location', isEqualTo: location);
      }
      if (transmission != null && transmission.isNotEmpty) {
        collectionReference = collectionReference.where('transmission', isEqualTo: transmission);
      }
      if (fuelType != null && fuelType.isNotEmpty) {
        collectionReference = collectionReference.where('fuelType', isEqualTo: fuelType);
      }
      if (make != null && make.isNotEmpty) {
        collectionReference = collectionReference.where('make', isEqualTo: make);
      }
      if (year != null) {
        collectionReference = collectionReference.where('year', isEqualTo: year);
      }
      if (minPrice != null) {
        collectionReference = collectionReference.where('price', isGreaterThanOrEqualTo: minPrice);
      }
      if (maxPrice != null) {
        collectionReference = collectionReference.where('price', isLessThanOrEqualTo: maxPrice);
      }

      // Apply sorting
      if (minPrice != null || maxPrice != null) {
        collectionReference = collectionReference.orderBy('price');
      } else {
        collectionReference = collectionReference.orderBy('createdAt', descending: true);
      }

      collectionReference = collectionReference.limit(10);

      if (startAfterValues != null && startAfterValues.isNotEmpty) {
        collectionReference = collectionReference.startAfter(startAfterValues);
      }

      final snapshot = await collectionReference.get();
      
      var cars = snapshot.docs.map((doc) => _carFromSnapshot(doc)).toList();

      // Client-side text search (since Firestore doesn't support it well)
      if (query != null && query.isNotEmpty) {
        final lowerQuery = query.toLowerCase();
        cars = cars.where((car) {
          return car.make.toLowerCase().contains(lowerQuery) ||
                 car.model.toLowerCase().contains(lowerQuery) ||
                 car.year.toString().contains(lowerQuery);
        }).toList();
      }

      return cars;
    } catch (e) {
      debugPrint('🚗 Error fetching cars: $e');
      if (e is FirebaseException && e.code == 'failed-precondition') {
        debugPrint('⚠️ MISSING INDEX: The query requires an index. Check the console output above or below for a URL to create it.');
        debugPrint('🔗 You can also deploy the firestore.indexes.json file included in the project.');
      }
      throw const ServerFailure('Failed to fetch cars. Check logs for missing indexes.');
    }
  }

  @override
  Future<CarEntity> getCarById(String id) async {
    try {
      final doc = await firestore.collection('cars').doc(id).get();
      if (!doc.exists) {
        throw const ServerFailure('Car not found');
      }
      return _carFromSnapshot(doc);
    } catch (e) {
      throw const ServerFailure('Failed to fetch car details');
    }
  }

  @override
  Future<void> addCar(CarEntity car) async {
    try {
      // If ID is empty, let Firestore generate it, but we need to update the object
      // For simplicity, we'll use the doc ref ID.
      final docRef = firestore.collection('cars').doc();
      final carWithId = _carToMap(car);
      carWithId['id'] = docRef.id;
      carWithId['createdAt'] = FieldValue.serverTimestamp();
      
      await docRef.set(carWithId);
    } catch (e) {
      throw const ServerFailure('Failed to add car');
    }
  }

  @override
  Future<void> updateCar(CarEntity car) async {
    try {
      await firestore.collection('cars').doc(car.id).update(_carToMap(car));
    } catch (e) {
      throw const ServerFailure('Failed to update car');
    }
  }

  @override
  Future<void> deleteCar(String id) async {
    try {
      await firestore.collection('cars').doc(id).delete();
    } catch (e) {
      throw const ServerFailure('Failed to delete car');
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

  Map<String, dynamic> _carToMap(CarEntity car) {
    return {
      'sellerId': car.sellerId,
      'sellerPhone': car.sellerPhone,
      'make': car.make,
      'model': car.model,
      'year': car.year,
      'price': car.price,
      'mileage': car.mileage,
      'condition': car.condition,
      'location': car.location,
      'description': car.description,
      'images': car.images,
      'status': car.status,
      // 'createdAt': car.createdAt, // Handled by server timestamp on create
    };
  }
  @override
  Future<List<String>> uploadCarImages(List<File> images) async {
    try {
      final List<String> imageUrls = [];
      
      for (final image in images) {
        // Compress image
        File imageToUpload = image;
        try {
          final compressed = await _compressImage(image);
          if (compressed != null) {
            imageToUpload = compressed;
            print('✅ Image compressed: ${image.lengthSync()} -> ${compressed.lengthSync()} bytes');
          }
        } catch (e) {
          print('⚠️ Compression failed, uploading original: $e');
        }

        final String fileName = '${DateTime.now().millisecondsSinceEpoch}_${p.basename(imageToUpload.path)}';
        final Reference ref = storage.ref().child('car_images/$fileName');
        
        final UploadTask uploadTask = ref.putFile(imageToUpload);
        final TaskSnapshot snapshot = await uploadTask;
        final String downloadUrl = await snapshot.ref.getDownloadURL();
        
        imageUrls.add(downloadUrl);
      }
      
      return imageUrls;
    } catch (e) {
      print('❌ Upload failed: $e');
      if (e is FirebaseException) {
        print('❌ Firebase Error Code: ${e.code}');
        print('❌ Firebase Error Message: ${e.message}');
      }
      throw const ServerFailure('Failed to upload images');
    }
  }

  Future<File?> _compressImage(File file) async {
    final filePath = file.absolute.path;
    final lastIndex = filePath.lastIndexOf('.');
    
    // Create a temp path for the compressed file
    final String targetPath = '${filePath.substring(0, lastIndex)}_compressed.jpg';
    
    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 85,
      minWidth: 1080,
      minHeight: 1080,
    );

    if (result == null) return null;
    return File(result.path);
  }

  @override
  Future<void> toggleFavorite(String carId, String userId) async {
    try {
      final userRef = firestore.collection('users').doc(userId);
      final userDoc = await userRef.get();
      
      if (userDoc.exists) {
        final favorites = List<String>.from(userDoc.data()?['favorites'] ?? []);
        if (favorites.contains(carId)) {
          favorites.remove(carId);
        } else {
          favorites.add(carId);
        }
        await userRef.update({'favorites': favorites});
      } else {
        // If user doc doesn't exist for some reason, create it with the favorite
        await userRef.set({'favorites': [carId]}, SetOptions(merge: true));
      }
    } catch (e) {
      throw const ServerFailure('Failed to toggle favorite');
    }
  }

  @override
  Future<List<CarEntity>> getFavorites(String userId) async {
    try {
      final userDoc = await firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return [];

      final favoriteIds = List<String>.from(userDoc.data()?['favorites'] ?? []);
      if (favoriteIds.isEmpty) return [];

      // Firestore 'in' queries are limited to 10 items. 
      // For simplicity in this MVP, we'll fetch them in batches or one by one if needed.
      // A better approach for large lists is to fetch all cars and filter, or store full car objects (not recommended).
      // Here we will fetch by ID for the first 10 for now, or use whereIn if list is small.
      
      // Chunking logic for > 10 items
      List<CarEntity> favoriteCars = [];
      for (var i = 0; i < favoriteIds.length; i += 10) {
        final end = (i + 10 < favoriteIds.length) ? i + 10 : favoriteIds.length;
        final chunk = favoriteIds.sublist(i, end);
        
        final snapshot = await firestore
            .collection('cars')
            .where(FieldPath.documentId, whereIn: chunk)
            .get();
            
        favoriteCars.addAll(snapshot.docs.map((doc) => _carFromSnapshot(doc)));
      }
      
      return favoriteCars;
    } catch (e) {
      throw const ServerFailure('Failed to fetch favorites');
    }
  }
}
