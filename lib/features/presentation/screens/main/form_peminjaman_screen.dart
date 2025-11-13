import 'package:flutter/material.dart';
import 'package:pbase_peminjaman_alat_lab/features/presentation/style/color.dart';

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
    _tglKembaliController.text = "${tomorrow.day}-${tomorrow.month}-${tomorrow.year}";
  }

  @override
  void dispose() {
    _tglPinjamController.dispose();
    _tglKembaliController.dispose();
    super.dispose();
  }

  void _ajukanPeminjaman() {
    // Simulasi pengajuan berhasil
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Pengajuan peminjaman terkirim!"),
        backgroundColor: Colors.green,
      ),
    );
    // Kembali ke dashboard
    Navigator.of(context).pop();
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
                // TODO: Implement date picker
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
                // TODO: Implement date picker
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

