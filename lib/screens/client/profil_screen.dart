import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});
  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  final supabase = Supabase.instance.client;
  Map<String, dynamic>? _user;
  bool _loading = true;

  static const kPrimary = Color(0xFF2563EB);
  static const kAccent  = Color(0xFF7C3AED);
  static const kBg      = Color(0xFFF8FAFC);

  @override
  void initState() { super.initState(); _loadUser(); }

  Future<void> _loadUser() async {
    try {
      final id = supabase.auth.currentUser?.id;
      if (id == null) return;
      final data = await supabase.from('utilisateurs').select('*').eq('id', id).single();
      if (mounted) setState(() { _user = data; _loading = false; });
    } catch (e) { if (mounted) setState(() => _loading = false); }
  }

  Future<void> _deconnexion() async {
    await supabase.auth.signOut();
    if (!mounted) return;
    context.go('/login');
  }

  // ── Modifier profil ──
  void _modifierProfil() {
    final nomCtrl = TextEditingController(text: _user?['nom'] ?? '');
    final telCtrl = TextEditingController(text: _user?['telephone'] ?? '');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Modifier le profil', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
            GestureDetector(onTap: () => Navigator.pop(context), child: Container(width: 32, height: 32, decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.close, size: 16, color: Color(0xFF374151)))),
          ]),
          const SizedBox(height: 20),
          const Text('Nom complet', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
          const SizedBox(height: 8),
          TextField(
            controller: nomCtrl,
            decoration: InputDecoration(
              hintText: 'Votre nom',
              prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
              filled: true, fillColor: kBg,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: kPrimary, width: 1.5)),
            ),
          ),
          const SizedBox(height: 14),
          const Text('Téléphone', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
          const SizedBox(height: 8),
          TextField(
            controller: telCtrl,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: '+213 XX XX XX XX',
              prefixIcon: const Icon(Icons.phone_outlined, size: 20),
              filled: true, fillColor: kBg,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: kPrimary, width: 1.5)),
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () async {
              try {
                final id = supabase.auth.currentUser?.id;
                if (id == null) return;
                await supabase.from('utilisateurs').update({
                  'nom': nomCtrl.text.trim(),
                  'telephone': telCtrl.text.trim(),
                }).eq('id', id);
                if (!mounted) return;
                Navigator.pop(context);
                _loadUser();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text('Profil mis à jour !'),
                  backgroundColor: Colors.green.shade400,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red.shade400));
              }
            },
            child: Container(
              width: double.infinity, height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [kPrimary, kAccent]),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: kPrimary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: const Center(child: Text('Sauvegarder', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15))),
            ),
          ),
        ]),
      ),
    );
  }

  // ── Ma Wishlist ──
  void _maWishlist() async {
    final id = supabase.auth.currentUser?.id;
    if (id == null) return;
    List items = [];
    try {
      items = await supabase.from('wishlist').select('produit_id, produits(titre, prix_dzd, categorie_type)').eq('client_id', id);
    } catch (_) {}
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.5,
        maxChildSize: 0.85,
        builder: (_, ctrl) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Ma Wishlist', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
              GestureDetector(onTap: () => Navigator.pop(context), child: Container(width: 32, height: 32, decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.close, size: 16))),
            ]),
            const SizedBox(height: 16),
            items.isEmpty
                ? Expanded(child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.favorite_outline, size: 60, color: Colors.grey.shade200),
                    const SizedBox(height: 12),
                    Text('Wishlist vide', style: TextStyle(color: Colors.grey.shade400, fontSize: 15)),
                  ])))
                : Expanded(child: ListView.builder(
                    controller: ctrl,
                    itemCount: items.length,
                    itemBuilder: (_, i) {
                      final p = items[i]['produits'] ?? {};
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey.shade200)),
                        child: Row(children: [
                          Container(width: 44, height: 44, decoration: BoxDecoration(color: kPrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                            child: Icon(p['categorie_type'] == 'ebook' ? Icons.menu_book_rounded : p['categorie_type'] == 'template' ? Icons.palette_rounded : Icons.code_rounded, color: kPrimary, size: 22)),
                          const SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(p['titre'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0F172A), fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text('${p['prix_dzd'] ?? 0} DZD', style: const TextStyle(color: kPrimary, fontWeight: FontWeight.w700, fontSize: 13)),
                          ])),
                          Icon(Icons.favorite, color: Colors.red.shade300, size: 20),
                        ]),
                      );
                    },
                  )),
          ]),
        ),
      ),
    );
  }

  // ── Langue ──
  void _changerLangue() {
    String langue = 'Français';
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Langue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
              GestureDetector(onTap: () => Navigator.pop(ctx), child: Container(width: 32, height: 32, decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.close, size: 16))),
            ]),
            const SizedBox(height: 20),
            ...['Français', 'العربية', 'English'].map((l) => GestureDetector(
              onTap: () => setModal(() => langue = l),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: langue == l ? kPrimary.withOpacity(0.06) : kBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: langue == l ? kPrimary : Colors.grey.shade200, width: langue == l ? 1.5 : 1),
                ),
                child: Row(children: [
                  Text(l == 'Français' ? '🇫🇷' : l == 'العربية' ? '🇩🇿' : '🇬🇧', style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 14),
                  Text(l, style: TextStyle(fontSize: 15, fontWeight: langue == l ? FontWeight.w700 : FontWeight.w500, color: langue == l ? kPrimary : const Color(0xFF374151))),
                  const Spacer(),
                  if (langue == l) const Icon(Icons.check_circle_rounded, color: kPrimary, size: 22),
                ]),
              ),
            )),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () { Navigator.pop(ctx); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Langue changée : $langue'), backgroundColor: Colors.green.shade400, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))); },
              child: Container(
                width: double.infinity, height: 52,
                decoration: BoxDecoration(gradient: const LinearGradient(colors: [kPrimary, kAccent]), borderRadius: BorderRadius.circular(14)),
                child: const Center(child: Text('Confirmer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15))),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  // ── Aide & Support ──
  void _aide() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Aide & Support', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
            GestureDetector(onTap: () => Navigator.pop(context), child: Container(width: 32, height: 32, decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.close, size: 16))),
          ]),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey.shade200)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(width: 40, height: 40, decoration: BoxDecoration(color: kPrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.email_outlined, color: kPrimary, size: 20)),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Email de support', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                  const Text('support@digitalstore.dz', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                ]),
              ]),
            ]),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey.shade200)),
            child: Row(children: [
              Container(width: 40, height: 40, decoration: BoxDecoration(color: kAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.schedule_outlined, color: kAccent, size: 20)),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Heures de support', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                const Text('Lun–Ven, 9h–18h', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
              ]),
            ]),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Redirection vers support@digitalstore.dz'), backgroundColor: kPrimary, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))); },
            child: Container(
              width: double.infinity, height: 52,
              decoration: BoxDecoration(gradient: const LinearGradient(colors: [kPrimary, kAccent]), borderRadius: BorderRadius.circular(14)),
              child: const Center(child: Text('Envoyer un message', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15))),
            ),
          ),
        ]),
      ),
    );
  }

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
    padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 16, 24, 28),
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
      const SizedBox(height: 24),
      Container(
        width: 80, height: 80,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [kPrimary, kAccent]),
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: kPrimary.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: Center(child: Text(
          (_user?['nom'] ?? 'U').isNotEmpty ? (_user?['nom'] ?? 'U')[0].toUpperCase() : 'U',
          style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800),
        )),
      ),
      const SizedBox(height: 14),
      Text(_user?['nom'] ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
      const SizedBox(height: 4),
      Text(_user?['email'] ?? '', style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
      const SizedBox(height: 10),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [kPrimary, kAccent]),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text((_user?['role'] ?? 'client').toString().toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
      ),
    ]),
  );

  Widget _buildMenu() => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(children: [
      const SizedBox(height: 8),
      _menuSection('Mon compte', [
        _menuItem(Icons.person_outline_rounded,     'Modifier le profil',  kPrimary,              _modifierProfil),
        _menuItem(Icons.shopping_bag_outlined,       'Mes achats',          const Color(0xFF059669), () => context.go('/bibliotheque')),
        _menuItem(Icons.favorite_outline_rounded,    'Ma wishlist',         const Color(0xFFDC2626), _maWishlist),
        _menuItem(Icons.library_books_outlined,      'Ma bibliothèque',     const Color(0xFF7C3AED), () => context.go('/bibliotheque')),
      ]),
      const SizedBox(height: 16),
      _menuSection('Paramètres', [
        _menuItem(Icons.notifications_outlined,      'Notifications',       kPrimary,              () => context.go('/notifications')),
        _menuItem(Icons.message_outlined,            'Messages',            const Color(0xFF0891B2), () => context.go('/messages')),
        _menuItem(Icons.language_rounded,            'Langue',              const Color(0xFF059669), _changerLangue),
        _menuItem(Icons.help_outline_rounded,        'Aide & Support',      const Color(0xFF7C3AED), _aide),
      ]),
      const SizedBox(height: 16),
      _menuSection('', [
        _menuItem(Icons.logout_rounded,              'Se déconnecter',      Colors.red,            _deconnexion),
      ]),
      const SizedBox(height: 80),
    ]),
  );

  Widget _menuSection(String title, List<Widget> items) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (title.isNotEmpty) ...[
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF6B7280))),
        ),
      ],
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
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 19),
        ),
        const SizedBox(width: 14),
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF0F172A))),
        const Spacer(),
        Icon(Icons.chevron_right_rounded, color: Colors.grey.shade300, size: 20),
      ]),
    ),
  );
}