import 'package:flutter/material.dart';
import 'package:pbase_peminjaman_alat_lab/features/domain/entities/alat.dart';
import 'package:pbase_peminjaman_alat_lab/features/domain/usecases/alat_usecases.dart';

class AlatProvider with ChangeNotifier {
  final GetAlatStream getAlatStream;
  final GetAlatDetail getAlatDetail;

  AlatProvider({required this.getAlatStream, required this.getAlatDetail});

  List<Alat> _alatList = [];
  List<Alat> get alatList => _alatList;

  Alat? _alatDetail;
  Alat? get alatDetail => _alatDetail;

  void fetchAlatStream() {
    getAlatStream().listen((alatList) {
      _alatList = alatList;
      notifyListeners();
    });
  }

  Future<void> fetchAlatDetail(String id) async {
    _alatDetail = await getAlatDetail(id);
    notifyListeners();
  }
}
