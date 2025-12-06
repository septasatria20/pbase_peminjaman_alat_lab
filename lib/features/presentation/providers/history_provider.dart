import 'package:flutter/cupertino.dart';
import 'package:pbase_peminjaman_alat_lab/features/domain/entities/history.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/usecases/history_usecases.dart';

class HistoryProvider extends ChangeNotifier {
  final GetUserHistory getUserHistory;
  final AddHistoryUseCase addHistoryUseCase;
  final GetHistoryKonfirmasiPeminjaman getHistoryKonfirmasiPeminjaman;
  final KonfirmasiPeminjamanUseCase konfirmasiPeminjamanUseCase;

  HistoryProvider({
    required this.getUserHistory,
    required this.addHistoryUseCase,
    required this.getHistoryKonfirmasiPeminjaman,
    required this.konfirmasiPeminjamanUseCase,
  }) : super();

  List<HistoryEntity> _historyList = [];
  List<HistoryEntity> get state => _historyList;

  List<HistoryEntity> _historyKonfirmasiList = [];
  List<HistoryEntity> get historyKonfirmasi => _historyKonfirmasiList;

  Future<void> fetchUserHistory(String userId) async {
    try {
      print("🔍 [HistoryProvider] Fetching history for user ID: $userId");

      final historyList = await getUserHistory.call(userId);

      print("✅ [HistoryProvider] History fetched successfully: $historyList");
      _historyList = historyList;
      notifyListeners();
    } catch (e) {
      print("❌ [HistoryProvider] Error fetching user history: $e");
    }
  }

  Future<void> addHistory({
    required String userId,
    required List<Map<String, dynamic>> alat,
    required String lab,
    required DateTime tanggalPinjam,
    required DateTime tanggalKembali,
    required String alasan,
    required String status,
  }) async {
    try {
      print("📤 [HistoryProvider] Sending data to use case...");
      print({
        "userId": userId,
        "alat": alat,
        "lab": lab,
        "tanggalPinjam": tanggalPinjam,
        "tanggalKembali": tanggalKembali,
        "alasan": alasan,
        "status": status,
      });

      await addHistoryUseCase.call(
        userId: userId,
        alat: alat,
        lab: lab,
        tanggalPinjam: tanggalPinjam,
        alasan: alasan,
        tanggalKembali: tanggalKembali,
        status: status,
      );

      print("✅ [HistoryProvider] Data successfully sent to use case.");
    } catch (e) {
      print("❌ [HistoryProvider] Error sending data to use case: $e");
      rethrow;
    }
  }

  Future<void> fetchHistoryKonfirmasiPeminjaman() async {
    try {
      print("🔍 [HistoryProvider] Fetching history konfirmasi peminjaman");

      final historyList = await getHistoryKonfirmasiPeminjaman.call();

      print(
        "✅ [HistoryProvider] History konfirmasi fetched successfully: $historyList",
      );
      _historyKonfirmasiList = historyList;
      notifyListeners();
    } catch (e) {
      print("❌ [HistoryProvider] Error fetching history konfirmasi: $e");
    }
  }

  Future<void> konfirmasiPeminjaman(String peminjamanId) async {
    try {
      print("📤 [HistoryProvider] Confirming peminjaman ID: $peminjamanId");

      await konfirmasiPeminjamanUseCase.call(peminjamanId);

      // Refresh the konfirmasi list after confirmation
      await fetchHistoryKonfirmasiPeminjaman();

      print("✅ [HistoryProvider] Peminjaman confirmed successfully");
    } catch (e) {
      print("❌ [HistoryProvider] Error confirming peminjaman: $e");
      rethrow;
    }
  }
}
