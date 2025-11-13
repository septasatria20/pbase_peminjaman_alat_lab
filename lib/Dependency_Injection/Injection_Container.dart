import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:pbase_peminjaman_alat_lab/features/data/datasources/alat_datasource.dart';
import 'package:pbase_peminjaman_alat_lab/features/data/datasources/firebase_auth_datasource.dart';
import 'package:pbase_peminjaman_alat_lab/features/data/datasources/user_datasource.dart';
import 'package:pbase_peminjaman_alat_lab/features/data/repositories/alat_repository_impl.dart';
import 'package:pbase_peminjaman_alat_lab/features/data/repositories/auth_repository_impl.dart';
import 'package:pbase_peminjaman_alat_lab/features/data/repositories/user_repository_impl.dart';
import 'package:pbase_peminjaman_alat_lab/features/domain/repositories/alat_repository.dart';
import 'package:pbase_peminjaman_alat_lab/features/domain/repositories/auth_repository.dart';
import 'package:pbase_peminjaman_alat_lab/features/domain/repositories/user_repository.dart';
import 'package:pbase_peminjaman_alat_lab/features/domain/usecases/alat_usecases.dart';
import 'package:pbase_peminjaman_alat_lab/features/domain/usecases/auth_usecases.dart';
import 'package:pbase_peminjaman_alat_lab/features/domain/usecases/user_usecases.dart';
import 'package:pbase_peminjaman_alat_lab/features/presentation/providers/alat_provider.dart';
import 'package:pbase_peminjaman_alat_lab/features/presentation/providers/auth_provider.dart';
import 'package:pbase_peminjaman_alat_lab/features/presentation/providers/user_provider.dart';

final sl = GetIt.instance;

void setupDependencyInjection() {
  // Firebase
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);

  // Data Sources
  sl.registerLazySingleton(() => FirebaseAuthDataSource());
  sl.registerLazySingleton(() => UserDataSource());
  sl.registerLazySingleton(() => AlatDataSource());

  // Repositories
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerLazySingleton<UserRepository>(() => UserRepositoryImpl(sl()));
  sl.registerLazySingleton<AlatRepository>(() => AlatRepositoryImpl(sl()));

  // Use Cases
  sl.registerLazySingleton(() => RegisterUser(sl()));
  sl.registerLazySingleton(() => LoginUser(sl()));
  sl.registerLazySingleton(() => SendPasswordResetEmail(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));
  sl.registerLazySingleton(() => GetUser(sl()));
  sl.registerLazySingleton(() => UpdateUser(sl()));
  sl.registerLazySingleton(() => GetAlatStream(sl()));
  sl.registerLazySingleton(() => GetAlatDetail(sl()));

  // Providers
  sl.registerLazySingleton(
    () => AuthProvider(
      registerUser: sl(),
      loginUser: sl(),
      sendPasswordResetEmail: sl(),
      signOut: sl(),
    ),
  );
  sl.registerLazySingleton(() => UserProvider(getUser: sl(), updateUser: sl()));
  sl.registerLazySingleton(
    () => AlatProvider(getAlatStream: sl(), getAlatDetail: sl()),
  );
}
