import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:animate_do/animate_do.dart';
import '../../app_colors.dart';

class BoutiqueVendeurScreen extends StatefulWidget {
  final String vendeurId;
  final String vendeurNom;

  const BoutiqueVendeurScreen({
    super.key,
    required this.vendeurId,
    required this.vendeurNom,
  });

  @override
  State<BoutiqueVendeurScreen> createState() => _BoutiqueVendeurScreenState();
}

class _BoutiqueVendeurScreenState extends State<BoutiqueVendeurScreen> {
  final supabase = Supabase.instance.client;
  Map<String, dynamic>? _vendeur;
  List<Map<String, dynamic>> _produits = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBoutique();
  }

  Future<void> _loadBoutique() async {
    try {
      // Charger infos vendeur
      final vendeur = await supabase
          .from('vendeurs')
          .select('*')
          .eq('id', widget.vendeurId)
          .single();

      // Charger produits du vendeur
      final produits = await supabase
          .from('produits')
          .select('*')
          .eq('vendeur_id', widget.vendeurId)
          .eq('statut', 'publie');

      if (mounted) {
        setState(() {
          _vendeur = vendeur;
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
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppColors.bgGradient),
          child: SafeArea(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.kDark))
                : CustomScrollView(
                    slivers: [
                      // Header avec bannière
                      SliverAppBar(
                        expandedHeight: 200,
                        pinned: true,
                        backgroundColor: AppColors.kDark,
                        leading: Container(
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_rounded, color: Colors.black, size: 20),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        flexibleSpace: FlexibleSpaceBar(
                          background: Stack(
                            fit: StackFit.expand,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  gradient: AppColors.buttonGradient,
                                ),
                              ),
                              Positioned(
                                bottom: 20,
                                left: 20,
                                right: 20,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 4),
                                      ),
                                      child: Center(
                                        child: Text(
                                          widget.vendeurNom[0].toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.kDark,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            widget.vendeurNom,
                                            style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(Icons.star_rounded, color: Colors.amber.shade400, size: 16),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${_vendeur?['note_moyenne'] ?? 4.5} • ${_produits.length} produits',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Description boutique
                      SliverToBoxAdapter(
                        child: FadeInUp(
                          duration: const Duration(milliseconds: 600),
                          child: Container(
                            margin: const EdgeInsets.all(20),
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
                                  'À PROPOS',
                                  style: AppColors.labelSmall(color: Colors.black45).copyWith(letterSpacing: 1.2),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _vendeur?['description'] ?? 'Boutique de produits digitaux de qualité',
                                  style: AppColors.bodyMedium(color: Colors.black87),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    _statChip(Icons.shopping_bag_rounded, '${_vendeur?['total_ventes'] ?? 0}', 'Ventes'),
                                    const SizedBox(width: 12),
                                    _statChip(Icons.inventory_2_rounded, '${_produits.length}', 'Produits'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Produits
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverToBoxAdapter(
                          child: Text(
                            'PRODUITS',
                            style: AppColors.labelSmall(color: Colors.black45).copyWith(letterSpacing: 1.2),
                          ),
                        ),
                      ),

                      const SliverToBoxAdapter(child: SizedBox(height: 16)),

                      _produits.isEmpty
                          ? SliverToBoxAdapter(
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(40),
                                  child: Column(
                                    children: [
                                      Icon(Icons.inventory_2_outlined, size: 64, color: Colors.black12),
                                      const SizedBox(height: 16),
                                      Text('Aucun produit', style: AppColors.bodyLarge(color: Colors.black54)),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : SliverPadding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                              sliver: SliverGrid(
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.7,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                ),
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final produit = _produits[index];
                                    return FadeInUp(
                                      duration: const Duration(milliseconds: 600),
                                      delay: Duration(milliseconds: 100 * index),
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

  Widget _statChip(IconData icon, String valeur, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.kPrimary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.kDark, size: 16),
          const SizedBox(width: 6),
          Text(valeur, style: AppColors.bodyMedium(color: Colors.black).copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(width: 4),
          Text(label, style: AppColors.labelSmall(color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _produitCard(Map<String, dynamic> produit) {
    return GestureDetector(
      onTap: () => context.go('/produit/${produit['id']}'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
                      height: 140,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: Colors.grey.shade200),
                      errorWidget: (_, __, ___) => Container(
                        height: 140,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image_not_supported_outlined, size: 40),
                      ),
                    )
                  : Container(
                      height: 140,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.image_not_supported_outlined, size: 40),
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
                      style: AppColors.bodyMedium(color: Colors.black).copyWith(fontWeight: FontWeight.w700),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${produit['prix_dzd'] ?? 0} DZD',
                          style: AppColors.bodyLarge(color: AppColors.kDark).copyWith(fontWeight: FontWeight.w800),
                        ),
                        Row(
                          children: [
                            Icon(Icons.star_rounded, color: Colors.amber.shade400, size: 14),
                            const SizedBox(width: 2),
                            Text(
                              '${produit['note_moyenne'] ?? 0}',
                              style: AppColors.labelSmall(color: Colors.black54).copyWith(fontWeight: FontWeight.w600),
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