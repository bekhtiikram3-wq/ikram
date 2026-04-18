import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:animate_do/animate_do.dart';
import '../../app_colors.dart';

class CatalogueScreen extends StatefulWidget {
  const CatalogueScreen({super.key});
  @override
  State<CatalogueScreen> createState() => _CatalogueScreenState();
}

class _CatalogueScreenState extends State<CatalogueScreen> {
  final supabase = Supabase.instance.client;
  final _searchCtrl = TextEditingController();
  List<Map<String, dynamic>> _produits = [];
  List<Map<String, dynamic>> _produitsFiltered = [];
  bool _loading = true;
  String _selectedCategory = 'Tous';

  final List<String> _categories = ['Tous', 'Ebooks', 'Templates', 'Scripts'];

  @override
  void initState() {
    super.initState();
    _loadProduits();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProduits() async {
    try {
      final produits = await supabase
          .from('produits')
          .select('*, vendeurs(nom_boutique)')
          .eq('statut', 'publie')
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _produits = List<Map<String, dynamic>>.from(produits);
          _produitsFiltered = _produits;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _filterProduits(String query) {
    setState(() {
      _produitsFiltered = _produits.where((p) {
        final matchesSearch = query.isEmpty || 
            (p['titre'] ?? '').toLowerCase().contains(query.toLowerCase());
        final matchesCategory = _selectedCategory == 'Tous' || 
            (p['categorie_type'] ?? '').toLowerCase() == _selectedCategory.toLowerCase().replaceAll('s', '');
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header avec Poppins + icônes modernes
              FadeInDown(
                duration: const Duration(milliseconds: 600),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
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
                          Text('Catalogue', style: AppColors.headingLarge()),
                          Row(
                            children: [
                              _headerIcon(Icons.notifications_none_rounded, () => context.go('/notifications')),
                              const SizedBox(width: 8),
                              _headerIcon(Icons.chat_outlined, () => context.go('/messages')),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Search bar
                      Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: AppColors.kDark.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(color: AppColors.kBlueViolet.withOpacity(0.3), width: 1.5),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.search_rounded, color: AppColors.kBlueViolet.withOpacity(0.7), size: 22),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _searchCtrl,
                                onChanged: _filterProduits,
                                style: AppColors.bodyLarge(),
                                decoration: InputDecoration(
                                  hintText: 'Rechercher...',
                                  hintStyle: AppColors.bodyMedium(color: AppColors.kBlueViolet.withOpacity(0.7)),
                                  border: InputBorder.none,
                                  filled: true,
                                  fillColor: Colors.transparent,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Categories filter
              FadeInLeft(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 200),
                child: Container(
                  height: 50,
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      final isSelected = _selectedCategory == cat;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedCategory = cat);
                          _filterProduits(_searchCtrl.text);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            gradient: isSelected ? AppColors.buttonGradient : null,
                            color: isSelected ? null : AppColors.kDark.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                              color: isSelected ? AppColors.kPrimary : AppColors.kBlueViolet.withOpacity(0.3),
                              width: isSelected ? 2 : 1.5,
                            ),
                            boxShadow: isSelected ? AppColors.glowShadow(0.3) : [],
                          ),
                          child: Text(
                            cat,
                            style: AppColors.bodyMedium(
                              color: isSelected ? AppColors.kLight : AppColors.kBlueViolet,
                            ).copyWith(fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Produits grid
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.kLight))
                    : _produitsFiltered.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_off_rounded, color: AppColors.kBlueViolet.withOpacity(0.4), size: 64),
                                const SizedBox(height: 16),
                                Text('Aucun produit trouvé', style: AppColors.bodyMedium(color: AppColors.kBlueViolet.withOpacity(0.6))),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadProduits,
                            color: AppColors.kPrimary,
                            child: GridView.builder(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.75,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                              itemCount: _produitsFiltered.length,
                              itemBuilder: (context, index) {
                                final produit = _produitsFiltered[index];
                                return SlideInRight(
                                  duration: const Duration(milliseconds: 600),
                                  delay: Duration(milliseconds: 100 * (index % 6)),
                                  child: _produitCard(produit),
                                );
                              },
                            ),
                          ),
              ),
            ],
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
          color: AppColors.kDark.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.kBlueViolet.withOpacity(0.3)),
        ),
        child: Icon(icon, color: AppColors.kLight, size: 20),
      ),
    );
  }

  Widget _produitCard(Map<String, dynamic> produit) {
    final vendeur = produit['vendeurs'] as Map<String, dynamic>?;
    return GestureDetector(
      onTap: () => context.go('/produit/${produit['id']}'),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.kDark.withOpacity(0.6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.kBlueViolet.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.kDeepDark.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: produit['images'] != null && (produit['images'] as List).isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: produit['images'][0],
                      width: double.infinity,
                      height: 120,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: AppColors.kDark),
                      errorWidget: (_, __, ___) => Container(
                        height: 120,
                        color: AppColors.kDark,
                        child: const Icon(Icons.image_not_supported_outlined, color: AppColors.kBlueViolet, size: 40),
                      ),
                    )
                  : Container(
                      height: 120,
                      color: AppColors.kDark,
                      child: const Icon(Icons.image_not_supported_outlined, color: AppColors.kBlueViolet, size: 40),
                    ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      produit['titre'] ?? '',
                      style: AppColors.bodyMedium(color: AppColors.kLight).copyWith(fontWeight: FontWeight.w700, fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      vendeur?['nom_boutique'] ?? '',
                      style: AppColors.labelSmall(color: AppColors.kBlueViolet.withOpacity(0.8)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: AppColors.buttonGradient,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${produit['prix_dzd'] ?? 0} DZD',
                            style: AppColors.labelSmall(color: AppColors.kLight).copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.star_rounded, color: Colors.amber.shade400, size: 14),
                            const SizedBox(width: 2),
                            Text(
                              '${produit['note_moyenne'] ?? 0}',
                              style: AppColors.labelSmall(color: AppColors.kLight).copyWith(fontSize: 11),
                            ),
                          ],
                        ),
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