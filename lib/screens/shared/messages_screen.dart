import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});
  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _conversations = [];
  bool _loading = true;

  static const Color kBlue1 = Color(0xFF1565C0);
  static const Color kBlue2 = Color(0xFF1E88E5);
  static const Color kBlueBg = Color(0xFFE3F2FD);

  @override
  void initState() { super.initState(); _loadConversations(); }

  Future<void> _loadConversations() async {
    try {
      final data = await supabase.rpc('get_mes_conversations');
      if (mounted) setState(() { _conversations = List<Map<String, dynamic>>.from(data); _loading = false; });
    } catch (e) { if (mounted) setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: kBlue1,
        title: const Text('Messages', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [IconButton(icon: const Icon(Icons.edit_outlined, color: Colors.white), onPressed: () {})],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _conversations.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(width: 100, height: 100, decoration: const BoxDecoration(color: kBlueBg, shape: BoxShape.circle), child: const Icon(Icons.chat_bubble_outline, size: 50, color: kBlue2)),
                  const SizedBox(height: 16),
                  const Text('Aucune conversation', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
                  const SizedBox(height: 8),
                  Text('Contactez un vendeur depuis une fiche produit', style: TextStyle(color: Colors.grey.shade500, fontSize: 13), textAlign: TextAlign.center),
                ]))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _conversations.length,
                  itemBuilder: (_, i) {
                    final c = _conversations[i];
                    final nonLus = (c['messages_non_lus'] ?? 0) as int;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: kBlue1.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 3))]),
                      child: Row(children: [
                        Stack(children: [
                          Container(
                            width: 50, height: 50,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [kBlue1, kBlue2]),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(child: Text(
                              (c['interlocuteur_nom'] ?? 'U').substring(0, 1).toUpperCase(),
                              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                            )),
                          ),
                          if (nonLus > 0)
                            Positioned(
                              right: 0, top: 0,
                              child: Container(
                                width: 18, height: 18,
                                decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                                child: Center(child: Text('$nonLus', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold))),
                              ),
                            ),
                        ]),
                        const SizedBox(width: 14),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(c['interlocuteur_nom'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A237E), fontSize: 14)),
                          if (c['nom_boutique'] != null) Text(c['nom_boutique'], style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                          const SizedBox(height: 4),
                          Text(c['dernier_message'] ?? '', style: TextStyle(color: Colors.grey.shade600, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ])),
                      ]),
                    );
                  },
                ),
    );
  }
}
