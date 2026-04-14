import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});
  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
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
      final users     = await supabase.from('utilisateurs').select('id, role, statut');
      final produits  = await supabase.from('produits').select('id, statut, prix_dzd');
      final commandes = await supabase.from('commandes').select('id, statut, montant_total_dzd');

      final totalClients   = users.where((u) => u['role'] == 'client').length;
      final totalVendeurs  = users.where((u) => u['role'] == 'vendeur').length;
      final totalProduits  = produits.length;
      final enAttente      = produits.where((p) => p['statut'] == 'en_attente').length;
      final totalCommandes = commandes.length;
      final revenus        = commandes.fold<double>(0, (sum, c) => sum + ((c['montant_total_dzd'] ?? 0) as num).toDouble());

      if (mounted) setState(() {
        _stats = {
          'total_clients':   totalClients,
          'total_vendeurs':  totalVendeurs,
          'total_produits':  totalProduits,
          'en_attente':      enAttente,
          'total_commandes': totalCommandes,
          'revenus':         revenus,
        };
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: kPrimary))
          : RefreshIndicator(
              onRefresh: _loadStats,
              child: CustomScrollView(slivers: [
                SliverToBoxAdapter(child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [kPrimary, kAccent], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
                  ),
                  padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 16, 20, 28),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Panel Admin', style: TextStyle(color: Colors.white70, fontSize: 13)),
                        const Text('DigitalStore DZ', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                      ]),
                      Container(width: 44, height: 44, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 24)),
                    ]),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.3))),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text('Revenus totaux', style: TextStyle(color: Colors.white70, fontSize: 13)),
                          const SizedBox(height: 4),
                          Text('${_stats['revenus']?.toStringAsFixed(0) ?? 0} DZD', style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
                        ]),
                        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                          const Text('Commandes', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          Text('${_stats['total_commandes'] ?? 0}', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
                        ]),
                      ]),
                    ),
                  ]),
                )),

                SliverToBoxAdapter(child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Vue d\'ensemble', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                    const SizedBox(height: 14),
                    Row(children: [
                      _statCard('Clients', '${_stats['total_clients'] ?? 0}', Icons.people_rounded, kPrimary),
                      const SizedBox(width: 12),
                      _statCard('Vendeurs', '${_stats['total_vendeurs'] ?? 0}', Icons.storefront_rounded, kAccent),
                    ]),
                    const SizedBox(height: 12),
                    Row(children: [
                      _statCard('Produits', '${_stats['total_produits'] ?? 0}', Icons.inventory_2_rounded, const Color(0xFF059669)),
                      const SizedBox(width: 12),
                      _statCard('En attente', '${_stats['en_attente'] ?? 0}', Icons.pending_rounded, const Color(0xFFDC2626), alert: (_stats['en_attente'] ?? 0) > 0),
                    ]),
                  ]),
                )),

                SliverToBoxAdapter(child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Actions rapides', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                    const SizedBox(height: 14),
                    _actionCard(Icons.pending_actions_rounded, 'Valider les produits', '${_stats['en_attente'] ?? 0} produit(s) en attente', const Color(0xFFDC2626), () => context.go('/admin/produits'), urgent: (_stats['en_attente'] ?? 0) > 0),
                    const SizedBox(height: 10),
                    _actionCard(Icons.people_rounded, 'Gérer les utilisateurs', 'Clients et vendeurs', kPrimary, () => context.go('/admin/utilisateurs')),
                    const SizedBox(height: 10),
                    _actionCard(Icons.account_balance_rounded, 'Finances & Commissions', 'Transactions et retraits', const Color(0xFF059669), () => context.go('/admin/finances')),
                    const SizedBox(height: 10),
                    // ✅ Bouton stats corrigé
                    _actionCard(Icons.bar_chart_rounded, 'Statistiques', 'Analytique de la plateforme', kAccent, () => context.go('/admin/stats')),
                  ]),
                )),

                if ((_stats['en_attente'] ?? 0) > 0)
                  SliverToBoxAdapter(child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFFCA5A5))),
                      child: Row(children: [
                        const Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 28),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text('Action requise !', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFFDC2626), fontSize: 14)),
                          Text('${_stats['en_attente']} produit(s) attendent votre validation', style: const TextStyle(color: Color(0xFF991B1B), fontSize: 12)),
                        ])),
                        GestureDetector(
                          onTap: () => context.go('/admin/produits'),
                          child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: const Color(0xFFDC2626), borderRadius: BorderRadius.circular(10)), child: const Text('Valider', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12))),
                        ),
                      ]),
                    ),
                  )),

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ]),
            ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color, {bool alert = false}) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: alert ? color.withOpacity(0.5) : Colors.grey.shade100, width: alert ? 1.5 : 1)),
      child: Row(children: [
        Container(width: 44, height: 44, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 22)),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: alert ? color : const Color(0xFF0F172A))),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
        ]),
      ]),
    ),
  );

  Widget _actionCard(IconData icon, String title, String subtitle, Color color, VoidCallback onTap, {bool urgent = false}) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: urgent ? color.withOpacity(0.4) : Colors.grey.shade100, width: urgent ? 1.5 : 1)),
      child: Row(children: [
        Container(width: 46, height: 46, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 22)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF0F172A))),
          Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
        ])),
        Icon(Icons.chevron_right_rounded, color: Colors.grey.shade300, size: 22),
      ]),
    ),
  );
}