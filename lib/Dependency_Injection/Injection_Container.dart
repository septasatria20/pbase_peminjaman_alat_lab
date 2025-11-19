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
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

void setupDependencyInjection() {
  print('🔵 Setting up Dependency Injection...');

  // Firebase instances
  sl.registerLazySingleton<firebase_auth.FirebaseAuth>(
    () => firebase_auth.FirebaseAuth.instance,
  );
  sl.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );

  // ===== Auth =====
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      sl<firebase_auth.FirebaseAuth>(),
      sl<FirebaseFirestore>(),
    ),
  );

  sl.registerFactory(() => AuthProvider(
    sl<AuthRepository>(),
    sl<FirebaseFirestore>(),
  ));

  // ===== User =====
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(sl<FirebaseFirestore>()),
  );

  sl.registerFactory(() => UserProvider(sl<UserRepository>()));

  // ===== Alat =====
  sl.registerLazySingleton<AlatRepository>(
    () => AlatRepositoryImpl(sl<FirebaseFirestore>()),
  );

  sl.registerFactory(() => AlatProvider(sl<AlatRepository>()));

  print('✅ Dependency Injection setup completed');
}
