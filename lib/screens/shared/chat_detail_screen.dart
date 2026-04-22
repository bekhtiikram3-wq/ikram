import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:animate_do/animate_do.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../app_colors.dart';
import '../client/boutique_vendeur_screen.dart';

class ChatDetailScreen extends StatefulWidget {
  final String vendeurId;
  final String vendeurNom;

  const ChatDetailScreen({
    super.key,
    required this.vendeurId,
    required this.vendeurNom,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final supabase = Supabase.instance.client;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  
  List<Map<String, dynamic>> _messages = [];
  bool _loading = true;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('fr', timeago.FrMessages());
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    try {
      final userId = supabase.auth.currentUser?.id ?? 'user123';
      await Future.delayed(const Duration(milliseconds: 500));
      
      final messages = [
        {
          'id': '1',
          'contenu': 'Bonjour, j\'ai acheté votre ebook mais je ne le trouve pas',
          'expediteur_id': userId,
          'est_moi': true,
          'timestamp': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        },
        {
          'id': '2',
          'contenu': 'Bonjour ! Pas de souci, je vérifie ça pour vous',
          'expediteur_id': widget.vendeurId,
          'est_moi': false,
          'timestamp': DateTime.now().subtract(const Duration(hours: 2, minutes: 5)).toIso8601String(),
        },
        {
          'id': '3',
          'contenu': 'Votre produit est maintenant disponible dans votre bibliothèque',
          'expediteur_id': widget.vendeurId,
          'est_moi': false,
          'timestamp': DateTime.now().subtract(const Duration(hours: 1, minutes: 30)).toIso8601String(),
        },
        {
          'id': '4',
          'contenu': 'Parfait, je l\'ai trouvé ! Merci beaucoup 🙏',
          'expediteur_id': userId,
          'est_moi': true,
          'timestamp': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
        },
      ];

      if (mounted) {
        setState(() {
          _messages = messages;
          _loading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  Future<void> _envoyerMessage() async {
    final texte = _messageController.text.trim();
    if (texte.isEmpty || _sending) return;

    setState(() => _sending = true);

    try {
      final userId = supabase.auth.currentUser?.id ?? 'user123';
      
      final nouveauMessage = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'contenu': texte,
        'expediteur_id': userId,
        'est_moi': true,
        'timestamp': DateTime.now().toIso8601String(),
      };

      setState(() {
        _messages.add(nouveauMessage);
        _messageController.clear();
        _sending = false;
      });

      _focusNode.unfocus();
      _scrollToBottom();
    } catch (e) {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _afficherMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.store_rounded, color: AppColors.kDark),
                title: Text('Voir la boutique', style: AppColors.bodyLarge(color: Colors.black)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BoutiqueVendeurScreen(
                        vendeurId: widget.vendeurId,
                        vendeurNom: widget.vendeurNom,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.notifications_off_outlined, color: Colors.orange.shade700),
                title: Text('Couper les notifications', style: AppColors.bodyLarge(color: Colors.black)),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Notifications désactivées pour cette conversation'),
                      backgroundColor: Colors.orange.shade700,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
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
                            onPressed: () => Navigator.pop(context),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: AppColors.buttonGradient,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              widget.vendeurNom[0].toUpperCase(),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.vendeurNom,
                                style: AppColors.bodyLarge(color: Colors.black).copyWith(fontWeight: FontWeight.w700),
                              ),
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade400,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text('En ligne', style: AppColors.labelSmall(color: Colors.black54)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.more_vert_rounded, color: Colors.black54, size: 20),
                            onPressed: _afficherMenu,
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Messages
                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.kDark))
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(20),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final message = _messages[index];
                            final estMoi = message['est_moi'] == true;
                            return FadeInUp(
                              duration: const Duration(milliseconds: 400),
                              delay: Duration(milliseconds: 50 * index),
                              child: _messageBubble(message, estMoi),
                            );
                          },
                        ),
                ),

                // Zone de saisie
                FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: TextField(
                                controller: _messageController,
                                focusNode: _focusNode,
                                decoration: InputDecoration(
                                  hintText: 'Écrivez votre message...',
                                  hintStyle: AppColors.bodyMedium(color: Colors.black38),
                                  border: InputBorder.none,
                                ),
                                maxLines: null,
                                textCapitalization: TextCapitalization.sentences,
                                onSubmitted: (_) => _envoyerMessage(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: _envoyerMessage,
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                gradient: AppColors.buttonGradient,
                                shape: BoxShape.circle,
                                boxShadow: AppColors.glowShadow(0.3),
                              ),
                              child: _sending
                                  ? const Padding(
                                      padding: EdgeInsets.all(12),
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                            ),
                          ),
                        ],
                      ),
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

  Widget _messageBubble(Map<String, dynamic> message, bool estMoi) {
    final timestamp = DateTime.parse(message['timestamp']);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: estMoi ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!estMoi) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: AppColors.buttonGradient,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  widget.vendeurNom[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: estMoi ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: estMoi ? AppColors.buttonGradient : null,
                    color: estMoi ? null : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(estMoi ? 20 : 4),
                      bottomRight: Radius.circular(estMoi ? 4 : 20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message['contenu'] ?? '',
                    style: AppColors.bodyMedium(
                      color: estMoi ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timeago.format(timestamp, locale: 'fr'),
                  style: AppColors.labelSmall(color: Colors.black38).copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          if (estMoi) const SizedBox(width: 8),
        ],
      ),
    );
  }
}