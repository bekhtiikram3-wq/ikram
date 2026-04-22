import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../app_colors.dart';

class AideSupportScreen extends StatelessWidget {
  const AideSupportScreen({super.key});

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _sendEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'support@digitalstore.dz',
      query: 'subject=Demande d\'aide',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
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
                          onPressed: () => context.pop(),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text('Aide & Support', style: AppColors.headingMedium(color: Colors.black).copyWith(fontSize: 20)),
                      ),
                      Icon(Icons.help_outline_rounded, color: AppColors.kPrimary, size: 28),
                    ],
                  ),
                ),
              ),

              // Contenu
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Contact rapide
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 100),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: AppColors.buttonGradient,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: AppColors.glowShadow(0.3),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.headset_mic_rounded, color: Colors.white, size: 48),
                              const SizedBox(height: 16),
                              Text(
                                'Besoin d\'aide ?',
                                style: AppColors.headingMedium(color: Colors.white),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Notre équipe est là pour vous',
                                style: AppColors.bodyMedium(color: Colors.white.withOpacity(0.9)),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                onPressed: _sendEmail,
                                icon: const Icon(Icons.email_rounded),
                                label: const Text('Contacter le support'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppColors.kDark,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // FAQ
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 200),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Questions fréquentes', style: AppColors.headingMedium(color: Colors.black).copyWith(fontSize: 18)),
                            const SizedBox(height: 16),
                            _faqItem(
                              'Comment acheter un produit ?',
                              'Parcourez le catalogue, sélectionnez un produit, ajoutez-le au panier et procédez au paiement via Chargily (Dahabia/CIB).',
                            ),
                            _faqItem(
                              'Comment télécharger mes achats ?',
                              'Rendez-vous dans "Bibliothèque" depuis le menu. Tous vos produits achetés y sont disponibles en téléchargement.',
                            ),
                            _faqItem(
                              'Puis-je demander un remboursement ?',
                              'Les produits digitaux ne sont pas remboursables. Contactez le support en cas de problème technique.',
                            ),
                            _faqItem(
                              'Comment devenir vendeur ?',
                              'Créez un compte vendeur lors de l\'inscription, complétez votre profil boutique et commencez à publier vos produits.',
                            ),
                            _faqItem(
                              'Quels sont les frais de vente ?',
                              'DigitalStore DZ prend une commission de 15% sur chaque vente. Le reste est reversé au vendeur.',
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Autres moyens de contact
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 300),
                        child: Container(
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
                                'AUTRES MOYENS DE CONTACT',
                                style: AppColors.labelSmall(color: Colors.black45).copyWith(letterSpacing: 1.2),
                              ),
                              const SizedBox(height: 16),
                              _contactItem(
                                Icons.email_outlined,
                                'Email',
                                'support@digitalstore.dz',
                                AppColors.kDark,
                                _sendEmail,
                              ),
                              _contactItem(
                                Icons.phone_outlined,
                                'Téléphone',
                                '+213 XXX XXX XXX',
                                AppColors.kPrimary,
                                () => _launchURL('tel:+213XXXXXXXXX'),
                              ),
                              _contactItem(
                                Icons.facebook_rounded,
                                'Facebook',
                                'DigitalStore DZ',
                                Colors.blue.shade700,
                                () => _launchURL('https://facebook.com/digitalstore.dz'),
                              ),
                              _contactItem(
                                Icons.language_rounded,
                                'Site web',
                                'www.digitalstore.dz',
                                AppColors.kDark,
                                () => _launchURL('https://digitalstore.dz'),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Horaires
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 400),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.kPrimary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.kPrimary.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.access_time_rounded, color: AppColors.kDark, size: 24),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Horaires de support',
                                      style: AppColors.bodyLarge(color: Colors.black).copyWith(fontWeight: FontWeight.w700),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Dimanche - Jeudi : 9h - 17h',
                                      style: AppColors.bodyMedium(color: Colors.black87),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _faqItem(String question, String reponse) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          backgroundColor: Colors.white,
          collapsedBackgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          title: Text(
            question,
            style: AppColors.bodyLarge(color: Colors.black).copyWith(fontWeight: FontWeight.w600),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                reponse,
                style: AppColors.bodyMedium(color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contactItem(IconData icon, String titre, String valeur, Color iconColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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
                  Text(titre, style: AppColors.bodyLarge(color: Colors.black).copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(valeur, style: AppColors.labelSmall(color: Colors.black54)),
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