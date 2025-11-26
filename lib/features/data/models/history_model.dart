import 'package:pbase_peminjaman_alat_lab/features/domain/entities/history.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryModel extends HistoryEntity {
  HistoryModel({
    required String id,
    required String userId,
    required List<Map<String, dynamic>> alat,
    required String lab,
    required DateTime tanggalPinjam,
    required DateTime tanggalKembali,
    required String alasan,
    required String status,
    required DateTime createdAt,
  }) : super(
         id: id,
         userId: userId,
         alat: alat,
         lab: lab,
         tanggalPinjam: tanggalPinjam,
         tanggalKembali: tanggalKembali,
         status: status,
         createdAt: createdAt,
          alasan: alasan,
       );

  factory HistoryModel.fromFirestore(Map<String, dynamic> data, String id) {
    return HistoryModel(
      id: id,
      userId: data['userId'] ?? '',
      alat: List<Map<String, dynamic>>.from(data['alat'] ?? []),
      lab: data['lab'] ?? '',
      tanggalPinjam:
          (data['tanggalPinjam'] as Timestamp?)?.toDate() ?? DateTime.now(),
      tanggalKembali:
          (data['tanggalKembali'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      alasan: data['alasan'] ?? '',
    );
  }
}
