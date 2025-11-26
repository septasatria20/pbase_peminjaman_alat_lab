import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/history_model.dart';

abstract class HistoryRemoteDataSource {
  Future<List<HistoryModel>> getUserHistory(String userId);
}

class HistoryRemoteDataSourceImpl implements HistoryRemoteDataSource {
  final FirebaseFirestore firestore;

  HistoryRemoteDataSourceImpl(this.firestore);

  @override
  Future<List<HistoryModel>> getUserHistory(String userId) async {
    final snapshot = await firestore
        .collection('peminjaman')
       
        .where('userId', isEqualTo: userId)
        .get();

    return snapshot.docs
        .map((doc) => HistoryModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }
}

class HistoryDatasource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  HistoryDatasource({required this.firestore, required this.auth});

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
      print("📤 [HistoryDatasource] Sending data to Firestore...");
      print({
        "userId": userId,
        "alat": alat,
        "lab": lab,
        "tanggalPinjam": tanggalPinjam,
        "tanggalKembali": tanggalKembali,
        "status": status,
        "alasan": alasan,
      });

      final historyRef = firestore.collection("peminjaman").doc();

      await historyRef.set({
        "userId": userId,
        "alat": alat,
        "lab": lab,
        "tanggalPinjam": tanggalPinjam.toIso8601String(),
        "tanggalKembali": tanggalKembali.toIso8601String(),
        "status": status,
        "createdAt": FieldValue.serverTimestamp(),
        "alasan": alasan,
      });

      print("✅ [HistoryDatasource] Data successfully sent to Firestore.");
    } catch (e) {
      print("❌ [HistoryDatasource] Error sending data to Firestore: $e");
      rethrow;
    }
  }
}
