import 'package:pbase_peminjaman_alat_lab/features/domain/entities/history.dart'
    show HistoryEntity;

import '../repositories/history_repository.dart';

class GetUserHistory {
  final HistoryRepository repository;
  GetUserHistory(this.repository);

  Future<List<HistoryEntity>> call(String userId) {
    return repository.getUserHistory(userId);
  }
}

class AddHistoryUseCase {
  final HistoryRepository repository;

  AddHistoryUseCase(this.repository);

  Future<void> call({
    required String userId,
    required List<Map<String, dynamic>> alat,
    required String lab,
    required DateTime tanggalPinjam,
    required DateTime tanggalKembali,
    required String alasan,
    required String status,
  }) async {
    try {
      print("📤 [AddHistoryUseCase] Sending data to repository...");
      print({
        "userId": userId,
        "alat": alat,
        "lab": lab,
        "tanggalPinjam": tanggalPinjam,
        "tanggalKembali": tanggalKembali,
        "alasan": alasan,
        "status": status,
      });

      await repository.addHistory(
        alasan: alasan,
        userId: userId,
        alat: alat,
        lab: lab,
        tanggalPinjam: tanggalPinjam,
        tanggalKembali: tanggalKembali,
        status: status,
      );

      print("✅ [AddHistoryUseCase] Data successfully sent to repository.");
    } catch (e) {
      print("❌ [AddHistoryUseCase] Error sending data to repository: $e");
      rethrow;
    }
  }
}
