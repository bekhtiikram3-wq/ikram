import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:animate_do/animate_do.dart';
import '../../app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
      if (!mounted) return;
      final user = await Supabase.instance.client
          .from('utilisateurs')
          .select('role')
          .eq('id', response.user!.id)
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
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Email ou mot de passe incorrect'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FadeInDown(
                      duration: const Duration(milliseconds: 800),
                      child: Container(
                        width: 100, height: 100,
                        decoration: BoxDecoration(
                          gradient: AppColors.buttonGradient,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: AppColors.glowShadow(0.5),
                        ),
                        child: const Icon(Icons.store_rounded, color: AppColors.kLight, size: 52),
                      ),
                    ),
                    const SizedBox(height: 32),

                    FadeInDown(
                      duration: const Duration(milliseconds: 800),
                      delay: const Duration(milliseconds: 200),
                      child: const Text(
                        'Connexion',
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.kLight, letterSpacing: -1),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FadeInDown(
                      duration: const Duration(milliseconds: 800),
                      delay: const Duration(milliseconds: 400),
                      child: const Text(
                        'Connectez-vous à votre compte',
                        style: TextStyle(fontSize: 14, color: AppColors.kBlueViolet, fontWeight: FontWeight.w400),
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Email - PILL SHAPE
                    FadeInUp(
                      duration: const Duration(milliseconds: 800),
                      delay: const Duration(milliseconds: 600),
                      from: 30,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 20, bottom: 8),
                            child: Text('Email', style: TextStyle(color: AppColors.kLight, fontSize: 13, fontWeight: FontWeight.w500)),
                          ),
                          Container(
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(50), // PILL!
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
                            ),
                            child: TextFormField(
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) => v == null || !v.contains('@') ? 'Email invalide' : null,
                              style: const TextStyle(color: Colors.black87, fontSize: 15),
                              decoration: InputDecoration(
                                hintText: 'exemple@email.com',
                                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                                prefixIcon: const Padding(
                                  padding: EdgeInsets.only(left: 20, right: 12),
                                  child: Icon(Icons.email_outlined, color: AppColors.kBlueViolet, size: 22),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Password - PILL SHAPE
                    FadeInUp(
                      duration: const Duration(milliseconds: 800),
                      delay: const Duration(milliseconds: 800),
                      from: 30,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 20, bottom: 8),
                            child: Text('Mot de passe', style: TextStyle(color: AppColors.kLight, fontSize: 13, fontWeight: FontWeight.w500)),
                          ),
                          Container(
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(50), // PILL!
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
                            ),
                            child: TextFormField(
                              controller: _passwordCtrl,
                              obscureText: _obscurePassword,
                              validator: (v) => v == null || v.length < 6 ? 'Min 6 caractères' : null,
                              style: const TextStyle(color: Colors.black87, fontSize: 15),
                              decoration: InputDecoration(
                                hintText: '••••••••',
                                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 18, letterSpacing: 2),
                                prefixIcon: const Padding(
                                  padding: EdgeInsets.only(left: 20, right: 12),
                                  child: Icon(Icons.lock_outline_rounded, color: AppColors.kBlueViolet, size: 22),
                                ),
                                suffixIcon: Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: IconButton(
                                    icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey.shade400, size: 22),
                                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                  ),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    FadeIn(
                      delay: const Duration(milliseconds: 1000),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Fonctionnalité bientôt disponible'),
                                backgroundColor: AppColors.kPrimary,
                                behavior: SnackBarBehavior.floating,
                                margin: const EdgeInsets.all(16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            );
                          },
                          child: const Text('Mot de passe oublié ?', style: TextStyle(color: AppColors.kBlueViolet, fontSize: 13)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Bouton - PILL
                    FadeInUp(
                      duration: const Duration(milliseconds: 800),
                      delay: const Duration(milliseconds: 1000),
                      from: 30,
                      child: GestureDetector(
                        onTap: _loading ? null : _login,
                        child: AnimatedScale(
                          scale: _loading ? 0.95 : 1.0,
                          duration: const Duration(milliseconds: 150),
                          child: Container(
                            width: double.infinity, height: 56,
                            decoration: BoxDecoration(
                              gradient: AppColors.buttonGradient,
                              borderRadius: BorderRadius.circular(50), // PILL!
                              boxShadow: AppColors.glowShadow(0.4),
                            ),
                            child: Center(
                              child: _loading
                                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: AppColors.kLight, strokeWidth: 2.5))
                                  : const Text('Se connecter', style: TextStyle(color: AppColors.kLight, fontWeight: FontWeight.w700, fontSize: 16)),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    FadeIn(
                      delay: const Duration(milliseconds: 1200),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Pas encore de compte ? ', style: TextStyle(color: AppColors.kBlueViolet, fontSize: 14)),
                          GestureDetector(
                            onTap: () => context.go('/register'),
                            child: const Text('S\'inscrire', style: TextStyle(color: AppColors.kLight, fontWeight: FontWeight.w700, fontSize: 14)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}