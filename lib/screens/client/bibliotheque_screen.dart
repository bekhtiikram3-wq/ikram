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

  static const Color kBlue1  = Color(0xFF1565C0);
  static const Color kBlue2  = Color(0xFF1E88E5);
  static const Color kBlueBg = Color(0xFFE3F2FD);

  @override
  void initState() { super.initState(); _loadBibliotheque(); }

  Future<void> _loadBibliotheque() async {
    try {
      final data = await supabase.rpc('get_ma_bibliotheque');
      if (mounted) setState(() { _produits = List<Map<String, dynamic>>.from(data); _loading = false; });
    } catch (e) { if (mounted) setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: kBlue1,
        title: const Text('Ma Bibliothèque', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.search, color: Colors.white), onPressed: () {}),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _produits.isEmpty
              ? _buildEmpty()
              : Column(
                  children: [
                    // Stats header
                    Container(
                      color: kBlue1,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                      child: Row(
                        children: [
                          _headerStat('${_produits.length}', 'Produits'),
                          _headerStat('${_produits.where((p) => p['categorie_type'] == 'ebook').length}', 'Ebooks'),
                          _headerStat('${_produits.where((p) => p['categorie_type'] == 'template').length}', 'Templates'),
                          _headerStat('${_produits.where((p) => p['categorie_type'] == 'script').length}', 'Scripts'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _produits.length,
                        itemBuilder: (_, i) => _buildItem(_produits[i]),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _headerStat(String val, String label) => Expanded(
    child: Column(children: [
      Text(val, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
    ]),
  );

  Widget _buildItem(Map<String, dynamic> p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: kBlue1.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 3))]),
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: Container(
          width: 54, height: 54,
          decoration: BoxDecoration(color: kBlueBg, borderRadius: BorderRadius.circular(12)),
          child: Icon(
            p['categorie_type'] == 'ebook' ? Icons.menu_book_rounded : p['categorie_type'] == 'template' ? Icons.palette_rounded : Icons.code_rounded,
            color: kBlue2, size: 28,
          ),
        ),
        title: Text(p['titre'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A237E)), maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(p['nom_boutique'] ?? '', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
            const SizedBox(height: 4),
            Text('Téléchargé ${p['nombre_fois_dl'] ?? 0} fois', style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: const BoxDecoration(gradient: LinearGradient(colors: [kBlue1, kBlue2]), borderRadius: BorderRadius.all(Radius.circular(10))),
          child: const Text('Télécharger', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildEmpty() => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(width: 120, height: 120, decoration: const BoxDecoration(color: kBlueBg, shape: BoxShape.circle), child: const Icon(Icons.library_books_outlined, size: 60, color: kBlue2)),
      const SizedBox(height: 20),
      const Text('Bibliothèque vide', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
      const SizedBox(height: 8),
      Text('Vos achats apparaîtront ici', style: TextStyle(color: Colors.grey.shade500)),
    ]),
  );
}
