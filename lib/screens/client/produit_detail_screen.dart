import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

class ProduitDetailScreen extends StatefulWidget {
  final String produitId;
  const ProduitDetailScreen({super.key, required this.produitId});
  @override
  State<ProduitDetailScreen> createState() => _ProduitDetailScreenState();
}

class _ProduitDetailScreenState extends State<ProduitDetailScreen> {
  final supabase = Supabase.instance.client;
  Map<String, dynamic>? _produit;
  bool _loading = true;
  bool _dansWishlist = false;
  bool _achete = false;

  static const Color kBlue1 = Color(0xFF1565C0);
  static const Color kBlue2 = Color(0xFF1E88E5);
  static const Color kBlueBg = Color(0xFFE3F2FD);

  @override
  void initState() {
    super.initState();
    _loadProduit();
  }

  Future<void> _loadProduit() async {
    try {
      final data = await supabase.rpc('get_produit_details', params: {'p_produit_id': widget.produitId});
      if (mounted) setState(() { _produit = data; _loading = false; });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _ajouterPanier() async {
    try {
      await supabase.rpc('ajouter_au_panier', params: {'p_produit_id': widget.produitId});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Ajouté au panier !'), backgroundColor: kBlue1, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_produit == null) return const Scaffold(body: Center(child: Text('Produit introuvable')));

    final p = _produit!['produit'] as Map<String, dynamic>? ?? {};
    final v = _produit!['vendeur'] as Map<String, dynamic>? ?? {};
    final tags = _produit!['tags'] as List? ?? [];
    final avis = _produit!['avis_recent'] as List? ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: CustomScrollView(
        slivers: [
          // ── Image header ──
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: kBlue1,
            leading: GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.arrow_back, color: kBlue1),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () => setState(() => _dansWishlist = !_dansWishlist),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(12)),
                  child: Icon(_dansWishlist ? Icons.favorite : Icons.favorite_border, color: _dansWishlist ? Colors.red : kBlue1),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: p['image_couverture'] != null
                  ? Image.network(p['image_couverture'], fit: BoxFit.cover)
                  : Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(colors: [kBlue1, kBlue2], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      ),
                      child: Center(child: Icon(
                        p['categorie_type'] == 'ebook' ? Icons.menu_book_rounded : p['categorie_type'] == 'template' ? Icons.palette_rounded : Icons.code_rounded,
                        color: Colors.white, size: 80,
                      )),
                    ),
            ),
          ),

          // ── Contenu ──
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF0F4FF),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge + titre
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: kBlueBg, borderRadius: BorderRadius.circular(6)),
                      child: Text(p['categorie_type']?.toString().toUpperCase() ?? '', style: const TextStyle(color: kBlue1, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 10),
                    Text(p['titre'] ?? '', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
                    const SizedBox(height: 12),

                    // Stats
                    Row(
                      children: [
                        _statBadge(Icons.star, '${p['note_moyenne'] ?? 0}', Colors.amber),
                        const SizedBox(width: 12),
                        _statBadge(Icons.shopping_bag_outlined, '${p['nombre_ventes'] ?? 0} ventes', kBlue2),
                        const SizedBox(width: 12),
                        _statBadge(Icons.comment_outlined, '${p['nombre_avis'] ?? 0} avis', Colors.green),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Vendeur
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                      child: Row(
                        children: [
                          Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(color: kBlueBg, borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.store, color: kBlue1),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(v['nom_boutique'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
                                Row(children: [
                                  const Icon(Icons.star, color: Colors.amber, size: 14),
                                  Text(' ${v['note_moyenne'] ?? 0} · ${v['total_ventes'] ?? 0} ventes', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                  if (v['est_verifie'] == true) ...[
                                    const SizedBox(width: 6),
                                    const Icon(Icons.verified, color: Colors.blue, size: 14),
                                  ],
                                ]),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Description
                    const Text('Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
                    const SizedBox(height: 8),
                    Text(p['description'] ?? '', style: TextStyle(color: Colors.grey.shade700, height: 1.6, fontSize: 14)),
                    const SizedBox(height: 16),

                    // Tags
                    if (tags.isNotEmpty) ...[
                      const Text('Tags', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8, runSpacing: 6,
                        children: tags.map((t) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: kBlueBg, borderRadius: BorderRadius.circular(20)),
                          child: Text('#$t', style: const TextStyle(color: kBlue1, fontSize: 12, fontWeight: FontWeight.w600)),
                        )).toList(),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Avis
                    if (avis.isNotEmpty) ...[
                      const Text('Avis récents', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
                      const SizedBox(height: 8),
                      ...avis.take(3).map((a) => _buildAvis(a)),
                    ],

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // ── Bouton achat ──
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: kBlue1.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, -5))],
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Prix', style: TextStyle(color: Colors.grey, fontSize: 12)),
                Text('${p['prix_dzd'] ?? 0} DZD', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: kBlue1)),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _ajouterPanier,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kBlue1,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Ajouter au panier', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statBadge(IconData icon, String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, color: color, size: 14),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    ]),
  );

  Widget _buildAvis(dynamic a) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(a['client'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            Row(children: List.generate(5, (i) => Icon(Icons.star, color: i < (a['note'] ?? 0) ? Colors.amber : Colors.grey.shade300, size: 14))),
          ],
        ),
        const SizedBox(height: 6),
        Text(a['commentaire'] ?? '', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
      ],
    ),
  );
}
