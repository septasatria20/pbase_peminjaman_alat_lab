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
        .collection('pemijaman')
        .doc(userId)
        .collection('history')
        .orderBy("createdAt", descending: true)
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
    required String alatId,
    required String namaAlat,
    required String lab,
    required DateTime tanggalPinjam,
    required DateTime tanggalKembali,
    required String status,
  }) async {
    final historyRef = firestore.collection("history").doc();

    await historyRef.set({
      "userId": userId,
      "alatId": alatId,
      "namaAlat": namaAlat,
      "lab": lab,
      "tanggalPinjam": tanggalPinjam.toIso8601String(),
      "tanggalKembali": tanggalKembali.toIso8601String(),
      "status": status,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }
}
