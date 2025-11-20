import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pbase_peminjaman_alat_lab/features/data/datasources/history_datasource.dart';
import 'package:pbase_peminjaman_alat_lab/features/domain/entities/history.dart';

import '../../domain/repositories/history_repository.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryRemoteDataSource remote;
  final HistoryDatasource datasource;

  HistoryRepositoryImpl(this.remote, this.datasource);

  @override
  Future<List<HistoryEntity>> getUserHistory(String userId) async {
    try {
      print(
        '🔍 [HistoryRepositoryImpl] Fetching history for user ID: $userId',
      ); // Debug log

      final snapshot = await datasource.firestore
          .collection('users')
          .doc(userId)
          .collection('history')
          .orderBy("createdAt", descending: true)
          .get();

      print(
        '📄 [HistoryRepositoryImpl] Query returned ${snapshot.docs.length} documents',
      ); // Debug log

      final historyList = snapshot.docs.map((doc) {
        print(
          '📄 [HistoryRepositoryImpl] Document data: ${doc.data()}',
        ); // Debug log
        return HistoryEntity(
          id: doc.id,
          namaAlat: doc['namaAlat'] ?? '-',
          tanggalPinjam:
              (doc['tanggalPinjam'] as Timestamp?)?.toDate() ?? DateTime.now(),
          tanggalKembali:
              (doc['tanggalKembali'] as Timestamp?)?.toDate() ?? DateTime.now(),
          status: doc['status'] ?? '-',
          createdAt:
              (doc['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();

      print(
        '✅ [HistoryRepositoryImpl] History fetched successfully: $historyList',
      ); // Debug log
      return historyList;
    } catch (e) {
      print('❌ [HistoryRepositoryImpl] Error fetching history: $e');
      rethrow;
    }
  }

  @override
  Future<void> addHistory({
    required String namaAlat,
    required DateTime tanggalPinjam,
    required DateTime tanggalKembali,
    required String status,
  }) async {
    return datasource.addHistory(
      namaAlat: namaAlat,
      tanggalPinjam: tanggalPinjam,
      tanggalKembali: tanggalKembali,
      status: status,
    );
  }
}
