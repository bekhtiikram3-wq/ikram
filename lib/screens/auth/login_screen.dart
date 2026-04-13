import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl    = TextEditingController();
  final _passCtrl     = TextEditingController();
  final _formKey      = GlobalKey<FormState>();
  bool _loading       = false;
  bool _showPass      = false;

  static const kPrimary = Color(0xFF2563EB);
  static const kAccent  = Color(0xFF7C3AED);

  @override
  void dispose() { _emailCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final res = await Supabase.instance.client.auth.signInWithPassword(email: _emailCtrl.text.trim(), password: _passCtrl.text);
      if (!mounted) return;
      final user = await Supabase.instance.client.from('utilisateurs').select('role').eq('id', res.user!.id).single();
      if (!mounted) return;
      context.go(user['role'] == 'vendeur' ? '/vendeur' : '/home');
    } on AuthException catch (e) {
      if (!mounted) return;
      _showError(e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.red.shade400,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
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
                const SizedBox(height: 48),
                // Logo
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [kPrimary, kAccent]),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.store_rounded, color: Colors.white, size: 28),
                ),
                const SizedBox(height: 32),
                const Text('Bon retour !', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), letterSpacing: -0.5)),
                const SizedBox(height: 6),
                Text('Connectez-vous à votre compte', style: TextStyle(fontSize: 15, color: Colors.grey.shade500)),
                const SizedBox(height: 40),

                // Email
                _label('Adresse email'),
                const SizedBox(height: 8),
                _input(
                  controller: _emailCtrl,
                  hint: 'exemple@email.com',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v!.isEmpty ? 'Email requis' : !v.contains('@') ? 'Email invalide' : null,
                ),
                const SizedBox(height: 20),

                // Password
                _label('Mot de passe'),
                const SizedBox(height: 8),
                _input(
                  controller: _passCtrl,
                  hint: '••••••••',
                  icon: Icons.lock_outline_rounded,
                  obscure: !_showPass,
                  suffix: IconButton(
                    icon: Icon(_showPass ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey.shade400, size: 20),
                    onPressed: () => setState(() => _showPass = !_showPass),
                  ),
                  validator: (v) => v!.isEmpty ? 'Mot de passe requis' : v.length < 6 ? 'Minimum 6 caractères' : null,
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text('Mot de passe oublié ?', style: TextStyle(color: kPrimary, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 32),

                // Bouton
                GestureDetector(
                  onTap: _loading ? null : _login,
                  child: Container(
                    width: double.infinity, height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [kPrimary, kAccent]),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: kPrimary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
                    ),
                    child: Center(child: _loading
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Se connecter', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16))),
                  ),
                ),
                const SizedBox(height: 24),

                // Divider
                Row(children: [
                  Expanded(child: Divider(color: Colors.grey.shade200)),
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text('ou', style: TextStyle(color: Colors.grey.shade400, fontSize: 13))),
                  Expanded(child: Divider(color: Colors.grey.shade200)),
                ]),
                const SizedBox(height: 24),

                // Google button
                _socialBtn(Icons.g_mobiledata_rounded, 'Continuer avec Google', () {}),
                const SizedBox(height: 40),

                // Inscription
                Center(child: GestureDetector(
                  onTap: () => context.go('/register'),
                  child: RichText(text: TextSpan(
                    text: 'Pas encore de compte ? ',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                    children: const [TextSpan(text: 'S\'inscrire', style: TextStyle(color: kPrimary, fontWeight: FontWeight.w700))],
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

  Widget _input({required TextEditingController controller, required String hint, required IconData icon, bool obscure = false, Widget? suffix, TextInputType? keyboardType, String? Function(String?)? validator}) =>
    TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(fontSize: 15, color: Color(0xFF0F172A)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: kPrimary, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.red)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );

  Widget _socialBtn(IconData icon, String label, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity, height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 24, color: const Color(0xFF0F172A)),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
      ]),
    ),
  );
}
