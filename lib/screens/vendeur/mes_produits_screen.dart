import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

class MesProduitsScreen extends StatefulWidget {
  const MesProduitsScreen({super.key});
  @override
  State<MesProduitsScreen> createState() => _MesProduitsScreenState();
}

class _MesProduitsScreenState extends State<MesProduitsScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _produits = [];
  bool _loading = true;
  String _filtre = 'tous';

  static const Color kBlue1 = Color(0xFF1565C0);
  static const Color kBlue2 = Color(0xFF1E88E5);
  static const Color kBlueBg = Color(0xFFE3F2FD);

  @override
  void initState() { super.initState(); _loadProduits(); }

  Future<void> _loadProduits() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;
      var query = supabase.from('produits').select('*').eq('vendeur_id', userId);
      if (_filtre != 'tous') query = query.eq('statut', _filtre);
      final data = await query.order('created_at', ascending: false);
      if (mounted) setState(() { _produits = List<Map<String, dynamic>>.from(data); _loading = false; });
    } catch (e) { if (mounted) setState(() => _loading = false); }
  }

  Color _statutColor(String? s) {
    switch (s) {
      case 'publie': return Colors.green;
      case 'en_attente': return Colors.orange;
      case 'rejete': return Colors.red;
      case 'brouillon': return Colors.grey;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: kBlue1,
        title: const Text('Mes Produits', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.white),
            onPressed: () => context.go('/vendeur/ajouter'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtres
          Container(
            color: kBlue1,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['tous', 'publie', 'en_attente', 'brouillon', 'rejete'].map((f) {
                  final labels = {'tous': 'Tous', 'publie': 'Publiés', 'en_attente': 'En attente', 'brouillon': 'Brouillons', 'rejete': 'Rejetés'};
                  return GestureDetector(
                    onTap: () { setState(() { _filtre = f; _loading = true; }); _loadProduits(); },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: _filtre == f ? Colors.white : Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(labels[f]!, style: TextStyle(color: _filtre == f ? kBlue1 : Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _produits.isEmpty
                    ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Container(width: 100, height: 100, decoration: const BoxDecoration(color: kBlueBg, shape: BoxShape.circle), child: const Icon(Icons.inventory_2_outlined, size: 50, color: kBlue2)),
                        const SizedBox(height: 16),
                        const Text('Aucun produit', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () => context.go('/vendeur/ajouter'),
                          icon: const Icon(Icons.add, color: Colors.white),
                          label: const Text('Ajouter un produit', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(backgroundColor: kBlue1, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        ),
                      ]))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _produits.length,
                        itemBuilder: (_, i) {
                          final p = _produits[i];
                          final statut = p['statut'] ?? '';
                          final color = _statutColor(statut);
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: kBlue1.withOpacity(0.07), blurRadius: 8, offset: const Offset(0, 3))]),
                            child: Row(children: [
                              Container(
                                width: 60, height: 60,
                                decoration: BoxDecoration(color: kBlueBg, borderRadius: BorderRadius.circular(12)),
                                child: Icon(
                                  p['categorie_type'] == 'ebook' ? Icons.menu_book_rounded : p['categorie_type'] == 'template' ? Icons.palette_rounded : Icons.code_rounded,
                                  color: kBlue2, size: 28,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(p['titre'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A237E), fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 4),
                                Text('${p['prix_dzd'] ?? 0} DZD · ${p['nombre_ventes'] ?? 0} ventes', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                                  child: Text(statut.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                              ])),
                              if (statut == 'brouillon' || statut == 'rejete')
                                IconButton(
                                  icon: const Icon(Icons.send, color: kBlue1, size: 20),
                                  onPressed: () async {
                                    await supabase.rpc('publier_produit', params: {'p_produit_id': p['id']});
                                    _loadProduits();
                                  },
                                ),
                            ]),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
