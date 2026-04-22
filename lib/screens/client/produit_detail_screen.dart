import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../app_colors.dart';

class ProduitDetailScreen extends StatefulWidget {
  final String produitId;

  const ProduitDetailScreen({
    super.key,
    required this.produitId,
  });

  @override
  State<ProduitDetailScreen> createState() => _ProduitDetailScreenState();
}

class _ProduitDetailScreenState extends State<ProduitDetailScreen> {
  final supabase = Supabase.instance.client;
  Map<String, dynamic>? _produit;
  bool _loading = true;
  bool _isFavorite = false;
  int _selectedImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadProduit();
  }

  Future<void> _loadProduit() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      final produit = {
        'id': widget.produitId,
        'titre': 'Formation Complete UI/UX Design 2024',
        'description': 'Apprenez le design d\'interface et d\'expérience utilisateur de A à Z. Cette formation complète couvre Figma, Adobe XD, les principes de design, le prototypage, les tests utilisateurs et bien plus encore.\n\nCe que vous allez apprendre :\n• Maîtriser Figma et Adobe XD\n• Créer des wireframes professionnels\n• Concevoir des interfaces modernes\n• Réaliser des prototypes interactifs\n• Conduire des tests utilisateurs\n• Appliquer les principes UX\n\nInclus :\n✓ 12 heures de vidéo\n✓ 50+ ressources téléchargeables\n✓ Certificat de completion\n✓ Accès à vie',
        'prix_dzd': 4500,
        'prix_original_dzd': 8900,
        'categorie': 'Formation',
        'note_moyenne': 4.8,
        'nombre_avis': 127,
        'nombre_ventes': 523,
        'images': [
          'https://picsum.photos/800/600?random=1',
          'https://picsum.photos/800/600?random=2',
          'https://picsum.photos/800/600?random=3',
        ],
        'type_fichier': 'video',
        'taille_fichier': '2.5 GB',
        'vendeur': {
          'id': 'v1',
          'nom_boutique': 'DesignPro Academy',
          'note_moyenne': 4.9,
          'total_ventes': 1200,
        },
        'specifications': [
          {'titre': 'Format', 'valeur': 'Vidéo MP4'},
          {'titre': 'Durée totale', 'valeur': '12 heures'},
          {'titre': 'Niveau', 'valeur': 'Débutant à Avancé'},
          {'titre': 'Langue', 'valeur': 'Français'},
          {'titre': 'Dernière mise à jour', 'valeur': 'Mars 2024'},
        ],
      };

      if (mounted) {
        setState(() {
          _produit = produit;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _ajouterAuPanier() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Récupérer panier actuel
      final panierJson = prefs.getString('panier') ?? '[]';
      final List<dynamic> panier = jsonDecode(panierJson);
      
      // Vérifier si déjà dans le panier
      final dejaPresent = panier.any((item) => item['produit']['id'] == _produit!['id']);
      
      if (dejaPresent) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Ce produit est déjà dans votre panier'),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              duration: const Duration(seconds: 3),
            ),
          );
        }
        return;
      }
      
      // Ajouter le produit
      panier.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'produit': _produit,
        'quantite': 1,
      });
      
      // Sauvegarder
      await prefs.setString('panier', jsonEncode(panier));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('✓ Ajouté au panier !', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                      Text('${_produit!['titre']}', style: const TextStyle(fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 6),
            action: SnackBarAction(
              label: 'VOIR',
              textColor: Colors.white,
              onPressed: () => context.go('/panier'),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  void _toggleFavorite() {
    setState(() => _isFavorite = !_isFavorite);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isFavorite ? '❤️ Ajouté aux favoris' : 'Retiré des favoris'),
        backgroundColor: _isFavorite ? Colors.red.shade400 : Colors.grey.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading
          ? Container(
              decoration: const BoxDecoration(gradient: AppColors.bgGradient),
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.kDark),
              ),
            )
          : _produit == null
              ? Container(
                  decoration: const BoxDecoration(gradient: AppColors.bgGradient),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                        const SizedBox(height: 16),
                        Text('Produit introuvable', style: AppColors.headingMedium(color: Colors.black54)),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => context.go('/catalogue'),
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Retour au catalogue'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.kDark,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Container(
                  decoration: const BoxDecoration(gradient: AppColors.bgGradient),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          SizedBox(
                            height: 350,
                            width: double.infinity,
                            child: PageView.builder(
                              itemCount: (_produit!['images'] as List).length,
                              onPageChanged: (index) => setState(() => _selectedImageIndex = index),
                              itemBuilder: (context, index) {
                                return CachedNetworkImage(
                                  imageUrl: (_produit!['images'] as List)[index],
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => Container(color: Colors.grey.shade200),
                                  errorWidget: (_, __, ___) => Container(
                                    color: Colors.grey.shade200,
                                    child: const Icon(Icons.image_not_supported_outlined, size: 64),
                                  ),
                                );
                              },
                            ),
                          ),
                          
                          SafeArea(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: IconButton(
                                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: IconButton(
                                      icon: Icon(
                                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                                        color: _isFavorite ? Colors.red : Colors.black,
                                      ),
                                      onPressed: _toggleFavorite,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          if ((_produit!['images'] as List).length > 1)
                            Positioned(
                              bottom: 16,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  (_produit!['images'] as List).length,
                                  (index) => Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 4),
                                    width: _selectedImageIndex == index ? 24 : 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: _selectedImageIndex == index
                                          ? Colors.white
                                          : Colors.white.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),

                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FadeInUp(
                                duration: const Duration(milliseconds: 600),
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(28),
                                      topRight: Radius.circular(28),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, -4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: AppColors.kPrimary.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          _produit!['categorie'] ?? '',
                                          style: AppColors.labelSmall(color: AppColors.kDark).copyWith(fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                      
                                      const SizedBox(height: 12),
                                      
                                      Text(
                                        _produit!['titre'] ?? '',
                                        style: AppColors.headingLarge(color: Colors.black).copyWith(fontSize: 24),
                                      ),
                                      
                                      const SizedBox(height: 12),
                                      
                                      Row(
                                        children: [
                                          Icon(Icons.star_rounded, color: Colors.amber.shade400, size: 20),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${_produit!['note_moyenne']}',
                                            style: AppColors.bodyLarge(color: Colors.black).copyWith(fontWeight: FontWeight.w700),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '(${_produit!['nombre_avis']} avis)',
                                            style: AppColors.bodyMedium(color: Colors.black54),
                                          ),
                                          const SizedBox(width: 16),
                                          Icon(Icons.shopping_bag_outlined, size: 18, color: Colors.black54),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${_produit!['nombre_ventes']} ventes',
                                            style: AppColors.bodyMedium(color: Colors.black54),
                                          ),
                                        ],
                                      ),
                                      
                                      const SizedBox(height: 16),
                                      
                                      Row(
                                        children: [
                                          Text(
                                            '${_produit!['prix_dzd']} DZD',
                                            style: AppColors.headingLarge(color: AppColors.kDark).copyWith(fontSize: 32),
                                          ),
                                          if (_produit!['prix_original_dzd'] != null) ...[
                                            const SizedBox(width: 12),
                                            Text(
                                              '${_produit!['prix_original_dzd']} DZD',
                                              style: AppColors.bodyMedium(color: Colors.black38).copyWith(
                                                decoration: TextDecoration.lineThrough,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.green.shade50,
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                '-${((((_produit!['prix_original_dzd'] ?? 0) - (_produit!['prix_dzd'] ?? 0)) / (_produit!['prix_original_dzd'] ?? 1)) * 100).round()}%',
                                                style: AppColors.labelSmall(color: Colors.green.shade700).copyWith(fontWeight: FontWeight.w700),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      
                                      const SizedBox(height: 16),
                                      
                                      GestureDetector(
                                        onTap: () {},
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade50,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: Colors.grey.shade200),
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  gradient: AppColors.buttonGradient,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    (_produit!['vendeur']['nom_boutique'] as String)[0].toUpperCase(),
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.w800,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      _produit!['vendeur']['nom_boutique'] ?? '',
                                                      style: AppColors.bodyLarge(color: Colors.black).copyWith(fontWeight: FontWeight.w700),
                                                    ),
                                                    Row(
                                                      children: [
                                                        Icon(Icons.star_rounded, color: Colors.amber.shade400, size: 14),
                                                        const SizedBox(width: 4),
                                                        Text(
                                                          '${_produit!['vendeur']['note_moyenne']} • ${_produit!['vendeur']['total_ventes']} ventes',
                                                          style: AppColors.labelSmall(color: Colors.black54),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const Icon(Icons.chevron_right_rounded, color: Colors.black38),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 8),
                              
                              FadeInUp(
                                duration: const Duration(milliseconds: 600),
                                delay: const Duration(milliseconds: 100),
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.03),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('DESCRIPTION', style: AppColors.labelSmall(color: Colors.black45).copyWith(letterSpacing: 1.2)),
                                      const SizedBox(height: 12),
                                      Text(
                                        _produit!['description'] ?? '',
                                        style: AppColors.bodyMedium(color: Colors.black87).copyWith(height: 1.6),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 8),
                              
                              if (_produit!['specifications'] != null)
                                FadeInUp(
                                  duration: const Duration(milliseconds: 600),
                                  delay: const Duration(milliseconds: 200),
                                  child: Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.03),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('SPÉCIFICATIONS', style: AppColors.labelSmall(color: Colors.black45).copyWith(letterSpacing: 1.2)),
                                        const SizedBox(height: 12),
                                        ...(_produit!['specifications'] as List).map((spec) {
                                          return Padding(
                                            padding: const EdgeInsets.only(bottom: 12),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(spec['titre'], style: AppColors.bodyMedium(color: Colors.black54)),
                                                Text(spec['valeur'], style: AppColors.bodyMedium(color: Colors.black).copyWith(fontWeight: FontWeight.w700)),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      ],
                                    ),
                                  ),
                                ),
                              
                              const SizedBox(height: 100),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
      bottomNavigationBar: _produit == null
          ? null
          : FadeInUp(
              duration: const Duration(milliseconds: 600),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _ajouterAuPanier,
                      icon: const Icon(Icons.shopping_cart_rounded, size: 20),
                      label: Text(
                        'Ajouter au panier',
                        style: AppColors.bodyLarge(color: Colors.white).copyWith(fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.kDark,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}