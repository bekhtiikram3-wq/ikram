import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import '../../app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final supabase = Supabase.instance.client;
  final PageController _bannerController = PageController();
  List<Map<String, dynamic>> _produits = [];
  Map<String, dynamic>? _userData;
  bool _loading = true;
  int _currentBanner = 0;

  final List<Map<String, dynamic>> _banners = [
    {
      'title': 'Nouvelle Collection',
      'subtitle': 'Réduction 50% sur\nla première transaction',
      'gradient': [Color(0xFFF5D5E0), Color(0xFFE8C4D8)],
      'action': 'Explorer',
    },
    {
      'title': 'Produits Premium',
      'subtitle': 'Templates professionnels\npour vos projets',
      'gradient': [Color(0xFF6667AB), Color(0xFF8E8FD5)],
      'action': 'Découvrir',
    },
    {
      'title': 'Scripts & Outils',
      'subtitle': 'Automatisez votre travail\navec nos scripts',
      'gradient': [Color(0xFF7B337E), Color(0xFFA356A7)],
      'action': 'Voir',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
    Future.delayed(const Duration(seconds: 3), _autoBanner);
  }

  void _autoBanner() {
    if (!mounted) return;
    final next = (_currentBanner + 1) % _banners.length;
    _bannerController.animateToPage(next, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    Future.delayed(const Duration(seconds: 3), _autoBanner);
  }

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId != null) {
        final user = await supabase.from('utilisateurs').select('nom').eq('id', userId).single();
        _userData = user;
      }

      final produits = await supabase
          .from('produits')
          .select('*, vendeurs(nom_boutique)')
          .eq('statut', 'publie')
          .order('created_at', ascending: false)
          .limit(10);

      if (mounted) {
        setState(() {
          _produits = List<Map<String, dynamic>>.from(produits);
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: AppColors.kDark))
              : RefreshIndicator(
                  onRefresh: _loadData,
                  color: AppColors.kPrimary,
                  child: CustomScrollView(
                    slivers: [
                      // Header avec Poppins + icônes modernes
                      SliverToBoxAdapter(
                        child: FadeInDown(
                          duration: const Duration(milliseconds: 600),
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                            decoration: BoxDecoration(
                              gradient: AppColors.headerGradient,
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(28),
                                bottomRight: Radius.circular(28),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.kDeepDark.withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Bonjour 👋', style: AppColors.bodyMedium(color: Colors.white)),
                                        const SizedBox(height: 4),
                                        Text(
                                          _userData?['nom'] ?? 'Client',
                                          style: AppColors.headingMedium(color: Colors.white),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(DateTime.now()),
                                          style: AppColors.labelSmall(color: Colors.white.withOpacity(0.8)),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        _headerIcon(Icons.notifications_none_rounded, () => context.go('/notifications')),
                                        const SizedBox(width: 8),
                                        _headerIcon(Icons.chat_outlined, () => context.go('/messages')),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                // Search bar
                                GestureDetector(
                                  onTap: () => context.go('/catalogue'),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.9),
                                      borderRadius: BorderRadius.circular(50),
                                      border: Border.all(color: AppColors.kDark.withOpacity(0.2), width: 1.5),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.search_rounded, color: Colors.grey.shade600, size: 22),
                                        const SizedBox(width: 12),
                                        Text('Rechercher des produits...', style: AppColors.bodyMedium(color: Colors.grey.shade600)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // BANNER CAROUSEL
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                          child: FadeInUp(
                            duration: const Duration(milliseconds: 600),
                            delay: const Duration(milliseconds: 200),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 180,
                                  child: PageView.builder(
                                    controller: _bannerController,
                                    onPageChanged: (i) => setState(() => _currentBanner = i),
                                    itemCount: _banners.length,
                                    itemBuilder: (context, index) {
                                      final banner = _banners[index];
                                      return Container(
                                        margin: const EdgeInsets.symmetric(horizontal: 4),
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: banner['gradient'],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: (banner['gradient'][0] as Color).withOpacity(0.4),
                                              blurRadius: 16,
                                              offset: const Offset(0, 8),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    banner['title'],
                                                    style: AppColors.headingMedium(color: Colors.white).copyWith(fontSize: 22),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    banner['subtitle'],
                                                    style: AppColors.bodyMedium(color: Colors.white.withOpacity(0.9)).copyWith(height: 1.4),
                                                  ),
                                                  const SizedBox(height: 16),
                                                  GestureDetector(
                                                    onTap: () => context.go('/catalogue'),
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                                      decoration: BoxDecoration(
                                                        color: Colors.black.withOpacity(0.3),
                                                        borderRadius: BorderRadius.circular(50),
                                                      ),
                                                      child: Text(
                                                        banner['action'],
                                                        style: AppColors.labelSmall(color: Colors.white).copyWith(fontWeight: FontWeight.w700),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Icon(Icons.local_offer_rounded, color: Colors.white.withOpacity(0.3), size: 80),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(_banners.length, (i) {
                                    final isActive = i == _currentBanner;
                                    return AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      margin: const EdgeInsets.symmetric(horizontal: 4),
                                      width: isActive ? 24 : 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: isActive ? AppColors.kDark : AppColors.kDark.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Categories
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                          child: FadeInLeft(
                            duration: const Duration(milliseconds: 600),
                            delay: const Duration(milliseconds: 300),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Catégories', style: AppColors.headingMedium(color: Colors.black).copyWith(fontSize: 18)),
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    Expanded(child: _categoryCard('Ebooks', Icons.menu_book_rounded, 'ebook')),
                                    const SizedBox(width: 12),
                                    Expanded(child: _categoryCard('Templates', Icons.palette_rounded, 'template')),
                                    const SizedBox(width: 12),
                                    Expanded(child: _categoryCard('Scripts', Icons.code_rounded, 'script')),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Produits récents
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                          child: FadeInLeft(
                            duration: const Duration(milliseconds: 600),
                            delay: const Duration(milliseconds: 400),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Nouveautés', style: AppColors.headingMedium(color: Colors.black).copyWith(fontSize: 18)),
                                GestureDetector(
                                  onTap: () => context.go('/catalogue'),
                                  child: Text('Voir tout', style: AppColors.labelSmall(color: Colors.black)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Liste produits
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                        sliver: _produits.isEmpty
                            ? SliverToBoxAdapter(
                                child: Center(
                                  child: Text('Aucun produit disponible', style: AppColors.bodyMedium(color: Colors.black54)),
                                ),
                              )
                            : SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final produit = _produits[index];
                                    return FadeInUp(
                                      duration: const Duration(milliseconds: 600),
                                      delay: Duration(milliseconds: 500 + (index * 100)),
                                      from: 30,
                                      child: _produitCard(produit),
                                    );
                                  },
                                  childCount: _produits.length,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _headerIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _categoryCard(String label, IconData icon, String type) {
    return GestureDetector(
      onTap: () => context.go('/catalogue'),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: AppColors.buttonGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.glowShadow(0.3),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 6),
            Text(label, style: AppColors.labelSmall(color: Colors.black)),
          ],
        ),
      ),
    );
  }

  Widget _produitCard(Map<String, dynamic> produit) {
    final vendeur = produit['vendeurs'] as Map<String, dynamic>?;
    return GestureDetector(
      onTap: () => context.go('/produit/${produit['id']}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.kDark.withOpacity(0.1), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.kDark.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
              child: produit['images'] != null && (produit['images'] as List).isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: produit['images'][0],
                      width: 110,
                      height: 110,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: Colors.grey.shade200),
                      errorWidget: (_, __, ___) => Container(
                        color: Colors.grey.shade200,
                        child: Icon(Icons.image_not_supported_outlined, color: Colors.grey.shade400),
                      ),
                    )
                  : Container(
                      width: 110,
                      height: 110,
                      color: Colors.grey.shade200,
                      child: Icon(Icons.image_not_supported_outlined, color: Colors.grey.shade400, size: 32),
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      produit['titre'] ?? '',
                      style: AppColors.bodyLarge(color: Colors.black).copyWith(fontWeight: FontWeight.w700),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      vendeur?['nom_boutique'] ?? '',
                      style: AppColors.labelSmall(color: Colors.black54),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: AppColors.buttonGradient,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${produit['prix_dzd'] ?? 0} DZD',
                            style: AppColors.labelSmall(color: Colors.white).copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.star_rounded, color: Colors.amber.shade400, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${produit['note_moyenne'] ?? 0}',
                          style: AppColors.labelSmall(color: Colors.black),
                        ),
                        const SizedBox(width: 12),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}