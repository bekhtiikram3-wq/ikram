import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

class ProfilVendeurScreen extends StatefulWidget {
  const ProfilVendeurScreen({super.key});
  @override
  State<ProfilVendeurScreen> createState() => _ProfilVendeurScreenState();
}

class _ProfilVendeurScreenState extends State<ProfilVendeurScreen> {
  final supabase = Supabase.instance.client;
  Map<String, dynamic>? _user;
  Map<String, dynamic>? _vendeur;
  bool _loading = true;

  static const kPrimary = Color(0xFF2563EB);
  static const kAccent  = Color(0xFF7C3AED);
  static const kBg      = Color(0xFFF8FAFC);

  @override
  void initState() { super.initState(); _loadData(); }

  Future<void> _loadData() async {
    try {
      final id = supabase.auth.currentUser?.id;
      if (id == null) return;
      final user = await supabase.from('utilisateurs').select('*').eq('id', id).single();
      final vendeur = await supabase.from('vendeurs').select('*').eq('id', id).single();
      if (mounted) setState(() { _user = user; _vendeur = vendeur; _loading = false; });
    } catch (e) { if (mounted) setState(() => _loading = false); }
  }

  Future<void> _deconnexion() async {
    await supabase.auth.signOut();
    if (!mounted) return;
    context.go('/login');
  }

  void _modifierProfil() {
    final nomCtrl = TextEditingController(text: _user?['nom'] ?? '');
    final boutiqueCtrl = TextEditingController(text: _vendeur?['nom_boutique'] ?? '');
    final bioCtrl = TextEditingController(text: _vendeur?['bio'] ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Modifier le profil', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
            GestureDetector(onTap: () => Navigator.pop(context), child: Container(width: 32, height: 32, decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.close, size: 16))),
          ]),
          const SizedBox(height: 20),
          _inputField('Nom complet', nomCtrl, Icons.person_outline_rounded),
          const SizedBox(height: 12),
          _inputField('Nom de la boutique', boutiqueCtrl, Icons.storefront_outlined),
          const SizedBox(height: 12),
          _inputField('Bio', bioCtrl, Icons.info_outline_rounded, maxLines: 3),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () async {
              try {
                final id = supabase.auth.currentUser?.id;
                await supabase.from('utilisateurs').update({'nom': nomCtrl.text.trim()}).eq('id', id!);
                await supabase.from('vendeurs').update({
                  'nom_boutique': boutiqueCtrl.text.trim(),
                  'bio': bioCtrl.text.trim(),
                }).eq('id', id);
                if (!mounted) return;
                Navigator.pop(context);
                _loadData();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text('Profil mis à jour !'),
                  backgroundColor: Colors.green.shade400,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
              }
            },
            child: Container(
              width: double.infinity, height: 52,
              decoration: BoxDecoration(gradient: const LinearGradient(colors: [kPrimary, kAccent]), borderRadius: BorderRadius.circular(14)),
              child: const Center(child: Text('Sauvegarder', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15))),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _inputField(String hint, TextEditingController ctrl, IconData icon, {int maxLines = 1}) => TextField(
    controller: ctrl,
    maxLines: maxLines,
    decoration: InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 20),
      filled: true, fillColor: kBg,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: kPrimary, width: 1.5)),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: kPrimary))
          : CustomScrollView(slivers: [
              SliverToBoxAdapter(child: _buildHeader()),
              SliverToBoxAdapter(child: _buildMenu()),
            ]),
    );
  }

  Widget _buildHeader() => Container(
    color: Colors.white,
    padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 16, 20, 28),
    child: Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Mon Profil', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
        GestureDetector(
          onTap: _modifierProfil,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: kPrimary.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
            child: const Text('Modifier', style: TextStyle(color: kPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
          ),
        ),
      ]),
      const SizedBox(height: 20),
      Container(
        width: 80, height: 80,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [kPrimary, kAccent]),
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: kPrimary.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: Center(child: Text(
          (_user?['nom'] ?? 'V').isNotEmpty ? (_user?['nom'] ?? 'V')[0].toUpperCase() : 'V',
          style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800),
        )),
      ),
      const SizedBox(height: 12),
      Text(_user?['nom'] ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
      const SizedBox(height: 4),
      Text(_vendeur?['nom_boutique'] ?? '', style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
      const SizedBox(height: 4),
      Text(_user?['email'] ?? '', style: TextStyle(fontSize: 13, color: Colors.grey.shade400)),
      const SizedBox(height: 10),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(gradient: const LinearGradient(colors: [kPrimary, kAccent]), borderRadius: BorderRadius.circular(20)),
          child: const Text('VENDEUR', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
        ),
        if (_vendeur?['est_verifie'] == true) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.green.shade300)),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.verified, color: Colors.green, size: 14),
              SizedBox(width: 4),
              Text('Vérifié', style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.w700)),
            ]),
          ),
        ],
      ]),
    ]),
  );

  Widget _buildMenu() => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(children: [
      const SizedBox(height: 8),
      _menuSection('Ma boutique', [
        _menuItem(Icons.person_outline_rounded,      'Modifier le profil',     kPrimary,              _modifierProfil),
        _menuItem(Icons.storefront_outlined,          'Ma boutique',            kAccent,               () {}),
        _menuItem(Icons.inventory_2_outlined,         'Mes produits',           const Color(0xFF059669), () => context.go('/vendeur/produits')),
        _menuItem(Icons.account_balance_outlined,     'Mes retraits',           const Color(0xFF0891B2), () => context.go('/vendeur/retraits')),
      ]),
      const SizedBox(height: 16),
      _menuSection('Paramètres', [
        _menuItem(Icons.notifications_outlined,      'Notifications',           kPrimary,              () => context.go('/notifications')),
        _menuItem(Icons.message_outlined,            'Messages',                const Color(0xFF0891B2), () => context.go('/messages')),
        _menuItem(Icons.help_outline_rounded,        'Aide & Support',          const Color(0xFF7C3AED), () {}),
      ]),
      const SizedBox(height: 16),
      _menuSection('', [
        _menuItem(Icons.logout_rounded,              'Se déconnecter',          Colors.red,            _deconnexion),
      ]),
      const SizedBox(height: 80),
    ]),
  );

  Widget _menuSection(String title, List<Widget> items) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (title.isNotEmpty) Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 10),
        child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF6B7280))),
      ),
      Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade100)),
        child: Column(children: items),
      ),
    ],
  );

  Widget _menuItem(IconData icon, String label, Color color, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade50))),
      child: Row(children: [
        Container(width: 38, height: 38, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 19)),
        const SizedBox(width: 14),
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF0F172A))),
        const Spacer(),
        Icon(Icons.chevron_right_rounded, color: Colors.grey.shade300, size: 20),
      ]),
    ),
  );
}