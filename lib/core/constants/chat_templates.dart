class ChatTemplates {
  static String getApprovalMessage(String labName) {
    return '''
✅ *PEMINJAMAN DISETUJUI*

Selamat! Peminjaman Anda untuk Laboratorium $labName telah disetujui oleh admin.

📋 *SYARAT DAN KETENTUAN PEMINJAMAN:*

1️⃣ *Waktu Pengambilan*
   • Silakan mengambil alat sesuai jam operasional laboratorium
   • Senin - Jumat: 08.00 - 16.00 WIB
   • Sabtu: 08.00 - 12.00 WIB
   • Minggu & Hari Libur: TUTUP

2️⃣ *Lokasi Pengambilan*
   • Ambil alat di Laboratorium $labName
   • Tunjukkan bukti persetujuan ini kepada petugas lab
   • Pastikan memeriksa kondisi alat sebelum dibawa

3️⃣ *Keterlambatan Pengembalian*
   • Denda Rp 10.000/hari untuk setiap alat yang terlambat dikembalikan
   • Perhitungan dimulai H+1 dari tanggal jatuh tempo
   • Keterlambatan > 7 hari akan dilaporkan ke bagian akademik

4️⃣ *Pengembalian Alat*
   • Kembalikan alat sesuai tanggal yang telah ditentukan
   • Alat harus dalam kondisi baik dan lengkap
   • Pengembalian di lokasi yang sama (Lab $labName)
   • Jika ada kerusakan/kehilangan, segera laporkan ke admin

5️⃣ *Tanggung Jawab Peminjam*
   • Anda bertanggung jawab penuh atas alat yang dipinjam
   • Dilarang meminjamkan kepada pihak lain
   • Gunakan alat sesuai fungsi dan prosedur yang benar
   • Kerusakan akibat kelalaian menjadi tanggung jawab peminjam

6️⃣ *Sanksi*
   • Keterlambatan berulang dapat menghambat peminjaman berikutnya
   • Kerusakan/kehilangan dikenakan biaya penggantian sesuai harga alat
   • Pelanggaran berat dapat dilaporkan ke pihak jurusan/institusi

⚠️ *PENTING:*
Dengan menyetujui peminjaman ini, Anda telah memahami dan menyetujui seluruh syarat dan ketentuan di atas.

Jika ada pertanyaan, silakan hubungi admin melalui chat ini.

Terima kasih dan gunakan alat dengan bijak! 🙏
''';
  }

  static String getRejectionMessage(String reason) {
    return '''
❌ *PEMINJAMAN DITOLAK*

Mohon maaf, peminjaman Anda tidak dapat disetujui.

*Alasan Penolakan:*
$reason

Silakan hubungi admin melalui chat ini untuk informasi lebih lanjut atau mengajukan peminjaman ulang dengan penyesuaian.

Terima kasih atas pengertiannya.
''';
  }

  static String getReturnValidationMessage(bool isApproved, String? notes) {
    if (isApproved) {
      return '''
✅ *PENGEMBALIAN DITERIMA*

Terima kasih! Alat yang Anda pinjam telah dikembalikan dan diterima dengan baik oleh admin.

${notes != null && notes.isNotEmpty ? '*Catatan Admin:*\n$notes\n\n' : ''}Status peminjaman Anda telah diperbarui menjadi "Dikembalikan".

Terima kasih atas kepercayaan dan kerjasama Anda dalam menjaga alat laboratorium. 🙏
''';
    } else {
      return '''
⚠️ *PENGEMBALIAN DITOLAK*

Mohon maaf, pengembalian alat Anda ditolak oleh admin.

*Alasan Penolakan:*
${notes ?? 'Tidak ada catatan'}

Silakan hubungi admin untuk koordinasi lebih lanjut mengenai pengembalian alat.
''';
    }
  }
}
