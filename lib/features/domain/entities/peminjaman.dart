class Peminjaman {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String alatId;
  final String alatNama;
  final String ruang; // BA, IS, etc
  final DateTime tanggalPinjam;
  final DateTime tanggalHarusKembali;
  final DateTime? tanggalKembali;
  final String status; // pending, approved, rejected, returned
  final int jumlah;
  final String? catatan;
  final DateTime createdAt;

  const Peminjaman({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.alatId,
    required this.alatNama,
    required this.ruang,
    required this.tanggalPinjam,
    required this.tanggalHarusKembali,
    this.tanggalKembali,
    required this.status,
    required this.jumlah,
    this.catatan,
    required this.createdAt,
  });
}
