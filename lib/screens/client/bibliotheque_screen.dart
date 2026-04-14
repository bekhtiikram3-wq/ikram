import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BibliothequeScreen extends StatefulWidget {
  const BibliothequeScreen({super.key});
  @override
  State<BibliothequeScreen> createState() => _BibliothequeScreenState();
}

class _BibliothequeScreenState extends State<BibliothequeScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _produits = [];
  bool _loading = true;

  static const kPrimary = Color(0xFF2563EB);
  static const kAccent  = Color(0xFF7C3AED);
  static const kBg      = Color(0xFFF8FAFC);

  @override
  void initState() { super.initState(); _loadBibliotheque(); }

  Future<void> _loadBibliotheque() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        setState(() => _loading = false);
        return;
      }

      // Requête directe sans RPC
      final data = await supabase
          .from('commande_items')
          .select('''
            date_achat,
            nombre_telechargements,
            produits(id, titre, categorie_type, image_couverture,
              vendeurs(nom_boutique)
            ),
            commandes!inner(client_id, statut)
          ''')
          .eq('commandes.client_id', userId)
          .inFilter('commandes.statut', ['complete', 'en_attente']);

      if (mounted) {
        setState(() {
          _produits = List<Map<String, dynamic>>.from(data);
          _loading = false;
        });
      }
    } catch (e) {
      print('Erreur bibliothèque: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Column(children: [
        // Header
        Container(
          color: Colors.white,
          padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 12, 20, 20),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Ma Bibliothèque', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [kPrimary, kAccent]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('${_produits.length} produit(s)', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
            ),
          ]),
        ),

        // Stats
        if (!_loading && _produits.isNotEmpty)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Row(children: [
              _statChip('Total', '${_produits.length}', kPrimary),
              const SizedBox(width: 10),
              _statChip('Ebooks', '${_produits.where((p) => p['produits']?['categorie_type'] == 'ebook').length}', const Color(0xFF2563EB)),
              const SizedBox(width: 10),
              _statChip('Templates', '${_produits.where((p) => p['produits']?['categorie_type'] == 'template').length}', kAccent),
              const SizedBox(width: 10),
              _statChip('Scripts', '${_produits.where((p) => p['produits']?['categorie_type'] == 'script').length}', const Color(0xFF059669)),
            ]),
          ),

        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: kPrimary))
              : _produits.isEmpty
                  ? _buildEmpty()
                  : RefreshIndicator(
                      onRefresh: _loadBibliotheque,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _produits.length,
                        itemBuilder: (_, i) => _buildItem(_produits[i]),
                      ),
                    ),
        ),
      ]),
    );
  }

  Widget _statChip(String label, String val, Color color) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
      child: Column(children: [
        Text(val, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w800)),
        Text(label, style: TextStyle(color: color.withOpacity(0.7), fontSize: 10)),
      ]),
    ),
  );

  Widget _buildItem(Map<String, dynamic> item) {
    final produit = item['produits'] as Map<String, dynamic>? ?? {};
    final vendeur = produit['vendeurs'] as Map<String, dynamic>? ?? {};
    final categorie = produit['categorie_type'] ?? '';
    final nbDl = item['nombre_telechargements'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: Container(
          width: 54, height: 54,
          decoration: BoxDecoration(
            color: kPrimary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            categorie == 'ebook' ? Icons.menu_book_rounded :
            categorie == 'template' ? Icons.palette_rounded : Icons.code_rounded,
            color: kPrimary, size: 26,
          ),
        ),
        title: Text(
          produit['titre'] ?? '',
          style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0F172A), fontSize: 14),
          maxLines: 1, overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 4),
          Text(vendeur['nom_boutique'] ?? '', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
          const SizedBox(height: 4),
          Text('Téléchargé $nbDl fois', style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
        ]),
        trailing: GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Text('Téléchargement en cours...'),
              backgroundColor: kPrimary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ));
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [kPrimary, kAccent]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text('Télécharger', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        width: 100, height: 100,
        decoration: BoxDecoration(color: kPrimary.withOpacity(0.08), shape: BoxShape.circle),
        child: const Icon(Icons.library_books_outlined, size: 50, color: kPrimary),
      ),
      const SizedBox(height: 20),
      const Text('Bibliothèque vide', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
      const SizedBox(height: 8),
      Text('Vos achats apparaîtront ici', style: TextStyle(color: Colors.grey.shade500)),
    ]),
  );
}