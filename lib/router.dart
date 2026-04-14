import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/client/home_screen.dart';
import 'screens/client/catalogue_screen.dart';
import 'screens/client/produit_detail_screen.dart';
import 'screens/client/panier_screen.dart';
import 'screens/client/bibliotheque_screen.dart';
import 'screens/client/profil_screen.dart';
import 'screens/client/langue_screen.dart';
import 'screens/vendeur/vendeur_dashboard_screen.dart';
import 'screens/vendeur/mes_produits_screen.dart';
import 'screens/vendeur/ajouter_produit_screen.dart';
import 'screens/vendeur/classement_screen.dart';
import 'screens/vendeur/retraits_screen.dart';
import 'screens/vendeur/profil_vendeur_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/admin_produits_screen.dart';
import 'screens/admin/admin_utilisateurs_screen.dart';
import 'screens/admin/admin_finances_screen.dart';
import 'screens/admin/admin_stats_screen.dart';
import 'screens/shared/notifications_screen.dart';
import 'screens/shared/messages_screen.dart';
import 'screens/shared/splash_screen.dart';
import 'screens/shared/onboarding_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final isLoggedIn = session != null;
      final isPublic = ['/login', '/register', '/splash', '/onboarding'].contains(state.matchedLocation);
      if (!isLoggedIn && !isPublic) return '/login';
      return null;
    },
    routes: [
      GoRoute(path: '/splash',     builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: '/login',      builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register',   builder: (_, __) => const RegisterScreen()),

      // ── Client ──
      ShellRoute(
        builder: (context, state, child) => _ClientShell(child: child),
        routes: [
          GoRoute(path: '/home',          builder: (_, __) => const HomeScreen()),
          GoRoute(path: '/catalogue',     builder: (_, __) => const CatalogueScreen()),
          GoRoute(path: '/produit/:id',   builder: (_, s)  => ProduitDetailScreen(produitId: s.pathParameters['id']!)),
          GoRoute(path: '/panier',        builder: (_, __) => const PanierScreen()),
          GoRoute(path: '/bibliotheque',  builder: (_, __) => const BibliothequeScreen()),
          GoRoute(path: '/profil',        builder: (_, __) => const ProfilScreen()),
          GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen()),
          GoRoute(path: '/messages',      builder: (_, __) => const MessagesScreen()),
          GoRoute(path: '/langue',        builder: (_, __) => const LangueScreen()),
        ],
      ),

      // ── Vendeur ──
      ShellRoute(
        builder: (context, state, child) => _VendeurShell(child: child),
        routes: [
          GoRoute(path: '/vendeur',            builder: (_, __) => const VendeurDashboardScreen()),
          GoRoute(path: '/vendeur/produits',   builder: (_, __) => const MesProduitsScreen()),
          GoRoute(path: '/vendeur/ajouter',    builder: (_, __) => const AjouterProduitScreen()),
          GoRoute(path: '/vendeur/classement', builder: (_, __) => const ClassementScreen()),
          GoRoute(path: '/vendeur/retraits',   builder: (_, __) => const RetraitsScreen()),
          GoRoute(path: '/vendeur/profil',     builder: (_, __) => const ProfilVendeurScreen()),
          GoRoute(path: '/notifications',      builder: (_, __) => const NotificationsScreen()),
          GoRoute(path: '/messages',           builder: (_, __) => const MessagesScreen()),
        ],
      ),

      // ── Admin ──
      ShellRoute(
        builder: (context, state, child) => _AdminShell(child: child),
        routes: [
          GoRoute(path: '/admin',                builder: (_, __) => const AdminDashboardScreen()),
          GoRoute(path: '/admin/produits',       builder: (_, __) => const AdminProduitsScreen()),
          GoRoute(path: '/admin/utilisateurs',   builder: (_, __) => const AdminUtilisateursScreen()),
          GoRoute(path: '/admin/finances',       builder: (_, __) => const AdminFinancesScreen()),
          GoRoute(path: '/admin/stats',          builder: (_, __) => const AdminStatsScreen()),
        ],
      ),
    ],
  );
});

// ── Client Bottom Nav ──
class _ClientShell extends StatelessWidget {
  final Widget child;
  const _ClientShell({required this.child});
  static const kPrimary = Color(0xFF2563EB);

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    int idx = 0;
    if (location.startsWith('/catalogue')) idx = 1;
    else if (location.startsWith('/panier')) idx = 2;
    else if (location.startsWith('/bibliotheque')) idx = 3;
    else if (location.startsWith('/profil')) idx = 4;

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade100)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, -4))],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(context, 0, idx, Icons.home_rounded, Icons.home_outlined, 'Accueil', '/home'),
                _navItem(context, 1, idx, Icons.explore_rounded, Icons.explore_outlined, 'Catalogue', '/catalogue'),
                _navItemSpecial(context, '/panier'),
                _navItem(context, 3, idx, Icons.library_books_rounded, Icons.library_books_outlined, 'Biblio', '/bibliotheque'),
                _navItem(context, 4, idx, Icons.person_rounded, Icons.person_outlined, 'Profil', '/profil'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(BuildContext context, int i, int current, IconData active, IconData inactive, String label, String route) {
    final isActive = i == current;
    return GestureDetector(
      onTap: () => context.go(route),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? kPrimary.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(isActive ? active : inactive, color: isActive ? kPrimary : Colors.grey.shade400, size: 22),
          const SizedBox(height: 3),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: isActive ? FontWeight.w700 : FontWeight.w400, color: isActive ? kPrimary : Colors.grey.shade400)),
        ]),
      ),
    );
  }

  Widget _navItemSpecial(BuildContext context, String route) => GestureDetector(
    onTap: () => context.go(route),
    child: Container(
      width: 48, height: 48,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [kPrimary, Color(0xFF7C3AED)]),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: kPrimary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: const Icon(Icons.shopping_cart_rounded, color: Colors.white, size: 22),
    ),
  );
}

// ── Vendeur Bottom Nav ──
class _VendeurShell extends StatelessWidget {
  final Widget child;
  const _VendeurShell({required this.child});
  static const kPrimary = Color(0xFF2563EB);
  static const kAccent  = Color(0xFF7C3AED);

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    int idx = 0;
    if (location == '/vendeur/produits')        idx = 1;
    else if (location == '/vendeur/ajouter')    idx = 2;
    else if (location == '/vendeur/classement') idx = 3;
    else if (location == '/vendeur/profil')     idx = 4;

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade100)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, -4))],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(context, 0, idx, Icons.dashboard_rounded, Icons.dashboard_outlined, 'Dashboard', '/vendeur'),
                _navItem(context, 1, idx, Icons.inventory_2_rounded, Icons.inventory_2_outlined, 'Produits', '/vendeur/produits'),
                _navItemAdd(context),
                _navItem(context, 3, idx, Icons.leaderboard_rounded, Icons.leaderboard_outlined, 'Classement', '/vendeur/classement'),
                _navItem(context, 4, idx, Icons.person_rounded, Icons.person_outlined, 'Profil', '/vendeur/profil'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(BuildContext context, int i, int current, IconData active, IconData inactive, String label, String route) {
    final isActive = i == current;
    return GestureDetector(
      onTap: () => context.go(route),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? kPrimary.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(isActive ? active : inactive, color: isActive ? kPrimary : Colors.grey.shade400, size: 22),
          const SizedBox(height: 3),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: isActive ? FontWeight.w700 : FontWeight.w400, color: isActive ? kPrimary : Colors.grey.shade400)),
        ]),
      ),
    );
  }

  Widget _navItemAdd(BuildContext context) => GestureDetector(
    onTap: () => context.go('/vendeur/ajouter'),
    child: Container(
      width: 48, height: 48,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [kPrimary, kAccent]),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: kPrimary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: const Icon(Icons.add_rounded, color: Colors.white, size: 26),
    ),
  );
}

// ── Admin Bottom Nav ──
class _AdminShell extends StatelessWidget {
  final Widget child;
  const _AdminShell({required this.child});
  static const kPrimary = Color(0xFF2563EB);

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    int idx = 0;
    if (location == '/admin/produits')          idx = 1;
    else if (location == '/admin/utilisateurs') idx = 2;
    else if (location == '/admin/finances')     idx = 3;
    else if (location == '/admin/stats')        idx = 4;

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade100)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, -4))],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(context, 0, idx, Icons.dashboard_rounded, Icons.dashboard_outlined, 'Dashboard', '/admin'),
                _navItem(context, 1, idx, Icons.inventory_2_rounded, Icons.inventory_2_outlined, 'Produits', '/admin/produits'),
                _navItem(context, 2, idx, Icons.people_rounded, Icons.people_outlined, 'Users', '/admin/utilisateurs'),
                _navItem(context, 3, idx, Icons.account_balance_rounded, Icons.account_balance_outlined, 'Finances', '/admin/finances'),
                _navItem(context, 4, idx, Icons.bar_chart_rounded, Icons.bar_chart_outlined, 'Stats', '/admin/stats'),
                _navItemLogout(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(BuildContext context, int i, int current, IconData active, IconData inactive, String label, String route) {
    final isActive = i == current;
    return GestureDetector(
      onTap: () => context.go(route),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? kPrimary.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(isActive ? active : inactive, color: isActive ? kPrimary : Colors.grey.shade400, size: 20),
          const SizedBox(height: 3),
          Text(label, style: TextStyle(fontSize: 9, fontWeight: isActive ? FontWeight.w700 : FontWeight.w400, color: isActive ? kPrimary : Colors.grey.shade400)),
        ]),
      ),
    );
  }

  Widget _navItemLogout(BuildContext context) => GestureDetector(
    onTap: () async {
      await Supabase.instance.client.auth.signOut();
      if (context.mounted) context.go('/login');
    },
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 36, height: 36,
        decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: const Icon(Icons.logout_rounded, color: Colors.red, size: 18),
      ),
      const SizedBox(height: 3),
      const Text('Quitter', style: TextStyle(fontSize: 9, color: Colors.red, fontWeight: FontWeight.w600)),
    ]),
  );
}