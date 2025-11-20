import 'package:flutter/cupertino.dart';
import 'package:pbase_peminjaman_alat_lab/features/domain/entities/history.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/usecases/history_usecases.dart';

class HistoryProvider extends ChangeNotifier {
  final GetUserHistory getUserHistory;
  final AddHistoryUseCase addHistoryUseCase;

  HistoryProvider({
    required this.getUserHistory,
    required this.addHistoryUseCase,
  }) : super();

  List<HistoryEntity> _historyList = [];
  List<HistoryEntity> get state => _historyList;

  Future<void> fetchUserHistory(String userId) async {
    try {
      print(
        '🔍 [HistoryProvider] Fetching history for user ID: $userId',
      ); // Debug log

      // Fetch history documents from Firestore
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('history')
          .orderBy('createdAt', descending: true)
          .get();

      print(
        '📄 [HistoryProvider] Query returned ${querySnapshot.docs.length} documents',
      ); // Debug log

      // Map Firestore documents to HistoryEntity objects
      _historyList = querySnapshot.docs.map((doc) {
        final data = doc.data();
        print('📄 [HistoryProvider] Document data: $data'); // Debug log

        // Safely parse tanggalPinjam and tanggalKembali
        DateTime parseDate(dynamic value) {
          if (value is Timestamp) {
            return value.toDate();
          } else if (value is String) {
            return DateTime.parse(value);
          } else {
            return DateTime.now(); // Default fallback
          }
        }

        return HistoryEntity(
          id: doc.id,
          namaAlat: data['namaAlat'] ?? '-',
          tanggalPinjam: parseDate(data['tanggalPinjam']),
          tanggalKembali: parseDate(data['tanggalKembali']),
          status: data['status'] ?? '-',
          createdAt:
              (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();

      print(
        '✅ [HistoryProvider] User history fetched successfully: $_historyList',
      ); // Debug log

      notifyListeners();
    } catch (e) {
      print('❌ [HistoryProvider] Error fetching user history: $e');
    }
  }

  Future<void> addHistory({
    required String namaAlat,
    required DateTime tanggalPinjam,
    required DateTime tanggalKembali,
    required String status,
  }) async {
    await addHistoryUseCase.call(
      namaAlat: namaAlat,
      tanggalPinjam: tanggalPinjam,
      tanggalKembali: tanggalKembali,
      status: status,
    );
    // Optionally refresh the history after adding
  }
}
