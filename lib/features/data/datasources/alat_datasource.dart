import 'package:cloud_firestore/cloud_firestore.dart';

class AlatDataSource {
  final FirebaseFirestore _firestore;

  AlatDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> getAlatStream() {
    return _firestore.collection('alat').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    });
  }

  Future<Map<String, dynamic>?> getAlatDetail(String id) async {
    final doc = await _firestore.collection('alat').doc(id).get();
    return doc.exists ? {'id': doc.id, ...doc.data()!} : null;
  }
}
