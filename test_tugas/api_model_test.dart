import 'package:flutter_test/flutter_test.dart';
import 'package:pbase_peminjaman_alat_lab/features/data/models/user_model.dart';
import 'package:pbase_peminjaman_alat_lab/features/domain/entities/user.dart';

void main() {
  group('Pengujian Model Data API (UserModel)', () {
    // Data dummy untuk pengujian
    final userJson = {
      'id': 'user-123',
      'name': 'John Doe',
      'email': 'john@example.com',
      'role': 'admin',
      'lab': 'Mobile',
    };

    // Tes API 1: Parsing JSON Normal
    // Tujuannya memastikan data JSON lengkap dapat diubah menjadi objek Dart dengan benar.
    test('Tes API 1: fromJson harus mengembalikan objek UserModel yang valid', () {
      print('\n[Tes API 1] Memulai parsing JSON valid...');
      
      // Act (Tindakan)
      final result = UserModel.fromJson('user-123', userJson);

      // Assert (Verifikasi)
      expect(result, isA<UserModel>(), reason: 'Harus bertipe UserModel');
      expect(result.id, 'user-123');
      expect(result.name, 'Septa Satria');
      expect(result.email, 'septa@example.com');
      expect(result.role, 'admin');
      expect(result.lab, 'Mobile');
      
      print('[Tes API 1] Sukses: Objek UserModel terbentuk dengan data yang benar.');
    });

    // Tes API 2: Pewarisan (Inheritance)
    // Tujuannya memastikan UserModel tetap kompatibel dengan entitas domain User.
    test('Tes API 2: UserModel harus merupakan subclass dari entitas User', () {
      print('\n[Tes API 2] Memverifikasi inheritance...');
      final result = UserModel.fromJson('user-123', userJson);
      expect(result, isA<User>(), reason: 'UserModel harus extend User');
      print('[Tes API 2] Sukses: UserModel adalah tipe User yang valid.');
    });
    
    // Tes API 3: Penanganan Field Opsional
    // Tujuannya memastikan aplikasi tidak crash jika field opsional (nullable) tidak dikirim oleh API.
    test('Tes API 3: fromJson harus menangani field opsional yang hilang (null safety)', () {
      print('\n[Tes API 3] Memulai parsing JSON dengan field opsional hilang...');
      
      final partialJson = {
        'id': 'user-123',
        'name': 'John Doe',
        'email': 'john@example.com',
        'role': 'user',
        // field 'lab' sengaja dihilangkan
      };

      final result = UserModel.fromJson('user-123', partialJson);
      expect(result.lab, null, reason: 'Field lab harus null jika tidak ada di JSON');
      
      print('[Tes API 3] Sukses: Field yang hilang ditangani sebagai null.');
    });

    // Tes API 4: Penanganan Data Kosong
    // Tujuannya memastikan aplikasi memiliki nilai default yang aman jika data penting hilang.
    test('Tes API 4: fromJson harus memberikan nilai default jika field wajib kosong', () {
      print('\n[Tes API 4] Memulai parsing JSON dengan data minimal...');
      
      final emptyJson = {
        'id': 'user-123',
        // name, email, role hilang
      };

      final result = UserModel.fromJson('user-123', emptyJson);
      
      // Asumsi implementasi UserModel memberikan default value atau handle null
      expect(result.name, isNotNull); 
      expect(result.role, 'user'); // Default role biasanya user
      
      print('[Tes API 4] Sukses: Nilai default diterapkan untuk field yang kosong.');
    });
  });
}
