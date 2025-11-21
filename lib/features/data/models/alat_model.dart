import '../../domain/entities/alat.dart';

class AlatModel extends Alat {
  const AlatModel({
    required String id,
    required String nama,
    required String kategori,
    required int jumlah,
    required String status,
    required String ruang,
    String? deskripsi,
    String? gambar,
  }) : super(
          id: id,
          nama: nama,
          kategori: kategori,
          jumlah: jumlah,
          status: status,
          ruang: ruang,
          deskripsi: deskripsi,
          gambar: gambar,
        );

  factory AlatModel.fromJson(String id, Map<String, dynamic> json) {
    return AlatModel(
      id: id,
      nama: json['nama'] ?? '',
      kategori: json['kategori'] ?? '',
      jumlah: json['jumlah'] ?? 0,
      status: json['status'] ?? 'tersedia',
      ruang: json['ruang'] ?? '',
      deskripsi: json['deskripsi'],
      gambar: json['gambar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama': nama,
      'kategori': kategori,
      'jumlah': jumlah,
      'status': status,
      'ruang': ruang,
      if (deskripsi != null) 'deskripsi': deskripsi,
      if (gambar != null) 'gambar': gambar,
    };
  }
}
