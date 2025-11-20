import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SeedAdmin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> createAdmins() async {
    final admins = [
      {
        'email': 'admin.ba@lab.polinema.ac.id',
        'password': 'admin123',
        'name': 'Admin Lab BA',
        'lab': 'BA',
      },
      {
        'email': 'admin.is@lab.polinema.ac.id',
        'password': 'admin123',
        'name': 'Admin Lab IS',
        'lab': 'IS',
      },
      {
        'email': 'admin.se@lab.polinema.ac.id',
        'password': 'admin123',
        'name': 'Admin Lab SE',
        'lab': 'SE',
      },
      {
        'email': 'admin.studio@lab.polinema.ac.id',
        'password': 'admin123',
        'name': 'Admin Lab Studio',
        'lab': 'STUDIO',
      },
      {
        'email': 'admin.ncs@lab.polinema.ac.id',
        'password': 'admin123',
        'name': 'Admin Lab NCS',
        'lab': 'NCS',
      },
    ];

    print('Starting admin creation...\n');

    for (var admin in admins) {
      try {
        print('Creating admin: ${admin['email']}');
        
        // Create auth user
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: admin['email']!,
          password: admin['password']!,
        );

        // Create Firestore document
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'id': userCredential.user!.uid,
          'name': admin['name'],
          'email': admin['email'],
          'role': 'admin',
          'lab': admin['lab'],
          'createdAt': FieldValue.serverTimestamp(),
        });

        print('Admin created: ${admin['email']} (${admin['lab']})\n');
      } catch (e) {
        if (e.toString().contains('email-already-in-use')) {
          print('Admin already exists: ${admin['email']}\n');
        } else {
          print('Error creating admin ${admin['email']}: $e\n');
        }
      }
    }

    print('✅ All admins processed!\n');
    print('═══════════════════════════════════════');
    print('Default password for all admins: admin123');
    print('═══════════════════════════════════════\n');
    print('Admin Credentials:');
    print('───────────────────────────────────────');
    for (var admin in admins) {
      print('${admin['lab']?.toString().padRight(8)}: ${admin['email']}');
    }
    print('───────────────────────────────────────\n');
  }

  Future<void> deleteAllAdmins() async {
    final admins = [
      'admin.ba@lab.polinema.ac.id',
      'admin.is@lab.polinema.ac.id',
      'admin.se@lab.polinema.ac.id',
      'admin.studio@lab.polinema.ac.id',
      'admin.ncs@lab.polinema.ac.id',
      'septa@admin.com', // OLD EMAIL
    ];

    print('🔴 Deleting old admin accounts...\n');

    for (var email in admins) {
      try {
        // Get user by email (requires Firebase Admin SDK)
        // For now, manual deletion via console is recommended
        print('⚠️  Please manually delete: $email from Firebase Console');
      } catch (e) {
        print('Error: $e');
      }
    }
  }
}
