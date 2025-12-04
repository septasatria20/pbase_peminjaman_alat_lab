import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';

// Auth
import '../features/domain/repositories/auth_repository.dart';
import '../features/data/repositories/auth_repository_impl.dart';
import '../features/presentation/providers/auth_provider.dart';

// User
import '../features/domain/repositories/user_repository.dart';
import '../features/data/repositories/user_repository_impl.dart';
import '../features/presentation/providers/user_provider.dart';

// Alat
import '../features/domain/repositories/alat_repository.dart';
import '../features/data/repositories/alat_repository_impl.dart';
import '../features/presentation/providers/alat_provider.dart';

final sl = GetIt.instance;

void setupDependencyInjection() {
  print('Setting up Dependency Injection...');

  // ===== Firebase Instances =====
  sl.registerLazySingleton<firebase_auth.FirebaseAuth>(
    () => firebase_auth.FirebaseAuth.instance,
  );
  
  sl.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );

  // ===== Repositories =====
  
  // Auth Repository
  sl.registerLazySingleton<AuthRepository>(
    () {
      print('Registering AuthRepository');
      return AuthRepositoryImpl(
        sl<firebase_auth.FirebaseAuth>(),
        sl<FirebaseFirestore>(),
      );
    },
  );

  // User Repository
  sl.registerLazySingleton<UserRepository>(
    () {
      print('Registering UserRepository');
      return UserRepositoryImpl(sl<FirebaseFirestore>());
    },
  );

  // Alat Repository
  sl.registerLazySingleton<AlatRepository>(
    () {
      print('Registering AlatRepository');
      return AlatRepositoryImpl(sl<FirebaseFirestore>());
    },
  );

  // ===== Providers =====
  
  // Auth Provider
  sl.registerFactory(() {
    print('Creating AuthProvider');
    return AuthProvider(
      sl<AuthRepository>(),
      sl<UserRepository>(),
    );
  });

  // User Provider
  sl.registerFactory(() {
    print('Creating UserProvider');
    return UserProvider(sl<UserRepository>());
  });

  // Alat Provider
  sl.registerFactory(() {
    print('Creating AlatProvider');
    return AlatProvider(sl<AlatRepository>());
  });

  print('Dependency Injection setup completed\n');
}
