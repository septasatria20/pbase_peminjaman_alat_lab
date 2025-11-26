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
          .collection('peminjaman')
          .where('userId', isEqualTo: userId)
          .get();

      print(
        '📄 [HistoryRepositoryImpl] Query returned ${snapshot.docs.length} documents',
      );

      final historyList = snapshot.docs.map((doc) {
        print('📄 [HistoryRepositoryImpl] Document data: ${doc.data()}');
        return HistoryEntity(
          id: doc.id,
          userId: doc['userId'] ?? '',
          alat: List<Map<String, dynamic>>.from(doc['alat'] ?? []),
          lab: doc['lab'] ?? '',
          tanggalPinjam: (doc['tanggalPinjam'] is Timestamp)
              ? (doc['tanggalPinjam'] as Timestamp).toDate()
              : DateTime.parse(doc['tanggalPinjam']),
          tanggalKembali: (doc['tanggalKembali'] is Timestamp)
              ? (doc['tanggalKembali'] as Timestamp).toDate()
              : DateTime.parse(doc['tanggalKembali']),
          status: doc['status'] ?? '',
          alasan: doc['alasan'] ?? '',
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
    required List<Map<String, dynamic>> alat,
    required String lab,
    required DateTime tanggalPinjam,
    required DateTime tanggalKembali,
    required String status,
    required String alasan,
  }) async {
    try {
      print("📤 [HistoryRepositoryImpl] Sending data to datasource...");
      print({
        "userId": userId,
        "alat": alat,
        "lab": lab,
        "tanggalPinjam": tanggalPinjam,
        "tanggalKembali": tanggalKembali,
        "alasan": alasan,
        "status": status,
      });

      await datasource.addHistory(
        userId: userId,
        alat: alat,
        lab: lab,
        tanggalPinjam: tanggalPinjam,
        tanggalKembali: tanggalKembali,
        status: status,
        alasan: alasan,
      );

      print("✅ [HistoryRepositoryImpl] Data successfully sent to datasource.");
    } catch (e) {
      print("❌ [HistoryRepositoryImpl] Error sending data to datasource: $e");
      rethrow;
    }
  }
}
