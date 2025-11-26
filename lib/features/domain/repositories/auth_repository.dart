import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> register(String email, String password, String name);
  Future<User> login(String email, String password);
  Future<void> sendPasswordResetEmail(String email);
  Future<void> signOut();
  firebase_auth.User? getCurrentUser();
  Stream<firebase_auth.User?> authStateChanges();
}
