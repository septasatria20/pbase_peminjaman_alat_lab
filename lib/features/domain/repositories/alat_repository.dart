import 'package:pbase_peminjaman_alat_lab/features/domain/entities/alat.dart';

abstract class AlatRepository {
  Stream<List<Alat>> getAlatStream();
  Future<Alat?> getAlatDetail(String id);
}
