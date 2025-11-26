import 'package:pbase_peminjaman_alat_lab/features/domain/entities/history.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryModel extends HistoryEntity {
  HistoryModel({
    required String id,
    required String userId,
    required String alatId,
    required String namaAlat,
    required String lab,
    required DateTime tanggalPinjam,
    required DateTime tanggalKembali,
    required String status,
    required DateTime createdAt,
  }) : super(
         id: id,
         userId: userId,
         alatId: alatId,
         namaAlat: namaAlat,
         lab: lab,
         tanggalPinjam: tanggalPinjam,
         tanggalKembali: tanggalKembali,
         status: status,
         createdAt: createdAt,
       );

  factory HistoryModel.fromFirestore(Map<String, dynamic> data, String id) {
    return HistoryModel(
      id: id,
      userId: data['userId'] ?? '',
      alatId: data['alatId'] ?? '',
      namaAlat: data['namaAlat'] ?? '',
      lab: data['lab'] ?? '',
      tanggalPinjam:
          (data['tanggalPinjam'] as Timestamp?)?.toDate() ?? DateTime.now(),
      tanggalKembali:
          (data['tanggalKembali'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
