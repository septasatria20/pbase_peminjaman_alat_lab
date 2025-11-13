import 'package:pbase_peminjaman_alat_lab/features/domain/entities/alat.dart';

class AlatModel extends Alat {
  const AlatModel({
    required String id,
    required String nama,
    required String kategori,
    required int jumlah,
    required String status,
    required String deskripsi,
    required String gambar,
  }) : super(
         id: id,
         nama: nama,
         kategori: kategori,
         jumlah: jumlah,
         status: status,
         deskripsi: deskripsi,
         gambar: gambar,
       );

  factory AlatModel.fromJson(String id, Map<String, dynamic> json) {
    return AlatModel(
      id: id,
      nama: json['nama'] ?? '',
      kategori: json['kategori'] ?? '',
      jumlah: (json['jumlah'] ?? 0) is int
          ? json['jumlah']
          : int.tryParse(json['jumlah'].toString()) ?? 0,
      status: json['status'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      gambar: json['gambar'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama': nama,
      'kategori': kategori,
      'jumlah': jumlah,
      'status': status,
      'deskripsi': deskripsi,
      'gambar': gambar,
    };
  }
}
