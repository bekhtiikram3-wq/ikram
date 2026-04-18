import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:animate_do/animate_do.dart';
import '../../app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoCtrl;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    _logoCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _logoScale   = CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut).drive(Tween(begin: 0.0, end: 1.0));
    _logoOpacity = CurvedAnimation(parent: _logoCtrl, curve: Curves.easeIn).drive(Tween(begin: 0.0, end: 1.0));
    _logoCtrl.forward();
    Future.delayed(const Duration(milliseconds: 2800), _redirect);
  }

  @override
  void dispose() { _logoCtrl.dispose(); super.dispose(); }

  Future<void> _redirect() async {
    if (!mounted) return;
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) { context.go('/onboarding'); return; }
    final user = await Supabase.instance.client
        .from('utilisateurs')
        .select('role')
        .eq('id', session.user.id)
        .single();
    if (!mounted) return;
    final role = user['role'];
    if (role == 'administrateur') {
      context.go('/admin');
    } else if (role == 'vendeur') {
      context.go('/vendeur');
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo animé avec scale élastique
              ScaleTransition(
                scale: _logoScale,
                child: FadeTransition(
                  opacity: _logoOpacity,
                  child: Container(
                    width: 120, height: 120,
                    decoration: BoxDecoration(
                      gradient: AppColors.buttonGradient,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(color: AppColors.kPrimary.withOpacity(0.5), blurRadius: 40, offset: const Offset(0, 16)),
                        BoxShadow(color: AppColors.kBlueViolet.withOpacity(0.3), blurRadius: 60, offset: const Offset(0, 24)),
                      ],
                    ),
                    child: const Icon(Icons.store_rounded, color: AppColors.kLight, size: 62),
                  ),
                ),
              ),
              const SizedBox(height: 36),

              // Titre avec fade + slide
              FadeInUp(
                duration: const Duration(milliseconds: 900),
                delay: const Duration(milliseconds: 600),
                child: ShaderMask(
                  shaderCallback: (b) => const LinearGradient(colors: [AppColors.kLight, AppColors.kBlueViolet]).createShader(b),
                  child: const Text(
                    'DigitalStore',
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -1),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              FadeInUp(
                duration: const Duration(milliseconds: 900),
                delay: const Duration(milliseconds: 900),
                child: const Text(
                  'Produits digitaux en Algérie',
                  style: TextStyle(fontSize: 14, color: AppColors.kBlueViolet, fontWeight: FontWeight.w400, letterSpacing: 0.5),
                ),
              ),

              const SizedBox(height: 80),

              // Loading spinner
              FadeIn(
                delay: const Duration(milliseconds: 1400),
                child: SizedBox(
                  width: 32, height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation(AppColors.kLight.withOpacity(0.6)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}