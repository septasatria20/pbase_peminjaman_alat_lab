import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pbase_peminjaman_alat_lab/features/domain/repositories/auth_repository.dart';
import 'package:pbase_peminjaman_alat_lab/features/domain/entities/user.dart';

import 'package:pbase_peminjaman_alat_lab/features/domain/repositories/user_repository.dart';

// Manual Mock for UserRepository
class MockUserRepository extends Fake implements UserRepository {
  @override
  Future<User?> getUser(String userId) async {
    if (userId == 'test-uid') {
      return const User(
        id: 'test-uid',
        name: 'Test User',
        email: 'test@example.com',
        role: 'user',
        lab: 'Mobile',
      );
    }
    return null;
  }
}

// Manual Mock for Firebase User
class MockFirebaseUser extends Fake implements firebase_auth.User {
  @override
  String get uid => 'test-uid';
  @override
  String? get email => 'test@example.com';
}

// Manual Mock for AuthRepository
class MockAuthRepository extends Fake implements AuthRepository {
  final _controller = StreamController<firebase_auth.User?>.broadcast();
  firebase_auth.User? _mockFirebaseUser;

  @override
  Stream<firebase_auth.User?> authStateChanges() => _controller.stream;

  @override
  Future<User> login(String email, String password) async {
    if (email == 'test@example.com' && password == 'password') {
      _mockFirebaseUser = MockFirebaseUser();
      return const User(
        id: 'test-uid',
        name: 'Test User',
        email: 'test@example.com',
        role: 'user',
      );
    }
    throw Exception('Invalid credentials');
  }

  @override
  Future<User> register(String email, String password, String name) async {
    if (email == 'new@example.com') {
      _mockFirebaseUser = MockFirebaseUser();
      return User(
        id: 'new-uid',
        name: name,
        email: email,
        role: 'user',
      );
    }
    throw Exception('Email already in use');
  }

  @override
  firebase_auth.User? getCurrentUser() {
    return _mockFirebaseUser; 
  }

  
  @override
  Future<void> signOut() async {
    _controller.add(null);
  }

  // Helper to emit state change
  void emitUser(firebase_auth.User? user) {
    _controller.add(user);
  }
}

