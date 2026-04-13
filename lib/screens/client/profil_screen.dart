import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});
  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  final supabase = Supabase.instance.client;
  Map<String, dynamic>? _user;
  bool _loading = true;

  static const Color kBlue1 = Color(0xFF1565C0);
  static const Color kBlue2 = Color(0xFF1E88E5);
  static const Color kBlueBg = Color(0xFFE3F2FD);

  @override
  void initState() { super.initState(); _loadUser(); }

  Future<void> _loadUser() async {
    try {
      final id = supabase.auth.currentUser?.id;
      if (id == null) return;
      final data = await supabase.from('utilisateurs').select('*').eq('id', id).single();
      if (mounted) setState(() { _user = data; _loading = false; });
    } catch (e) { if (mounted) setState(() => _loading = false); }
  }

  Future<void> _deconnexion() async {
    await supabase.auth.signOut();
    if (!mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildHeader()),
                SliverToBoxAdapter(child: _buildMenu()),
              ],
            ),
    );
  }

  Widget _buildHeader() => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(colors: [kBlue1, kBlue2], begin: Alignment.topLeft, end: Alignment.bottomRight),
      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
    ),
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
        child: Column(
          children: [
            const Text('Mon Profil', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Container(
              width: 90, height: 90,
              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3)),
              child: const Icon(Icons.person, color: kBlue1, size: 50),
            ),
            const SizedBox(height: 12),
            Text(_user?['nom'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(_user?['email'] ?? '', style: const TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
              child: Text(_user?['role']?.toString().toUpperCase() ?? '', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _buildMenu() => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        const SizedBox(height: 8),
        _menuSection('Mon compte', [
          _menuItem(Icons.person_outline, 'Modifier le profil', () {}),
          _menuItem(Icons.shopping_bag_outlined, 'Mes achats', () {}),
          _menuItem(Icons.favorite_outline, 'Ma wishlist', () {}),
          _menuItem(Icons.library_books_outlined, 'Ma bibliothèque', () => context.go('/bibliotheque')),
        ]),
        const SizedBox(height: 16),
        _menuSection('Paramètres', [
          _menuItem(Icons.notifications_outlined, 'Notifications', () => context.go('/notifications')),
          _menuItem(Icons.message_outlined, 'Messages', () => context.go('/messages')),
          _menuItem(Icons.language, 'Langue', () {}),
          _menuItem(Icons.help_outline, 'Aide & Support', () {}),
        ]),
        const SizedBox(height: 16),
        _menuSection('', [
          _menuItem(Icons.logout, 'Se déconnecter', _deconnexion, color: Colors.red),
        ]),
        const SizedBox(height: 80),
      ],
    ),
  );

  Widget _menuSection(String title, List<Widget> items) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (title.isNotEmpty) ...[
        Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1565C0))),
        const SizedBox(height: 8),
      ],
      Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: kBlue1.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 3))]),
        child: Column(children: items),
      ),
    ],
  );

  Widget _menuItem(IconData icon, String label, VoidCallback onTap, {Color? color}) => ListTile(
    leading: Container(
      width: 38, height: 38,
      decoration: BoxDecoration(color: (color ?? kBlue1).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, color: color ?? kBlue1, size: 20),
    ),
    title: Text(label, style: TextStyle(color: color ?? const Color(0xFF1A237E), fontWeight: FontWeight.w500, fontSize: 14)),
    trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
    onTap: onTap,
  );
}
