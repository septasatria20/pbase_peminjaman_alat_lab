import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pbase_peminjaman_alat_lab/features/presentation/providers/history_provider.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pbase_peminjaman_alat_lab/features/presentation/style/color.dart';
import 'package:pbase_peminjaman_alat_lab/features/presentation/screens/auth/splash_screen.dart';
import 'package:provider/provider.dart';
import 'Dependency_Injection/Injection_Container.dart' as di;
import 'features/presentation/providers/auth_provider.dart';
import 'features/presentation/providers/user_provider.dart';
import 'features/presentation/providers/alat_provider.dart';
import 'features/presentation/providers/chat_provider.dart'; // Import ChatProvider

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  di.setupDependencyInjection();

  runApp(
    MultiProvider(
      providers: [
        Provider<FirebaseFirestore>(create: (_) => FirebaseFirestore.instance),
        ChangeNotifierProvider(create: (_) => di.sl<AuthProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<UserProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<AlatProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<HistoryProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<ChatProvider>()), // Register ChatProvider
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Peminjaman Lab',
      theme: ThemeData(
        primaryColor: primaryColor,
        scaffoldBackgroundColor: Colors.grey[50],
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
          secondary: primaryColor.withOpacity(0.7),
        ),
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
          titleTextStyle: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryColor, width: 2),
          ),
          labelStyle: const TextStyle(color: primaryColor),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
