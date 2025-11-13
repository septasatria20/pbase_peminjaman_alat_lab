import 'package:pbase_peminjaman_alat_lab/features/data/datasources/alat_datasource.dart';
import 'package:pbase_peminjaman_alat_lab/features/data/models/alat_model.dart';
import 'package:pbase_peminjaman_alat_lab/features/domain/entities/alat.dart';
import 'package:pbase_peminjaman_alat_lab/features/domain/repositories/alat_repository.dart';

class AlatRepositoryImpl implements AlatRepository {
  final AlatDataSource _dataSource;

  AlatRepositoryImpl(this._dataSource);

  @override
  Stream<List<Alat>> getAlatStream() {
    return _dataSource.getAlatStream().map((list) {
      return list.map((data) => AlatModel.fromJson(data['id'], data)).toList();
    });
  }

  @override
  Future<Alat?> getAlatDetail(String id) async {
    final data = await _dataSource.getAlatDetail(id);
    if (data != null) {
      return AlatModel.fromJson(id, data);
    }
    return null;
  }
}
