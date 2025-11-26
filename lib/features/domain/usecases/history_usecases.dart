import 'package:pbase_peminjaman_alat_lab/features/domain/entities/history.dart'
    show HistoryEntity;

import '../repositories/history_repository.dart';

class GetUserHistory {
  final HistoryRepository repository;
  GetUserHistory(this.repository);

  Future<List<HistoryEntity>> call(String userId) {
    return repository.getUserHistory(userId);
  }
}

class AddHistoryUseCase {
  final HistoryRepository repository;

  AddHistoryUseCase(this.repository);

  Future<void> call({
    required String userId,
    required String alatId,
    required String namaAlat,
    required String lab,
    required DateTime tanggalPinjam,
    required DateTime tanggalKembali,
    required String status,
  }) async {
    return repository.addHistory(
      userId: userId,
      alatId: alatId,
      namaAlat: namaAlat,
      lab: lab,
      tanggalPinjam: tanggalPinjam,
      tanggalKembali: tanggalKembali,
      status: status,
    );
  }
}
