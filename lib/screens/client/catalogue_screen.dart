import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

class CatalogueScreen extends StatefulWidget {
  const CatalogueScreen({super.key});
  @override
  State<CatalogueScreen> createState() => _CatalogueScreenState();
}

class _CatalogueScreenState extends State<CatalogueScreen> with SingleTickerProviderStateMixin {
  final supabase = Supabase.instance.client;
  late TabController _tabController;
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _produits = [];
  bool _loading = true;
  String _categorieSelectee = 'tous';
  String _tri = 'recent';
  double _prixMax = 10000;

  static const Color kBlue1  = Color(0xFF1565C0);
  static const Color kBlue2  = Color(0xFF1E88E5);
  static const Color kBlueBg = Color(0xFFE3F2FD);

  final List<Map<String, dynamic>> _categories = [
    {'key': 'tous',     'label': 'Tous',      'icon': Icons.apps_rounded},
    {'key': 'ebook',    'label': 'Ebooks',    'icon': Icons.menu_book_rounded},
    {'key': 'template', 'label': 'Templates', 'icon': Icons.palette_rounded},
    {'key': 'script',   'label': 'Scripts',   'icon': Icons.code_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      final keys = ['tous', 'ebook', 'template', 'script'];
      setState(() => _categorieSelectee = keys[_tabController.index]);
      _loadProduits();
    });
    _loadProduits();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProduits() async {
    setState(() => _loading = true);
    try {
      var query = supabase
          .from('produits')
          .select('id, titre, prix_dzd, image_couverture, categorie_type, note_moyenne, nombre_ventes, description_courte')
          .eq('statut', 'publie')
          .lte('prix_dzd', _prixMax);

      if (_categorieSelectee != 'tous') {
        query = query.eq('categorie_type', _categorieSelectee);
      }

      final data = await query.order(
        _tri == 'prix_asc' ? 'prix_dzd' : _tri == 'note' ? 'note_moyenne' : 'date_publication',
        ascending: _tri == 'prix_asc',
      ).limit(20);

      if (mounted) setState(() { _produits = List<Map<String, dynamic>>.from(data); _loading = false; });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: NestedScrollView(
        headerSliverBuilder: (context, inner) => [
          SliverAppBar(
            expandedHeight: 140,
            floating: true,
            pinned: true,
            backgroundColor: kBlue1,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [kBlue1, kBlue2], begin: Alignment.topLeft, end: Alignment.bottomRight),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Catalogue', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Container(
                          height: 46,
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (_) => _loadProduits(),
                            decoration: InputDecoration(
                              hintText: 'Rechercher...',
                              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                              prefixIcon: const Icon(Icons.search, color: kBlue1, size: 20),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.tune, color: kBlue1, size: 20),
                                onPressed: _showFiltres,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 13),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              tabs: _categories.map((c) => Tab(
                child: Row(children: [
                  Icon(c['icon'] as IconData, size: 16),
                  const SizedBox(width: 6),
                  Text(c['label'] as String),
                ]),
              )).toList(),
            ),
          ),
        ],
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _produits.isEmpty
                ? _buildEmpty()
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, childAspectRatio: 0.72, crossAxisSpacing: 12, mainAxisSpacing: 12,
                    ),
                    itemCount: _produits.length,
                    itemBuilder: (_, i) => _buildCard(_produits[i]),
                  ),
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> p) {
    return GestureDetector(
      onTap: () => context.go('/produit/${p['id']}'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: kBlue1.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Container(
                height: 110, width: double.infinity, color: kBlueBg,
                child: p['image_couverture'] != null
                    ? Image.network(p['image_couverture'], fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image_outlined, color: kBlue2, size: 40))
                    : Center(child: Icon(
                        p['categorie_type'] == 'ebook' ? Icons.menu_book_rounded : p['categorie_type'] == 'template' ? Icons.palette_rounded : Icons.code_rounded,
                        color: kBlue2, size: 40,
                      )),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: kBlueBg, borderRadius: BorderRadius.circular(4)),
                    child: Text(p['categorie_type']?.toString().toUpperCase() ?? '', style: const TextStyle(color: kBlue1, fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 5),
                  Text(p['titre'] ?? '', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${p['prix_dzd'] ?? 0} DZD', style: const TextStyle(color: kBlue1, fontWeight: FontWeight.bold, fontSize: 12)),
                      Row(children: [
                        const Icon(Icons.star, color: Colors.amber, size: 12),
                        Text('${p['note_moyenne'] ?? 0}', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                      ]),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.search_off_rounded, size: 80, color: Colors.grey.shade300),
      const SizedBox(height: 16),
      Text('Aucun produit trouvé', style: TextStyle(color: Colors.grey.shade500, fontSize: 16, fontWeight: FontWeight.w500)),
      const SizedBox(height: 8),
      Text('Essayez d\'autres filtres', style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
    ]),
  );

  void _showFiltres() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(
        builder: (context, setModal) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Filtres', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
              const SizedBox(height: 20),
              const Text('Prix maximum (DZD)', style: TextStyle(fontWeight: FontWeight.w600)),
              Slider(
                value: _prixMax, min: 0, max: 50000, divisions: 50,
                activeColor: kBlue1,
                label: '${_prixMax.round()} DZD',
                onChanged: (v) { setModal(() => _prixMax = v); setState(() => _prixMax = v); },
              ),
              const SizedBox(height: 12),
              const Text('Trier par', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _triChip('recent', 'Récent', setModal),
                  _triChip('prix_asc', 'Prix ↑', setModal),
                  _triChip('note', 'Note', setModal),
                  _triChip('ventes', 'Ventes', setModal),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: kBlue1, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: () { Navigator.pop(context); _loadProduits(); },
                  child: const Text('Appliquer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _triChip(String key, String label, StateSetter setModal) {
    final selected = _tri == key;
    return GestureDetector(
      onTap: () => setModal(() { _tri = key; setState(() => _tri = key); }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? kBlue1 : kBlueBg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: TextStyle(color: selected ? Colors.white : kBlue1, fontWeight: FontWeight.w600, fontSize: 12)),
      ),
    );
  }
}
