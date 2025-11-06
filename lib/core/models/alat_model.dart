class Alat {
  final String id;
  final String nama;
  final String kategori;
  final int jumlah;
  final String status;
  final String deskripsi;
  final String gambar;

  Alat({
    required this.id,
    required this.nama,
    required this.kategori,
    required this.jumlah,
    required this.status,
    required this.deskripsi,
    required this.gambar,
  });

  factory Alat.fromFirestore(String id, Map<String, dynamic> data) {
    return Alat(
      id: id,
      nama: data['nama'] ?? '',
      kategori: data['kategori'] ?? '',
      jumlah: (data['jumlah'] ?? 0) is int ? data['jumlah'] : int.tryParse(data['jumlah'].toString()) ?? 0,
      status: data['status'] ?? '',
      deskripsi: data['deskripsi'] ?? '',
      gambar: data['gambar'] ?? '',
    );
  }
}
