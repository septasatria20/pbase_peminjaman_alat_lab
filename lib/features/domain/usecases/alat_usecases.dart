import 'package:pbase_peminjaman_alat_lab/features/domain/entities/alat.dart';
import 'package:pbase_peminjaman_alat_lab/features/domain/repositories/alat_repository.dart';

class GetAlatStream {
  final AlatRepository repository;

  GetAlatStream(this.repository);

  Stream<List<Alat>> call() {
    return repository.getAlatStream();
  }
}

class GetAlatDetail {
  final AlatRepository repository;

  GetAlatDetail(this.repository);

  Future<Alat?> call(String id) {
    return repository.getAlatDetail(id);
  }
}
