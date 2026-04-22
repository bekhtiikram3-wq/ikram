import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:animate_do/animate_do.dart';
import '../../app_colors.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _favoris = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFavoris();
  }

  Future<void> _loadFavoris() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId != null) {
        await Future.delayed(const Duration(milliseconds: 500));
        
        final produits = await supabase
            .from('produits')
            .select('*, vendeurs(nom_boutique)')
            .eq('statut', 'publie')
            .limit(5);

        if (mounted) {
          setState(() {
            _favoris = List<Map<String, dynamic>>.from(produits);
            _loading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _retirerDesFavoris(String produitId) async {
    setState(() {
      _favoris.removeWhere((p) => p['id'] == produitId);
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Retiré de la wishlist'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _ajouterAuPanier(String produitId) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      await supabase.from('panier').insert({
        'utilisateur_id': userId,
        'produit_id': produitId,
        'quantite': 1,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Ajouté au panier !'),
            backgroundColor: AppColors.kDark,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        context.go('/profil');
        return false;
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppColors.bgGradient),
          child: SafeArea(
            child: Column(
              children: [
                FadeInDown(
                  duration: const Duration(milliseconds: 600),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_rounded, size: 20, color: Colors.black),
                            onPressed: () => context.go('/profil'),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Ma Wishlist', style: AppColors.headingMedium(color: Colors.black).copyWith(fontSize: 20)),
                              Text('${_favoris.length} produit${_favoris.length > 1 ? 's' : ''}', style: AppColors.labelSmall(color: Colors.black54)),
                            ],
                          ),
                        ),
                        Icon(Icons.favorite_rounded, color: Colors.red.shade400, size: 28),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.kDark))
                      : _favoris.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.favorite_border_rounded, size: 80, color: Colors.black12),
                                  const SizedBox(height: 16),
                                  Text('Aucun favori', style: AppColors.headingMedium(color: Colors.black54)),
                                  const SizedBox(height: 8),
                                  Text('Ajoutez des produits à votre wishlist', style: AppColors.bodyMedium(color: Colors.black38)),
                                  const SizedBox(height: 24),
                                  ElevatedButton.icon(
                                    onPressed: () => context.go('/catalogue'),
                                    icon: const Icon(Icons.explore_rounded),
                                    label: const Text('Explorer'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.kDark,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _loadFavoris,
                              color: AppColors.kDark,
                              child: ListView.builder(
                                padding: const EdgeInsets.all(20),
                                itemCount: _favoris.length,
                                itemBuilder: (context, index) {
                                  final produit = _favoris[index];
                                  return FadeInUp(
                                    duration: const Duration(milliseconds: 600),
                                    delay: Duration(milliseconds: 100 * index),
                                    child: _favoriCard(produit),
                                  );
                                },
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

  Widget _favoriCard(Map<String, dynamic> produit) {
    final vendeur = produit['vendeurs'] as Map<String, dynamic>?;
    return GestureDetector(
      onTap: () => context.go('/produit/${produit['id']}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 6))],
        ),
        child: Column(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                  child: produit['images'] != null && (produit['images'] as List).isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: produit['images'][0],
                          width: double.infinity,
                          height: 180,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(color: Colors.grey.shade200),
                          errorWidget: (_, __, ___) => Container(height: 180, color: Colors.grey.shade200, child: const Icon(Icons.image_not_supported_outlined, size: 48)),
                        )
                      : Container(height: 180, color: Colors.grey.shade200, child: const Icon(Icons.image_not_supported_outlined, size: 48)),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () => _retirerDesFavoris(produit['id']),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)]),
                      child: Icon(Icons.favorite_rounded, color: Colors.red.shade400, size: 20),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(produit['titre'] ?? '', style: AppColors.bodyLarge(color: Colors.black).copyWith(fontWeight: FontWeight.w700), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.store_rounded, size: 14, color: Colors.black54),
                      const SizedBox(width: 4),
                      Text(vendeur?['nom_boutique'] ?? '', style: AppColors.labelSmall(color: Colors.black54)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${produit['prix_dzd'] ?? 0} DZD', style: AppColors.headingMedium(color: AppColors.kDark).copyWith(fontSize: 20)),
                      Row(
                        children: [
                          Icon(Icons.star_rounded, color: Colors.amber.shade400, size: 18),
                          const SizedBox(width: 4),
                          Text('${produit['note_moyenne'] ?? 0}', style: AppColors.bodyMedium(color: Colors.black).copyWith(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _ajouterAuPanier(produit['id']),
                      icon: const Icon(Icons.shopping_cart_rounded, size: 18),
                      label: const Text('Ajouter au panier'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.kDark,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}