import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:animate_do/animate_do.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../app_colors.dart';
import 'chat_detail_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _conversations = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('fr', timeago.FrMessages());
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId != null) {
        await Future.delayed(const Duration(milliseconds: 500));
        
        final conversations = [
          {
            'id': '1',
            'vendeur_id': 'v1',
            'vendeur_nom': 'TechStore DZ',
            'vendeur_avatar': null,
            'dernier_message': 'Bonjour, votre produit est prêt à télécharger',
            'non_lu': 2,
            'timestamp': DateTime.now().subtract(const Duration(minutes: 5)).toIso8601String(),
          },
          {
            'id': '2',
            'vendeur_id': 'v2',
            'vendeur_nom': 'DesignHub',
            'vendeur_avatar': null,
            'dernier_message': 'Merci pour votre achat !',
            'non_lu': 0,
            'timestamp': DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
          },
          {
            'id': '3',
            'vendeur_id': 'v3',
            'vendeur_nom': 'CodeMasters',
            'vendeur_avatar': null,
            'dernier_message': 'Le fichier a été mis à jour',
            'non_lu': 1,
            'timestamp': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
          },
        ];

        if (mounted) {
          setState(() {
            _conversations = conversations;
            _loading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _ouvrirChat(String vendeurId, String vendeurNom) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatDetailScreen(
          vendeurId: vendeurId,
          vendeurNom: vendeurNom,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                              Text('Messages', style: AppColors.headingMedium(color: Colors.black).copyWith(fontSize: 20)),
                              Text('${_conversations.length} conversation${_conversations.length > 1 ? 's' : ''}', style: AppColors.labelSmall(color: Colors.black54)),
                            ],
                          ),
                        ),
                        Icon(Icons.chat_bubble_outline_rounded, color: AppColors.kDark, size: 28),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.kDark))
                      : _conversations.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.chat_bubble_outline_rounded, size: 80, color: Colors.black12),
                                  const SizedBox(height: 16),
                                  Text('Aucun message', style: AppColors.headingMedium(color: Colors.black54)),
                                  const SizedBox(height: 8),
                                  Text('Contactez un vendeur pour commencer', style: AppColors.bodyMedium(color: Colors.black38)),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _loadConversations,
                              color: AppColors.kDark,
                              child: ListView.builder(
                                padding: const EdgeInsets.all(20),
                                itemCount: _conversations.length,
                                itemBuilder: (context, index) {
                                  final conv = _conversations[index];
                                  return FadeInUp(
                                    duration: const Duration(milliseconds: 600),
                                    delay: Duration(milliseconds: 100 * index),
                                    child: _conversationCard(conv),
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

  Widget _conversationCard(Map<String, dynamic> conv) {
    final nonLu = conv['non_lu'] as int? ?? 0;
    final timestamp = DateTime.parse(conv['timestamp']);

    return GestureDetector(
      onTap: () => _ouvrirChat(conv['vendeur_id'], conv['vendeur_nom']),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: nonLu > 0 ? AppColors.kPrimary.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: nonLu > 0 ? AppColors.kPrimary.withOpacity(0.2) : Colors.grey.shade200,
            width: nonLu > 0 ? 2 : 1,
          ),
          boxShadow: [
            if (nonLu > 0)
              BoxShadow(
                color: AppColors.kPrimary.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: AppColors.buttonGradient,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      (conv['vendeur_nom'] ?? 'V')[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                if (nonLu > 0)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                      child: Center(
                        child: Text(
                          '$nonLu',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          conv['vendeur_nom'] ?? '',
                          style: AppColors.bodyLarge(color: Colors.black).copyWith(
                            fontWeight: nonLu > 0 ? FontWeight.w800 : FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        timeago.format(timestamp, locale: 'fr'),
                        style: AppColors.labelSmall(color: Colors.black45),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conv['dernier_message'] ?? '',
                          style: AppColors.bodyMedium(color: nonLu > 0 ? Colors.black87 : Colors.black54),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, color: Colors.black26, size: 24),
          ],
        ),
      ),
    );
  }
}