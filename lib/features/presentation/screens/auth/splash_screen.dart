import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../style/color.dart';
import 'login_screen.dart';
import '../main/dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _progressController;
  
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    
    // Logo Animation Controller
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.easeOutBack,
      ),
    );

    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    // Text Animation Controller
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeOutCubic,
      ),
    );

    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeIn,
      ),
    );

    // Progress Animation Controller
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeInOut,
      ),
    );

    // Start animations sequentially
    _startAnimations();
    _navigateToNextScreen();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _logoController.forward();
    
    await Future.delayed(const Duration(milliseconds: 400));
    _textController.forward();
    
    await Future.delayed(const Duration(milliseconds: 300));
    _progressController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  Future<void> _navigateToNextScreen() async {
    try {
      print('🔵 Starting navigation from splash screen...');
      await Future.delayed(const Duration(milliseconds: 3000));
      
      if (!mounted) {
        print('⚠️ Widget not mounted, aborting navigation');
        return;
      }
      
      final authProvider = context.read<AuthProvider>();
      print('🔵 AuthProvider found: ${authProvider != null}');
      
      int attempts = 0;
      while (!authProvider.isInitialized && attempts < 50) {
        await Future.delayed(const Duration(milliseconds: 100));
        attempts++;
        print('⏳ Waiting for auth initialization... attempt $attempts');
      }
      
      if (!mounted) {
        print('⚠️ Widget not mounted after waiting, aborting');
        return;
      }
      
      final isAuthenticated = authProvider.isAuthenticated;
      print('✅ Auth initialized. Authenticated: $isAuthenticated');
      print('🔵 Navigating to ${isAuthenticated ? "Dashboard" : "Login"}...');
      
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) {
            return isAuthenticated ? const DashboardScreen() : const LoginScreen();
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
      
      print('✅ Navigation completed successfully');
    } catch (e, stackTrace) {
      print('❌ Error in splash navigation: $e');
      print('Stack trace: $stackTrace');
      
      // Fallback to login screen on error
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                
                // Logo and Text Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Animated Logo
                    FadeTransition(
                      opacity: _logoFadeAnimation,
                      child: ScaleTransition(
                        scale: _logoScaleAnimation,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [colorMaroon, colorMaroonDark],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: colorMaroon.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.science_rounded,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 20),
                    
                    // Animated Text
                    Flexible(
                      child: SlideTransition(
                        position: _textSlideAnimation,
                        child: FadeTransition(
                          opacity: _textFadeAnimation,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'SIMPEL',
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: colorMaroonDark,
                                  letterSpacing: 1,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Sistem Peminjaman Alat Lab',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'POLINEMA',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[500],
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 60),
                
                // Animated Progress Bar
                AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return Column(
                      children: [
                        Container(
                          width: 200,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: _progressAnimation.value,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [colorMaroon, colorMaroonDark],
                                ),
                                borderRadius: BorderRadius.circular(2),
                                boxShadow: [
                                  BoxShadow(
                                    color: colorMaroon.withOpacity(0.3),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Memuat aplikasi...',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                
                const Spacer(flex: 2),
                
                // Version Info
                FadeTransition(
                  opacity: _textFadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[400],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
