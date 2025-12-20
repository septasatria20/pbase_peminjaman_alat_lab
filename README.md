# SIMPEL - Sistem Peminjaman Alat Lab

<div align="center">
  <img src="assets/images/logo.png" alt="SIMPEL Logo" width="200"/>
  
  [![Flutter](https://img.shields.io/badge/Flutter-3.9.0-02569B?style=flat&logo=flutter)](https://flutter.dev)
  [![Firebase](https://img.shields.io/badge/Firebase-Enabled-FFCA28?style=flat&logo=firebase)](https://firebase.google.com)
  [![Dart](https://img.shields.io/badge/Dart-3.9.0-0175C2?style=flat&logo=dart)](https://dart.dev)
  
  **Aplikasi mobile untuk mempermudah pengelolaan peminjaman alat laboratorium**
</div>

---

## 📖 Tentang SIMPEL

**SIMPEL (Sistem Peminjaman Alat Lab)** adalah aplikasi mobile berbasis Flutter yang dirancang untuk memudahkan mahasiswa dan pengelola laboratorium dalam mengelola peminjaman alat-alat praktikum. Aplikasi ini menyediakan sistem yang terintegrasi untuk melakukan peminjaman, pengembalian, dan monitoring status alat laboratorium secara real-time.

###  Fitur Utama

#### Untuk Mahasiswa/Peminjam:
-  **Dashboard Interaktif** - Tampilan ringkasan alat yang tersedia dan status peminjaman
-  **Browse Alat Lab** - Melihat katalog lengkap alat laboratorium dengan detail informasi
-  **Peminjaman Online** - Mengajukan peminjaman alat dengan jadwal yang fleksibel
-  **Kalender Peminjaman** - Melihat jadwal peminjaman alat dengan calendar view
-  **Riwayat Peminjaman** - Tracking semua riwayat peminjaman yang pernah dilakukan
-  **Chat Support** - Berkomunikasi dengan admin untuk pertanyaan atau bantuan
-  **Manajemen Profil** - Edit dan kelola informasi profil pribadi

#### Untuk Admin:
-  **Dashboard Admin** - Kelola semua aspek sistem peminjaman
-  **Manajemen Alat** - Tambah, edit, dan hapus data alat laboratorium
-  **Approval Peminjaman** - Setujui atau tolak pengajuan peminjaman
-  **Monitoring** - Pantau status peminjaman dan ketersediaan alat
-  **Chat Management** - Merespon pertanyaan dari pengguna

### Arsitektur Aplikasi

Aplikasi ini dibangun dengan mengikuti **Clean Architecture** dan prinsip **SOLID**:

```
lib/
├── core/                    # Core utilities dan konstanta
├── Dependency_Injection/    # Dependency injection setup
├── features/
│   ├── data/               # Data layer (repositories, data sources)
│   ├── domain/             # Domain layer (entities, use cases)
│   └── presentation/       # Presentation layer (UI, providers)
│       ├── providers/      # State management dengan Provider
│       ├── screens/        # Halaman-halaman aplikasi
│       ├── widgets/        # Reusable widgets
│       └── style/          # Styling dan tema
└── main.dart               # Entry point aplikasi
```

###  Teknologi yang Digunakan

- **Flutter 3.9.0** - Framework UI untuk pengembangan cross-platform
- **Firebase Authentication** - Sistem autentikasi pengguna
- **Cloud Firestore** - Database NoSQL real-time
- **Provider** - State management
- **GetIt** - Dependency injection
- **GoRouter** - Navigasi dan routing
- **Google Fonts** - Custom typography
- **Table Calendar** - Tampilan kalender peminjaman
- **HTTP** - Integrasi API (AI Helper)

---

##  Instalasi dan Setup

### Prasyarat

Sebelum memulai, pastikan Anda telah menginstal:

1. **Flutter SDK** (versi 3.9.0 atau lebih tinggi)
   - Download dari: https://flutter.dev/docs/get-started/install
   - Verifikasi instalasi dengan menjalankan: `flutter doctor`

2. **Android Studio** atau **VS Code** dengan ekstensi Flutter/Dart

3. **Git** untuk clone repository

4. **Firebase Account** untuk konfigurasi backend

### Langkah-langkah Instalasi

#### 1️ Clone Repository

```bash
git clone https://github.com/username/pbase_peminjaman_alat_lab.git
cd pbase_peminjaman_alat_lab
```

#### 2️ Install Dependencies

```bash
flutter pub get
```

#### 3️ Konfigurasi Firebase

**a. Buat Proyek Firebase**
- Kunjungi [Firebase Console](https://console.firebase.google.com/)
- Buat proyek baru atau gunakan proyek yang sudah ada
- Aktifkan **Authentication** (Email/Password)
- Aktifkan **Cloud Firestore**

**b. Konfigurasi untuk Android**
- Download file `google-services.json` dari Firebase Console
- Letakkan di folder `android/app/`

**c. Konfigurasi untuk iOS** (opsional)
- Download file `GoogleService-Info.plist`
- Tambahkan ke proyek iOS Anda

**d. Generate Firebase Options**
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Konfigurasi Firebase untuk proyek
flutterfire configure
```

File `firebase_options.dart` akan otomatis dibuat di folder `lib/`

#### 4️ Setup Firestore Database

Buat koleksi berikut di Firestore Console:

**Collection: `users`**
```javascript
{
  "uid": "string",
  "email": "string",
  "name": "string",
  "nim": "string",
  "prodi": "string",
  "phoneNumber": "string",
  "role": "user" // atau "admin"
}
```

**Collection: `alat`**
```javascript
{
  "id": "string",
  "nama": "string",
  "kategori": "string",
  "deskripsi": "string",
  "jumlahTotal": number,
  "jumlahTersedia": number,
  "gambarUrl": "string" // opsional
}
```

**Collection: `peminjaman`**
```javascript
{
  "id": "string",
  "userId": "string",
  "userName": "string",
  "alatId": "string",
  "alatNama": "string",
  "jumlah": number,
  "tanggalPinjam": timestamp,
  "tanggalKembali": timestamp,
  "status": "pending" // pending, approved, rejected, returned
}
```

**Collection: `chats`**
```javascript
{
  "userId": "string",
  "messages": [
    {
      "text": "string",
      "sender": "user" // atau "admin",
      "timestamp": timestamp
    }
  ]
}
```

#### 5️ Konfigurasi Firestore Rules

Tambahkan rules berikut di Firebase Console:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
    
    // Alat collection
    match /alat/{alatId} {
      allow read: if request.auth != null;
      allow write: if get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Peminjaman collection
    match /peminjaman/{peminjamanId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Chats collection
    match /chats/{chatId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

#### 6️ Setup AI Helper (Opsional)

Jika Anda ingin menggunakan fitur AI Helper:

1. Dapatkan API key dari provider AI (contoh: Google Gemini API)
2. Konfigurasi di file `lib/core/constants.dart` atau gunakan environment variables

#### 7️ Jalankan Aplikasi

```bash
# Untuk Android
flutter run

# Atau pilih device spesifik
flutter devices
flutter run -d <device_id>

# Build APK untuk production
flutter build apk --release
```

---

##  Cara Menggunakan SIMPEL

### Untuk Mahasiswa/Peminjam

#### 1. **Registrasi & Login**
   - Buka aplikasi dan pilih "Daftar" jika belum memiliki akun
   - Isi data: Email, Password, Nama, NIM, Prodi, dan No. HP
   - Login menggunakan email dan password yang telah didaftarkan

#### 2. **Browsing Alat Lab**
   - Pada halaman Dashboard, lihat alat-alat yang tersedia
   - Gunakan fitur pencarian untuk menemukan alat tertentu
   - Filter berdasarkan kategori untuk mempermudah pencarian
   - Klik pada alat untuk melihat detail lengkap

#### 3. **Mengajukan Peminjaman**
   - Pilih alat yang ingin dipinjam
   - Klik tombol "Pinjam"
   - Pilih tanggal peminjaman dan pengembalian menggunakan kalender
   - Tentukan jumlah alat yang ingin dipinjam
   - Klik "Ajukan Peminjaman"
   - Tunggu approval dari admin

#### 4. **Melihat Status Peminjaman**
   - Buka tab "Peminjaman" untuk melihat peminjaman aktif
   - Status peminjaman:
     -  **Pending**: Menunggu approval admin
     -  **Approved**: Disetujui, bisa diambil di lab
     -  **Rejected**: Ditolak oleh admin
     -  **Returned**: Sudah dikembalikan

#### 5. **Menggunakan Fitur Kalender**
   - Buka halaman Peminjaman
   - Lihat kalender untuk mengecek ketersediaan alat
   - Tanggal berwarna menunjukkan ada peminjaman

#### 6. **Melihat Riwayat**
   - Buka tab "Riwayat" untuk melihat semua peminjaman Anda
   - Filter berdasarkan status atau tanggal
   - Klik item untuk melihat detail peminjaman

#### 7. **Menggunakan Chat Support**
   - Klik ikon chat di halaman utama
   - Kirim pesan untuk bertanya kepada admin
   - Tunggu balasan dari admin

#### 8. **Menggunakan AI Helper**
   - Buka fitur AI Helper dari menu
   - Tanyakan informasi tentang alat lab
   - AI akan membantu menjawab pertanyaan Anda

#### 9. **Mengelola Profil**
   - Buka halaman Profil
   - Klik "Edit Profil" untuk mengubah data
   - Update informasi seperti nama, NIM, prodi, atau no. HP
   - Simpan perubahan

### Untuk Admin

#### 1. **Login sebagai Admin**
   - Login menggunakan akun admin
   - Anda akan diarahkan ke Dashboard Admin

#### 2. **Mengelola Alat Lab**
   - **Menambah Alat Baru**:
     - Klik tombol "+" atau "Tambah Alat"
     - Isi informasi: nama, kategori, deskripsi, jumlah total
     - Upload gambar alat (opsional)
     - Simpan
   
   - **Mengedit Alat**:
     - Klik alat yang ingin diedit
     - Update informasi yang diperlukan
     - Simpan perubahan
   
   - **Menghapus Alat**:
     - Klik tombol hapus pada alat
     - Konfirmasi penghapusan

#### 3. **Approval Peminjaman**
   - Lihat daftar peminjaman dengan status "Pending"
   - Review detail peminjaman
   - Pilih "Setujui" atau "Tolak"
   - Tambahkan catatan jika perlu

#### 4. **Monitoring Peminjaman**
   - Pantau semua peminjaman aktif
   - Update status peminjaman menjadi "Returned" saat alat dikembalikan
   - Lihat statistik peminjaman

#### 5. **Merespons Chat**
   - Buka dashboard chat
   - Lihat pesan dari pengguna
   - Balas pertanyaan atau permintaan bantuan

---

##  Troubleshooting

### Masalah Umum

**1. Error saat `flutter pub get`**
```bash
# Bersihkan cache dan coba lagi
flutter clean
flutter pub get
```

**2. Firebase tidak terhubung**
- Pastikan file `google-services.json` ada di `android/app/`
- Jalankan ulang `flutterfire configure`
- Cek konfigurasi di Firebase Console

**3. Aplikasi crash saat login**
- Pastikan Firebase Authentication sudah diaktifkan
- Cek Firestore rules sudah benar
- Periksa logs dengan `flutter logs`

**4. Gambar alat tidak muncul**
- Pastikan URL gambar valid
- Cek koneksi internet
- Verifikasi Storage rules di Firebase (jika menggunakan Firebase Storage)

**5. Build error di Android**
- Update Gradle: buka `android/gradle/wrapper/gradle-wrapper.properties`
- Clean project: `flutter clean`
- Rebuild: `flutter build apk`

---

##  Catatan Pengembangan

### Struktur Database Firestore

Aplikasi ini menggunakan Firestore dengan struktur berikut:
- **users**: Data pengguna dan role
- **alat**: Katalog alat laboratorium
- **peminjaman**: Transaksi peminjaman
- **chats**: Pesan chat antara user dan admin

### State Management

Aplikasi menggunakan **Provider** untuk state management dengan beberapa provider:
- `AuthProvider`: Mengelola autentikasi
- `UserProvider`: Mengelola data pengguna
- `AlatProvider`: Mengelola data alat
- `HistoryProvider`: Mengelola riwayat peminjaman
- `ChatProvider`: Mengelola chat

### Dependency Injection

Menggunakan **GetIt** untuk dependency injection, dikonfigurasi di `Dependency_Injection/Injection_Container.dart`

---

##  Kontribusi

Kontribusi selalu diterima! Jika Anda ingin berkontribusi:

1. Fork repository ini
2. Buat branch fitur baru (`git checkout -b feature/AmazingFeature`)
3. Commit perubahan (`git commit -m 'Add some AmazingFeature'`)
4. Push ke branch (`git push origin feature/AmazingFeature`)
5. Buat Pull Request

---

##  Lisensi

Project ini dibuat untuk keperluan pembelajaran dan pengembangan sistem informasi laboratorium di Politeknik Negeri Malang

---

##  Tim Pengembang

Dikembangkan oleh Tim Mobile Semester 5 SIB-3D 2025

---

##  Kontak & Dukungan

Jika Anda memiliki pertanyaan atau memerlukan bantuan:
-  Email: [septasatria.str@gmail.com]

---

##  Roadmap & Fitur Mendatang

- [ ] Notifikasi push untuk status peminjaman
- [ ] Export laporan peminjaman ke PDF
- [ ] Integrasi dengan sistem barcode/QR code
- [ ] Multi-language support
- [ ] Dark mode
- [ ] Sistem rating dan review alat
- [ ] Dashboard analytics untuk admin

---

<div align="center">
  
  **Terima kasih telah menggunakan SIMPEL!** 
  
  Jika aplikasi ini bermanfaat, berikan ⭐ pada repository ini!
  
</div>
