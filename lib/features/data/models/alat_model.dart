import '../../domain/entities/alat.dart';

class AlatModel extends Alat {
  const AlatModel({
    required String id,
    required String nama,
    required String kategori,
    required int jumlah,
    required String status,
    String? deskripsi,
    String? lokasi,
  }) : super(
          id: id,
          nama: nama,
          kategori: kategori,
          jumlah: jumlah,
          status: status,
          deskripsi: deskripsi,
          lokasi: lokasi,
        );

  factory AlatModel.fromJson(String id, Map<String, dynamic> json) {
    return AlatModel(
      id: id,
      nama: json['nama'] ?? '',
      kategori: json['kategori'] ?? '',
      jumlah: json['jumlah'] ?? 0,
      status: json['status'] ?? 'tersedia',
      deskripsi: json['deskripsi'],
      lokasi: json['lokasi'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama': nama,
      'kategori': kategori,
      'jumlah': jumlah,
      'status': status,
      'deskripsi': deskripsi,
      'lokasi': lokasi,
    };
  }
}
