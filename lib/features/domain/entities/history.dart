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

  HistoryEntity copyWith({
    String? id,
    String? userId,
    List<Map<String, dynamic>>? alat,
    String? lab,
    DateTime? tanggalPinjam,
    DateTime? tanggalKembali,
    String? status,
    String? alasan,
    DateTime? createdAt,
  }) {
    return HistoryEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      alat: alat ?? this.alat,
      lab: lab ?? this.lab,
      tanggalPinjam: tanggalPinjam ?? this.tanggalPinjam,
      tanggalKembali: tanggalKembali ?? this.tanggalKembali,
      status: status ?? this.status,
      alasan: alasan ?? this.alasan,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

