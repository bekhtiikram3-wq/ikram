import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/main.dart';

class LangueScreen extends StatefulWidget {
  const LangueScreen({super.key});
  @override
  State<LangueScreen> createState() => _LangueScreenState();
}

class _LangueScreenState extends State<LangueScreen> {
  String _langueSelectee = 'fr';

  static const kPrimary = Color(0xFF2563EB);
  static const kAccent  = Color(0xFF7C3AED);
  static const kBg      = Color(0xFFF8FAFC);

  final List<Map<String, dynamic>> _langues = [
    {'code': 'fr', 'nom': 'Français',  'drapeau': '🇫🇷', 'natif': 'Français'},
    {'code': 'ar', 'nom': 'العربية',   'drapeau': '🇩🇿', 'natif': 'اللغة العربية'},
    {'code': 'en', 'nom': 'English',   'drapeau': '🇬🇧', 'natif': 'English'},
  ];

  @override
  void initState() {
    super.initState();
    _langueSelectee = localeNotifier.value.languageCode;
  }

  Future<void> _confirmer() async {
    // Changer la langue immédiatement
    await localeNotifier.setLocale(_langueSelectee);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        _langueSelectee == 'fr' ? '✓ Langue : Français' :
        _langueSelectee == 'ar' ? '✓ اللغة : العربية' :
        '✓ Language: English',
      ),
      backgroundColor: Colors.green.shade400,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Column(children: [
        Container(
          color: Colors.white,
          padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 12, 20, 20),
          child: Row(children: [
            GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: kBg,
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Color(0xFF0F172A)),
              ),
            ),
            const SizedBox(width: 14),
            const Text('Langue', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
          ]),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: kPrimary.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: kPrimary.withOpacity(0.15)),
                ),
                child: Row(children: [
                  const Icon(Icons.info_outline_rounded, color: kPrimary, size: 18),
                  const SizedBox(width: 10),
                  Expanded(child: Text(
                    'Le changement s\'applique immédiatement.',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  )),
                ]),
              ),
              const SizedBox(height: 24),
              const Text('Choisissez une langue',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF374151))),
              const SizedBox(height: 12),
              ...(_langues.map((l) {
                final isSelected = _langueSelectee == l['code'];
                return GestureDetector(
                  onTap: () => setState(() => _langueSelectee = l['code'] as String),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected ? kPrimary.withOpacity(0.06) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? kPrimary : Colors.grey.shade200,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(children: [
                      Container(
                        width: 52, height: 52,
                        decoration: BoxDecoration(
                          color: isSelected ? kPrimary.withOpacity(0.1) : kBg,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(child: Text(l['drapeau'] as String, style: const TextStyle(fontSize: 26))),
                      ),
                      const SizedBox(width: 14),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(l['nom'] as String, style: TextStyle(
                          fontSize: 15,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                          color: isSelected ? kPrimary : const Color(0xFF0F172A),
                        )),
                        Text(l['natif'] as String, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                      ])),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 24, height: 24,
                        decoration: BoxDecoration(
                          color: isSelected ? kPrimary : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? kPrimary : Colors.grey.shade300,
                            width: 1.5,
                          ),
                        ),
                        child: isSelected ? const Icon(Icons.check_rounded, color: Colors.white, size: 14) : null,
                      ),
                    ]),
                  ),
                );
              })),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _confirmer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                  ),
                  child: const Text(
                    'Confirmer',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}