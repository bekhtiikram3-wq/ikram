import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'router.dart';

final supabase = Supabase.instance.client;

class LocaleNotifier extends ValueNotifier<Locale> {
  LocaleNotifier() : super(const Locale('fr'));
  Future<void> setLocale(String code) async {
    value = Locale(code);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('langue', code);
  }
}

final localeNotifier = LocaleNotifier();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ✅ Empêcher rotation écran (optionnel)
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  await Supabase.initialize(
    url: 'https://qhvotwpezzooosdvupkt.supabase.co',
    anonKey: 'sb_publishable_MLxPqNgTR0kxSmrn4vXdbw_cbeuzZF_',
  );
  final prefs = await SharedPreferences.getInstance();
  localeNotifier.value = Locale(prefs.getString('langue') ?? 'fr');
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});
  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    localeNotifier.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final locale = localeNotifier.value;
    
    return MaterialApp.router(
      title: 'DigitalStore DZ',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      locale: locale,
      supportedLocales: const [Locale('fr'), Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // ✅ GESTION GLOBALE DU BOUTON RETOUR
      builder: (context, child) {
        return WillPopScope(
          onWillPop: () async {
            // Récupère la route actuelle
            final currentRoute = router.routerDelegate.currentConfiguration.uri.toString();
            
            // Définit où aller selon la page actuelle
            if (currentRoute.contains('/notifications') ||
                currentRoute.contains('/wishlist') ||
                currentRoute.contains('/aide') ||
                currentRoute.contains('/confidentialite') ||
                currentRoute.contains('/langue') ||
                currentRoute.contains('/messages')) {
              router.go('/profil');
              return false;
            }
            else if (currentRoute.contains('/produit/')) {
              router.go('/catalogue');
              return false;
            }
            else if (currentRoute.contains('/panier') ||
                     currentRoute.contains('/bibliotheque')) {
              router.go('/home');
              return false;
            }
            
            // Pour les autres pages, comportement par défaut
            return true;
          },
          child: Directionality(
            textDirection: locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
            child: child!,
          ),
        );
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB), brightness: Brightness.light),
        useMaterial3: true,
        fontFamily: 'Roboto',
        // ✅ SWIPE BACK ACTIVÉ
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}