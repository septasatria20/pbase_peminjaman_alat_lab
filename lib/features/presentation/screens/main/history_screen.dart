import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbase_peminjaman_alat_lab/features/presentation/providers/auth_provider.dart';
import 'package:pbase_peminjaman_alat_lab/features/presentation/providers/history_provider.dart';
import 'package:pbase_peminjaman_alat_lab/features/presentation/style/color.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final authProvider = context.read<AuthProvider>();
      final historyProvider = context.read<HistoryProvider>();
      final userId =
          authProvider.currentUser?.id ?? authProvider.firebaseUser?.uid;

      if (userId != null) {
        historyProvider.fetchUserHistory(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Riwayat Peminjaman',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: themeGradient),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<HistoryProvider>(
        builder: (context, historyProvider, _) {
          final historyList = historyProvider.state;

          if (historyList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: themeBlue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.history_rounded,
                      size: 80,
                      color: themeBlue.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Belum Ada Riwayat',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Riwayat peminjaman akan muncul di sini',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: textSecondary),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: historyList.length,
            itemBuilder: (context, index) {
              final history = historyList[index];
              final statusLower = history.status.toLowerCase();

              Color statusColor;
              String statusText;

              if (statusLower == 'disetujui') {
                statusColor = successColor;
                statusText = 'Disetujui';
              } else if (statusLower == 'ditolak') {
                statusColor = errorColor;
                statusText = 'Ditolak';
              } else if (statusLower == 'dikembalikan') {
                statusColor = themeBlue;
                statusText = 'Selesai';
              } else {
                statusColor = warningColor;
                statusText = 'Diajukan';
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Lab ${history.lab}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              statusText,
                              style: TextStyle(
                                fontSize: 12,
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 32),
                      Text(
                        'Alasan: ${history.alasan}',
                        style: TextStyle(color: textSecondary),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
