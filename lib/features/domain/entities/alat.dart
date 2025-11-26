class Alat {
  final String id;
  final String nama;
  final String kategori;
  final int jumlah;
  final String status;
  final String ruang; // BA, IS, SE, STUDIO, NCS
  final String? deskripsi;
  final String? gambar;

  const Alat({
    required this.id,
    required this.nama,
    required this.kategori,
    required this.jumlah,
    required this.status,
    required this.ruang,
    this.deskripsi,
    this.gambar,
  });
}
