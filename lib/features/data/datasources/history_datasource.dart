import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/history_model.dart';

abstract class HistoryRemoteDataSource {
  Future<List<HistoryModel>> getUserHistory(String userId);
  Future<List<HistoryModel>> getHistoryKonfirmasiPeminjaman();
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

  @override
  Future<List<HistoryModel>> getHistoryKonfirmasiPeminjaman() async {
    final snapshot = await firestore
        .collection('peminjaman')
        .where('status', isEqualTo: 'menunggu persetujuan')
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

  Future<void> konfirmasiPeminjaman(String peminjamanId) async {
    try {
      print("📤 [HistoryDatasource] Konfirmasi peminjaman ID: $peminjamanId");

      // Get peminjaman document
      final peminjamanDoc = await firestore
          .collection("peminjaman")
          .doc(peminjamanId)
          .get();

      if (!peminjamanDoc.exists) {
        throw Exception("Peminjaman tidak ditemukan");
      }

      final peminjamanData = peminjamanDoc.data()!;
      final List<Map<String, dynamic>> alatList =
          List<Map<String, dynamic>>.from(peminjamanData['alat'] ?? []);

      // Update peminjaman status
      await firestore.collection("peminjaman").doc(peminjamanId).update({
        "status": "disetujui",
      });

      print("✅ [HistoryDatasource] Status updated to 'disetujui'");

      // Update alat quantities
      final batch = firestore.batch();

      for (var alat in alatList) {
        final alatId = alat['id'] as String;
        final jumlahPinjam = alat['jumlah'] as int;

        print(
          "📦 [HistoryDatasource] Reducing alat ID: $alatId by $jumlahPinjam",
        );

        final alatRef = firestore.collection("alat").doc(alatId);
        final alatDoc = await alatRef.get();

        if (alatDoc.exists) {
          final currentJumlah = alatDoc.data()?['jumlah'] as int? ?? 0;
          final newJumlah = currentJumlah - jumlahPinjam;

          if (newJumlah < 0) {
            throw Exception("Jumlah alat tidak mencukupi untuk ID: $alatId");
          }

          batch.update(alatRef, {"jumlah": newJumlah});
        }
      }

      await batch.commit();
      print("✅ [HistoryDatasource] Alat quantities updated successfully");
    } catch (e) {
      print("❌ [HistoryDatasource] Error konfirmasi peminjaman: $e");
      rethrow;
    }
  }
}
