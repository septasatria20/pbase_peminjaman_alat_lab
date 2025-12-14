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
  
  List<HistoryEntity> _state = [];
  List<HistoryEntity> _historyKonfirmasi = [];

  List<HistoryEntity> get state => _state;
  List<HistoryEntity> get historyKonfirmasi => _historyKonfirmasi;

  HistoryProvider({
    required this.getUserHistory,
    required this.addHistoryUseCase,
    required this.getHistoryKonfirmasiPeminjaman,
    required this.konfirmasiPeminjamanUseCase,
  }) : super();

  Future<void> fetchHistoryKonfirmasiPeminjaman() async {
    try {
      print('[HistoryProvider] Fetching history konfirmasi peminjaman...');
      
      final snapshot = await _firestore
          .collection('peminjaman')
          .where('status', isEqualTo: 'menunggu persetujuan')
          .get();

      print('[HistoryProvider] Found ${snapshot.docs.length} pending confirmations');

      _historyKonfirmasi = snapshot.docs.map((doc) {
        final data = doc.data();
        print('   [HistoryProvider] Processing doc: ${doc.id}');
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
              print('   Failed to parse $fieldName as String: $e');
              return DateTime.now();
            }
          } else {
            print('   Unknown type for $fieldName: ${value.runtimeType}');
            return DateTime.now();
          }
        }
        
        final tanggalPinjam = parseDateTime(data['tanggalPinjam'], 'tanggalPinjam');
        final tanggalKembali = parseDateTime(data['tanggalKembali'], 'tanggalKembali');
        
        print('   Dates parsed successfully');
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

      print('[HistoryProvider] Successfully loaded ${_historyKonfirmasi.length} items');
      notifyListeners();
    } catch (e, stackTrace) {
      print('[HistoryProvider] Error fetching history konfirmasi: $e');
      print('Stack trace: $stackTrace');
      _historyKonfirmasi = [];
      notifyListeners();
    }
  }

  Future<void> fetchUserHistory(String userId) async {
    try {
      print('[HistoryProvider] Fetching history for user: $userId');
      
      final snapshot = await _firestore
          .collection('peminjaman')
          .where('userId', isEqualTo: userId)
          .get();

      print('[HistoryProvider] Found ${snapshot.docs.length} user history items');

      DateTime parseDateTime(dynamic value, String fieldName) {
        if (value is Timestamp) {
          return value.toDate();
        } else if (value is String) {
          try {
            return DateTime.parse(value);
          } catch (e) {
            print('   Failed to parse $fieldName as String: $e');
            return DateTime.now();
          }
        } else {
          print('   Unknown type for $fieldName: ${value.runtimeType}');
          return DateTime.now();
        }
      }

      _state = snapshot.docs.map((doc) {
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

      // Manual sorting by createdAt descending (newest first)
      _state.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      print('[HistoryProvider] Successfully loaded ${_state.length} user history items');
      notifyListeners();
    } catch (e, stackTrace) {
      print('[HistoryProvider] Error fetching user history: $e');
      print('Stack trace: $stackTrace');
      _state = [];
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
      print("[HistoryProvider] Sending data to use case...");
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

      print("[HistoryProvider] Data successfully sent to use case.");
    } catch (e) {
      print("[HistoryProvider] Error sending data to use case: $e");
      rethrow;
    }
  }

  Future<void> konfirmasiPeminjaman(String peminjamanId) async {
    try {
      print("[HistoryProvider] Confirming peminjaman ID: $peminjamanId");

      await konfirmasiPeminjamanUseCase.call(peminjamanId);

      // Refresh the konfirmasi list after confirmation
      await fetchHistoryKonfirmasiPeminjaman();

      print("[HistoryProvider] Peminjaman confirmed successfully");
    } catch (e) {
      print("[HistoryProvider] Error confirming peminjaman: $e");
      rethrow;
    }
  }

  /// Update status peminjaman menjadi "menunggu validasi pengembalian"
  Future<void> updateStatusToReturned(String peminjamanId) async {
    try {
      print(
        "[HistoryProvider] Requesting return validation for peminjaman ID: $peminjamanId",
      );

      await _firestore.collection('peminjaman').doc(peminjamanId).update({
        'status': 'menunggu validasi pengembalian',
        'returnRequestedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print("[HistoryProvider] Status updated to 'menunggu validasi pengembalian'");

      notifyListeners();
    } catch (e) {
      print("[HistoryProvider] Error updating status: $e");
      rethrow;
    }
  }

  /// Fetch peminjaman yang menunggu validasi pengembalian (untuk Admin)
  Future<void> fetchPendingReturns() async {
    try {
      print('[HistoryProvider] Fetching pending returns...');
      
      final snapshot = await _firestore
          .collection('peminjaman')
          .where('status', isEqualTo: 'menunggu validasi pengembalian')
          .get();

      print('[HistoryProvider] Found ${snapshot.docs.length} pending returns');

      notifyListeners();
    } catch (e, stackTrace) {
      print('[HistoryProvider] Error fetching pending returns: $e');
      print('Stack trace: $stackTrace');
    }
  }

  /// Admin konfirmasi pengembalian alat
  Future<void> confirmReturn(String peminjamanId, {String? notes}) async {
    try {
      print("[HistoryProvider] Confirming return for ID: $peminjamanId");

      // Get peminjaman data to return stock
      final doc = await _firestore.collection('peminjaman').doc(peminjamanId).get();
      final data = doc.data()!;
      final alatList = List<Map<String, dynamic>>.from(data['alat']);

      // Return stock for each alat
      for (var item in alatList) {
        final alatId = item['id'];
        final jumlah = item['jumlah'] as int;

        await _firestore.collection('alat').doc(alatId).update({
          'jumlah': FieldValue.increment(jumlah),
        });
      }

      // Update peminjaman status
      await _firestore.collection('peminjaman').doc(peminjamanId).update({
        'status': 'dikembalikan',
        'returnConfirmedAt': FieldValue.serverTimestamp(),
        'returnNotes': notes,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print("[HistoryProvider] Return confirmed successfully");
      notifyListeners();
    } catch (e) {
      print("[HistoryProvider] Error confirming return: $e");
      rethrow;
    }
  }

  /// Admin tolak pengembalian alat
  Future<void> rejectReturn(String peminjamanId, String reason) async {
    try {
      print("[HistoryProvider] Rejecting return for ID: $peminjamanId");

      await _firestore.collection('peminjaman').doc(peminjamanId).update({
        'status': 'disetujui',
        'returnRejectedAt': FieldValue.serverTimestamp(),
        'returnRejectionReason': reason,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print("[HistoryProvider] Return rejected successfully");
      notifyListeners();
    } catch (e) {
      print("[HistoryProvider] Error rejecting return: $e");
      rethrow;
    }
  }
}

