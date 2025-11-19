import 'package:flutter/material.dart';
import '../../domain/repositories/alat_repository.dart';
import '../../domain/entities/alat.dart';

class AlatProvider extends ChangeNotifier {
  final AlatRepository _alatRepository;
  
  List<Alat> _alatList = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _isStreamActive = false;

  AlatProvider(this._alatRepository);

  List<Alat> get alatList => _alatList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void fetchAlatStream() {
    if (_isStreamActive) {
      print('⚠️ Alat stream already active, skipping');
      return;
    }
    
    _isStreamActive = true;
    _isLoading = true;
    print('🔵 Starting alat stream...');
    
    _alatRepository.getAlatStream().listen(
      (alatList) {
        _alatList = alatList;
        _isLoading = false;
        print('✅ Alat list updated: ${alatList.length} items');
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        _isLoading = false;
        _isStreamActive = false;
        print('❌ Error in alat stream: $error');
        notifyListeners();
      },
      onDone: () {
        print('⚠️ Alat stream done');
        _isStreamActive = false;
      },
    );
  }

  @override
  void dispose() {
    _isStreamActive = false;
    super.dispose();
  }
}
