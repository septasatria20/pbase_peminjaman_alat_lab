import 'package:flutter/material.dart';
import 'package:pbase_peminjaman_alat_lab/features/domain/entities/user.dart';
import 'package:pbase_peminjaman_alat_lab/features/domain/usecases/auth_usecases.dart';

class AuthProvider with ChangeNotifier {
  final RegisterUser registerUser;
  final LoginUser loginUser;
  final SendPasswordResetEmail sendPasswordResetEmail;
  final SignOut signOut;

  AuthProvider({
    required this.registerUser,
    required this.loginUser,
    required this.sendPasswordResetEmail,
    required this.signOut,
  });

  User? _user;
  User? get user => _user;

  Future<void> register(String email, String password, String name) async {
    _user = await registerUser(email, password, name);
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _user = await loginUser(email, password);
    notifyListeners();
  }

  Future<void> logout() async {
    await signOut();
    _user = null;
    notifyListeners();
  }
}
