import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:animate_do/animate_do.dart';
import '../../app_colors.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  final supabase = Supabase.instance.client;
  Map<String, dynamic>? _userData;
  int _achatsCount = 0;
  int _enAttenteCount = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId != null) {
        final user = await supabase
            .from('utilisateurs')
            .select('*')
            .eq('id', userId)
            .single();

        final achats = await supabase
            .from('achats')
            .select('id')
            .eq('utilisateur_id', userId);

        final commandes = await supabase
            .from('commandes')
            .select('id')
            .eq('utilisateur_id', userId)
            .eq('statut', 'en_attente');

        if (mounted) {
          setState(() {
            _userData = user;
            _achatsCount = achats.length;
            _enAttenteCount = commandes.length;
            _loading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    await supabase.auth.signOut();
    if (mounted) context.go('/login');
  }

  void _showEditProfile() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Modifier le profil', style: AppColors.headingMedium(color: Colors.black)),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Nom complet',
                  labelStyle: AppColors.bodyMedium(color: Colors.black54),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Téléphone',
                  labelStyle: AppColors.bodyMedium(color: Colors.black54),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    backgroundColor: AppColors.kDark,
                  ),
                  child: Text('Enregistrer', style: AppColors.bodyLarge(color: Colors.white)),
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
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: AppColors.kDark))
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      // Header
                      FadeInDown(
                        duration: const Duration(milliseconds: 600),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const SizedBox(width: 40),
                              Text(
                                'DigitalStore DZ',
                                style: AppColors.headingMedium(color: AppColors.kDark).copyWith(fontSize: 18),
                              ),
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.notifications_outlined, size: 20, color: Colors.black),
                                  onPressed: () => context.go('/notifications'),
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Avatar + Nom + Email
                      FadeIn(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 200),
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: AppColors.buttonGradient,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.kDark.withOpacity(0.3),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      (_userData?['nom'] ?? 'U')[0].toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 48,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: _showEditProfile,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColors.kDark,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 3),
                                      ),
                                      child: const Icon(Icons.edit_rounded, color: Colors.white, size: 16),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _userData?['nom'] ?? 'Utilisateur',
                              style: AppColors.headingLarge(color: Colors.black).copyWith(fontSize: 24),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              supabase.auth.currentUser?.email ?? '',
                              style: AppColors.bodyMedium(color: Colors.black54),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Stats Cards
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 300),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Expanded(child: _statCard('$_achatsCount', 'ACHATS', AppColors.kDark)),
                              const SizedBox(width: 16),
                              Expanded(child: _statCard('$_enAttenteCount', 'EN ATTENTE', AppColors.kPrimary)),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Paramètres du compte
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 400),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'PARAMÈTRES DU COMPTE',
                                style: AppColors.labelSmall(color: Colors.black45).copyWith(letterSpacing: 1.2),
                              ),
                              const SizedBox(height: 16),
                              _menuItem(Icons.person_outline_rounded, 'Modifier le profil', 'Nom, email, téléphone', AppColors.kDark, _showEditProfile),
                              _menuItem(Icons.language_rounded, 'Langue', 'Français (DZ)', AppColors.kDark, () => context.go('/langue')),
                              _menuItem(Icons.notifications_active_outlined, 'Notifications', 'Activées', AppColors.kPrimary, () => context.go('/notifications')),
                              _menuItem(Icons.shopping_bag_outlined, 'Historique d\'achats', 'Gérer mes commandes', AppColors.kDark, () => context.go('/bibliotheque')),
                              _menuItem(Icons.favorite_border_rounded, 'Ma wishlist', 'Produits favoris', Colors.red.shade400, () => context.go('/wishlist')),
                              _menuItem(Icons.chat_bubble_outline_rounded, 'Messages', 'Conversations vendeurs', Colors.blue.shade600, () => context.go('/messages')),
                              _menuItem(Icons.help_outline_rounded, 'Aide & Support', 'Centre d\'aide', AppColors.kPrimary, () => context.go('/aide')),
                              _menuItem(Icons.privacy_tip_outlined, 'Confidentialité', 'Politique et conditions', AppColors.kDark, () => context.go('/confidentialite')),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Déconnexion
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 500),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: GestureDetector(
                            onTap: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  title: Text('Déconnexion', style: AppColors.headingMedium(color: Colors.black)),
                                  content: Text('Voulez-vous vraiment vous déconnecter ?', style: AppColors.bodyMedium(color: Colors.black87)),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: Text('Annuler', style: AppColors.labelSmall(color: Colors.black54)),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: Text('Déconnexion', style: AppColors.labelSmall(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) _logout();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.logout_rounded, color: Colors.red.shade700, size: 20),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Déconnexion',
                                    style: AppColors.bodyLarge(color: Colors.red.shade700).copyWith(fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _statCard(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppColors.headingLarge(color: color).copyWith(fontSize: 32),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppColors.labelSmall(color: Colors.black45).copyWith(letterSpacing: 1.2),
          ),
        ],
      ),
    );
  }

  Widget _menuItem(IconData icon, String title, String subtitle, Color iconColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppColors.bodyLarge(color: Colors.black).copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppColors.labelSmall(color: Colors.black45)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: Colors.black26, size: 16),
          ],
        ),
      ),
    );
  }
}