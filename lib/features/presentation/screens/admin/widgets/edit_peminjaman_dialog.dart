import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../style/color.dart';

class EditPeminjamanDialog extends StatefulWidget {
  final String peminjamanId;
  final List<dynamic> alatList;

  const EditPeminjamanDialog({
    Key? key,
    required this.peminjamanId,
    required this.alatList,
  }) : super(key: key);

  @override
  State<EditPeminjamanDialog> createState() => _EditPeminjamanDialogState();
}

class _EditPeminjamanDialogState extends State<EditPeminjamanDialog> {
  late List<Map<String, dynamic>> _editableAlat;
  final Map<String, int> _stokTersedia = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _editableAlat = List<Map<String, dynamic>>.from(widget.alatList);
    _loadStokData();
  }

  Future<void> _loadStokData() async {
    try {
      for (var alat in _editableAlat) {
        final doc = await FirebaseFirestore.instance
            .collection('alat')
            .doc(alat['id'])
            .get();

        if (doc.exists) {
          final data = doc.data()!;
          _stokTersedia[alat['id']] = data['jumlah'] as int;
        }
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _removeAlat(int index) {
    setState(() {
      _editableAlat.removeAt(index);
    });
  }

  void _updateJumlah(int index, int newJumlah) {
    setState(() {
      _editableAlat[index]['jumlah'] = newJumlah;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: primaryColor),
            const SizedBox(height: 16),
            const Text('Memuat data alat...'),
          ],
        ),
      );
    }

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: const [
          Icon(Icons.edit, color: primaryColor),
          SizedBox(width: 8),
          Text('Edit Peminjaman'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Anda dapat mengurangi jumlah atau menghapus alat jika stok tidak mencukupi',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _editableAlat.length,
                itemBuilder: (context, index) {
                  final alat = _editableAlat[index];
                  final stok = _stokTersedia[alat['id']] ?? 0;
                  final jumlahDiminta = alat['jumlah'] as int;
                  final tidakCukup = jumlahDiminta > stok;

                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('alat')
                        .doc(alat['id'])
                        .get(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox();

                      final alatData =
                          snapshot.data!.data() as Map<String, dynamic>;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        color: tidakCukup ? Colors.red.shade50 : Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  if (alatData['gambar'] != null)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        alatData['gambar'],
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(
                                              Icons.inventory,
                                              size: 50,
                                            ),
                                      ),
                                    )
                                  else
                                    const Icon(Icons.inventory, size: 50),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          alatData['nama'] ?? 'Tanpa Nama',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Stok tersedia: $stok',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: tidakCukup
                                                ? Colors.red
                                                : secondaryColor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => _removeAlat(index),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Text(
                                    'Jumlah:',
                                    style: TextStyle(fontSize: 13),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                    ),
                                    onPressed: jumlahDiminta > 1
                                        ? () => _updateJumlah(
                                            index,
                                            jumlahDiminta - 1,
                                          )
                                        : null,
                                    iconSize: 20,
                                    color: primaryColor,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '$jumlahDiminta',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    onPressed: jumlahDiminta < stok
                                        ? () => _updateJumlah(
                                            index,
                                            jumlahDiminta + 1,
                                          )
                                        : null,
                                    iconSize: 20,
                                    color: primaryColor,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _editableAlat.isEmpty
              ? null
              : () => Navigator.pop(context, _editableAlat),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
          ),
          child: const Text('Simpan & Setujui'),
        ),
      ],
    );
  }
}
