import 'package:flutter_test/flutter_test.dart';
import 'package:pbase_peminjaman_alat_lab/features/presentation/providers/auth_provider.dart';
import 'mocks.dart';

void main() {
  late AuthProvider authProvider;
  late MockAuthRepository mockAuthRepository;
  late MockUserRepository mockUserRepository;

  // Persiapan awal sebelum setiap tes dijalankan (Arrange)
  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockUserRepository = MockUserRepository();
    authProvider = AuthProvider(mockAuthRepository, mockUserRepository);
  });

  group('Pengujian Unit AuthProvider', () {
    // Tes Unit 1: Verifikasi Status Awal
    // Tujuannya memastikan bahwa ketika aplikasi baru dibuka, user belum login.
    test('Tes Unit 1: Status awal harus belum terautentikasi (unauthenticated)', () {
      print('\n[Tes Unit 1] Memulai verifikasi status awal...');
      
      // Assert (Verifikasi)
      expect(authProvider.isAuthenticated, false, reason: 'User seharusnya belum login');
      expect(authProvider.currentUser, null, reason: 'Data user harus kosong');
      expect(authProvider.isLoading, false, reason: 'Loading indicator harus mati');
      
      print('[Tes Unit 1] Sukses: Status awal sesuai ekspektasi.');
    });

    // Tes Unit 2: Skenario Login Berhasil
    // Tujuannya memastikan state provider diperbarui dengan benar saat login sukses.
    test('Tes Unit 2: Fungsi signIn harus memperbarui state ketika login berhasil', () async {
      print('\n[Tes Unit 2] Memulai simulasi login berhasil...');
      
      // Act (Tindakan)
      final success = await authProvider.signIn('test@example.com', 'password');

      // Assert (Verifikasi)
      expect(success, true, reason: 'Fungsi signIn harus mengembalikan true');
      expect(authProvider.isLoading, false, reason: 'Loading harus berhenti setelah selesai');
      expect(authProvider.errorMessage, null, reason: 'Tidak boleh ada pesan error');
      
      // Menunggu proses asinkron pengambilan data user
      await Future.delayed(Duration.zero);
      
      expect(authProvider.currentUser, isNotNull, reason: 'Data user harus terisi');
      expect(authProvider.currentUser!.email, 'test@example.com');
      expect(authProvider.currentUser!.role, 'user');
      
      print('[Tes Unit 2] Sukses: User berhasil login dan data tersimpan di state.');
    });

    // Tes Unit 3: Skenario Login Gagal
    // Tujuannya memastikan sistem menangani kesalahan input kredensial dengan benar.
    test('Tes Unit 3: Fungsi signIn harus mengisi errorMessage ketika login gagal', () async {
      print('\n[Tes Unit 3] Memulai simulasi login gagal...');
      
      // Act (Tindakan) - Login dengan email salah
      final success = await authProvider.signIn('wrong@example.com', 'password');

      // Assert (Verifikasi)
      expect(success, false, reason: 'Fungsi signIn harus mengembalikan false');
      expect(authProvider.isLoading, false);
      expect(authProvider.errorMessage, contains('Invalid credentials'), reason: 'Pesan error harus sesuai');
      expect(authProvider.currentUser, null, reason: 'User tidak boleh terisi');
      
      print('[Tes Unit 3] Sukses: Error message terisi dengan benar.');
    });

    // Tes Unit 4: Skenario Register Berhasil
    // Tujuannya memastikan user baru bisa mendaftar dan langsung masuk.
    test('Tes Unit 4: Fungsi register harus membuat user baru dan login otomatis', () async {
      print('\n[Tes Unit 4] Memulai simulasi register user baru...');
      
      // Act (Tindakan)
      final success = await authProvider.register('new@example.com', 'password123', 'New User');

      // Assert (Verifikasi)
      expect(success, true);
      expect(authProvider.currentUser, isNotNull);
      expect(authProvider.currentUser!.name, 'New User');
      expect(authProvider.currentUser!.email, 'new@example.com');
      
      print('[Tes Unit 4] Sukses: User baru berhasil dibuat dan login.');
    });

    // Tes Unit 5: Skenario Register Gagal
    // Tujuannya memastikan validasi email duplikat berjalan.
    test('Tes Unit 5: Fungsi register harus menangani error jika email sudah terpakai', () async {
      print('\n[Tes Unit 5] Memulai simulasi register dengan email duplikat...');
      
      // Act (Tindakan) - Register dengan email yang disimulasikan sudah ada
      final success = await authProvider.register('existing@example.com', 'password', 'User');

      // Assert (Verifikasi)
      expect(success, false);
      expect(authProvider.errorMessage, isNotNull);
      
      print('[Tes Unit 5] Sukses: Register gagal sesuai ekspektasi karena email duplikat.');
    });

    // Tes Unit 6: Skenario Logout
    // Tujuannya memastikan sesi pengguna dihapus sepenuhnya saat logout.
    test('Tes Unit 6: Fungsi signOut harus menghapus data user dari state', () async {
      print('\n[Tes Unit 6] Memulai simulasi logout...');
      
      // Arrange (Login dulu)
      await authProvider.signIn('test@example.com', 'password');
      expect(authProvider.isAuthenticated, true);

      // Act (Tindakan Logout)
      await authProvider.signOut();

      // Assert (Verifikasi)
      expect(authProvider.isAuthenticated, false, reason: 'Status harus kembali false');
      expect(authProvider.currentUser, null, reason: 'Data user harus dihapus');
      expect(authProvider.firebaseUser, null);
      
      print('[Tes Unit 6] Sukses: Data user bersih setelah logout.');
    });
  });
}
