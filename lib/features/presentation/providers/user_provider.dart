import 'package:flutter/material.dart';
import 'package:pbase_peminjaman_alat_lab/features/domain/entities/user.dart';
import 'package:pbase_peminjaman_alat_lab/features/domain/usecases/user_usecases.dart';

class UserProvider with ChangeNotifier {
  final GetUser getUser;
  final UpdateUser updateUser;

  UserProvider({required this.getUser, required this.updateUser});

  User? _user;
  User? get user => _user;

  Future<void> fetchUser(String userId) async {
    _user = await getUser(userId);
    notifyListeners();
  }

  Future<void> updateUserData(String userId, Map<String, dynamic> data) async {
    await updateUser(userId, data);
    await fetchUser(userId);
  }
}
