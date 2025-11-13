import 'package:pbase_peminjaman_alat_lab/features/domain/entities/user.dart';
import 'package:pbase_peminjaman_alat_lab/features/domain/repositories/auth_repository.dart';

class RegisterUser {
  final AuthRepository repository;

  RegisterUser(this.repository);

  Future<User> call(String email, String password, String name) {
    return repository.register(email, password, name);
  }
}

class LoginUser {
  final AuthRepository repository;

  LoginUser(this.repository);

  Future<User> call(String email, String password) {
    return repository.login(email, password);
  }
}

class SendPasswordResetEmail {
  final AuthRepository repository;

  SendPasswordResetEmail(this.repository);

  Future<void> call(String email) {
    return repository.sendPasswordResetEmail(email);
  }
}

class SignOut {
  final AuthRepository repository;

  SignOut(this.repository);

  Future<void> call() {
    return repository.signOut();
  }
}



