import 'package:pbase_peminjaman_alat_lab/features/domain/entities/user.dart';

abstract class UserRepository {
  Future<User?> getUser(String userId);
  Future<void> updateUser(String userId, Map<String, dynamic> data);
}
