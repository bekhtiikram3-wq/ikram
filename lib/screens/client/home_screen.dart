import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final supabase = Supabase.instance.client;
  String _nom = 'Utilisateur';
  List<Map<String, dynamic>> _produits = [];
  bool _loading = true;

  static const kPrimary = Color(0xFF2563EB);
  static const kAccent  = Color(0xFF7C3AED);
  static const kBg      = Color(0xFFF8FAFC);

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final id = supabase.auth.currentUser?.id;
      if (id == null) return;
      final u = await supabase.from('utilisateurs').select('nom').eq('id', id).single();
      final p = await supabase.from('produits').select('id,titre,prix_dzd,image_couverture,categorie_type,note_moyenne,nombre_ventes').eq('statut', 'publie').order('date_publication', ascending: false).limit(6);
      if (mounted) setState(() { _nom = u['nom'] ?? 'Utilisateur'; _produits = List<Map<String, dynamic>>.from(p); _loading = false; });
    } catch (e) { if (mounted) setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    final h = DateTime.now().hour;
    final salut = h < 12 ? 'Bonjour' : h < 18 ? 'Bon après-midi' : 'Bonsoir';

    return Scaffold(
      backgroundColor: kBg,
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: kPrimary))
          : CustomScrollView(slivers: [

        // ── Header ──
        SliverToBoxAdapter(child: Container(
          color: Colors.white,
          padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 16, 24, 20),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('$salut 👋', style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                const SizedBox(height: 2),
                Text(_nom, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
              ]),
              Row(children: [
                _iconBtn(Icons.notifications_outlined, () => context.go('/notifications')),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => context.go('/profil'),
                  child: Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [kPrimary, kAccent]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(child: Text(_nom.isNotEmpty ? _nom[0].toUpperCase() : 'U', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16))),
                  ),
                ),
              ]),
            ]),
            const SizedBox(height: 16),
            // Search
            GestureDetector(
              onTap: () => context.go('/catalogue'),
              child: Container(
                height: 48, padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey.shade200)),
                child: Row(children: [
                  Icon(Icons.search_rounded, color: Colors.grey.shade400, size: 20),
                  const SizedBox(width: 10),
                  Text('Ebooks, templates, scripts...', style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
                  const Spacer(),
                  Container(
                    width: 30, height: 30,
                    decoration: BoxDecoration(gradient: const LinearGradient(colors: [kPrimary, kAccent]), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.tune_rounded, color: Colors.white, size: 15),
                  ),
                ]),
              ),
            ),
          ]),
        )),

        // ── Bannière ──
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF1D4ED8), Color(0xFF7C3AED)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(children: [
              Positioned(right: -20, top: -20, child: Container(width: 130, height: 130, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.07)))),
              Positioned(right: 30, bottom: -30, child: Container(width: 90, height: 90, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.05)))),
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(6)), child: const Text('NOUVEAU', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700))),
                  const SizedBox(height: 8),
                  const Text('Découvrez les\nmeilleurs produits', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800, height: 1.2)),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => context.go('/catalogue'),
                    child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)), child: const Text('Explorer', style: TextStyle(color: kPrimary, fontSize: 12, fontWeight: FontWeight.w700))),
                  ),
                ]),
              ),
              Positioned(right: 16, bottom: 0, top: 0, child: Center(child: Icon(Icons.rocket_launch_rounded, color: Colors.white.withOpacity(0.5), size: 72))),
            ]),
          ),
        )),

        // ── Catégories ──
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _sectionHeader('Catégories', null, null),
            const SizedBox(height: 14),
            Row(children: [
              _catChip('Ebooks', Icons.menu_book_rounded, kPrimary, 'ebook'),
              const SizedBox(width: 10),
              _catChip('Templates', Icons.palette_rounded, kAccent, 'template'),
              const SizedBox(width: 10),
              _catChip('Scripts', Icons.code_rounded, const Color(0xFF059669), 'script'),
            ]),
          ]),
        )),

        // ── Top sellers ──
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 24, 0, 0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _sectionHeader('Top Sellers', 'Voir tout', () => context.go('/catalogue')),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 190,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _produits.isEmpty ? 3 : _produits.length.clamp(0, 5),
                itemBuilder: (_, i) {
                  final colors = [[kPrimary, kAccent], [const Color(0xFF059669), const Color(0xFF0891B2)], [const Color(0xFFDC2626), const Color(0xFFEA580C)]];
                  final c = colors[i % colors.length];
                  final p = _produits.isEmpty ? null : _produits[i];
                  return Container(
                    width: 150, margin: const EdgeInsets.only(right: 14),
                    decoration: BoxDecoration(gradient: LinearGradient(colors: c, begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(18)),
                    child: Stack(children: [
                      Positioned(right: -15, top: -15, child: Container(width: 80, height: 80, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.1)))),
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(6)), child: Text(p?['categorie_type']?.toString().toUpperCase() ?? 'EBOOK', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700))),
                          const Spacer(),
                          Text(p?['titre'] ?? 'Produit digital', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700), maxLines: 2),
                          const SizedBox(height: 6),
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Text('${p?['prix_dzd'] ?? 1200} DZD', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                            Row(children: [const Icon(Icons.star_rounded, color: Colors.amber, size: 12), Text('${p?['note_moyenne'] ?? 4.8}', style: const TextStyle(color: Colors.white, fontSize: 11))]),
                          ]),
                        ]),
                      ),
                    ]),
                  );
                },
              ),
            ),
          ]),
        )),

        // ── Nouveautés ──
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: _sectionHeader('Nouveautés', 'Voir tout', () => context.go('/catalogue')),
        )),

        _produits.isEmpty
            ? SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.all(40),
                child: Center(child: Column(children: [
                  Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey.shade200),
                  const SizedBox(height: 12),
                  Text('Aucun produit', style: TextStyle(color: Colors.grey.shade400)),
                ])),
              ))
            : SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.75, crossAxisSpacing: 14, mainAxisSpacing: 14),
                  delegate: SliverChildBuilderDelegate((_, i) => _produitCard(_produits[i]), childCount: _produits.length),
                ),
              ),

        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ]),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 42, height: 42,
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(12)),
      child: Icon(icon, size: 20, color: const Color(0xFF374151)),
    ),
  );

  Widget _sectionHeader(String title, String? action, VoidCallback? onTap) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
      if (action != null) GestureDetector(
        onTap: onTap,
        child: Row(children: [
          Text(action, style: const TextStyle(fontSize: 13, color: kPrimary, fontWeight: FontWeight.w600)),
          const Icon(Icons.chevron_right_rounded, color: kPrimary, size: 18),
        ]),
      ),
    ],
  );

  Widget _catChip(String label, IconData icon, Color color, String key) => Expanded(
    child: GestureDetector(
      onTap: () => context.go('/catalogue'),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade100)),
        child: Column(children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 22)),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
        ]),
      ),
    ),
  );

  Widget _produitCard(Map<String, dynamic> p) => GestureDetector(
    onTap: () => context.go('/produit/${p['id']}'),
    child: Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade100)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: Container(
            height: 100, width: double.infinity,
            color: const Color(0xFFEFF6FF),
            child: p['image_couverture'] != null
                ? Image.network(p['image_couverture'], fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(Icons.image_outlined, color: Colors.grey.shade300, size: 36))
                : Center(child: Icon(
                    p['categorie_type'] == 'ebook' ? Icons.menu_book_rounded : p['categorie_type'] == 'template' ? Icons.palette_rounded : Icons.code_rounded,
                    color: kPrimary.withOpacity(0.4), size: 36,
                  )),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: kPrimary.withOpacity(0.08), borderRadius: BorderRadius.circular(4)),
              child: Text(p['categorie_type']?.toString().toUpperCase() ?? '', style: const TextStyle(color: kPrimary, fontSize: 9, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 5),
            Text(p['titre'] ?? '', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('${p['prix_dzd']} DZD', style: const TextStyle(color: kPrimary, fontWeight: FontWeight.w700, fontSize: 12)),
              Row(children: [const Icon(Icons.star_rounded, color: Colors.amber, size: 12), Text('${p['note_moyenne'] ?? 0}', style: TextStyle(fontSize: 11, color: Colors.grey.shade500))]),
            ]),
          ]),
        ),
      ]),
    ),
  );
}
