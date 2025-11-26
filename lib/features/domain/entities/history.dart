class HistoryEntity {
  final String id;
  final String userId;
  final String alatId;
  final String namaAlat;
  final String lab;
  final DateTime tanggalPinjam;
  final DateTime tanggalKembali;
  final String status;
  final DateTime createdAt;

  HistoryEntity({
    required this.id,
    required this.userId,
    required this.alatId,
    required this.namaAlat,
    required this.lab,
    required this.tanggalPinjam,
    required this.tanggalKembali,
    required this.status,
    required this.createdAt,
  });
}
