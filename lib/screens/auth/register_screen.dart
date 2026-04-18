import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:animate_do/animate_do.dart';
import '../../app_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nomUtilisateurCtrl = TextEditingController();
  final _nomBoutiqueCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _obscurePassword = true;
  String _selectedRole = 'client';

  @override
  void dispose() {
    _nomUtilisateurCtrl.dispose();
    _nomBoutiqueCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final authResponse = await Supabase.instance.client.auth.signUp(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
      if (authResponse.user == null) throw Exception('Erreur inscription');

      await Supabase.instance.client.from('utilisateurs').insert({
        'id': authResponse.user!.id,
        'email': _emailCtrl.text.trim(),
        'nom': _nomUtilisateurCtrl.text.trim(),
        'role': _selectedRole,
        'statut': 'actif',
      });

      if (_selectedRole == 'client') {
        await Supabase.instance.client.from('clients').insert({
          'id': authResponse.user!.id,
          'adresse': '',
          'telephone': '',
        });
      } else if (_selectedRole == 'vendeur') {
        await Supabase.instance.client.from('vendeurs').insert({
          'id': authResponse.user!.id,
          'nom_boutique': _nomBoutiqueCtrl.text.trim(),
          'description': '',
          'solde_dzd': 0,
        });
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('✅ Compte créé avec succès !'),
          backgroundColor: Colors.green.shade400,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      context.go('/login');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur : ${e.toString()}'),
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
                    // Logo
                    FadeInDown(
                      duration: const Duration(milliseconds: 800),
                      child: Container(
                        width: 100, height: 100,
                        decoration: BoxDecoration(
                          gradient: AppColors.buttonGradient,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: AppColors.glowShadow(0.5),
                        ),
                        child: const Icon(Icons.person_add_rounded, color: AppColors.kLight, size: 52),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Titre
                    FadeInDown(
                      duration: const Duration(milliseconds: 800),
                      delay: const Duration(milliseconds: 200),
                      child: const Text(
                        'Inscription',
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.kLight, letterSpacing: -1),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FadeInDown(
                      duration: const Duration(milliseconds: 800),
                      delay: const Duration(milliseconds: 400),
                      child: const Text(
                        'Créez votre compte DigitalStore',
                        style: TextStyle(fontSize: 14, color: AppColors.kBlueViolet, fontWeight: FontWeight.w400),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Role selector (en premier)
                    FadeInUp(
                      duration: const Duration(milliseconds: 800),
                      delay: const Duration(milliseconds: 600),
                      from: 30,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 20, bottom: 12),
                            child: Text('Je suis', style: TextStyle(color: AppColors.kLight, fontSize: 13, fontWeight: FontWeight.w500)),
                          ),
                          Row(
                            children: [
                              Expanded(child: _roleCard('client', 'Client', Icons.shopping_bag_outlined)),
                              const SizedBox(width: 12),
                              Expanded(child: _roleCard('vendeur', 'Vendeur', Icons.storefront_outlined)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Nom utilisateur
                    FadeInUp(
                      duration: const Duration(milliseconds: 800),
                      delay: const Duration(milliseconds: 700),
                      from: 30,
                      child: _buildTextField(
                        controller: _nomUtilisateurCtrl,
                        label: 'Nom d\'utilisateur',
                        icon: Icons.person_outline_rounded,
                        validator: (v) => v == null || v.isEmpty ? 'Nom requis' : null,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Nom boutique (si vendeur)
                    if (_selectedRole == 'vendeur')
                      FadeInUp(
                        duration: const Duration(milliseconds: 800),
                        delay: const Duration(milliseconds: 750),
                        from: 30,
                        child: _buildTextField(
                          controller: _nomBoutiqueCtrl,
                          label: 'Nom de la boutique',
                          icon: Icons.storefront_rounded,
                          validator: (v) => v == null || v.isEmpty ? 'Nom de boutique requis' : null,
                        ),
                      ),
                    if (_selectedRole == 'vendeur') const SizedBox(height: 16),

                    // Email
                    FadeInUp(
                      duration: const Duration(milliseconds: 800),
                      delay: const Duration(milliseconds: 800),
                      from: 30,
                      child: _buildTextField(
                        controller: _emailCtrl,
                        label: 'Email',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => v == null || !v.contains('@') ? 'Email invalide' : null,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Password
                    FadeInUp(
                      duration: const Duration(milliseconds: 800),
                      delay: const Duration(milliseconds: 900),
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
                              borderRadius: BorderRadius.circular(28),
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
                    const SizedBox(height: 28),

                    // Bouton inscription
                    FadeInUp(
                      duration: const Duration(milliseconds: 800),
                      delay: const Duration(milliseconds: 1000),
                      from: 30,
                      child: GestureDetector(
                        onTap: _loading ? null : _register,
                        child: AnimatedScale(
                          scale: _loading ? 0.95 : 1.0,
                          duration: const Duration(milliseconds: 150),
                          child: Container(
                            width: double.infinity, height: 56,
                            decoration: BoxDecoration(
                              gradient: AppColors.buttonGradient,
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: AppColors.glowShadow(0.4),
                            ),
                            child: Center(
                              child: _loading
                                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: AppColors.kLight, strokeWidth: 2.5))
                                  : const Text('S\'inscrire', style: TextStyle(color: AppColors.kLight, fontWeight: FontWeight.w700, fontSize: 16)),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Login link
                    FadeIn(
                      delay: const Duration(milliseconds: 1200),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Déjà un compte ? ', style: TextStyle(color: AppColors.kBlueViolet, fontSize: 14)),
                          GestureDetector(
                            onTap: () => context.go('/login'),
                            child: const Text('Se connecter', style: TextStyle(color: AppColors.kLight, fontWeight: FontWeight.w700, fontSize: 14)),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, bottom: 8),
          child: Text(label, style: const TextStyle(color: AppColors.kLight, fontSize: 13, fontWeight: FontWeight.w500)),
        ),
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            style: const TextStyle(color: Colors.black87, fontSize: 15),
            decoration: InputDecoration(
              hintText: label,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 20, right: 12),
                child: Icon(icon, color: AppColors.kBlueViolet, size: 22),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _roleCard(String role, String label, IconData icon) {
    final isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.buttonGradient : null,
          color: isSelected ? null : AppColors.kDark.withOpacity(0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.kPrimary : AppColors.kBlueViolet.withOpacity(0.3),
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: isSelected ? AppColors.glowShadow(0.3) : [],
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? AppColors.kLight : AppColors.kBlueViolet, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.kLight : AppColors.kBlueViolet,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}