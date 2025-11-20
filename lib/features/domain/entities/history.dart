class HistoryEntity {
  final String id;
  final String namaAlat;
  final DateTime tanggalPinjam;
  final DateTime tanggalKembali;
  final String status;
  final DateTime createdAt;

  HistoryEntity({
    required this.id,
    required this.namaAlat,
    required this.tanggalPinjam,
    required this.tanggalKembali,
    required this.status,
    required this.createdAt,
  });
}
