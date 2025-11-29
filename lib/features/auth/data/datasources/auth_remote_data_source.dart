import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../domain/entities/user_entity.dart';
import 'dart:math';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../../../core/error/failures.dart';

abstract class AuthRemoteDataSource {
  Future<UserEntity> login(String email, String password);
  Future<UserEntity> signInWithGoogle();
  Future<UserEntity> signInWithApple();
  Future<UserEntity> register(
    String email,
    String password,
    String name,
    String phone,
    String role, {
    String? businessName,
    String? businessLicense,
    String? taxId,
    String? businessAddress,
  });
  Future<void> logout();
  Future<UserEntity> getCurrentUser();
  Future<UserEntity> updateProfile({
    String? name,
    String? phone,
    File? photo,
  });
  Future<void> sendPasswordResetEmail(String email);
  Future<void> deleteAccount();
  Future<void> blockUser(String userId);
  Future<void> unblockUser(String userId);
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  final GoogleSignIn googleSignIn;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
    required this.storage,
    required this.googleSignIn,
  });

  // ... existing methods ...

  @override
  Future<void> blockUser(String userId) async {
    final user = firebaseAuth.currentUser;
    if (user == null) throw const AuthFailure('No user logged in');
    
    await firestore.collection('users').doc(user.uid).update({
      'blockedUsers': FieldValue.arrayUnion([userId]),
    });
  }

  @override
  Future<void> unblockUser(String userId) async {
    final user = firebaseAuth.currentUser;
    if (user == null) throw const AuthFailure('No user logged in');
    
    await firestore.collection('users').doc(user.uid).update({
      'blockedUsers': FieldValue.arrayRemove([userId]),
    });
  }

  @override
  Future<void> deleteAccount() async {
    final user = firebaseAuth.currentUser;
    if (user == null) {
      throw const AuthFailure('No user logged in');
    }

    try {
      // 1. Delete user data from Firestore
      await firestore.collection('users').doc(user.uid).delete();
      
      // 2. Delete user auth record
      // This requires recent login. If it fails, we catch the error.
      await user.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw const AuthFailure('Please log in again to delete your account.');
      }
      throw AuthFailure(e.message ?? 'Failed to delete account');
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<UserEntity> login(String email, String password) async {
    try {
      debugPrint('🔑 Login started for: $email');
      final result = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (result.user == null) {
        print('❌ Firebase Auth returned null user during login');
        throw const ServerFailure('User not found');
      }

      print('✅ Firebase Auth login successful: ${result.user!.uid}');
      print('📥 Fetching user data from Firestore...');
      
      return await _getUserData(result.user!.uid);
    } on FirebaseAuthException catch (e) {
      print('❌ Login FirebaseAuthException: ${e.code} - ${e.message}');
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found for that email.';
          break;
        case 'wrong-password':
          errorMessage = 'Wrong password provided.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is invalid.';
          break;
        case 'user-disabled':
          errorMessage = 'This user has been disabled.';
          break;
        case 'invalid-credential':
          errorMessage = 'Invalid credentials. Please check your email and password.';
          break;
        default:
          errorMessage = e.message ?? 'Login failed';
      }
      throw AuthFailure(errorMessage);
    } catch (e) {
      print('❌ Unexpected login error: $e');
      throw const ServerFailure('Something went wrong');
    }
  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    try {
      print('🌐 Starting Google Sign-In...');
      // Use authenticate() instead of signIn()
      final GoogleSignInAccount googleUser = await googleSignIn.authenticate();
      
      print('✅ Google User obtained: ${googleUser.email}');
      
      // Get ID Token
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Get Access Token (separated in v7.x)
      // We assume default scopes are sufficient for login
      final GoogleSignInClientAuthorization? authz = 
          await googleUser.authorizationClient.authorizationForScopes([]);
          
      if (authz == null) {
        throw const AuthFailure('Failed to get Google authorization tokens');
      }

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: authz.accessToken,
        idToken: googleAuth.idToken,
      );

      print('🔐 Signing in to Firebase with Google credential...');
      final UserCredential userCredential = await firebaseAuth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user == null) {
        throw const ServerFailure('Firebase Sign-In failed');
      }

      print('✅ Firebase Sign-In successful: ${user.uid}');
      
      // Check if user exists in Firestore
      final docSnapshot = await firestore.collection('users').doc(user.uid).get();

      if (docSnapshot.exists) {
        print('📥 Existing user found in Firestore');
        return await _getUserData(user.uid);
      } else {
        print('🆕 New user! Creating Firestore document...');
        // Create new user
        final newUser = UserEntity(
          uid: user.uid,
          name: user.displayName ?? 'No Name',
          email: user.email ?? '',
          phone: '', // Google doesn't provide phone, will be handled by Complete Profile
          role: 'buyer', // Default role
          createdAt: DateTime.now(),
          photoUrl: user.photoURL,
          isVerified: false,
        );

        final userData = <String, dynamic>{
          'uid': newUser.uid,
          'name': newUser.name,
          'email': newUser.email,
          'phone': newUser.phone,
          'role': newUser.role,
          'isVerified': newUser.isVerified,
          'createdAt': FieldValue.serverTimestamp(),
          'photoUrl': newUser.photoUrl,
          'isBanned': false,
        };

        await firestore.collection('users').doc(user.uid).set(userData);
        print('✅ New user document created');
        
        return newUser;
      }
    } on GoogleSignInException catch (e) {
      print('❌ GoogleSignInException: ${e.code} - ${e.toString()}');
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw const AuthFailure('Google Sign-In cancelled');
      }
      throw AuthFailure(e.toString());
    } on FirebaseAuthException catch (e) {
      print('❌ FirebaseAuthException: ${e.message}');
      throw AuthFailure(e.message ?? 'Google Sign-In failed');
    } catch (e) {
      print('❌ Unexpected error during Google Sign-In: $e');
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<UserEntity> signInWithApple() async {
    try {
      print('🍎 Starting Apple Sign-In...');
      final rawNonce = generateNonce();
      final nonce = sha256ofString(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      final OAuthProvider oAuthProvider = OAuthProvider('apple.com');
      final AuthCredential credential = oAuthProvider.credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
        rawNonce: rawNonce,
      );

      print('🔐 Signing in to Firebase with Apple credential...');
      final UserCredential userCredential = await firebaseAuth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user == null) {
        throw const ServerFailure('Firebase Sign-In failed');
      }

      print('✅ Firebase Sign-In successful: ${user.uid}');
      
      // Check if user exists in Firestore
      final docSnapshot = await firestore.collection('users').doc(user.uid).get();

      if (docSnapshot.exists) {
        print('📥 Existing user found in Firestore');
        return await _getUserData(user.uid);
      } else {
        print('🆕 New user! Creating Firestore document...');
        
        // Apple only provides name on the FIRST sign-in.
        // We try to get it from the credential, otherwise fallback to "Apple User"
        String name = 'Apple User';
        if (appleCredential.givenName != null) {
          name = '${appleCredential.givenName} ${appleCredential.familyName ?? ''}'.trim();
        } else if (user.displayName != null && user.displayName!.isNotEmpty) {
          name = user.displayName!;
        }

        // Create new user
        final newUser = UserEntity(
          uid: user.uid,
          name: name,
          email: user.email ?? '',
          phone: '', // Apple doesn't provide phone, will be handled by Complete Profile
          role: 'buyer', // Default role
          createdAt: DateTime.now(),
          photoUrl: user.photoURL,
          isVerified: false,
        );

        final userData = <String, dynamic>{
          'uid': newUser.uid,
          'name': newUser.name,
          'email': newUser.email,
          'phone': newUser.phone,
          'role': newUser.role,
          'isVerified': newUser.isVerified,
          'createdAt': FieldValue.serverTimestamp(),
          'photoUrl': newUser.photoUrl,
          'isBanned': false,
        };

        await firestore.collection('users').doc(user.uid).set(userData);
        print('✅ New user document created');
        
        return newUser;
      }
    } on FirebaseAuthException catch (e) {
      print('❌ FirebaseAuthException: ${e.message}');
      throw AuthFailure(e.message ?? 'Apple Sign-In failed');
    } catch (e) {
      print('❌ Unexpected error during Apple Sign-In: $e');
      if (e.toString().contains('Canceled')) {
         throw const AuthFailure('Apple Sign-In cancelled');
      }
      throw ServerFailure(e.toString());
    }
  }

  /// Generates a cryptographically secure random nonce, to be included in a
  /// credential request.
  String generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  @override
  Future<UserEntity> register(
    String email,
    String password,
    String name,
    String phone,
    String role, {
    String? businessName,
    String? businessLicense,
    String? taxId,
    String? businessAddress,
  }) async {
    try {
      print('📝 Creating Firebase Auth user...');
      final result = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user == null) {
        print('❌ Firebase Auth returned null user');
        throw const ServerFailure('Registration failed');
      }

      print('✅ Firebase Auth user created: ${result.user!.uid}');

      final userEntity = UserEntity(
        uid: result.user!.uid,
        name: name,
        email: email,
        phone: phone,
        role: role,
        createdAt: DateTime.now(),
        isVerified: false,
        businessName: businessName,
        businessLicense: businessLicense,
        taxId: taxId,
        businessAddress: businessAddress,
      );

      print('💾 Saving user data to Firestore...');
      final userData = <String, dynamic>{
        'uid': userEntity.uid,
        'name': userEntity.name,
        'email': userEntity.email,
        'phone': userEntity.phone,
        'role': userEntity.role,
        'isVerified': userEntity.isVerified,
        'createdAt': FieldValue.serverTimestamp(),
      };
      
      // Add trader-specific fields if provided
      if (businessName != null) userData['businessName'] = businessName;
      if (businessLicense != null) userData['businessLicense'] = businessLicense;
      if (taxId != null) userData['taxId'] = taxId;
      if (businessAddress != null) userData['businessAddress'] = businessAddress;
      
      await firestore.collection('users').doc(userEntity.uid).set(userData);

      print('✅ User data saved to Firestore');
      return userEntity;
    } on FirebaseAuthException catch (e) {
      print('❌ FirebaseAuthException: ${e.code} - ${e.message}');
      // Provide specific error messages
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'This email is already registered';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Email/password accounts are not enabled. Please enable them in Firebase Console.';
          break;
        case 'weak-password':
          errorMessage = 'Password is too weak';
          break;
        default:
          errorMessage = e.message ?? 'Registration failed';
      }
      throw AuthFailure(errorMessage);
    } catch (e) {
      print('❌ Unexpected error: $e');
      throw ServerFailure('Something went wrong: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    await firebaseAuth.signOut();
  }

  @override
  Future<UserEntity> getCurrentUser() async {
    final user = firebaseAuth.currentUser;
    if (user == null) {
      throw const AuthFailure('No user logged in');
    }
    return await _getUserData(user.uid);
  }

  @override
  Future<UserEntity> updateProfile({
    String? name,
    String? phone,
    File? photo,
  }) async {
    final user = firebaseAuth.currentUser;
    if (user == null) {
      throw const AuthFailure('No user logged in');
    }

    final updates = <String, dynamic>{};
    
    if (name != null) {
      updates['name'] = name;
      // Update display name in Firebase Auth
      await user.updateDisplayName(name);
    }
    
    if (phone != null) {
      updates['phone'] = phone;
    }

    if (photo != null) {
      // Upload photo to Firebase Storage
      final ref = storage.ref().child('user_avatars/${user.uid}.jpg');
      await ref.putFile(photo);
      final photoUrl = await ref.getDownloadURL();
      
      updates['photoUrl'] = photoUrl;
      // Update photo URL in Firebase Auth
      await user.updatePhotoURL(photoUrl);
    }

    if (updates.isNotEmpty) {
      await firestore.collection('users').doc(user.uid).update(updates);
    }

    return await _getUserData(user.uid);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(e.message ?? 'Failed to send password reset email');
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  Future<UserEntity> _getUserData(String uid) async {
    final doc = await firestore.collection('users').doc(uid).get();
    if (!doc.exists) {
      throw const ServerFailure('User data not found');
    }
    final data = doc.data()!;
    return UserEntity(
      uid: data['uid'],
      name: data['name'],
      email: data['email'],
      phone: data['phone'],
      role: data['role'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isVerified: data['isVerified'] ?? false,
      businessName: data['businessName'],
      businessLicense: data['businessLicense'],
      taxId: data['taxId'],
      businessAddress: data['businessAddress'],
      isBanned: data['isBanned'] ?? false,
      bannedAt: (data['bannedAt'] as Timestamp?)?.toDate(),
      bannedBy: data['bannedBy'],
      banReason: data['banReason'],
      photoUrl: data['photoUrl'],
      blockedUsers: List<String>.from(data['blockedUsers'] ?? []),
    );
  }
}
