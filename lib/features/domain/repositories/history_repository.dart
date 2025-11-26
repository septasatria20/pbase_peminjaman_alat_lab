import 'package:pbase_peminjaman_alat_lab/features/domain/entities/history.dart';

abstract class HistoryRepository {
  Future<void> addHistory({
    required String userId,
    required List<Map<String, dynamic>> alat,
    required String lab,
    required DateTime tanggalPinjam,
    required DateTime tanggalKembali,
    required String alasan,
    required String status,
  });

  Future<List<HistoryEntity>> getUserHistory(String userId);
}
