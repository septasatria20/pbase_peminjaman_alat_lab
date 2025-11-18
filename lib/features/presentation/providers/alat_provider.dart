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

  bool _isStreamActive = false;

  void fetchAlatStream() {
    // Prevent multiple stream subscriptions
    if (_isStreamActive) {
      print('⚠️ Stream already active, skipping fetchAlatStream');
      return;
    }
    
    _isStreamActive = true;
    print('🔵 Starting alat stream...');
    
    getAlatStream().listen(
      (alatList) {
        _alatList = alatList;
        print('✅ Alat list updated: ${alatList.length} items');
        notifyListeners();
      },
      onError: (error) {
        print('❌ Error in alat stream: $error');
        _isStreamActive = false;
      },
      onDone: () {
        print('⚠️ Stream done');
        _isStreamActive = false;
      },
    );
  }

  Future<void> fetchAlatDetail(String id) async {
    _alatDetail = await getAlatDetail(id);
    notifyListeners();
  }

  @override
  void dispose() {
    _isStreamActive = false;
    super.dispose();
  }
}
