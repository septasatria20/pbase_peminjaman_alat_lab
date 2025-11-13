import 'package:pbase_peminjaman_alat_lab/features/data/datasources/user_datasource.dart';
import 'package:pbase_peminjaman_alat_lab/features/data/models/user_model.dart';
import 'package:pbase_peminjaman_alat_lab/features/domain/entities/user.dart';
import 'package:pbase_peminjaman_alat_lab/features/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UserDataSource _dataSource;

  UserRepositoryImpl(this._dataSource);

  @override
  Future<User?> getUser(String userId) async {
    final data = await _dataSource.getUserData(userId);
    if (data != null) {
      return UserModel.fromJson(userId, data);
    }
    return null;
  }

  @override
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    await _dataSource.updateUserData(userId, data);
  }
}
