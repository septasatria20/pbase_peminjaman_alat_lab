import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/entities/user.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  final FirebaseFirestore _firestore;

  UserRepositoryImpl(this._firestore);

  @override
  Future<User?> getUser(String userId) async {
    return getUserById(userId);
  }

  @override
  Future<User?> getUserById(String id) async {
    try {
      final doc = await _firestore.collection('users').doc(id).get();
      if (!doc.exists) return null;
      return UserModel.fromJson(doc.id, doc.data()!);
    } catch (e) {
      print('❌ Error getting user: $e');
      return null;
    }
  }

  @override
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(userId).update(data);
      print('✅ User updated successfully');
    } catch (e) {
      print('❌ Error updating user: $e');
      rethrow;
    }
  }
}
