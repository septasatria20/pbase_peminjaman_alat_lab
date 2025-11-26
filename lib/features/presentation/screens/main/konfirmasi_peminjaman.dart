import 'package:flutter/material.dart';
import 'package:pbase_peminjaman_alat_lab/features/presentation/providers/history_provider.dart';
import 'package:pbase_peminjaman_alat_lab/features/presentation/style/color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

class FormPeminjamanScreen extends StatefulWidget {
  final Map<String, int> selectedItems;
  final String activeRoom;

  const FormPeminjamanScreen({
    super.key,
    required this.selectedItems,
    required this.activeRoom,
  });

  @override
  State<FormPeminjamanScreen> createState() => _FormPeminjamanScreenState();
}

class _FormPeminjamanScreenState extends State<FormPeminjamanScreen> {
  final _tglPinjamController = TextEditingController();
  final _tglKembaliController = TextEditingController();
  final _alasanController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final today = DateTime.now();
    final tomorrow = today.add(const Duration(days: 1));

    _tglPinjamController.text = "${today.day}-${today.month}-${today.year}";
    _tglKembaliController.text =
        "${tomorrow.day}-${tomorrow.month}-${tomorrow.year}";
  }

  @override
  void dispose() {
    _tglPinjamController.dispose();
    _tglKembaliController.dispose();
    _alasanController.dispose();
    super.dispose();
  }

  void _ajukanPeminjaman() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception("User ID is null. Ensure the user is logged in.");
      }

      final alat = widget.selectedItems.entries.map((entry) {
        return {"id": entry.key, "jumlah": entry.value};
      }).toList();

      final tanggalPinjam = DateFormat(
        "dd-MM-yyyy",
      ).parse(_tglPinjamController.text);
      final tanggalKembali = DateFormat(
        "dd-MM-yyyy",
      ).parse(_tglKembaliController.text);
      final alasan = _alasanController.text;
      final lab = widget.activeRoom;
      final status = "menunggu persetujuan";

      print("📤 Sending data to provider...");
      await Provider.of<HistoryProvider>(context, listen: false).addHistory(
        userId: userId,
        alat: alat,
        lab: lab,
        tanggalPinjam: tanggalPinjam,
        tanggalKembali: tanggalKembali,
        alasan: alasan,
        status: status,
      );

      print("✅ Data successfully sent to provider.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Pengajuan peminjaman terkirim!"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      print("❌ Error sending data to provider: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal mengajukan peminjaman: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // LOGIC SAMA SEPERTI KODE PERTAMA
  bool _isEnabledDay(DateTime day, DateTime firstDate) {
    return !day.isBefore(firstDate.subtract(const Duration(days: 1)));
  }

  Future<DateTime?> _openCalendar(DateTime firstDate) async {
    DateTime? selected;

    return await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: FloatingActionButton.extended(
                        onPressed: () {
                          Navigator.of(context).pop(selected);
                        },
                        backgroundColor: colorMaroon,
                        elevation: 4,
                        label: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.touch_app_rounded,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              "Pilih Tanggal",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // CALENDAR
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: TableCalendar(
                      firstDay: firstDate,
                      lastDay: DateTime(2100),
                      focusedDay: selected ?? firstDate,
                      selectedDayPredicate: (day) {
                        return selected != null &&
                            day.year == selected!.year &&
                            day.month == selected!.month &&
                            day.day == selected!.day;
                      },
                      onDaySelected: (day, _) {
                        if (!_isEnabledDay(day, firstDate)) return;
                        setState(() => selected = day);
                      },

                      // LOGIC ENABLE = SAMA PERSIS DENGAN FILE PERTAMA
                      enabledDayPredicate: (day) {
                        return _isEnabledDay(day, firstDate);
                      },

                      calendarStyle: const CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: BoxDecoration(
                          color: colorMaroon,
                          shape: BoxShape.circle,
                        ),
                        disabledTextStyle: TextStyle(color: Colors.grey),
                        weekendTextStyle: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Formulir Peminjaman"),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Ruangan Aktif: ${widget.activeRoom}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // DAFTAR ITEM TERPILIH
            ...widget.selectedItems.entries.map((entry) {
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('alat')
                    .doc(entry.key)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Text(
                      "Data alat tidak ditemukan.",
                      style: TextStyle(color: Colors.grey),
                    );
                  }

                  final data = snapshot.data!.data() as Map<String, dynamic>;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      leading: Image.network(
                        data['gambar'] ?? '',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.broken_image),
                      ),
                      title: Text(data['nama'] ?? 'Tanpa Nama'),
                      subtitle: Text('Jumlah: ${entry.value}'),
                    ),
                  );
                },
              );
            }).toList(),

            const SizedBox(height: 24),

            // TANGGAL PINJAM
            TextFormField(
              controller: _tglPinjamController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Tanggal Pinjam',
                prefixIcon: Icon(Icons.calendar_today_outlined),
              ),
              onTap: () async {
                final today = DateTime.now();
                final selectedDate = await _openCalendar(today);

                if (selectedDate != null) {
                  setState(() {
                    _tglPinjamController.text =
                        "${selectedDate.day}-${selectedDate.month}-${selectedDate.year}";
                  });
                }
              },
            ),

            const SizedBox(height: 16),

            // TANGGAL KEMBALI
            TextFormField(
              controller: _tglKembaliController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Tanggal Kembali',
                prefixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () async {
                final pinjamDate = DateFormat(
                  "dd-MM-yyyy",
                ).parse(_tglPinjamController.text);

                final selectedDate = await _openCalendar(
                  pinjamDate.add(const Duration(days: 1)),
                );

                if (selectedDate != null) {
                  setState(() {
                    _tglKembaliController.text =
                        "${selectedDate.day}-${selectedDate.month}-${selectedDate.year}";
                  });
                }
              },
            ),

            const SizedBox(height: 16),

            // ALASAN
            TextFormField(
              controller: _alasanController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Alasan Peminjaman',
                prefixIcon: Icon(Icons.edit_note),
              ),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _ajukanPeminjaman,
                child: const Text('Ajukan Peminjaman'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
