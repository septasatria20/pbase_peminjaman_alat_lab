class HistoryEntity {
  final String id;
  final String userId;
  final List<Map<String, dynamic>> alat; 
  final String lab;
  final DateTime tanggalPinjam;
  final DateTime tanggalKembali;
  final String status;
  final String alasan;
  final DateTime createdAt;

  HistoryEntity({
    required this.id,
    required this.userId,
    required this.alat,
    required this.lab,
    required this.tanggalPinjam,
    required this.tanggalKembali,
    required this.status,
    required this.alasan,
    required this.createdAt,
  });
}
