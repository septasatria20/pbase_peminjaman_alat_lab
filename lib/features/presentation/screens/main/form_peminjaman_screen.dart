import 'package:flutter/material.dart';
import 'package:pbase_peminjaman_alat_lab/features/presentation/style/color.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pbase_peminjaman_alat_lab/features/presentation/providers/history_provider.dart';

class FormPeminjamanScreen extends StatefulWidget {
  final String namaAlat;
  final String iconPath;
  const FormPeminjamanScreen({
    super.key,
    required this.namaAlat,
    required this.iconPath,
  });

  @override
  State<FormPeminjamanScreen> createState() => _FormPeminjamanScreenState();
}

bool _isEnabledDay(DateTime day, DateTime firstDate) {
  // Disable semua sebelum firstDate, termasuk hari ini
  return !day.isBefore(firstDate.subtract(Duration(days: 1)));
}

class _FormPeminjamanScreenState extends State<FormPeminjamanScreen> {
  final _tglPinjamController = TextEditingController();
  final _tglKembaliController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set tanggal default
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
    super.dispose();
  }

  void _ajukanPeminjaman() {
    final addHistoryProvider = Provider.of<HistoryProvider>(
      context,
      listen: false,
    );

    
    final namaAlat = widget.namaAlat;
    final tanggalPinjam = DateFormat(
      "dd-MM-yyyy",
    ).parse(_tglPinjamController.text);
    final tanggalKembali = DateFormat(
      "dd-MM-yyyy",
    ).parse(_tglKembaliController.text);
    const status = "menunggu konfirmasi";

    addHistoryProvider.addHistory(
  
      namaAlat: namaAlat,
      tanggalPinjam: tanggalPinjam,
      tanggalKembali: tanggalKembali,
      status: status,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Pengajuan peminjaman terkirim!"),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.of(context).pop();
  }

  // Tambahkan fungsi untuk membuka kalender
  Future<DateTime?> _openCalendar(DateTime firstDate) async {
    DateTime? selected;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SizedBox(
              height: 420,
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
                enabledDayPredicate: (day) {
                  return _isEnabledDay(day, firstDate);
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: colorMaroon,
                    shape: BoxShape.circle,
                  ),
                  disabledTextStyle: const TextStyle(color: Colors.grey),
                  weekendTextStyle: const TextStyle(color: Colors.black),
                ),
              ),
            );
          },
        );
      },
    );

    return selected;
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
            // Header Info Alat
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0F0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.laptop_chromebook,
                      color: colorMaroon,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Anda akan meminjam:",
                          style: TextStyle(color: Colors.black54),
                        ),
                        Text(
                          widget.namaAlat,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Form Tanggal Pinjam
            TextFormField(
              controller: _tglPinjamController,
              decoration: const InputDecoration(
                labelText: 'Tanggal Pinjam',
                prefixIcon: Icon(Icons.calendar_today_outlined),
              ),
              readOnly: true,
              onTap: () async {
                final today = DateTime.now();
                final selected = await _openCalendar(today);

                if (selected != null) {
                  _tglPinjamController.text =
                      "${selected.day}-${selected.month}-${selected.year}";
                }
              },
            ),
            const SizedBox(height: 16),

            // Form Tanggal Kembali
            TextFormField(
              controller: _tglKembaliController,
              decoration: const InputDecoration(
                labelText: 'Tanggal Kembali',
                prefixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: () async {
                final pinjamDate = DateFormat(
                  "dd-MM-yyyy",
                ).parse(_tglPinjamController.text);
                final selected = await _openCalendar(
                  pinjamDate.add(const Duration(days: 1)),
                );

                if (selected != null) {
                  _tglKembaliController.text =
                      "${selected.day}-${selected.month}-${selected.year}";
                }
              },
            ),
            const SizedBox(height: 40),

            // Tombol Ajukan
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
