import '../entities/user.dart';

abstract class UserRepository {
  Future<User?> getUser(String userId);
  Future<User?> getUserById(String id);
  Future<void> updateUser(String userId, Map<String, dynamic> data);
}
