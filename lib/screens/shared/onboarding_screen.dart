import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import '../../app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageCtrl = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'icon': Icons.store_rounded,
      'title': 'Explorez notre catalogue',
      'subtitle': 'Des milliers de produits digitaux : ebooks, templates, scripts',
    },
    {
      'icon': Icons.workspace_premium_rounded,
      'title': 'Vendez vos créations',
      'subtitle': 'Devenez vendeur et monétisez vos produits digitaux facilement',
    },
    {
      'icon': Icons.verified_user_rounded,
      'title': 'Paiement sécurisé',
      'subtitle': 'Paiements en Dinars Algériens via Dahabia, CIB, BaridiMob',
    },
  ];

  @override
  void dispose() { _pageCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('Passer', style: TextStyle(color: AppColors.kBlueViolet, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),

              // Pages
              Expanded(
                child: PageView.builder(
                  controller: _pageCtrl,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemCount: _pages.length,
                  itemBuilder: (_, i) => _buildPage(_pages[i], i),
                ),
              ),

              // Indicator + Button
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                child: Column(
                  children: [
                    // Dots
                    FadeIn(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_pages.length, (i) => _dot(i)),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Button
                    FadeInUp(
                      from: 30,
                      child: GestureDetector(
                        onTap: () {
                          if (_currentPage == _pages.length - 1) {
                            context.go('/login');
                          } else {
                            _pageCtrl.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
                          }
                        },
                        child: Container(
                          width: double.infinity, height: 56,
                          decoration: BoxDecoration(
                            gradient: AppColors.buttonGradient,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: AppColors.glowShadow(0.4),
                          ),
                          child: Center(
                            child: Text(
                              _currentPage == _pages.length - 1 ? 'Commencer' : 'Suivant',
                              style: const TextStyle(color: AppColors.kLight, fontWeight: FontWeight.w700, fontSize: 16),
                            ),
                          ),
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
    );
  }

  Widget _buildPage(Map<String, dynamic> page, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with staggered animation
          FadeInDown(
            duration: const Duration(milliseconds: 800),
            delay: Duration(milliseconds: 200 * index),
            child: Container(
              width: 140, height: 140,
              decoration: BoxDecoration(
                gradient: AppColors.buttonGradient,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(color: AppColors.kPrimary.withOpacity(0.4), blurRadius: 30, offset: const Offset(0, 12)),
                  BoxShadow(color: AppColors.kBlueViolet.withOpacity(0.2), blurRadius: 50, offset: const Offset(0, 20)),
                ],
              ),
              child: Icon(page['icon'], color: AppColors.kLight, size: 70),
            ),
          ),
          const SizedBox(height: 48),

          // Title
          FadeInUp(
            duration: const Duration(milliseconds: 800),
            delay: Duration(milliseconds: 400 + (200 * index)),
            child: Text(
              page['title'],
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.kLight,
                letterSpacing: -0.5,
                height: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Subtitle
          FadeInUp(
            duration: const Duration(milliseconds: 800),
            delay: Duration(milliseconds: 600 + (200 * index)),
            child: Text(
              page['subtitle'],
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.kBlueViolet,
                fontWeight: FontWeight.w400,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(int index) {
    final isActive = _currentPage == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.kPrimary : AppColors.kBlueViolet.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}