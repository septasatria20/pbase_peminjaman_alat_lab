import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/alat_provider.dart';
import '../../style/color.dart';
import '../../../domain/entities/alat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddEditAlatScreen extends StatefulWidget {
  final Alat? alat; // null = Add mode, not null = Edit mode

  const AddEditAlatScreen({Key? key, this.alat}) : super(key: key);

  @override
  State<AddEditAlatScreen> createState() => _AddEditAlatScreenState();
}

class _AddEditAlatScreenState extends State<AddEditAlatScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _jumlahController = TextEditingController();
  final _deskripsiController = TextEditingController();
  
  String _kategoriTerpilih = 'komponen';
  String _statusTerpilih = 'tersedia';
  bool _isLoading = false;

  final List<String> _kategoriList = [
    'komponen',
    'perangkat',
    'kabel',
    'lainnya',
  ];

  final List<String> _statusList = [
    'tersedia',
    'dipinjam',
    'rusak',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.alat != null) {
      // Edit mode - populate fields
      _namaController.text = widget.alat!.nama;
      _jumlahController.text = widget.alat!.jumlah.toString();
      _deskripsiController.text = widget.alat!.deskripsi ?? '';
      _kategoriTerpilih = widget.alat!.kategori;
      _statusTerpilih = widget.alat!.status;
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _jumlahController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  bool get isEditMode => widget.alat != null;

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final adminLab = authProvider.userLab ?? 'BA';
      final firestore = FirebaseFirestore.instance;

      final alatData = {
        'nama': _namaController.text.trim(),
        'kategori': _kategoriTerpilih,
        'jumlah': int.parse(_jumlahController.text),
        'status': _statusTerpilih,
        'ruang': adminLab,
        'deskripsi': _deskripsiController.text.trim(),
      };

      if (isEditMode) {
        // Update existing alat
        await firestore.collection('alat').doc(widget.alat!.id).update(alatData);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Alat berhasil diupdate'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Add new alat
        await firestore.collection('alat').add({
          ...alatData,
          'createdAt': FieldValue.serverTimestamp(),
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Alat berhasil ditambahkan'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      if (mounted) {
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          isEditMode ? 'Edit Alat' : 'Tambah Alat',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: colorMaroon,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Form Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama Alat
                    const Text(
                      'Nama Alat *',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _namaController,
                      decoration: InputDecoration(
                        hintText: 'Contoh: Arduino Uno R3',
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[200]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: colorMaroon, width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama alat tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Kategori
                    const Text(
                      'Kategori *',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _kategoriTerpilih,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[200]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: colorMaroon, width: 2),
                        ),
                      ),
                      items: _kategoriList.map((kategori) {
                        return DropdownMenuItem(
                          value: kategori,
                          child: Text(kategori[0].toUpperCase() + kategori.substring(1)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _kategoriTerpilih = value!);
                      },
                    ),
                    const SizedBox(height: 20),

                    // Jumlah
                    const Text(
                      'Jumlah Stok *',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _jumlahController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Contoh: 10',
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[200]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: colorMaroon, width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Jumlah tidak boleh kosong';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Jumlah harus berupa angka';
                        }
                        if (int.parse(value) < 0) {
                          return 'Jumlah tidak boleh negatif';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Status
                    const Text(
                      'Status *',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _statusTerpilih,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[200]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: colorMaroon, width: 2),
                        ),
                      ),
                      items: _statusList.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(status[0].toUpperCase() + status.substring(1)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _statusTerpilih = value!);
                      },
                    ),
                    const SizedBox(height: 20),

                    // Deskripsi
                    const Text(
                      'Deskripsi (Opsional)',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _deskripsiController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Deskripsi atau spesifikasi alat...',
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[200]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: colorMaroon, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [colorMaroon, colorMaroonDark],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorMaroon.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          isEditMode ? 'Update Alat' : 'Tambah Alat',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
