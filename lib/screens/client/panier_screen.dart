import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../app_colors.dart';

class PanierScreen extends StatefulWidget {
  const PanierScreen({super.key});

  @override
  State<PanierScreen> createState() => _PanierScreenState();
}

class _PanierScreenState extends State<PanierScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _articles = [];
  bool _loading = true;
  bool _processingPayment = false;

  @override
  void initState() {
    super.initState();
    _loadPanier();
  }

  Future<void> _loadPanier() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final panierJson = prefs.getString('panier') ?? '[]';
      final List<dynamic> panier = jsonDecode(panierJson);
      
      if (mounted) {
        setState(() {
          _articles = List<Map<String, dynamic>>.from(panier);
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  int get _total {
    return _articles.fold(0, (sum, article) {
      final produit = article['produit'] as Map<String, dynamic>;
      final prix = produit['prix_dzd'] as int? ?? 0;
      final quantite = article['quantite'] as int? ?? 1;
      return sum + (prix * quantite);
    });
  }

  Future<void> _retirerDuPanier(String articleId) async {
    setState(() {
      _articles.removeWhere((a) => a['id'] == articleId);
    });
    
    // Sauvegarder
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('panier', jsonEncode(_articles));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Article retiré du panier'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _procederAuPaiement() async {
    if (_articles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Votre panier est vide'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.payment_rounded, color: AppColors.kDark),
              const SizedBox(width: 12),
              Expanded(child: Text('Paiement Chargily', style: AppColors.headingMedium(color: Colors.black))),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Vous allez procéder au paiement via Chargily Pay.', 
                style: AppColors.bodyMedium(color: Colors.black87)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.kPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Montant total:', style: AppColors.labelSmall(color: Colors.black54)),
                    const SizedBox(height: 4),
                    Text('$_total DZD', style: AppColors.headingMedium(color: AppColors.kDark).copyWith(fontSize: 28)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text('Modes de paiement acceptés:', style: AppColors.labelSmall(color: Colors.black54)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _paymentMethodChip('CIB'),
                  _paymentMethodChip('Dahabia'),
                  _paymentMethodChip('BaridiMob'),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Annuler', style: AppColors.labelSmall(color: Colors.black54)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                
                // Vider le panier
                setState(() => _articles.clear());
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('panier');
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('✓ Paiement simulé avec succès ! Vos produits sont dans votre bibliothèque.'),
                      backgroundColor: Colors.green.shade700,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      duration: const Duration(seconds: 5),
                      action: SnackBarAction(
                        label: 'VOIR',
                        textColor: Colors.white,
                        onPressed: () => context.go('/bibliotheque'),
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.kDark,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Confirmer le paiement'),
            ),
          ],
        ),
      );
    }
  }

  Widget _paymentMethodChip(String method) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.credit_card_rounded, size: 16, color: AppColors.kDark),
          const SizedBox(width: 6),
          Text(method, style: AppColors.bodyMedium(color: Colors.black).copyWith(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Mon Panier', style: AppColors.headingMedium(color: Colors.black).copyWith(fontSize: 24)),
                          Text('${_articles.length} article${_articles.length > 1 ? 's' : ''}', style: AppColors.labelSmall(color: Colors.black54)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: AppColors.buttonGradient,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.shopping_cart_rounded, color: Colors.white, size: 24),
                      ),
                    ],
                  ),
                ),
              ),

              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.kDark))
                    : _articles.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.black12),
                                const SizedBox(height: 16),
                                Text('Panier vide', style: AppColors.headingMedium(color: Colors.black54)),
                                const SizedBox(height: 8),
                                Text('Ajoutez des produits au panier', style: AppColors.bodyMedium(color: Colors.black38)),
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
                            onRefresh: _loadPanier,
                            color: AppColors.kDark,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(20),
                              itemCount: _articles.length,
                              itemBuilder: (context, index) {
                                final article = _articles[index];
                                return FadeInUp(
                                  duration: const Duration(milliseconds: 600),
                                  delay: Duration(milliseconds: 100 * index),
                                  child: _articleCard(article),
                                );
                              },
                            ),
                          ),
              ),

              if (_articles.isNotEmpty)
                FadeInUp(
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
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Total à payer', style: AppColors.labelSmall(color: Colors.black54)),
                                  const SizedBox(height: 4),
                                  Text('$_total DZD', style: AppColors.headingLarge(color: AppColors.kDark).copyWith(fontSize: 28)),
                                ],
                              ),
                              Icon(Icons.payment_rounded, color: AppColors.kDark, size: 32),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _processingPayment ? null : _procederAuPaiement,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.kDark,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: _processingPayment
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.lock_rounded, size: 20),
                                        const SizedBox(width: 8),
                                        Text('Payer avec Chargily', style: AppColors.bodyLarge(color: Colors.white).copyWith(fontWeight: FontWeight.w700)),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _articleCard(Map<String, dynamic> article) {
    final produit = article['produit'] as Map<String, dynamic>;
    final vendeur = produit['vendeur'] as Map<String, dynamic>?;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: Colors.grey.shade200),
                    errorWidget: (_, __, ___) => Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.image_not_supported_outlined, size: 30),
                    ),
                  )
                : Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image_not_supported_outlined, size: 30),
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
                    style: AppColors.bodyLarge(color: Colors.black).copyWith(fontWeight: FontWeight.w700),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (vendeur != null)
                    Row(
                      children: [
                        Icon(Icons.store_rounded, size: 12, color: Colors.black54),
                        const SizedBox(width: 4),
                        Text(
                          vendeur['nom_boutique'] ?? '',
                          style: AppColors.labelSmall(color: Colors.black54),
                        ),
                      ],
                    ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${produit['prix_dzd'] ?? 0} DZD',
                        style: AppColors.headingMedium(color: AppColors.kDark).copyWith(fontSize: 18),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_rounded, color: Colors.red.shade400, size: 20),
                        onPressed: () => _retirerDuPanier(article['id']),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}