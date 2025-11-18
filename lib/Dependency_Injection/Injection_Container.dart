import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/domain/repositories/auth_repository.dart';
import '../features/data/repositories/auth_repository_impl.dart';
import '../features/presentation/providers/auth_provider.dart';
import 'package:get_it/get_it.dart';
import 'package:pbase_peminjaman_alat_lab/features/data/datasources/alat_datasource.dart';
import 'package:pbase_peminjaman_alat_lab/features/data/datasources/firebase_auth_datasource.dart';
import 'package:pbase_peminjaman_alat_lab/features/data/datasources/user_datasource.dart';
import 'package:pbase_peminjaman_alat_lab/features/data/repositories/alat_repository_impl.dart';
import 'package:pbase_peminjaman_alat_lab/features/data/repositories/user_repository_impl.dart';
import 'package:pbase_peminjaman_alat_lab/features/domain/repositories/alat_repository.dart';
import 'package:pbase_peminjaman_alat_lab/features/domain/repositories/user_repository.dart';
import 'package:pbase_peminjaman_alat_lab/features/domain/usecases/alat_usecases.dart';
import 'package:pbase_peminjaman_alat_lab/features/domain/usecases/auth_usecases.dart';
import 'package:pbase_peminjaman_alat_lab/features/domain/usecases/user_usecases.dart';
import 'package:pbase_peminjaman_alat_lab/features/presentation/providers/alat_provider.dart';
import 'package:pbase_peminjaman_alat_lab/features/presentation/providers/user_provider.dart';

final sl = GetIt.instance;

void setupDependencyInjection() {
  // Firebase instances
  sl.registerLazySingleton<firebase_auth.FirebaseAuth>(
    () => firebase_auth.FirebaseAuth.instance,
  );
  sl.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      sl<firebase_auth.FirebaseAuth>(),
      sl<FirebaseFirestore>(),
    ),
  );

  // Providers - Register as Factory (new instance each time)
  sl.registerFactory(() => AuthProvider(
    sl<AuthRepository>(),
    sl<FirebaseFirestore>(),
  ));
  sl.registerLazySingleton(() => UserProvider(getUser: sl(), updateUser: sl()));
  sl.registerLazySingleton(
    () => AlatProvider(getAlatStream: sl(), getAlatDetail: sl()),
  );
}
