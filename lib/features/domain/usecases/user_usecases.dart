import 'package:pbase_peminjaman_alat_lab/features/domain/entities/user.dart';
import 'package:pbase_peminjaman_alat_lab/features/domain/repositories/user_repository.dart';

class GetUser {
  final UserRepository repository;

  GetUser(this.repository);

  Future<User?> call(String userId) {
    return repository.getUser(userId);
  }
}

class UpdateUser {
  final UserRepository repository;

  UpdateUser(this.repository);

  Future<void> call(String userId, Map<String, dynamic> data) {
    return repository.updateUser(userId, data);
  }
}
