import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pbase_peminjaman_alat_lab/features/data/models/user_model.dart';
import 'package:pbase_peminjaman_alat_lab/features/domain/entities/user.dart';
import 'package:pbase_peminjaman_alat_lab/features/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRepositoryImpl(this._firebaseAuth, this._firestore);

  @override
  Future<User> register(String email, String password, String name) async {
    try {
      print('🔵 REGISTER - Email: $email');
      print('🔵 REGISTER - Name: $name');
      
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw Exception('Registrasi gagal. Silakan coba lagi.');
      }

      // Create user model with the name parameter
      final user = UserModel(
        id: firebaseUser.uid,
        name: name, // Make sure this is the full name from input
        email: firebaseUser.email ?? '',
        role: 'user',
      );

      print('🔵 REGISTER - User Model Created:');
      print('   ID: ${user.id}');
      print('   Name: ${user.name}');
      print('   Email: ${user.email}');
      print('   Role: ${user.role}');

      // Save to Firestore
      await _firestore.collection('users').doc(firebaseUser.uid).set({
        'id': user.id,
        'name': user.name,
        'email': user.email,
        'role': user.role,
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('✅ REGISTER - Data saved to Firestore successfully');

      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw Exception('Email sudah terdaftar. Silakan gunakan email lain.');
        case 'weak-password':
          throw Exception('Password terlalu lemah. Gunakan minimal 6 karakter.');
        case 'invalid-email':
          throw Exception('Format email tidak valid.');
        case 'operation-not-allowed':
          throw Exception('Registrasi tidak diizinkan. Hubungi administrator.');
        default:
          throw Exception('Registrasi gagal: ${e.message}');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Terjadi kesalahan. Silakan coba lagi.');
    }
  }

  @override
  Future<User> login(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw Exception('Login gagal. Silakan coba lagi.');
      }

      // Get user data from Firestore
      final userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();
      
      if (!userDoc.exists) {
        // If user data doesn't exist in Firestore, create default data
        final defaultUser = UserModel(
          id: firebaseUser.uid,
          name: firebaseUser.email?.split('@')[0] ?? 'User',
          email: firebaseUser.email ?? '',
          role: 'user',
        );
        
        await _firestore.collection('users').doc(firebaseUser.uid).set({
          'id': defaultUser.id,
          'name': defaultUser.name,
          'email': defaultUser.email,
          'role': defaultUser.role,
          'createdAt': FieldValue.serverTimestamp(),
        });
        
        return defaultUser;
      }

      // Convert Firestore data to UserModel
      final userData = userDoc.data()!;
      return UserModel(
        id: userData['id'] ?? firebaseUser.uid,
        name: userData['name'] ?? 'User',
        email: userData['email'] ?? firebaseUser.email ?? '',
        role: userData['role'] ?? 'user',
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw Exception('Email tidak terdaftar. Silakan daftar terlebih dahulu.');
        case 'wrong-password':
          throw Exception('Password salah. Silakan coba lagi.');
        case 'invalid-email':
          throw Exception('Format email tidak valid.');
        case 'user-disabled':
          throw Exception('Akun Anda telah dinonaktifkan. Hubungi administrator.');
        case 'too-many-requests':
          throw Exception('Terlalu banyak percobaan login. Coba lagi nanti.');
        case 'invalid-credential':
          throw Exception('Email atau password salah. Silakan periksa kembali.');
        default:
          throw Exception('Login gagal: ${e.message}');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Terjadi kesalahan. Silakan coba lagi.');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  firebase_auth.User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  @override
  Stream<firebase_auth.User?> authStateChanges() {
    return _firebaseAuth.authStateChanges();
  }
}
