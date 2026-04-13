import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

class PanierScreen extends StatefulWidget {
  const PanierScreen({super.key});
  @override
  State<PanierScreen> createState() => _PanierScreenState();
}

class _PanierScreenState extends State<PanierScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;
  double _total = 0;

  static const Color kBlue1  = Color(0xFF1565C0);
  static const Color kBlue2  = Color(0xFF1E88E5);
  static const Color kBlueBg = Color(0xFFE3F2FD);

  @override
  void initState() { super.initState(); _loadPanier(); }

  Future<void> _loadPanier() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;
      final panier = await supabase.from('paniers').select('id').eq('client_id', userId).maybeSingle();
      if (panier == null) { setState(() => _loading = false); return; }
      final items = await supabase.from('panier_items')
          .select('produit_id, prix_snapshot_dzd, produits(titre, image_couverture, categorie_type)')
          .eq('panier_id', panier['id']);
      double total = 0;
      for (var item in items) total += (item['prix_snapshot_dzd'] ?? 0).toDouble();
      if (mounted) setState(() { _items = List<Map<String, dynamic>>.from(items); _total = total; _loading = false; });
    } catch (e) { if (mounted) setState(() => _loading = false); }
  }

  Future<void> _commander() async {
    try {
      final result = await supabase.rpc('creer_commande');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Commande créée ! Montant: ${result['montant_dzd']} DZD'), backgroundColor: kBlue1, behavior: SnackBarBehavior.floating),
      );
      _loadPanier();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: kBlue1,
        title: const Text('Mon Panier', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          if (_items.isNotEmpty)
            TextButton(
              onPressed: () {},
              child: const Text('Vider', style: TextStyle(color: Colors.white70)),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? _buildEmpty()
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _items.length,
                        itemBuilder: (_, i) => _buildItem(_items[i]),
                      ),
                    ),
                    _buildCheckout(),
                  ],
                ),
    );
  }

  Widget _buildItem(Map<String, dynamic> item) {
    final produit = item['produits'] as Map<String, dynamic>? ?? {};
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: kBlue1.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Row(
        children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(color: kBlueBg, borderRadius: BorderRadius.circular(12)),
            child: Icon(
              produit['categorie_type'] == 'ebook' ? Icons.menu_book_rounded : produit['categorie_type'] == 'template' ? Icons.palette_rounded : Icons.code_rounded,
              color: kBlue2, size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(produit['titre'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1A237E)), maxLines: 2),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: kBlueBg, borderRadius: BorderRadius.circular(4)),
                  child: Text(produit['categorie_type']?.toString().toUpperCase() ?? '', style: const TextStyle(color: kBlue1, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${item['prix_snapshot_dzd']} DZD', style: const TextStyle(fontWeight: FontWeight.bold, color: kBlue1, fontSize: 14)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                  child: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 18),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckout() => Container(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [BoxShadow(color: kBlue1.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, -5))],
    ),
    child: Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('${_items.length} article(s)', style: TextStyle(color: Colors.grey.shade600)),
          Text('${_total.round()} DZD', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A237E), fontSize: 16)),
        ]),
        const SizedBox(height: 4),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Commission', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
          Text('Incluse', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
        ]),
        const Divider(height: 20),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text('${_total.round()} DZD', style: const TextStyle(fontWeight: FontWeight.bold, color: kBlue1, fontSize: 20)),
        ]),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _commander,
            style: ElevatedButton.styleFrom(
              backgroundColor: kBlue1,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Payer avec Dahabia', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    ),
  );

  Widget _buildEmpty() => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        width: 120, height: 120,
        decoration: const BoxDecoration(color: kBlueBg, shape: BoxShape.circle),
        child: const Icon(Icons.shopping_cart_outlined, size: 60, color: kBlue2),
      ),
      const SizedBox(height: 20),
      const Text('Votre panier est vide', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
      const SizedBox(height: 8),
      Text('Découvrez nos produits digitaux', style: TextStyle(color: Colors.grey.shade500)),
      const SizedBox(height: 24),
      ElevatedButton(
        onPressed: () => context.go('/catalogue'),
        style: ElevatedButton.styleFrom(backgroundColor: kBlue1, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        child: const Text('Explorer le catalogue', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    ]),
  );
}
