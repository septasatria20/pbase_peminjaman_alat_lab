import 'package:flutter/material.dart';
import 'package:pbase_peminjaman_alat_lab/features/domain/entities/history.dart';
import 'package:provider/provider.dart';
import 'package:pbase_peminjaman_alat_lab/features/presentation/providers/history_provider.dart';
import 'package:pbase_peminjaman_alat_lab/features/presentation/style/color.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    final historyProvider = Provider.of<HistoryProvider>(
      context,
      listen: false,
    );
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      print('🔍 [HistoryScreen] User ID: $userId'); // Debug log
      historyProvider.fetchUserHistory(userId);
    } else {
      print('❌ [HistoryScreen] Error: User ID is null');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Riwayat Peminjaman"),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Consumer<HistoryProvider>(
        builder: (context, historyProvider, child) {
          final historyList = historyProvider.state;

          print('🔍 [HistoryScreen] History list: $historyList'); // Debug log

          if (historyList.isEmpty) {
            print('ℹ️ [HistoryScreen] No history data available'); // Debug log
            return const Center(child: Text("Belum ada riwayat peminjaman."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: historyList.length,
            itemBuilder: (context, index) {
              print(
                '🔍 [HistoryScreen] Building history card for index $index',
              ); // Debug log
              return _buildHistoryCard(context, historyList[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, HistoryEntity item) {
    final statusColor = _getStatusColor(item.status);
    final iconBgColor = _getIconBgColor(item.status);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.inventory_2, color: statusColor, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.namaAlat,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${item.tanggalPinjam} - ${item.tanggalKembali}",
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    item.status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Disetujui':
        return Colors.green[700]!;
      case 'Diajukan':
        return Colors.orange[700]!;
      case 'Ditolak':
        return Colors.red[700]!;
      default:
        return Colors.grey[600]!;
    }
  }

  Color _getIconBgColor(String status) {
    switch (status) {
      case 'Disetujui':
        return Colors.green[50]!;
      case 'Diajukan':
        return Colors.orange[50]!;
      case 'Ditolak':
        return Colors.red[50]!;
      default:
        return Colors.grey[100]!;
    }
  }
}
