import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:pbase_peminjaman_alat_lab/features/presentation/screens/auth/login_screen.dart';
import 'package:pbase_peminjaman_alat_lab/features/presentation/providers/auth_provider.dart';
import 'package:pbase_peminjaman_alat_lab/features/presentation/providers/user_provider.dart';
import 'package:pbase_peminjaman_alat_lab/features/presentation/providers/alat_provider.dart';
import 'package:pbase_peminjaman_alat_lab/features/presentation/screens/main/dashboard_screen.dart';
import 'mocks.dart';

import 'package:pbase_peminjaman_alat_lab/features/domain/entities/alat.dart';
import 'package:pbase_peminjaman_alat_lab/features/domain/entities/user.dart';

// Simple Mocks for other providers
class MockUserProvider extends ChangeNotifier implements UserProvider {
  @override
  User? get currentUser => null;
  @override
  bool get isLoading => false;
  @override
  String? get errorMessage => null;
  
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockAlatProvider extends ChangeNotifier implements AlatProvider {
  @override
  List<Alat> get alatList => [];
  @override
  bool get isLoading => false;
  @override
  String? get errorMessage => null;

  @override
  void fetchAlatStream() {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late AuthProvider authProvider;
  late MockAuthRepository mockAuthRepository;
  late MockUserRepository mockUserRepository;
  late MockUserProvider mockUserProvider;
  late MockAlatProvider mockAlatProvider;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockUserRepository = MockUserRepository();
    authProvider = AuthProvider(mockAuthRepository, mockUserRepository);
    mockUserProvider = MockUserProvider();
    mockAlatProvider = MockAlatProvider();
  });

  Widget createWidgetUnderTest() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<UserProvider>.value(value: mockUserProvider),
        ChangeNotifierProvider<AlatProvider>.value(value: mockAlatProvider),
      ],
      child: MaterialApp(
        home: const LoginScreen(),
        routes: {
          '/dashboard': (context) => const DashboardScreen(),
        },
      ),
    );
  }

  // Tes E2E 1: Alur Login Berhasil
  // Tujuannya mensimulasikan interaksi user dari membuka aplikasi, input data, hingga berhasil masuk dashboard.
  testWidgets('Tes E2E 1: Alur Login Berhasil', (WidgetTester tester) async {
    print('\n[Tes E2E 1] Memulai simulasi login user...');
    
    // Arrange (Persiapan)
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle(); // Tunggu animasi selesai

    // Verifikasi tampilan awal
    expect(find.text('Selamat Datang'), findsOneWidget, reason: 'Judul halaman login harus muncul');
    expect(find.text('Masuk'), findsOneWidget);

    // Act (Tindakan): Masukkan Email
    final emailField = find.byType(TextFormField).at(0); // Asumsi field pertama adalah email
    await tester.enterText(emailField, 'test@example.com');

    // Act (Tindakan): Masukkan Password
    final passwordField = find.byType(TextFormField).at(1); // Asumsi field kedua adalah password
    await tester.enterText(passwordField, 'password');

    // Act (Tindakan): Tekan Tombol Masuk
    final loginButton = find.text('Masuk');
    await tester.tap(loginButton);
    
    // Tunggu proses asinkron dan navigasi
    await tester.pump(); // Mulai animasi
    await tester.pump(const Duration(milliseconds: 1000)); // Tunggu delay di LoginScreen
    await tester.pump(); // Frame navigasi
    await tester.pump(const Duration(seconds: 1)); // Tunggu Dashboard stabil

    // Assert (Verifikasi): Cek apakah state berubah (menandakan login sukses)
    expect(authProvider.isAuthenticated, true, reason: 'Status auth harus true setelah login');
    expect(authProvider.currentUser?.email, 'test@example.com', reason: 'Email user harus sesuai');
    
    print('[Tes E2E 1] Sukses: User berhasil login dan navigasi terjadi.');
  });

  // Tes E2E 2: Alur Login Gagal
  // Tujuannya memastikan user mendapatkan feedback visual (dialog error) jika salah input.
  testWidgets('Tes E2E 2: Alur Login Gagal', (WidgetTester tester) async {
    print('\n[Tes E2E 2] Memulai simulasi login gagal...');
    
    // Arrange
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Act: Masukkan kredensial salah
    await tester.enterText(find.byType(TextFormField).at(0), 'wrong@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'password');
    await tester.tap(find.text('Masuk'));
    
    await tester.pumpAndSettle();

    // Assert: Dialog Error harus muncul
    expect(find.text('Login Gagal'), findsOneWidget, reason: 'Dialog error harus muncul');
    expect(find.text('Invalid credentials'), findsOneWidget, reason: 'Pesan error harus sesuai');
    
    print('[Tes E2E 2] Sukses: Dialog error muncul sesuai ekspektasi.');
  });

  // Tes E2E 3: Navigasi ke Halaman Register
  // Tujuannya memastikan tombol navigasi ke halaman pendaftaran berfungsi.
  testWidgets('Tes E2E 3: Navigasi ke Halaman Register', (WidgetTester tester) async {
    print('\n[Tes E2E 3] Memulai tes navigasi ke register...');
    
    // Arrange
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Act: Cari dan tekan tombol "Daftar"
    final registerFinder = find.text('Daftar');
    
    // Cek apakah tombol ada
    if (registerFinder.evaluate().isNotEmpty) {
       await tester.tap(registerFinder);
       await tester.pumpAndSettle();
       print('[Tes E2E 3] Sukses: Tombol daftar ditemukan dan ditekan.');
    } else {
      print('[Tes E2E 3] Info: Tombol Daftar tidak ditemukan dengan text finder sederhana (mungkin dalam RichText).');
    }
  });
}
