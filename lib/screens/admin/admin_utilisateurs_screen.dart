import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

class AdminUtilisateursScreen extends StatefulWidget {
  const AdminUtilisateursScreen({super.key});
  @override
  State<AdminUtilisateursScreen> createState() => _AdminUtilisateursScreenState();
}

class _AdminUtilisateursScreenState extends State<AdminUtilisateursScreen> with SingleTickerProviderStateMixin {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _users = [];
  bool _loading = true;
  late TabController _tabController;
  String _role = 'client';

  static const kPrimary = Color(0xFF2563EB);
  static const kAccent  = Color(0xFF7C3AED);
  static const kBg      = Color(0xFFF8FAFC);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() => _role = _tabController.index == 0 ? 'client' : 'vendeur');
      _loadUsers();
    });
    _loadUsers();
  }

  @override
  void dispose() { _tabController.dispose(); super.dispose(); }

  Future<void> _loadUsers() async {
    setState(() => _loading = true);
    try {
      final data = await supabase
          .from('utilisateurs')
          .select('id, nom, email, role, statut, date_inscription, telephone')
          .eq('role', _role)
          .order('date_inscription', ascending: false);
      if (mounted) setState(() { _users = List<Map<String, dynamic>>.from(data); _loading = false; });
    } catch (e) { if (mounted) setState(() => _loading = false); }
  }

  Future<void> _toggleStatut(String id, String statutActuel) async {
    final newStatut = statutActuel == 'actif' ? 'suspendu' : 'actif';
    await supabase.from('utilisateurs').update({'statut': newStatut}).eq('id', id);
    _loadUsers();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(newStatut == 'actif' ? '✅ Compte activé' : '🚫 Compte suspendu'),
      backgroundColor: newStatut == 'actif' ? Colors.green.shade400 : Colors.red.shade400,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  Future<void> _verifierVendeur(String id) async {
    await supabase.from('vendeurs').update({'est_verifie': true}).eq('id', id);
    _loadUsers();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('✅ Vendeur vérifié !'),
      backgroundColor: Colors.green.shade400,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Column(children: [
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
              const Text('Utilisateurs', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: kPrimary.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
                child: Text('${_users.length}', style: const TextStyle(color: kPrimary, fontWeight: FontWeight.w700)),
              ),
            ]),
            const SizedBox(height: 12),
            TabBar(
              controller: _tabController,
              labelColor: kPrimary,
              unselectedLabelColor: Colors.grey.shade400,
              indicatorColor: kPrimary,
              tabs: const [Tab(text: 'Clients'), Tab(text: 'Vendeurs')],
            ),
          ]),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: kPrimary))
              : _users.isEmpty
                  ? Center(child: Text('Aucun utilisateur', style: TextStyle(color: Colors.grey.shade400)))
                  : RefreshIndicator(
                      onRefresh: _loadUsers,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _users.length,
                        itemBuilder: (_, i) => _buildUserCard(_users[i]),
                      ),
                    ),
        ),
      ]),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> u) {
    final statut = u['statut'] ?? 'actif';
    final isActif = statut == 'actif';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade100)),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: isActif ? [kPrimary, kAccent] : [Colors.grey.shade400, Colors.grey.shade500]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: Text(
                (u['nom'] ?? 'U').isNotEmpty ? (u['nom'] ?? 'U')[0].toUpperCase() : 'U',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
              )),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(u['nom'] ?? '', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF0F172A))),
              Text(u['email'] ?? '', style: TextStyle(color: Colors.grey.shade500, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isActif ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(statut.toUpperCase(), style: TextStyle(color: isActif ? Colors.green : Colors.red, fontSize: 10, fontWeight: FontWeight.w700)),
              ),
            ])),
          ]),
        ),
        Container(
          decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey.shade100))),
          child: Row(children: [
            Expanded(child: TextButton.icon(
              onPressed: () => _toggleStatut(u['id'], statut),
              icon: Icon(isActif ? Icons.block_rounded : Icons.check_circle_outline, color: isActif ? Colors.red : Colors.green, size: 18),
              label: Text(isActif ? 'Suspendre' : 'Activer', style: TextStyle(color: isActif ? Colors.red : Colors.green, fontWeight: FontWeight.w700)),
            )),
            if (_role == 'vendeur') ...[
              Container(width: 1, height: 40, color: Colors.grey.shade100),
              Expanded(child: TextButton.icon(
                onPressed: () => _verifierVendeur(u['id']),
                icon: const Icon(Icons.verified_rounded, color: kPrimary, size: 18),
                label: const Text('Vérifier', style: TextStyle(color: kPrimary, fontWeight: FontWeight.w700)),
              )),
            ],
          ]),
        ),
      ]),
    );
  }
}