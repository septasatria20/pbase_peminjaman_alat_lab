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
      print('🔍 [HistoryRepositoryImpl] Fetching history for user ID: $userId');

      final snapshot = await datasource.firestore
          .collection('history')
          .where('userId', isEqualTo: userId)
          .orderBy("createdAt", descending: true)
          .get();

      print(
        '📄 [HistoryRepositoryImpl] Query returned ${snapshot.docs.length} documents',
      );

      final historyList = snapshot.docs.map((doc) {
        print('📄 [HistoryRepositoryImpl] Document data: ${doc.data()}');
        return HistoryEntity(
          id: doc.id,
          userId: doc['userId'] ?? '',
          alatId: doc['alatId'] ?? '',
          namaAlat: doc['namaAlat'] ?? '-',
          lab: doc['lab'] ?? '',
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
      );
      return historyList;
    } catch (e) {
      print('❌ [HistoryRepositoryImpl] Error fetching history: $e');
      rethrow;
    }
  }

  @override
  Future<void> addHistory({
    required String userId,
    required String alatId,
    required String namaAlat,
    required String lab,
    required DateTime tanggalPinjam,
    required DateTime tanggalKembali,
    required String status,
  }) async {
    return datasource.addHistory(
      userId: userId,
      alatId: alatId,
      namaAlat: namaAlat,
      lab: lab,
      tanggalPinjam: tanggalPinjam,
      tanggalKembali: tanggalKembali,
      status: status,
    );
  }
}
