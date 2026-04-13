import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nomCtrl      = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _passCtrl     = TextEditingController();
  final _boutiqueCtrl = TextEditingController();
  final _formKey      = GlobalKey<FormState>();
  bool _loading       = false;
  bool _showPass      = false;
  String _role        = 'client';

  static const kPrimary = Color(0xFF2563EB);
  static const kAccent  = Color(0xFF7C3AED);

  @override
  void dispose() { _nomCtrl.dispose(); _emailCtrl.dispose(); _passCtrl.dispose(); _boutiqueCtrl.dispose(); super.dispose(); }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await Supabase.instance.client.auth.signUp(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
        data: {'nom': _nomCtrl.text.trim(), 'role': _role, if (_role == 'vendeur') 'nom_boutique': _boutiqueCtrl.text.trim()},
      );
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Compte créé avec succès !'),
        backgroundColor: Colors.green.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      context.go(_role == 'vendeur' ? '/vendeur' : '/home');
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message), backgroundColor: Colors.red.shade400, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: () => context.go('/login'),
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: const Color(0xFFF8FAFC), border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Color(0xFF0F172A)),
                  ),
                ),
                const SizedBox(height: 28),
                const Text('Créer un compte', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), letterSpacing: -0.5)),
                const SizedBox(height: 6),
                Text('Rejoignez DigitalStore DZ', style: TextStyle(fontSize: 15, color: Colors.grey.shade500)),
                const SizedBox(height: 32),

                // Choix rôle
                const Text('Je souhaite', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
                const SizedBox(height: 10),
                Row(children: [
                  _roleCard('client', 'Acheter', Icons.shopping_bag_outlined, kPrimary),
                  const SizedBox(width: 12),
                  _roleCard('vendeur', 'Vendre', Icons.storefront_outlined, kAccent),
                ]),
                const SizedBox(height: 24),

                _label('Nom complet'),
                const SizedBox(height: 8),
                _input(_nomCtrl, 'Votre nom', Icons.person_outline_rounded, validator: (v) => v!.isEmpty ? 'Requis' : null),
                const SizedBox(height: 16),

                _label('Adresse email'),
                const SizedBox(height: 8),
                _input(_emailCtrl, 'exemple@email.com', Icons.email_outlined, keyboard: TextInputType.emailAddress, validator: (v) => v!.isEmpty ? 'Requis' : !v.contains('@') ? 'Email invalide' : null),
                const SizedBox(height: 16),

                _label('Mot de passe'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: !_showPass,
                  validator: (v) => v!.isEmpty ? 'Requis' : v.length < 6 ? 'Min. 6 caractères' : null,
                  style: const TextStyle(fontSize: 15, color: Color(0xFF0F172A)),
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    prefixIcon: Icon(Icons.lock_outline_rounded, color: Colors.grey.shade400, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(_showPass ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey.shade400, size: 20),
                      onPressed: () => setState(() => _showPass = !_showPass),
                    ),
                    filled: true, fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: kPrimary, width: 1.5)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),

                if (_role == 'vendeur') ...[
                  const SizedBox(height: 16),
                  _label('Nom de la boutique'),
                  const SizedBox(height: 8),
                  _input(_boutiqueCtrl, 'Ma Boutique Digitale', Icons.storefront_outlined, validator: (v) => _role == 'vendeur' && v!.isEmpty ? 'Requis' : null),
                ],
                const SizedBox(height: 32),

                GestureDetector(
                  onTap: _loading ? null : _register,
                  child: Container(
                    width: double.infinity, height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [kPrimary, kAccent]),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: kPrimary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
                    ),
                    child: Center(child: _loading
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Créer mon compte', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16))),
                  ),
                ),
                const SizedBox(height: 24),
                Center(child: GestureDetector(
                  onTap: () => context.go('/login'),
                  child: RichText(text: TextSpan(
                    text: 'Déjà un compte ? ',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                    children: const [TextSpan(text: 'Se connecter', style: TextStyle(color: kPrimary, fontWeight: FontWeight.w700))],
                  )),
                )),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String t) => Text(t, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151)));

  Widget _input(TextEditingController ctrl, String hint, IconData icon, {TextInputType? keyboard, String? Function(String?)? validator}) =>
    TextFormField(
      controller: ctrl, keyboardType: keyboard, validator: validator,
      style: const TextStyle(fontSize: 15, color: Color(0xFF0F172A)),
      decoration: InputDecoration(
        hintText: hint, hintStyle: TextStyle(color: Colors.grey.shade400),
        prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 20),
        filled: true, fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: kPrimary, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );

  Widget _roleCard(String key, String label, IconData icon, Color color) => Expanded(
    child: GestureDetector(
      onTap: () => setState(() => _role = key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: _role == key ? color.withOpacity(0.08) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _role == key ? color : Colors.grey.shade200, width: _role == key ? 1.5 : 1),
        ),
        child: Column(children: [
          Icon(icon, color: _role == key ? color : Colors.grey.shade400, size: 28),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _role == key ? color : Colors.grey.shade500)),
        ]),
      ),
    ),
  );
}
