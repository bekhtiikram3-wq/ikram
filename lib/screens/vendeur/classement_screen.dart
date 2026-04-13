import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClassementScreen extends StatefulWidget {
  const ClassementScreen({super.key});
  @override
  State<ClassementScreen> createState() => _ClassementScreenState();
}

class _ClassementScreenState extends State<ClassementScreen> with SingleTickerProviderStateMixin {
  final supabase = Supabase.instance.client;
  Map<String, dynamic>? _classement;
  bool _loading = true;
  late TabController _tabController;

  static const Color kBlue1 = Color(0xFF1565C0);
  static const Color kBlue2 = Color(0xFF1E88E5);
  static const Color kBlueBg = Color(0xFFE3F2FD);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadClassement();
  }

  @override
  void dispose() { _tabController.dispose(); super.dispose(); }

  Future<void> _loadClassement() async {
    try {
      final data = await supabase.rpc('get_mon_classement');
      if (mounted) setState(() { _classement = data; _loading = false; });
    } catch (e) { if (mounted) setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    final actuel = _classement?['classement_actuel'] ?? {};
    final top10  = _classement?['top10_cette_semaine'] as List? ?? [];
    final histo  = _classement?['historique_8_semaines'] as List? ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: kBlue1,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFF0D47A1), kBlue2], begin: Alignment.topLeft, end: Alignment.bottomRight),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Mon Classement', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                          _rankStat('Rang', actuel['rang'] != null ? '#${actuel['rang']}' : '-'),
                          _rankStat('Sur', '${actuel['total_vendeurs'] ?? 0}'),
                          _rankStat('Ventes', '${actuel['ventes_semaine'] ?? 0}'),
                          _rankStat('Top %', '${actuel['pourcentage'] ?? 0}%'),
                        ]),
                        if (actuel['badge_top10'] == true) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(20)),
                            child: const Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(Icons.emoji_events, color: Colors.white, size: 16),
                              SizedBox(width: 6),
                              Text('Badge Top 10 !', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ]),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              indicatorColor: Colors.white,
              tabs: const [Tab(text: 'Top 10 Plateforme'), Tab(text: 'Mon Historique')],
            ),
          ),
        ],
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabController,
                children: [
                  // Top 10
                  top10.isEmpty
                      ? Center(child: Text('Pas encore de classement cette semaine', style: TextStyle(color: Colors.grey.shade500)))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: top10.length,
                          itemBuilder: (_, i) {
                            final v = top10[i];
                            final estMoi = v['est_moi'] == true;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: estMoi ? kBlueBg : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: estMoi ? Border.all(color: kBlue1, width: 1.5) : null,
                              ),
                              child: Row(children: [
                                SizedBox(width: 36, child: Text(
                                  i == 0 ? '🥇' : i == 1 ? '🥈' : i == 2 ? '🥉' : '#${i+1}',
                                  style: TextStyle(fontSize: i < 3 ? 22 : 16, fontWeight: FontWeight.bold, color: kBlue1),
                                  textAlign: TextAlign.center,
                                )),
                                const SizedBox(width: 12),
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Row(children: [
                                    Text(v['nom_boutique'] ?? '', style: TextStyle(fontWeight: FontWeight.bold, color: estMoi ? kBlue1 : const Color(0xFF1A237E))),
                                    if (estMoi) ...[const SizedBox(width: 6), Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: kBlue1, borderRadius: BorderRadius.circular(6)), child: const Text('Moi', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)))],
                                  ]),
                                  Text('${v['ventes'] ?? 0} ventes · ${v['revenus_dzd'] ?? 0} DZD', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                                ])),
                                if (v['badge_top10'] == true) const Icon(Icons.emoji_events, color: Colors.amber, size: 20),
                              ]),
                            );
                          }),

                  // Historique
                  histo.isEmpty
                      ? Center(child: Text('Pas encore d\'historique', style: TextStyle(color: Colors.grey.shade500)))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: histo.length,
                          itemBuilder: (_, i) {
                            final h = histo[i];
                            final evo = h['evolution'] ?? 0;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                              child: Row(children: [
                                Container(width: 50, height: 50, decoration: BoxDecoration(color: kBlueBg, borderRadius: BorderRadius.circular(12)), child: Center(child: Text('#${h['rang'] ?? '?'}', style: const TextStyle(fontWeight: FontWeight.bold, color: kBlue1, fontSize: 16)))),
                                const SizedBox(width: 14),
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text('Semaine du ${h['semaine']?.toString().substring(0, 10) ?? ''}', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                                  Text('${h['ventes'] ?? 0} ventes · ${h['revenus_dzd'] ?? 0} DZD', style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1A237E))),
                                ])),
                                Row(children: [
                                  Icon(evo > 0 ? Icons.trending_up : evo < 0 ? Icons.trending_down : Icons.trending_flat, color: evo > 0 ? Colors.green : evo < 0 ? Colors.red : Colors.grey, size: 20),
                                  Text('${evo > 0 ? '+' : ''}$evo', style: TextStyle(color: evo > 0 ? Colors.green : evo < 0 ? Colors.red : Colors.grey, fontWeight: FontWeight.bold, fontSize: 13)),
                                ]),
                              ]),
                            );
                          }),
                ],
              ),
      ),
    );
  }

  Widget _rankStat(String label, String val) => Column(children: [
    Text(val, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
    Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
  ]);
}
