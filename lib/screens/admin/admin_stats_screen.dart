import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

class AdminStatsScreen extends StatefulWidget {
  const AdminStatsScreen({super.key});
  @override
  State<AdminStatsScreen> createState() => _AdminStatsScreenState();
}

class _AdminStatsScreenState extends State<AdminStatsScreen> {
  final supabase = Supabase.instance.client;
  Map<String, dynamic> _stats = {};
  bool _loading = true;

  static const kPrimary = Color(0xFF2563EB);
  static const kAccent  = Color(0xFF7C3AED);
  static const kBg      = Color(0xFFF8FAFC);

  @override
  void initState() { super.initState(); _loadStats(); }

  Future<void> _loadStats() async {
    try {
      final users     = await supabase.from('utilisateurs').select('id, role, statut, date_inscription');
      final produits  = await supabase.from('produits').select('id, statut, categorie_type, note_moyenne, nombre_ventes');
      final commandes = await supabase.from('commandes').select('id, statut, montant_total_dzd, created_at');

      // Calculs
      final totalUsers    = users.length;
      final totalClients  = users.where((u) => u['role'] == 'client').length;
      final totalVendeurs = users.where((u) => u['role'] == 'vendeur').length;
      final totalProduits = produits.length;
      final produitsPublies  = produits.where((p) => p['statut'] == 'publie').length;
      final produitsEnAttente = produits.where((p) => p['statut'] == 'en_attente').length;
      final totalCommandes = commandes.length;
      final commandesCompletes = commandes.where((c) => c['statut'] == 'complete').length;
      double totalRevenus = 0;
      for (var c in commandes) totalRevenus += (c['montant_total_dzd'] ?? 0).toDouble();

      // Top catégories
      final ebooks    = produits.where((p) => p['categorie_type'] == 'ebook').length;
      final templates = produits.where((p) => p['categorie_type'] == 'template').length;
      final scripts   = produits.where((p) => p['categorie_type'] == 'script').length;

      if (mounted) setState(() {
        _stats = {
          'total_users': totalUsers,
          'total_clients': totalClients,
          'total_vendeurs': totalVendeurs,
          'total_produits': totalProduits,
          'produits_publies': produitsPublies,
          'produits_en_attente': produitsEnAttente,
          'total_commandes': totalCommandes,
          'commandes_completes': commandesCompletes,
          'total_revenus': totalRevenus,
          'commission': totalRevenus * 0.1,
          'ebooks': ebooks,
          'templates': templates,
          'scripts': scripts,
        };
        _loading = false;
      });
    } catch (e) { if (mounted) setState(() => _loading = false); }
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
          child: Row(children: [
            GestureDetector(
              onTap: () => context.go('/admin'),
              child: Container(width: 40, height: 40, decoration: BoxDecoration(color: kBg, border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16)),
            ),
            const SizedBox(width: 14),
            const Text('Statistiques', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
          ]),
        ),

        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: kPrimary))
              : RefreshIndicator(
                  onRefresh: _loadStats,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                      // Utilisateurs
                      _sectionTitle('👥 Utilisateurs'),
                      const SizedBox(height: 10),
                      Row(children: [
                        _statCard('Total', '${_stats['total_users']}', Icons.people_rounded, kPrimary),
                        const SizedBox(width: 10),
                        _statCard('Clients', '${_stats['total_clients']}', Icons.person_rounded, const Color(0xFF059669)),
                        const SizedBox(width: 10),
                        _statCard('Vendeurs', '${_stats['total_vendeurs']}', Icons.storefront_rounded, kAccent),
                      ]),
                      const SizedBox(height: 20),

                      // Produits
                      _sectionTitle('📦 Produits'),
                      const SizedBox(height: 10),
                      Row(children: [
                        _statCard('Total', '${_stats['total_produits']}', Icons.inventory_2_rounded, kPrimary),
                        const SizedBox(width: 10),
                        _statCard('Publiés', '${_stats['produits_publies']}', Icons.check_circle_rounded, Colors.green),
                        const SizedBox(width: 10),
                        _statCard('En attente', '${_stats['produits_en_attente']}', Icons.pending_rounded, Colors.orange),
                      ]),
                      const SizedBox(height: 14),

                      // Catégories
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade100)),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text('Répartition par catégorie', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF0F172A))),
                          const SizedBox(height: 14),
                          _catBar('Ebooks', _stats['ebooks'] ?? 0, _stats['total_produits'] ?? 1, kPrimary, Icons.menu_book_rounded),
                          const SizedBox(height: 10),
                          _catBar('Templates', _stats['templates'] ?? 0, _stats['total_produits'] ?? 1, kAccent, Icons.palette_rounded),
                          const SizedBox(height: 10),
                          _catBar('Scripts', _stats['scripts'] ?? 0, _stats['total_produits'] ?? 1, const Color(0xFF059669), Icons.code_rounded),
                        ]),
                      ),
                      const SizedBox(height: 20),

                      // Commandes & Revenus
                      _sectionTitle('💰 Commandes & Revenus'),
                      const SizedBox(height: 10),
                      Row(children: [
                        _statCard('Commandes', '${_stats['total_commandes']}', Icons.shopping_bag_rounded, kPrimary),
                        const SizedBox(width: 10),
                        _statCard('Complètes', '${_stats['commandes_completes']}', Icons.check_circle_rounded, Colors.green),
                      ]),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [kPrimary, kAccent], begin: Alignment.topLeft, end: Alignment.bottomRight),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text('Revenus totaux', style: TextStyle(color: Colors.white70, fontSize: 13)),
                          const SizedBox(height: 6),
                          Text('${_stats['total_revenus']?.toStringAsFixed(0) ?? 0} DZD', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 8),
                          const Text('Commission (10%)', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          Text('${_stats['commission']?.toStringAsFixed(0) ?? 0} DZD', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                        ]),
                      ),
                      const SizedBox(height: 80),
                    ]),
                  ),
                ),
        ),
      ]),
    );
  }

  Widget _sectionTitle(String title) => Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)));

  Widget _statCard(String label, String value, IconData icon, Color color) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey.shade100)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 34, height: 34, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 18)),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
      ]),
    ),
  );

  Widget _catBar(String label, int val, int total, Color color, IconData icon) {
    final pct = total > 0 ? val / total : 0.0;
    return Row(children: [
      Icon(icon, color: color, size: 18),
      const SizedBox(width: 10),
      SizedBox(width: 70, child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)))),
      Expanded(child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(value: pct, backgroundColor: Colors.grey.shade100, valueColor: AlwaysStoppedAnimation(color), minHeight: 8),
      )),
      const SizedBox(width: 10),
      Text('$val', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
    ]);
  }
}