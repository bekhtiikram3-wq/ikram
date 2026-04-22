import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import '../../app_colors.dart';
import '../../main.dart';

class LangueScreen extends StatefulWidget {
  const LangueScreen({super.key});

  @override
  State<LangueScreen> createState() => _LangueScreenState();
}

class _LangueScreenState extends State<LangueScreen> {
  String _selectedLanguage = 'fr';

  @override
  void initState() {
    super.initState();
    _selectedLanguage = localeNotifier.value.languageCode;
  }

  Future<void> _changeLanguage(String code) async {
    setState(() => _selectedLanguage = code);
    await localeNotifier.setLocale(code);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getSuccessMessage(code)),
          backgroundColor: AppColors.kDark,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  String _getSuccessMessage(String code) {
    switch (code) {
      case 'fr': return 'Langue changée en Français';
      case 'ar': return 'تم تغيير اللغة إلى العربية';
      case 'en': return 'Language changed to English';
      default: return 'Langue changée';
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
                          onPressed: () => context.go('/profil'),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text('Langue', style: AppColors.headingMedium(color: Colors.black).copyWith(fontSize: 20)),
                      ),
                      Icon(Icons.language_rounded, color: AppColors.kDark, size: 28),
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
                      // Info
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
                              Icon(Icons.info_outline, color: AppColors.kDark, size: 24),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Choisissez votre langue préférée',
                                  style: AppColors.bodyMedium(color: Colors.black87),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Liste langues
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 200),
                        child: Container(
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
                              _languageOption(
                                'Français',
                                'French',
                                '🇫🇷',
                                'fr',
                              ),
                              Divider(height: 1, color: Colors.grey.shade200),
                              _languageOption(
                                'العربية',
                                'Arabic',
                                '🇩🇿',
                                'ar',
                              ),
                              Divider(height: 1, color: Colors.grey.shade200),
                              _languageOption(
                                'English',
                                'English',
                                '🇬🇧',
                                'en',
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Note RTL
                      if (_selectedLanguage == 'ar')
                        FadeInUp(
                          duration: const Duration(milliseconds: 600),
                          delay: const Duration(milliseconds: 300),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.orange.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.translate_rounded, color: Colors.orange.shade700, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'L\'interface sera en mode RTL (de droite à gauche)',
                                    style: AppColors.bodyMedium(color: Colors.orange.shade900).copyWith(fontSize: 13),
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

  Widget _languageOption(String nom, String nomEn, String flag, String code) {
    final isSelected = _selectedLanguage == code;
    
    return GestureDetector(
      onTap: () => _changeLanguage(code),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.kPrimary.withOpacity(0.05) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.kDark.withOpacity(0.1) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  flag,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nom,
                    style: AppColors.bodyLarge(color: Colors.black).copyWith(
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    nomEn,
                    style: AppColors.labelSmall(color: Colors.black54),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  gradient: AppColors.buttonGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 18),
              )
            else
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}