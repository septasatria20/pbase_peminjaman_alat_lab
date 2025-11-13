import 'package:pbase_peminjaman_alat_lab/features/domain/entities/user.dart';

abstract class AuthRepository {
  Future<User> register(String email, String password, String name);
  Future<User> login(String email, String password);
  Future<void> sendPasswordResetEmail(String email);
  Future<void> signOut();
}
