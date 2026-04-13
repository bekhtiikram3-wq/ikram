import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RetraitsScreen extends StatefulWidget {
  const RetraitsScreen({super.key});
  @override
  State<RetraitsScreen> createState() => _RetraitsScreenState();
}

class _RetraitsScreenState extends State<RetraitsScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _retraits = [];
  double _solde = 0;
  bool _loading = true;

  static const Color kBlue1 = Color(0xFF1565C0);
  static const Color kBlue2 = Color(0xFF1E88E5);
  static const Color kBlueBg = Color(0xFFE3F2FD);

  final _montantController = TextEditingController();
  String _methode = 'ccp_algerie_poste';

  @override
  void initState() { super.initState(); _loadData(); }

  Future<void> _loadData() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;
      final vendeur = await supabase.from('vendeurs').select('solde_dzd').eq('id', userId).single();
      final retraits = await supabase.from('retraits').select('*').eq('vendeur_id', userId).order('demande_le', ascending: false);
      if (mounted) setState(() {
        _solde = (vendeur['solde_dzd'] ?? 0).toDouble();
        _retraits = List<Map<String, dynamic>>.from(retraits);
        _loading = false;
      });
    } catch (e) { if (mounted) setState(() => _loading = false); }
  }

  Future<void> _demanderRetrait() async {
    final montant = double.tryParse(_montantController.text);
    if (montant == null || montant <= 0) return;
    try {
      await supabase.rpc('demander_retrait', params: {'p_montant_dzd': montant, 'p_methode': _methode});
      _montantController.clear();
      Navigator.pop(context);
      _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Demande de retrait envoyée !'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    }
  }

  void _showRetrait() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Demande de retrait', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
              const SizedBox(height: 6),
              Text('Solde disponible: ${_solde.round()} DZD', style: const TextStyle(color: kBlue2, fontWeight: FontWeight.w600)),
              const SizedBox(height: 20),
              TextField(
                controller: _montantController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Montant (DZD)',
                  prefixIcon: const Icon(Icons.account_balance_wallet, color: kBlue1),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  suffix: TextButton(
                    onPressed: () => _montantController.text = _solde.round().toString(),
                    child: const Text('Max', style: TextStyle(color: kBlue1, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Méthode', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              ...['ccp_algerie_poste', 'virement_bancaire', 'dahabia'].map((m) {
                final labels = {'ccp_algerie_poste': 'CCP Algérie Poste', 'virement_bancaire': 'Virement Bancaire', 'dahabia': 'Dahabia'};
                final icons  = {'ccp_algerie_poste': Icons.mail_outline, 'virement_bancaire': Icons.account_balance, 'dahabia': Icons.credit_card};
                return GestureDetector(
                  onTap: () => setModal(() => _methode = m),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _methode == m ? kBlueBg : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _methode == m ? kBlue1 : Colors.grey.shade300, width: _methode == m ? 2 : 1),
                    ),
                    child: Row(children: [
                      Icon(icons[m], color: _methode == m ? kBlue1 : Colors.grey.shade500),
                      const SizedBox(width: 12),
                      Text(labels[m]!, style: TextStyle(fontWeight: _methode == m ? FontWeight.bold : FontWeight.normal, color: _methode == m ? kBlue1 : const Color(0xFF1A237E))),
                      const Spacer(),
                      if (_methode == m) const Icon(Icons.check_circle, color: kBlue1, size: 20),
                    ]),
                  ),
                );
              }),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _demanderRetrait,
                  style: ElevatedButton.styleFrom(backgroundColor: kBlue1, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  child: const Text('Confirmer le retrait', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: kBlue1,
        title: const Text('Retraits', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: _loading ? const Center(child: CircularProgressIndicator()) : Column(
        children: [
          // Solde header
          Container(
            color: kBlue1,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(16)),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Solde disponible', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text('${_solde.round()} DZD', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                  const Text('Min. retrait: 5 000 DZD', style: TextStyle(color: Colors.white60, fontSize: 11)),
                ]),
                ElevatedButton.icon(
                  onPressed: _showRetrait,
                  icon: const Icon(Icons.arrow_upward, color: kBlue1, size: 18),
                  label: const Text('Retirer', style: TextStyle(color: kBlue1, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                ),
              ]),
            ),
          ),
          // Historique
          Expanded(
            child: _retraits.isEmpty
                ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Container(width: 100, height: 100, decoration: const BoxDecoration(color: kBlueBg, shape: BoxShape.circle), child: const Icon(Icons.account_balance_wallet_outlined, size: 50, color: kBlue2)),
                    const SizedBox(height: 16),
                    const Text('Aucun retrait effectué', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
                  ]))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _retraits.length,
                    itemBuilder: (_, i) {
                      final r = _retraits[i];
                      final statut = r['statut'] ?? '';
                      final color = statut == 'traite' ? Colors.green : statut == 'rejete' ? Colors.red : Colors.orange;
                      final icon  = statut == 'traite' ? Icons.check_circle : statut == 'rejete' ? Icons.cancel : Icons.pending;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                        child: Row(children: [
                          Container(width: 46, height: 46, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 22)),
                          const SizedBox(width: 14),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('${r['montant_dzd'] ?? 0} DZD', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1A237E))),
                            Text(r['methode'] ?? '', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                          ])),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                            child: Text(statut.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
