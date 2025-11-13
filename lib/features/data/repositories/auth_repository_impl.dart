import 'package:pbase_peminjaman_alat_lab/features/data/datasources/firebase_auth_datasource.dart';
import 'package:pbase_peminjaman_alat_lab/features/data/models/user_model.dart';
import 'package:pbase_peminjaman_alat_lab/features/domain/entities/user.dart';
import 'package:pbase_peminjaman_alat_lab/features/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource _dataSource;

  AuthRepositoryImpl(this._dataSource);

  @override
  Future<User> register(String email, String password, String name) async {
    final firebaseUser = await _dataSource.register(email, password);
    if (firebaseUser == null) {
      throw Exception('Registration failed');
    }
    final user = UserModel(
      id: firebaseUser.uid,
      name: name,
      email: firebaseUser.email ?? '',
      role: 'user',
    );
    return user;
  }

  @override
  Future<User> login(String email, String password) async {
    final firebaseUser = await _dataSource.login(email, password);
    if (firebaseUser == null) {
      throw Exception('Login failed');
    }
    return UserModel(
      id: firebaseUser.uid,
      name: 'Default Name', // Replace with actual data
      email: firebaseUser.email ?? '',
      role: 'user',
    );
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _dataSource.sendPasswordResetEmail(email);
  }

  @override
  Future<void> signOut() async {
    await _dataSource.signOut();
  }


}
