class Alat {
  final String id;
  final String nama;
  final String kategori;
  final int jumlah;
  final String status;
  final String? deskripsi;
  final String? lokasi;

  const Alat({
    required this.id,
    required this.nama,
    required this.kategori,
    required this.jumlah,
    required this.status,
    this.deskripsi,
    this.lokasi,
  });
}
