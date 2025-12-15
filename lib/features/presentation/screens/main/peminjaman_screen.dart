import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:provider/provider.dart';
import 'package:pbase_peminjaman_alat_lab/features/presentation/providers/alat_provider.dart';
import 'package:pbase_peminjaman_alat_lab/features/presentation/providers/auth_provider.dart';
import 'package:pbase_peminjaman_alat_lab/features/presentation/providers/history_provider.dart';
import 'package:pbase_peminjaman_alat_lab/features/presentation/style/color.dart';

class PeminjamanScreen extends StatefulWidget {
  const PeminjamanScreen({super.key});

  @override
  State<PeminjamanScreen> createState() => _PeminjamanScreenState();
}

class _PeminjamanScreenState extends State<PeminjamanScreen> {
  final _alasanController = TextEditingController();
  DateTime _tanggalPinjam = DateTime.now();
  DateTime _tanggalKembali = DateTime.now().add(const Duration(days: 7));
  bool _isLoading = false;

  String _kategoriTerpilih = "semua";
  String _ruangTerpilih = "BA";
  final Map<String, int> _selectedItems = {};

  final Map<String, IconData> _kategoriList = {
    "komponen": Icons.memory,
    "perangkat": Icons.laptop,
    "kabel": Icons.cable,
    "lainnya": Icons.more_horiz,
  };

  final List<String> _ruangList = ["BA", "IS", "NCS", "SE", "STUDIO"];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final alatProvider = context.read<AlatProvider>();
      alatProvider.fetchAlatStream();
    });
  }

  @override
  void dispose() {
    _alasanController.dispose();
    super.dispose();
  }

  Future<void> _selectTanggalPinjam(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _tanggalPinjam,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(
            context,
          ).copyWith(colorScheme: ColorScheme.light(primary: primaryColor)),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _tanggalPinjam) {
      setState(() {
        _tanggalPinjam = picked;
        if (_tanggalKembali.isBefore(_tanggalPinjam)) {
          _tanggalKembali = _tanggalPinjam.add(const Duration(days: 7));
        }
      });
    }
  }

  Future<void> _selectTanggalKembali(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _tanggalKembali,
      firstDate: _tanggalPinjam,
      lastDate: _tanggalPinjam.add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(
            context,
          ).copyWith(colorScheme: ColorScheme.light(primary: primaryColor)),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _tanggalKembali) {
      setState(() => _tanggalKembali = picked);
    }
  }

  void _toggleSelection(String alatId, int maxStock) {
    setState(() {
      if (_selectedItems.containsKey(alatId)) {
        _selectedItems.remove(alatId);
      } else {
        _selectedItems[alatId] = 1;
      }
    });
  }

  void _updateQuantity(String alatId, int newQty, int maxStock) {
    if (newQty > 0 && newQty <= maxStock) {
      setState(() {
        _selectedItems[alatId] = newQty;
      });
    }
  }

  Future<void> _submitPeminjaman() async {
    if (_selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih minimal 1 alat'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_alasanController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alasan tidak boleh kosong'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final userId =
          authProvider.currentUser?.id ?? authProvider.firebaseUser?.uid;

      if (userId == null) {
        throw Exception('User not found');
      }

      final alatList = _selectedItems.entries
          .map((e) => {'id': e.key, 'jumlah': e.value})
          .toList();

      await FirebaseFirestore.instance.collection('peminjaman').add({
        'userId': userId,
        'lab': _ruangTerpilih,
        'alat': alatList,
        'tanggalPinjam': Timestamp.fromDate(_tanggalPinjam),
        'tanggalKembali': Timestamp.fromDate(_tanggalKembali),
        'alasan': _alasanController.text.trim(),
        'status': 'menunggu persetujuan',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        // Refresh history
        await context.read<HistoryProvider>().fetchUserHistory(userId);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text('Peminjaman berhasil diajukan!'),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        // Navigate back
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengajukan peminjaman: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
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
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Pilih Alat'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: themeGradient),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer2<AuthProvider, AlatProvider>(
        builder: (context, authProvider, alatProvider, child) {
          final alatList = alatProvider.alatList;

          final alatFiltered = alatList.where((alat) {
            final cocokRuang =
                alat.ruang.toLowerCase() == _ruangTerpilih.toLowerCase();
            final cocokKategori =
                _kategoriTerpilih == "semua" ||
                alat.kategori.toLowerCase() == _kategoriTerpilih.toLowerCase();
            return cocokRuang && cocokKategori && alat.jumlah > 0;
          }).toList();

          return Column(
            children: [
              // Filters
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _ruangTerpilih,
                            decoration: InputDecoration(
                              labelText: 'Laboratorium',
                              filled: true,
                              fillColor: Colors.grey[50],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            items: _ruangList.map((ruang) {
                              return DropdownMenuItem(
                                value: ruang,
                                child: Text(ruang.toUpperCase()),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _ruangTerpilih = value!;
                                _selectedItems.clear();
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _kategoriTerpilih,
                            decoration: InputDecoration(
                              labelText: 'Kategori',
                              filled: true,
                              fillColor: Colors.grey[50],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            items: [
                              const DropdownMenuItem(
                                value: "semua",
                                child: Text("Semua"),
                              ),
                              ..._kategoriList.keys.map((kategori) {
                                return DropdownMenuItem(
                                  value: kategori,
                                  child: Text(
                                    kategori[0].toUpperCase() +
                                        kategori.substring(1),
                                  ),
                                );
                              }).toList(),
                            ],
                            onChanged: (value) {
                              setState(() => _kategoriTerpilih = value!);
                            },
                          ),
                        ),
                      ],
                    ),
                    if (_selectedItems.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: themeGradient.scale(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.shopping_cart,
                              color: themeBlue,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${_selectedItems.length} alat dipilih',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: themeBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Grid Alat
              Expanded(
                child: alatFiltered.isEmpty
                    ? const Center(child: Text('Tidak ada alat tersedia'))
                    : GridView.builder(
                        padding: EdgeInsets.only(
                          left: 16,
                          right: 16,
                          top: 16,
                          bottom: _selectedItems.isNotEmpty ? 300 : 16,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.7,
                            ),
                        itemCount: alatFiltered.length,
                        itemBuilder: (context, index) {
                          final alat = alatFiltered[index];
                          final isSelected = _selectedItems.containsKey(
                            alat.id,
                          );
                          final quantity = _selectedItems[alat.id] ?? 0;

                          return InkWell(
                            onTap: () => _toggleSelection(alat.id, alat.jumlah),
                            borderRadius: BorderRadius.circular(12),
                            child: Card(
                              elevation: isSelected ? 6 : 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: isSelected
                                      ? themeBlue
                                      : Colors.grey[200]!,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              color: isSelected
                                  ? themeBlue.withOpacity(0.05)
                                  : Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (alat.gambar != null)
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                          alat.gambar!,
                                          width: double.infinity,
                                          height: 70,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return Container(
                                                  width: double.infinity,
                                                  height: 70,
                                                  decoration: BoxDecoration(
                                                    gradient: themeGradient
                                                        .scale(0.2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                  ),
                                                  child: const Icon(
                                                    Icons.inventory,
                                                    size: 35,
                                                    color: themeBlue,
                                                  ),
                                                );
                                              },
                                        ),
                                      )
                                    else
                                      Container(
                                        width: double.infinity,
                                        height: 70,
                                        decoration: BoxDecoration(
                                          gradient: themeGradient.scale(0.2),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.inventory,
                                          size: 35,
                                          color: themeBlue,
                                        ),
                                      ),
                                    const Spacer(),
                                    Text(
                                      alat.nama,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Stok: ${alat.jumlah}',
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                    if (isSelected) ...[
                                      const SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.remove_circle,
                                            ),
                                            color: themeBlue,
                                            iconSize: 18,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            onPressed: quantity > 1
                                                ? () => _updateQuantity(
                                                    alat.id,
                                                    quantity - 1,
                                                    alat.jumlah,
                                                  )
                                                : null,
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3,
                                            ),
                                            margin: const EdgeInsets.symmetric(
                                              horizontal: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              gradient: themeGradient,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              '$quantity',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.add_circle),
                                            color: themeBlue,
                                            iconSize: 18,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            onPressed: quantity < alat.jumlah
                                                ? () => _updateQuantity(
                                                    alat.id,
                                                    quantity + 1,
                                                    alat.jumlah,
                                                  )
                                                : null,
                                          ),
                                        ],
                                      ),
                                    ] else
                                      const SizedBox(height: 6),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: isSelected
                                            ? themeGradient
                                            : null,
                                        color: isSelected
                                            ? null
                                            : Colors.grey[200],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Text(
                                          isSelected ? 'Dipilih' : 'Pilih',
                                          style: TextStyle(
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.black87,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),

              // Bottom Sheet Form
              if (_selectedItems.isNotEmpty)
                Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.4,
                  ),
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 12,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  await _selectTanggalPinjam(context);
                                },
                                icon: const Icon(
                                  Icons.calendar_today,
                                  size: 16,
                                  color: themeBlue,
                                ),
                                label: Text(
                                  DateFormat('dd/MM/yy').format(_tanggalPinjam),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: themeBlue,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: themeBlue),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 8,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  await _selectTanggalKembali(context);
                                },
                                icon: const Icon(
                                  Icons.event,
                                  size: 16,
                                  color: themeBlue,
                                ),
                                label: Text(
                                  DateFormat('dd/MM/yy').format(_tanggalKembali),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: themeBlue,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: themeBlue),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 8,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _alasanController,
                          maxLines: 2,
                          decoration: InputDecoration(
                            hintText: 'Alasan peminjaman...',
                            filled: true,
                            fillColor: Colors.grey[50],
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: themeBlue,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: themeGradient,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: themeBlue.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submitPeminjaman,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    'Ajukan Peminjaman',
                                    style: TextStyle(
                                      fontSize: 15,
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
            ],
          );
        },
      ),
    );
  }
}
