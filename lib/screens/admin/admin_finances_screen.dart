import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

class AdminFinancesScreen extends StatefulWidget {
  const AdminFinancesScreen({super.key});
  @override
  State<AdminFinancesScreen> createState() => _AdminFinancesScreenState();
}

class _AdminFinancesScreenState extends State<AdminFinancesScreen> with SingleTickerProviderStateMixin {
  final supabase = Supabase.instance.client;
  Map<String, dynamic> _stats = {};
  List<Map<String, dynamic>> _transactions = [];
  List<Map<String, dynamic>> _retraits = [];
  bool _loading = true;
  late TabController _tabController;

  static const kPrimary = Color(0xFF2563EB);
  static const kAccent  = Color(0xFF7C3AED);
  static const kBg      = Color(0xFFF8FAFC);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() { _tabController.dispose(); super.dispose(); }

  Future<void> _loadData() async {
    try {
      final commandes = await supabase.from('commandes').select('id, statut, montant_total_dzd, created_at, client_id');
      final retraits  = await supabase.from('retraits').select('id, montant_dzd, statut, methode, demande_le, vendeur_id, vendeurs(nom_boutique)').order('demande_le', ascending: false);

      double totalRevenus = 0;
      double totalCommission = 0;
      int totalCommandes = commandes.length;

      for (var c in commandes) {
        final montant = (c['montant_total_dzd'] ?? 0).toDouble();
        totalRevenus += montant;
        totalCommission += montant * 0.1;
      }

      if (mounted) setState(() {
        _stats = {
          'total_revenus': totalRevenus,
          'total_commission': totalCommission,
          'total_commandes': totalCommandes,
          'retraits_en_attente': retraits.where((r) => r['statut'] == 'en_attente').length,
        };
        _transactions = List<Map<String, dynamic>>.from(commandes);
        _retraits = List<Map<String, dynamic>>.from(retraits);
        _loading = false;
      });
    } catch (e) { if (mounted) setState(() => _loading = false); }
  }

  Future<void> _traiterRetrait(String id, String statut) async {
    await supabase.from('retraits').update({'statut': statut}).eq('id', id);
    _loadData();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(statut == 'traite' ? '✅ Retrait traité !' : '❌ Retrait rejeté'),
      backgroundColor: statut == 'traite' ? Colors.green.shade400 : Colors.red.shade400,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Column(children: [
        // Header
        Container(
          color: Colors.white,
          padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 12, 20, 0),
          child: Column(children: [
            Row(children: [
              GestureDetector(
                onTap: () => context.go('/admin'),
                child: Container(width: 40, height: 40, decoration: BoxDecoration(color: kBg, border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16)),
              ),
              const SizedBox(width: 14),
              const Text('Finances', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
            ]),
            const SizedBox(height: 16),
            // Stats
            if (!_loading) Row(children: [
              _statCard('Revenus', '${_stats['total_revenus']?.toStringAsFixed(0)} DZD', Icons.payments_rounded, kPrimary),
              const SizedBox(width: 10),
              _statCard('Commission', '${_stats['total_commission']?.toStringAsFixed(0)} DZD', Icons.percent_rounded, kAccent),
            ]),
            const SizedBox(height: 10),
            if (!_loading) Row(children: [
              _statCard('Commandes', '${_stats['total_commandes']}', Icons.shopping_bag_rounded, const Color(0xFF059669)),
              const SizedBox(width: 10),
              _statCard('Retraits', '${_stats['retraits_en_attente']} en attente', Icons.account_balance_rounded, const Color(0xFFDC2626), alert: (_stats['retraits_en_attente'] ?? 0) > 0),
            ]),
            const SizedBox(height: 12),
            TabBar(
              controller: _tabController,
              labelColor: kPrimary,
              unselectedLabelColor: Colors.grey.shade400,
              indicatorColor: kPrimary,
              tabs: const [Tab(text: 'Transactions'), Tab(text: 'Retraits')],
            ),
          ]),
        ),

        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: kPrimary))
              : TabBarView(
                  controller: _tabController,
                  children: [
                    // Transactions
                    _transactions.isEmpty
                        ? Center(child: Text('Aucune transaction', style: TextStyle(color: Colors.grey.shade400)))
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _transactions.length,
                            itemBuilder: (_, i) {
                              final t = _transactions[i];
                              final statut = t['statut'] ?? '';
                              final color = statut == 'complete' ? Colors.green : statut == 'en_attente' ? Colors.orange : Colors.red;
                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey.shade100)),
                                child: Row(children: [
                                  Container(width: 44, height: 44, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.receipt_long_rounded, color: color, size: 22)),
                                  const SizedBox(width: 12),
                                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text('Commande #${t['id'].toString().substring(0, 8)}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF0F172A))),
                                    Text(statut.toUpperCase(), style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
                                  ])),
                                  Text('${t['montant_total_dzd'] ?? 0} DZD', style: const TextStyle(fontWeight: FontWeight.w800, color: kPrimary, fontSize: 14)),
                                ]),
                              );
                            },
                          ),

                    // Retraits
                    _retraits.isEmpty
                        ? Center(child: Text('Aucun retrait', style: TextStyle(color: Colors.grey.shade400)))
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _retraits.length,
                            itemBuilder: (_, i) {
                              final r = _retraits[i];
                              final statut = r['statut'] ?? '';
                              final vendeur = r['vendeurs'] as Map<String, dynamic>? ?? {};
                              final color = statut == 'traite' ? Colors.green : statut == 'en_attente' ? Colors.orange : Colors.red;
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey.shade100)),
                                child: Column(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Row(children: [
                                      Container(width: 44, height: 44, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.account_balance_wallet_rounded, color: color, size: 22)),
                                      const SizedBox(width: 12),
                                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                        Text(vendeur['nom_boutique'] ?? '', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF0F172A))),
                                        Text(r['methode'] ?? '', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                                        Text('${r['montant_dzd'] ?? 0} DZD', style: const TextStyle(color: kPrimary, fontWeight: FontWeight.w800, fontSize: 14)),
                                      ])),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                        child: Text(statut.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700)),
                                      ),
                                    ]),
                                  ),
                                  if (statut == 'en_attente')
                                    Container(
                                      decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey.shade100))),
                                      child: Row(children: [
                                        Expanded(child: TextButton.icon(
                                          onPressed: () => _traiterRetrait(r['id'], 'traite'),
                                          icon: const Icon(Icons.check_circle_outline, color: Colors.green, size: 18),
                                          label: const Text('Approuver', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w700)),
                                        )),
                                        Container(width: 1, height: 40, color: Colors.grey.shade100),
                                        Expanded(child: TextButton.icon(
                                          onPressed: () => _traiterRetrait(r['id'], 'rejete'),
                                          icon: const Icon(Icons.cancel_outlined, color: Colors.red, size: 18),
                                          label: const Text('Rejeter', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700)),
                                        )),
                                      ]),
                                    ),
                                ]),
                              );
                            },
                          ),
                  ],
                ),
        ),
      ]),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color, {bool alert = false}) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: alert ? color.withOpacity(0.4) : Colors.grey.shade100, width: alert ? 1.5 : 1),
      ),
      child: Row(children: [
        Container(width: 36, height: 36, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 18)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: alert ? color : const Color(0xFF0F172A)), maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
        ])),
      ]),
    ),
  );
}