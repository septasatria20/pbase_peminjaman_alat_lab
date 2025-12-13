import 'package:flutter/cupertino.dart';
import 'package:pbase_peminjaman_alat_lab/features/domain/entities/history.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/usecases/history_usecases.dart';

class HistoryProvider extends ChangeNotifier {
  final GetUserHistory getUserHistory;
  final AddHistoryUseCase addHistoryUseCase;
  final GetHistoryKonfirmasiPeminjaman getHistoryKonfirmasiPeminjaman;
  final KonfirmasiPeminjamanUseCase konfirmasiPeminjamanUseCase;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  Future<void> fetchHistoryKonfirmasiPeminjaman() async {
    try {
      print('🔍 [HistoryProvider] Fetching history konfirmasi peminjaman...');
      
      final snapshot = await _firestore
          .collection('peminjaman')
          .where('status', isEqualTo: 'menunggu persetujuan')
          .get();

      print('📊 [HistoryProvider] Found ${snapshot.docs.length} pending confirmations');

      _historyKonfirmasiList = snapshot.docs.map((doc) {
        final data = doc.data();
        print('📝 [HistoryProvider] Processing doc: ${doc.id}');
        print('   Lab: ${data['lab']}');
        print('   Status: ${data['status']}');
        print('   UserId: ${data['userId']}');
        
        // Helper function to parse DateTime from Timestamp or String
        DateTime parseDateTime(dynamic value, String fieldName) {
          if (value is Timestamp) {
            return value.toDate();
          } else if (value is String) {
            try {
              return DateTime.parse(value);
            } catch (e) {
              print('   ⚠️ Failed to parse $fieldName as String: $e');
              return DateTime.now();
            }
          } else {
            print('   ⚠️ Unknown type for $fieldName: ${value.runtimeType}');
            return DateTime.now();
          }
        }
        
        final tanggalPinjam = parseDateTime(data['tanggalPinjam'], 'tanggalPinjam');
        final tanggalKembali = parseDateTime(data['tanggalKembali'], 'tanggalKembali');
        
        print('   ✅ Dates parsed successfully');
        print('   Tanggal Pinjam: $tanggalPinjam');
        print('   Tanggal Kembali: $tanggalKembali');
        
        return HistoryEntity(
          id: doc.id,
          userId: data['userId'] ?? '',
          lab: data['lab'] ?? '',
          tanggalPinjam: tanggalPinjam,
          tanggalKembali: tanggalKembali,
          alasan: data['alasan'] ?? '',
          status: data['status'] ?? 'menunggu persetujuan',
          alat: List<Map<String, dynamic>>.from(data['alat'] ?? []),
          createdAt: data['createdAt'] != null
              ? (data['createdAt'] is Timestamp 
                  ? (data['createdAt'] as Timestamp).toDate()
                  : DateTime.parse(data['createdAt']))
              : DateTime.now(),
        );
      }).toList();

      print('✅ [HistoryProvider] Successfully loaded ${_historyKonfirmasiList.length} items');
      notifyListeners();
    } catch (e, stackTrace) {
      print('❌ [HistoryProvider] Error fetching history konfirmasi: $e');
      print('Stack trace: $stackTrace');
      _historyKonfirmasiList = [];
      notifyListeners();
    }
  }

  Future<void> fetchUserHistory(String userId) async {
    try {
      print('🔍 [HistoryProvider] Fetching history for user: $userId');
      
      final snapshot = await _firestore
          .collection('peminjaman')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      print('📊 [HistoryProvider] Found ${snapshot.docs.length} user history items');

      // Helper function to parse DateTime from Timestamp or String
      DateTime parseDateTime(dynamic value, String fieldName) {
        if (value is Timestamp) {
          return value.toDate();
        } else if (value is String) {
          try {
            return DateTime.parse(value);
          } catch (e) {
            print('   ⚠️ Failed to parse $fieldName as String: $e');
            return DateTime.now();
          }
        } else {
          print('   ⚠️ Unknown type for $fieldName: ${value.runtimeType}');
          return DateTime.now();
        }
      }

      _historyList = snapshot.docs.map((doc) {
        final data = doc.data();
        
        return HistoryEntity(
          id: doc.id,
          userId: data['userId'] ?? '',
          lab: data['lab'] ?? '',
          tanggalPinjam: parseDateTime(data['tanggalPinjam'], 'tanggalPinjam'),
          tanggalKembali: parseDateTime(data['tanggalKembali'], 'tanggalKembali'),
          alasan: data['alasan'] ?? '',
          status: data['status'] ?? '',
          alat: List<Map<String, dynamic>>.from(data['alat'] ?? []),
          createdAt: data['createdAt'] != null
              ? (data['createdAt'] is Timestamp 
                  ? (data['createdAt'] as Timestamp).toDate()
                  : DateTime.parse(data['createdAt']))
              : DateTime.now(),
        );
      }).toList();

      print('✅ [HistoryProvider] Successfully loaded ${_historyList.length} user history items');
      notifyListeners();
    } catch (e, stackTrace) {
      print('❌ [HistoryProvider] Error fetching user history: $e');
      print('Stack trace: $stackTrace');
      _historyList = [];
      notifyListeners();
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

  /// Update status peminjaman menjadi "dikembalikan"
  Future<void> updateStatusToReturned(String peminjamanId) async {
    try {
      print(
        "📤 [HistoryProvider] Updating status for peminjaman ID: $peminjamanId",
      );

      await _firestore.collection('peminjaman').doc(peminjamanId).update({
        'status': 'dikembalikan',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print("✅ [HistoryProvider] Status updated successfully to 'dikembalikan'");

      // Refresh history list
      final currentHistoryIndex = _historyList.indexWhere((h) => h.id == peminjamanId);
      if (currentHistoryIndex != -1) {
        _historyList[currentHistoryIndex] = _historyList[currentHistoryIndex].copyWith(
          status: 'dikembalikan',
        );
        notifyListeners();
      }
    } catch (e) {
      print("❌ [HistoryProvider] Error updating status: $e");
      rethrow;
    }
  }
}

