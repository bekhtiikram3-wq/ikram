import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:animate_do/animate_do.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _notifications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('fr', timeago.FrMessages());
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId != null) {
        await Future.delayed(const Duration(milliseconds: 500));
        
        final notifications = [
          {
            'id': '1',
            'type': 'commande',
            'titre': 'Commande confirmée',
            'message': 'Votre commande #12345 a été confirmée',
            'lu': false,
            'created_at': DateTime.now().subtract(const Duration(minutes: 5)).toIso8601String(),
          },
          {
            'id': '2',
            'type': 'produit',
            'titre': 'Nouveau produit disponible',
            'message': 'Un nouveau template UI/UX est disponible',
            'lu': false,
            'created_at': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
          },
          {
            'id': '3',
            'type': 'promotion',
            'titre': 'Promotion -30%',
            'message': 'Profitez de -30% sur tous les ebooks ce weekend',
            'lu': true,
            'created_at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
          },
          {
            'id': '4',
            'type': 'systeme',
            'titre': 'Mise à jour disponible',
            'message': 'Une nouvelle version de l\'app est disponible',
            'lu': true,
            'created_at': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
          },
        ];

        if (mounted) {
          setState(() {
            _notifications = notifications;
            _loading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'commande': return Icons.shopping_bag_rounded;
      case 'produit': return Icons.new_releases_rounded;
      case 'promotion': return Icons.local_offer_rounded;
      case 'systeme': return Icons.info_rounded;
      default: return Icons.notifications_rounded;
    }
  }

  Color _getColor(String type) {
    switch (type) {
      case 'commande': return AppColors.kDark;
      case 'produit': return AppColors.kPrimary;
      case 'promotion': return Colors.orange.shade600;
      case 'systeme': return Colors.blue.shade600;
      default: return AppColors.kDark;
    }
  }

  void _marquerCommeLu(String id) {
    setState(() {
      final index = _notifications.indexWhere((n) => n['id'] == id);
      if (index != -1) {
        _notifications[index]['lu'] = true;
      }
    });
  }

  void _marquerToutCommeLu() {
    setState(() {
      for (var notif in _notifications) {
        notif['lu'] = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final nonLues = _notifications.where((n) => n['lu'] == false).length;

    return WillPopScope(
      onWillPop: () async {
        context.go('/profil');
        return false;
      },
      child: Scaffold(
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Notifications', style: AppColors.headingMedium(color: Colors.black).copyWith(fontSize: 20)),
                              if (nonLues > 0)
                                Text('$nonLues non lue${nonLues > 1 ? 's' : ''}', style: AppColors.labelSmall(color: AppColors.kDark)),
                            ],
                          ),
                        ),
                        if (nonLues > 0)
                          TextButton(
                            onPressed: _marquerToutCommeLu,
                            child: Text('Tout marquer', style: AppColors.labelSmall(color: AppColors.kDark)),
                          ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.kDark))
                      : _notifications.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.notifications_off_outlined, size: 64, color: Colors.black26),
                                  const SizedBox(height: 16),
                                  Text('Aucune notification', style: AppColors.bodyLarge(color: Colors.black54)),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _loadNotifications,
                              color: AppColors.kDark,
                              child: ListView.builder(
                                padding: const EdgeInsets.all(20),
                                itemCount: _notifications.length,
                                itemBuilder: (context, index) {
                                  final notif = _notifications[index];
                                  return FadeInUp(
                                    duration: const Duration(milliseconds: 600),
                                    delay: Duration(milliseconds: 100 * index),
                                    child: _notificationCard(notif),
                                  );
                                },
                              ),
                            ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _notificationCard(Map<String, dynamic> notif) {
    final isLu = notif['lu'] == true;
    final type = notif['type'] ?? 'systeme';
    final date = DateTime.parse(notif['created_at']);

    return GestureDetector(
      onTap: () => _marquerCommeLu(notif['id']),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isLu ? Colors.white : AppColors.kPrimary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isLu ? Colors.grey.shade200 : AppColors.kPrimary.withOpacity(0.2),
            width: isLu ? 1 : 2,
          ),
          boxShadow: [
            if (!isLu)
              BoxShadow(
                color: AppColors.kPrimary.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getColor(type).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_getIcon(type), color: _getColor(type), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notif['titre'] ?? '',
                          style: AppColors.bodyLarge(color: Colors.black).copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      if (!isLu)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.kDark,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notif['message'] ?? '',
                    style: AppColors.bodyMedium(color: Colors.black87),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    timeago.format(date, locale: 'fr'),
                    style: AppColors.labelSmall(color: Colors.black45),
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