import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

class VendeurDashboardScreen extends StatefulWidget {
  const VendeurDashboardScreen({super.key});
  @override
  State<VendeurDashboardScreen> createState() => _VendeurDashboardScreenState();
}

class _VendeurDashboardScreenState extends State<VendeurDashboardScreen> {
  final supabase = Supabase.instance.client;
  Map<String, dynamic>? _dashboard;
  bool _loading = true;

  static const Color kBlue1 = Color(0xFF1565C0);
  static const Color kBlue2 = Color(0xFF1E88E5);
  static const Color kBlueBg = Color(0xFFE3F2FD);

  @override
  void initState() { super.initState(); _loadDashboard(); }

  Future<void> _loadDashboard() async {
    try {
      final data = await supabase.rpc('get_dashboard_vendeur');
      if (mounted) setState(() { _dashboard = data; _loading = false; });
    } catch (e) { if (mounted) setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboard,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader()),
                  SliverToBoxAdapter(child: _buildStatsCards()),
                  SliverToBoxAdapter(child: _buildGraphique()),
                  SliverToBoxAdapter(child: _buildTopProduits()),
                  SliverToBoxAdapter(child: _buildDernieresVentes()),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    final boutique = _dashboard?['boutique'] ?? {};
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [kBlue1, kBlue2], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Ma Boutique', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    Text(boutique['nom_boutique'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    if (boutique['est_verifie'] == true)
                      const Row(children: [
                        Icon(Icons.verified, color: Colors.lightBlueAccent, size: 14),
                        SizedBox(width: 4),
                        Text('Vendeur vérifié', style: TextStyle(color: Colors.lightBlueAccent, fontSize: 11)),
                      ]),
                  ]),
                  Row(children: [
                    GestureDetector(
                      onTap: () => context.go('/notifications'),
                      child: Container(
                        width: 42, height: 42,
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.notifications_outlined, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => context.go('/vendeur/ajouter'),
                      child: Container(
                        width: 42, height: 42,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.add, color: kBlue1),
                      ),
                    ),
                  ]),
                ],
              ),
              const SizedBox(height: 20),
              // Solde principal
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.3))),
                child: Column(children: [
                  const Text('Solde disponible', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 6),
                  Text('${boutique['solde_dzd'] ?? 0} DZD', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => context.go('/vendeur/retraits'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: kBlue1, minimumSize: const Size(140, 36), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    child: const Text('Retirer', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    final today = _dashboard?['aujourd_hui'] ?? {};
    final week  = _dashboard?['semaine'] ?? {};
    final month = _dashboard?['mois'] ?? {};
    final prods = _dashboard?['produits'] ?? {};

    final stats = [
      {'label': "Aujourd'hui", 'ventes': today['ventes'] ?? 0, 'revenus': today['revenus_dzd'] ?? 0, 'color': const Color(0xFF1565C0), 'icon': Icons.today},
      {'label': '7 jours',     'ventes': week['ventes']  ?? 0, 'revenus': week['revenus_dzd']  ?? 0, 'color': const Color(0xFF6A1B9A), 'icon': Icons.date_range},
      {'label': '30 jours',    'ventes': month['ventes'] ?? 0, 'revenus': month['revenus_dzd'] ?? 0, 'color': const Color(0xFF00695C), 'icon': Icons.calendar_month},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Performances', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
          const SizedBox(height: 12),
          Row(
            children: stats.map((s) {
              final color = s['color'] as Color;
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [color, color.withOpacity(0.7)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(s['icon'] as IconData, color: Colors.white, size: 20),
                      const SizedBox(height: 8),
                      Text('${s['ventes']}', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      const Text('ventes', style: TextStyle(color: Colors.white70, fontSize: 10)),
                      const SizedBox(height: 4),
                      Text('${s['revenus']} DZ', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                      Text(s['label'] as String, style: const TextStyle(color: Colors.white60, fontSize: 9)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          // Produits stats
          Row(children: [
            _produitStat('Publiés', '${prods['total_publies'] ?? 0}', Colors.green),
            const SizedBox(width: 10),
            _produitStat('En attente', '${prods['en_attente'] ?? 0}', Colors.orange),
            const SizedBox(width: 10),
            _produitStat('Brouillons', '${prods['total_brouillons'] ?? 0}', Colors.grey),
          ]),
        ],
      ),
    );
  }

  Widget _produitStat(String label, String val, Color color) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.3))),
      child: Column(children: [
        Text(val, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
      ]),
    ),
  );

  Widget _buildGraphique() {
    final data = (_dashboard?['graphique_7j'] as List? ?? []);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: kBlue1.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ventes — 7 derniers jours', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
            const SizedBox(height: 16),
            data.isEmpty
                ? Center(child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text('Pas encore de ventes', style: TextStyle(color: Colors.grey.shade400)),
                  ))
                : SizedBox(
                    height: 120,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: data.map<Widget>((d) {
                        final ventes = (d['ventes'] ?? 0).toDouble();
                        final maxVal = data.fold<double>(1, (m, e) => (e['ventes'] ?? 0).toDouble() > m ? (e['ventes'] ?? 0).toDouble() : m);
                        final height = maxVal > 0 ? (ventes / maxVal * 100) : 0.0;
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text('${ventes.round()}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: kBlue1)),
                            const SizedBox(height: 4),
                            Container(
                              width: 28,
                              height: height.clamp(8, 100),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [kBlue1, kBlue2], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              d['date'] != null ? d['date'].toString().substring(5, 10) : '',
                              style: TextStyle(fontSize: 9, color: Colors.grey.shade500),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopProduits() {
    final top = (_dashboard?['top_produits'] as List? ?? []);
    if (top.isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Top Produits', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
            GestureDetector(onTap: () => context.go('/vendeur/produits'), child: const Text('Voir tout', style: TextStyle(color: kBlue2, fontWeight: FontWeight.w600, fontSize: 13))),
          ]),
          const SizedBox(height: 12),
          ...top.take(3).toList().asMap().entries.map((e) {
            final i = e.key;
            final p = e.value;
            const medals = ['🥇', '🥈', '🥉'];
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: kBlue1.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 3))]),
              child: Row(children: [
                Text(i < 3 ? medals[i] : '${i+1}', style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(p['titre'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A237E), fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text('${p['nombre_ventes'] ?? 0} ventes · ${p['revenus_dzd'] ?? 0} DZD', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                ])),
                Row(children: [const Icon(Icons.star, color: Colors.amber, size: 14), Text('${p['note_moyenne'] ?? 0}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12))]),
              ]),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDernieresVentes() {
    final ventes = (_dashboard?['dernieres_ventes'] as List? ?? []);
    if (ventes.isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Dernières ventes', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: kBlue1.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 3))]),
            child: Column(
              children: ventes.take(5).toList().asMap().entries.map((e) {
                final v = e.value;
                return ListTile(
                  leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: kBlueBg, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.check_circle_outline, color: kBlue1, size: 20)),
                  title: Text(v['produit'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF1A237E)), maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text('Revenu: ${v['revenu_dzd'] ?? 0} DZD', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                  trailing: Text('+${v['montant_dzd'] ?? 0}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
