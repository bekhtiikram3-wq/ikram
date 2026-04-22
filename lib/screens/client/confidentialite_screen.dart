import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import '../../app_colors.dart';

class ConfidentialiteScreen extends StatelessWidget {
  const ConfidentialiteScreen({super.key});

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
                        child: Text('Confidentialité', style: AppColors.headingMedium(color: Colors.black).copyWith(fontSize: 20)),
                      ),
                      Icon(Icons.privacy_tip_outlined, color: AppColors.kDark, size: 28),
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
                      // Intro
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 100),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.kPrimary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.kPrimary.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.shield_outlined, color: AppColors.kDark, size: 32),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  'Nous respectons votre vie privée et protégeons vos données personnelles.',
                                  style: AppColors.bodyMedium(color: Colors.black87),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Politique de confidentialité
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 200),
                        child: _section(
                          'Politique de confidentialité',
                          '''Dernière mise à jour : ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}

DigitalStore DZ s'engage à protéger la confidentialité de vos informations personnelles. Cette politique explique comment nous collectons, utilisons et protégeons vos données.''',
                        ),
                      ),

                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 250),
                        child: _section(
                          'Collecte des données',
                          '''Nous collectons les informations suivantes :

• Informations de compte : nom, email, téléphone
• Informations de paiement : données bancaires via Chargily (sécurisé)
• Données d'utilisation : historique d'achats, préférences
• Données techniques : adresse IP, type d'appareil, navigateur

Ces données sont nécessaires pour fournir nos services et améliorer votre expérience.''',
                        ),
                      ),

                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 300),
                        child: _section(
                          'Utilisation des données',
                          '''Vos données sont utilisées pour :

• Traiter vos commandes et paiements
• Vous envoyer des notifications importantes
• Améliorer nos services
• Prévenir la fraude et assurer la sécurité
• Respecter nos obligations légales

Nous ne vendons jamais vos données à des tiers.''',
                        ),
                      ),

                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 350),
                        child: _section(
                          'Protection des données',
                          '''Nous mettons en œuvre des mesures de sécurité :

• Chiffrement SSL pour toutes les communications
• Stockage sécurisé des données (Supabase)
• Authentification à deux facteurs disponible
• Audits de sécurité réguliers
• Accès limité aux données personnelles''',
                        ),
                      ),

                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 400),
                        child: _section(
                          'Vos droits',
                          '''Conformément à la législation algérienne, vous avez le droit de :

• Accéder à vos données personnelles
• Rectifier vos informations
• Supprimer votre compte
• Vous opposer au traitement de vos données
• Demander la portabilité de vos données

Pour exercer ces droits, contactez-nous à : privacy@digitalstore.dz''',
                        ),
                      ),

                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 450),
                        child: _section(
                          'Cookies',
                          '''Nous utilisons des cookies pour :

• Maintenir votre session connectée
• Mémoriser vos préférences
• Analyser l'utilisation de notre plateforme
• Améliorer votre expérience

Vous pouvez gérer les cookies dans les paramètres de votre navigateur.''',
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Conditions générales
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 500),
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
                                'CONDITIONS GÉNÉRALES D\'UTILISATION',
                                style: AppColors.labelSmall(color: Colors.black45).copyWith(letterSpacing: 1.2),
                              ),
                              const SizedBox(height: 16),
                              _conditionItem(Icons.check_circle_outline, 'Produits numériques non remboursables'),
                              _conditionItem(Icons.check_circle_outline, 'Commission de 15% pour les vendeurs'),
                              _conditionItem(Icons.check_circle_outline, 'Paiement sécurisé via Chargily'),
                              _conditionItem(Icons.check_circle_outline, 'Licence d\'utilisation personnelle'),
                              _conditionItem(Icons.check_circle_outline, 'Interdiction de revendre les produits'),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Contact
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 550),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: AppColors.buttonGradient,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.mail_outline_rounded, color: Colors.white, size: 32),
                              const SizedBox(height: 12),
                              Text(
                                'Des questions ?',
                                style: AppColors.headingMedium(color: Colors.white).copyWith(fontSize: 18),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Contactez-nous à privacy@digitalstore.dz',
                                style: AppColors.bodyMedium(color: Colors.white.withOpacity(0.9)),
                                textAlign: TextAlign.center,
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

  Widget _section(String titre, String contenu) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titre,
            style: AppColors.bodyLarge(color: Colors.black).copyWith(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Text(
            contenu,
            style: AppColors.bodyMedium(color: Colors.black87).copyWith(height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _conditionItem(IconData icon, String texte) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.kDark, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              texte,
              style: AppColors.bodyMedium(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}