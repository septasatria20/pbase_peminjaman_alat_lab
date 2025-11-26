import 'package:flutter/material.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/entities/user.dart';

class UserProvider extends ChangeNotifier {
  final UserRepository _userRepository;
  
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserProvider(this._userRepository);

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Add methods as needed
}
