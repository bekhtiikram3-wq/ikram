import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoCtrl;
  late AnimationController _textCtrl;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _textOpacity;

  static const kPrimary = Color(0xFF2563EB);
  static const kAccent  = Color(0xFF7C3AED);

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.dark));
    _logoCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _textCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _logoScale   = CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut).drive(Tween(begin: 0.0, end: 1.0));
    _logoOpacity = CurvedAnimation(parent: _logoCtrl, curve: Curves.easeIn).drive(Tween(begin: 0.0, end: 1.0));
    _textSlide   = CurvedAnimation(parent: _textCtrl, curve: Curves.easeOutCubic).drive(Tween(begin: const Offset(0, 0.5), end: Offset.zero));
    _textOpacity = CurvedAnimation(parent: _textCtrl, curve: Curves.easeIn).drive(Tween(begin: 0.0, end: 1.0));
    _logoCtrl.forward().then((_) => _textCtrl.forward());
    Future.delayed(const Duration(milliseconds: 2800), _redirect);
  }

  @override
  void dispose() { _logoCtrl.dispose(); _textCtrl.dispose(); super.dispose(); }

  Future<void> _redirect() async {
    if (!mounted) return;
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) { context.go('/onboarding'); return; }
    final user = await Supabase.instance.client.from('utilisateurs').select('role').eq('id', session.user.id).single();
    if (!mounted) return;
    context.go(user['role'] == 'vendeur' ? '/vendeur' : '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _logoScale,
              child: FadeTransition(
                opacity: _logoOpacity,
                child: Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [kPrimary, kAccent], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [BoxShadow(color: kPrimary.withOpacity(0.3), blurRadius: 30, offset: const Offset(0, 12))],
                  ),
                  child: const Icon(Icons.store_rounded, color: Colors.white, size: 52),
                ),
              ),
            ),
            const SizedBox(height: 28),
            SlideTransition(
              position: _textSlide,
              child: FadeTransition(
                opacity: _textOpacity,
                child: Column(children: [
                  ShaderMask(
                    shaderCallback: (b) => const LinearGradient(colors: [kPrimary, kAccent]).createShader(b),
                    child: const Text('DigitalStore', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -1)),
                  ),
                  const SizedBox(height: 6),
                  Text('Produits digitaux en Algérie', style: TextStyle(fontSize: 14, color: Colors.grey.shade500, fontWeight: FontWeight.w400)),
                ]),
              ),
            ),
            const SizedBox(height: 80),
            FadeTransition(
              opacity: _textOpacity,
              child: SizedBox(
                width: 28, height: 28,
                child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation(kPrimary.withOpacity(0.4))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}