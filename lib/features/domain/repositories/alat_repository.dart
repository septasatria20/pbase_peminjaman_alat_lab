import '../entities/alat.dart';

abstract class AlatRepository {
  Stream<List<Alat>> getAlatStream();
  Future<Alat?> getAlatDetail(String id);
}
