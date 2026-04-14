import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

class AdminProduitsScreen extends StatefulWidget {
  const AdminProduitsScreen({super.key});
  @override
  State<AdminProduitsScreen> createState() => _AdminProduitsScreenState();
}

class _AdminProduitsScreenState extends State<AdminProduitsScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _produits = [];
  bool _loading = true;
  String _filtre = 'en_attente';

  static const kPrimary = Color(0xFF2563EB);
  static const kBg      = Color(0xFFF8FAFC);

  @override
  void initState() { super.initState(); _loadProduits(); }

  Future<void> _loadProduits() async {
    setState(() => _loading = true);
    try {
      List<Map<String, dynamic>> data;
      if (_filtre == 'tous') {
        data = await supabase
            .from('produits')
            .select('id, titre, prix_dzd, categorie_type, statut, vendeur_id, vendeurs(nom_boutique)')
            .order('created_at', ascending: false);
      } else {
        data = await supabase
            .from('produits')
            .select('id, titre, prix_dzd, categorie_type, statut, vendeur_id, vendeurs(nom_boutique)')
            .eq('statut', _filtre)
            .order('created_at', ascending: false);
      }
      if (mounted) setState(() { _produits = List<Map<String, dynamic>>.from(data); _loading = false; });
    } catch (e) { if (mounted) setState(() => _loading = false); }
  }

  Future<void> _valider(String id) async {
    await supabase.from('produits').update({'statut': 'publie'}).eq('id', id);
    _loadProduits();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('✅ Produit validé et publié !'),
      backgroundColor: Colors.green.shade400,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  Future<void> _rejeter(String id) async {
    await supabase.from('produits').update({'statut': 'rejete'}).eq('id', id);
    _loadProduits();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('❌ Produit rejeté'),
      backgroundColor: Colors.orange.shade400,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  Future<void> _supprimer(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer le produit ?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true) return;
    await supabase.from('produits').delete().eq('id', id);
    _loadProduits();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Column(children: [
        Container(
          color: Colors.white,
          padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 12, 20, 16),
          child: Column(children: [
            Row(children: [
              GestureDetector(
                onTap: () => context.go('/admin'),
                child: Container(width: 40, height: 40, decoration: BoxDecoration(color: kBg, border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16)),
              ),
              const SizedBox(width: 14),
              const Text('Gestion Produits', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
            ]),
            const SizedBox(height: 14),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: [
                _filtreChip('en_attente', 'En attente', Colors.orange),
                const SizedBox(width: 8),
                _filtreChip('publie', 'Publiés', Colors.green),
                const SizedBox(width: 8),
                _filtreChip('rejete', 'Rejetés', Colors.red),
                const SizedBox(width: 8),
                _filtreChip('tous', 'Tous', kPrimary),
              ]),
            ),
          ]),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: kPrimary))
              : _produits.isEmpty
                  ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey.shade200),
                      const SizedBox(height: 12),
                      Text('Aucun produit', style: TextStyle(color: Colors.grey.shade400, fontSize: 16)),
                    ]))
                  : RefreshIndicator(
                      onRefresh: _loadProduits,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _produits.length,
                        itemBuilder: (_, i) => _buildProduitCard(_produits[i]),
                      ),
                    ),
        ),
      ]),
    );
  }

  Widget _filtreChip(String key, String label, Color color) => GestureDetector(
    onTap: () { setState(() => _filtre = key); _loadProduits(); },
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: _filtre == key ? color : color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label, style: TextStyle(color: _filtre == key ? Colors.white : color, fontWeight: FontWeight.w600, fontSize: 12)),
    ),
  );

  Widget _buildProduitCard(Map<String, dynamic> p) {
    final statut = p['statut'] ?? '';
    final vendeur = p['vendeurs'] as Map<String, dynamic>? ?? {};
    final statutColor = statut == 'publie' ? Colors.green : statut == 'en_attente' ? Colors.orange : statut == 'rejete' ? Colors.red : Colors.grey;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade100)),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(color: kPrimary.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
              child: Icon(
                p['categorie_type'] == 'ebook' ? Icons.menu_book_rounded : p['categorie_type'] == 'template' ? Icons.palette_rounded : Icons.code_rounded,
                color: kPrimary, size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p['titre'] ?? '', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF0F172A)), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 3),
              Text(vendeur['nom_boutique'] ?? '', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              Text('${p['prix_dzd'] ?? 0} DZD', style: const TextStyle(color: kPrimary, fontWeight: FontWeight.w700, fontSize: 13)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: statutColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Text(statut.toUpperCase(), style: TextStyle(color: statutColor, fontSize: 10, fontWeight: FontWeight.w700)),
            ),
          ]),
        ),
        Container(
          decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey.shade100))),
          child: Row(children: [
            if (statut == 'en_attente' || statut == 'rejete')
              Expanded(child: TextButton.icon(
                onPressed: () => _valider(p['id']),
                icon: const Icon(Icons.check_circle_outline, color: Colors.green, size: 18),
                label: Text(statut == 'rejete' ? 'Republier' : 'Valider', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w700)),
              )),
            if (statut == 'en_attente') ...[
              Container(width: 1, height: 40, color: Colors.grey.shade100),
              Expanded(child: TextButton.icon(
                onPressed: () => _rejeter(p['id']),
                icon: const Icon(Icons.cancel_outlined, color: Colors.orange, size: 18),
                label: const Text('Rejeter', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w700)),
              )),
            ],
            Container(width: 1, height: 40, color: Colors.grey.shade100),
            Expanded(child: TextButton.icon(
              onPressed: () => _supprimer(p['id']),
              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
              label: const Text('Supprimer', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700)),
            )),
          ]),
        ),
      ]),
    );
  }
}