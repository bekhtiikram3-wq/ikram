import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _notifs = [];
  bool _loading = true;

  static const Color kBlue1 = Color(0xFF1565C0);
  static const Color kBlue2 = Color(0xFF1E88E5);

  @override
  void initState() { super.initState(); _loadNotifs(); }

  Future<void> _loadNotifs() async {
    try {
      final data = await supabase.rpc('get_mes_notifications');
      if (mounted) setState(() { _notifs = List<Map<String, dynamic>>.from(data); _loading = false; });
    } catch (e) { if (mounted) setState(() => _loading = false); }
  }

  IconData _iconForType(String? type) {
    switch (type) {
      case 'nouvelle_vente': return Icons.shopping_bag;
      case 'paiement_succes': return Icons.check_circle;
      case 'paiement_echec': return Icons.cancel;
      case 'produit_valide': return Icons.verified;
      case 'produit_rejete': return Icons.block;
      case 'nouveau_avis': return Icons.star;
      case 'message': return Icons.message;
      case 'classement_monte': return Icons.trending_up;
      case 'badge_top10': return Icons.emoji_events;
      default: return Icons.notifications;
    }
  }

  Color _colorForType(String? type) {
    switch (type) {
      case 'nouvelle_vente': return Colors.green;
      case 'paiement_succes': return Colors.green;
      case 'paiement_echec': return Colors.red;
      case 'produit_valide': return kBlue1;
      case 'produit_rejete': return Colors.red;
      case 'nouveau_avis': return Colors.amber;
      case 'classement_monte': return Colors.orange;
      case 'badge_top10': return Colors.purple;
      default: return kBlue2;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: kBlue1,
        title: const Text('Notifications', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () async { await supabase.rpc('marquer_toutes_lues'); _loadNotifs(); },
            child: const Text('Tout lire', style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _notifs.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(width: 100, height: 100, decoration: const BoxDecoration(color: Color(0xFFE3F2FD), shape: BoxShape.circle), child: const Icon(Icons.notifications_none, size: 50, color: kBlue2)),
                  const SizedBox(height: 16),
                  const Text('Aucune notification', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
                ]))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _notifs.length,
                  itemBuilder: (_, i) {
                    final n = _notifs[i];
                    final color = _colorForType(n['type']);
                    return GestureDetector(
                      onTap: () async { await supabase.rpc('marquer_notif_lue', params: {'p_notif_id': n['id']}); _loadNotifs(); },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: n['est_lu'] == true ? Colors.white : const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: n['est_lu'] == true ? Colors.transparent : kBlue1.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 46, height: 46,
                              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                              child: Icon(_iconForType(n['type']), color: color, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(n['titre'] ?? '', style: TextStyle(fontWeight: n['est_lu'] == true ? FontWeight.normal : FontWeight.bold, color: const Color(0xFF1A237E), fontSize: 14)),
                                const SizedBox(height: 3),
                                Text(n['message'] ?? '', style: TextStyle(color: Colors.grey.shade600, fontSize: 12), maxLines: 2),
                              ],
                            )),
                            if (n['est_lu'] != true)
                              Container(width: 8, height: 8, decoration: const BoxDecoration(color: kBlue1, shape: BoxShape.circle)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
