import 'package:flutter/material.dart';
import 'package:pbase_peminjaman_alat_lab/features/presentation/style/color.dart';
import 'package:pbase_peminjaman_alat_lab/features/presentation/screens/main/main_screen.dart';
import 'package:pbase_peminjaman_alat_lab/features/presentation/screens/auth/register_screen.dart';
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  void _login(BuildContext context) {
    // TODO: Tambahkan logika Firebase Auth
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const MainScreen(),
      ),
    );
  }

  void _goToRegister(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const RegisterScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colorMaroon.withAlpha(26),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.laptop_chromebook_outlined,
                  size: 64,
                  color: colorMaroon,
                ),
              ),
              const SizedBox(height: 16),
              // Judul
              const Text(
                "LabKom Pinjam",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Text(
                "Politeknik Negeri Malang",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 48),

              // Form Email
              TextFormField(
                initialValue: "mahasiswa@polinema.ac.id",
                decoration: const InputDecoration(
                  labelText: "Email",
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // Form Password
              TextFormField(
                initialValue: "123456",
                decoration: const InputDecoration(
                  labelText: "Password",
                  prefixIcon: Icon(Icons.lock_outline),
                  suffixIcon: Icon(Icons.visibility_off_outlined),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 32),

              // Tombol Login
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _login(context),
                  child: const Text('Login'),
                ),
              ),
              const SizedBox(height: 16),

              // Tombol Daftar
              TextButton(
                onPressed: () => _goToRegister(context),
                child: const Text("Belum punya akun? Daftar di sini"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

