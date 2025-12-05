import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user.dart' as domain;
import '../../data/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  final FirebaseFirestore _firestore;
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  
  firebase_auth.User? _firebaseUser;
  domain.User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isInitialized = false;

  AuthProvider(this._authRepository, this._firestore) {
    _initAuth();
  }

  firebase_auth.User? get firebaseUser => _firebaseUser;
  domain.User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _firebaseUser != null;
  bool get isInitialized => _isInitialized;
  String? get userRole => _currentUser?.role;
  String? get userLab => _currentUser?.lab; // NEW
  bool get isAdmin => _currentUser?.role == 'admin';
  bool get isUser => _currentUser?.role == 'user';

  void _initAuth() {
    print('AuthProvider - Initializing auth listener...');
    _authRepository.authStateChanges().listen((user) async {
      print('Auth state changed. User: ${user?.email ?? "null"}');
      _firebaseUser = user;
      
      if (user != null) {
        print('Loading user data for: ${user.uid}');
        await _loadUserData(user.uid);
      } else {
        print('No user logged in');
        _currentUser = null;
      }
      
      _isInitialized = true;
      print('Auth initialized. Authenticated: ${_firebaseUser != null}');
      notifyListeners();
    }, onError: (error) {
      print('Auth state change error: $error');
      _isInitialized = true;
      notifyListeners();
    });
  }

  Future<void> _loadUserData(String userId) async {
    try {
      print('Loading user data for: $userId');
      final userDoc = await _firestore.collection('users').doc(userId).get();
      
      if (userDoc.exists) {
        final data = userDoc.data()!;
        _currentUser = UserModel(
          id: data['id'] ?? userId,
          name: data['name'] ?? 'User',
          email: data['email'] ?? '',
          role: data['role'] ?? 'user',
          lab: data['lab'], // ADD THIS LINE
        );
        print('User loaded successfully: ${_currentUser?.name}');
        print('   Role: ${_currentUser?.role}');
        print('   Lab: ${_currentUser?.lab ?? "N/A"}'); // ADD THIS LINE
        notifyListeners();
      } else {
        print('User document does not exist for $userId');
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('Starting login...');
      final user = await _authRepository.login(email, password);
      _currentUser = user;
      _firebaseUser = _authRepository.getCurrentUser();
      
      print('Login successful');
      print('User ID: ${user.id}');
      print('User Name: ${user.name}');
      print('User Email: ${user.email}');
      
      _isLoading = false;
      notifyListeners();
      
      // Reload user data from Firestore to ensure it's fresh
      await _loadUserData(user.id);
      
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      print('Login error: $e');
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String email, String password, String name) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('AuthProvider - Starting registration...');
      print('   Email: $email');
      print('   Name: $name');
      
      final user = await _authRepository.register(email, password, name);
      _currentUser = user;
      _firebaseUser = _authRepository.getCurrentUser();
      
      print('AuthProvider - Registration successful');
      print('   User ID: ${user.id}');
      print('   User Name: ${user.name}');
      print('   User Email: ${user.email}');
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      print('AuthProvider - Register error: $e');
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
    _currentUser = null;
    _firebaseUser = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Update user name
  Future<void> updateUserName(String newName) async {
    try {
      if (_currentUser == null) {
        throw Exception('No user logged in');
      }

      await _firestore.collection('users').doc(_currentUser!.id).update({
        'name': newName,
      });

      _currentUser = _currentUser!.copyWith(name: newName);
      notifyListeners();

      print('[AuthProvider] User name updated successfully');
    } catch (e) {
      print('[AuthProvider] Error updating user name: $e');
      throw Exception('Gagal mengubah nama: $e');
    }
  }

  // Update password
  Future<void> updatePassword(String currentPassword, String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        throw Exception('No user logged in');
      }

      // Re-authenticate user with current password
      final credential = firebase_auth.EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);

      print('[AuthProvider] Password updated successfully');
    } on firebase_auth.FirebaseAuthException catch (e) {
      print('[AuthProvider] Error updating password: ${e.code}');
      
      if (e.code == 'wrong-password') {
        throw Exception('Password saat ini salah');
      } else if (e.code == 'weak-password') {
        throw Exception('Password terlalu lemah');
      } else if (e.code == 'requires-recent-login') {
        throw Exception('Silakan login ulang untuk mengubah password');
      } else {
        throw Exception('Gagal mengubah password: ${e.message}');
      }
    } catch (e) {
      print('[AuthProvider] Error updating password: $e');
      throw Exception('Gagal mengubah password: $e');
    }
  }
}
