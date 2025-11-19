import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/alat_model.dart';
import '../../domain/entities/alat.dart';
import '../../domain/repositories/alat_repository.dart';

class AlatRepositoryImpl implements AlatRepository {
  final FirebaseFirestore _firestore;

  AlatRepositoryImpl(this._firestore);

  @override
  Stream<List<Alat>> getAlatStream() {
    print('🔵 AlatRepository - Starting Firestore stream...');
    return _firestore
        .collection('alat')
        .snapshots()
        .map((snapshot) {
          print('📦 Received ${snapshot.docs.length} documents from Firestore');
          return snapshot.docs
              .map((doc) => AlatModel.fromJson(doc.id, doc.data()))
              .toList();
        });
  }

  @override
  Future<Alat?> getAlatDetail(String id) async {
    try {
      final doc = await _firestore.collection('alat').doc(id).get();
      if (!doc.exists) return null;
      return AlatModel.fromJson(doc.id, doc.data()!);
    } catch (e) {
      print('❌ Error getting alat detail: $e');
      return null;
    }
  }
}
