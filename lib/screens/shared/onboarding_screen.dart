import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with TickerProviderStateMixin {
  final _pageCtrl = PageController();
  int _page = 0;

  static const kPrimary = Color(0xFF2563EB);
  static const kAccent  = Color(0xFF7C3AED);

  final _pages = [
    {
      'icon': Icons.auto_stories_rounded,
      'color': const Color(0xFF2563EB),
      'bg': const Color(0xFFEFF6FF),
      'title': 'Ebooks & Guides',
      'sub': 'Accédez à des centaines d\'ebooks et guides dans tous les domaines, directement sur votre mobile.',
    },
    {
      'icon': Icons.palette_rounded,
      'color': const Color(0xFF7C3AED),
      'bg': const Color(0xFFF5F3FF),
      'title': 'Templates Premium',
      'sub': 'Des templates de design professionnels pour Figma, Adobe et plus encore.',
    },
    {
      'icon': Icons.code_rounded,
      'color': const Color(0xFF059669),
      'bg': const Color(0xFFECFDF5),
      'title': 'Scripts & Outils',
      'sub': 'Des scripts prêts à l\'emploi pour automatiser vos tâches et booster votre productivité.',
    },
  ];

  @override
  void dispose() { _pageCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ShaderMask(
                    shaderCallback: (b) => const LinearGradient(colors: [kPrimary, kAccent]).createShader(b),
                    child: const Text('DigitalStore', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Colors.white)),
                  ),
                  if (_page < 2)
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: Text('Passer', style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
                    ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageCtrl,
                onPageChanged: (i) => setState(() => _page = i),
                itemCount: _pages.length,
                itemBuilder: (_, i) {
                  final p = _pages[i];
                  final color = p['color'] as Color;
                  final bg    = p['bg'] as Color;
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 180, height: 180,
                          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
                          child: Icon(p['icon'] as IconData, size: 90, color: color),
                        ),
                        const SizedBox(height: 48),
                        Text(p['title'] as String, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), letterSpacing: -0.5), textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        Text(p['sub'] as String, style: TextStyle(fontSize: 15, color: Colors.grey.shade500, height: 1.6), textAlign: TextAlign.center),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
              child: Column(
                children: [
                  // Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _page == i ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _page == i ? kPrimary : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    )),
                  ),
                  const SizedBox(height: 32),
                  // Bouton
                  GestureDetector(
                    onTap: () {
                      if (_page < 2) _pageCtrl.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeOutCubic);
                      else context.go('/login');
                    },
                    child: Container(
                      width: double.infinity, height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [kPrimary, kAccent]),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: kPrimary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
                      ),
                      child: Center(child: Text(_page < 2 ? 'Suivant' : 'Commencer', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16))),
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
