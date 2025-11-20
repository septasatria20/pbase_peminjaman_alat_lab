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
        .collection('users')
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
    required String namaAlat,
    required DateTime tanggalPinjam,
    required DateTime tanggalKembali,
    required String status,
  }) async {
    final uid = auth.currentUser?.uid;
    if (uid == null) throw Exception("User not logged in");

    final historyRef = firestore
        .collection("users")
        .doc(uid)
        .collection("history")
        .doc();

    await historyRef.set({
      "namaAlat": namaAlat,
      "tanggalPinjam": tanggalPinjam.toIso8601String(),
      "tanggalKembali": tanggalKembali.toIso8601String(),
      "status": status,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }
}
