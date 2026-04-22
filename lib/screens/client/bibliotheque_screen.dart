import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:animate_do/animate_do.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../../app_colors.dart';

class BibliothequeScreen extends StatefulWidget {
  const BibliothequeScreen({super.key});

  @override
  State<BibliothequeScreen> createState() => _BibliothequeScreenState();
}

class _BibliothequeScreenState extends State<BibliothequeScreen> {
  final supabase = Supabase.instance.client;
  final Dio _dio = Dio();
  
  List<Map<String, dynamic>> _achats = [];
  bool _loading = true;
  String _filtreCategorie = 'Tous';
  
  String? _downloadingId;
  double _downloadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('fr', timeago.FrMessages());
    _loadAchats();
  }

  Future<void> _loadAchats() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId != null) {
        await Future.delayed(const Duration(milliseconds: 500));
        
        final achats = [
          {
            'id': '1',
            'produit': {
              'id': 'p1',
              'titre': 'UI/UX Design Masterclass 2024',
              'categorie': 'Formation',
              'images': ['https://picsum.photos/400/300?random=1'],
              'type_fichier': 'mp4',
              'taille_fichier': '2.5 MB',
            },
            'date_achat': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
            'prix_paye': 4500,
            'fichier_url': 'https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-mp4-file.mp4',
          },
          {
            'id': '2',
            'produit': {
              'id': 'p2',
              'titre': 'Pack 500 Templates Figma',
              'categorie': 'Design',
              'images': ['https://picsum.photos/400/300?random=2'],
              'type_fichier': 'zip',
              'taille_fichier': '850 KB',
            },
            'date_achat': DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
            'prix_paye': 3200,
            'fichier_url': 'https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-zip-file.zip',
          },
          {
            'id': '3',
            'produit': {
              'id': 'p3',
              'titre': 'Guide Complet Flutter Firebase',
              'categorie': 'eBook',
              'images': ['https://picsum.photos/400/300?random=3'],
              'type_fichier': 'pdf',
              'taille_fichier': '45 KB',
            },
            'date_achat': DateTime.now().subtract(const Duration(days: 15)).toIso8601String(),
            'prix_paye': 2800,
            'fichier_url': 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
          },
          {
            'id': '4',
            'produit': {
              'id': 'p4',
              'titre': 'Code Source App Ecommerce',
              'categorie': 'Code',
              'images': ['https://picsum.photos/400/300?random=4'],
              'type_fichier': 'zip',
              'taille_fichier': '120 KB',
            },
            'date_achat': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
            'prix_paye': 8900,
            'fichier_url': 'https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-zip-file.zip',
          },
        ];

        if (mounted) {
          setState(() {
            _achats = achats;
            _loading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> get _achatsFiltres {
    if (_filtreCategorie == 'Tous') return _achats;
    return _achats.where((a) => a['produit']['categorie'] == _filtreCategorie).toList();
  }

  Future<void> _telecharger(String achatId, String url, String titre, String extension) async {
    setState(() {
      _downloadingId = achatId;
      _downloadProgress = 0.0;
    });

    try {
      // Utiliser le dossier Documents de l'app (pas besoin de permission)
      final directory = await getApplicationDocumentsDirectory();
      final fileName = '${titre.replaceAll(RegExp(r'[^\w\s]+'), '')}_${DateTime.now().millisecondsSinceEpoch}.$extension';
      final filePath = '${directory.path}/$fileName';

      await _dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              _downloadProgress = received / total;
            });
          }
        },
      );

      if (mounted) {
        setState(() {
          _downloadingId = null;
          _downloadProgress = 0.0;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('✓ "$titre" téléchargé !', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 6),
                Text('📁 Fichier sauvegardé dans l\'application', style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 2),
                Text('Nom: $fileName', style: const TextStyle(fontSize: 11)),
              ],
            ),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 8),
            action: SnackBarAction(
              label: 'OUVRIR',
              textColor: Colors.white,
              onPressed: () async {
                final result = await OpenFile.open(filePath);
                if (result.type != ResultType.done && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Impossible d\'ouvrir le fichier: ${result.message}'),
                      backgroundColor: Colors.orange,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                }
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _downloadingId = null;
          _downloadProgress = 0.0;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ['Tous', 'Formation', 'Design', 'eBook', 'Code'];
    
    return Scaffold(
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
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Ma Bibliothèque', style: AppColors.headingMedium(color: Colors.black).copyWith(fontSize: 24)),
                              Text('${_achats.length} produit${_achats.length > 1 ? 's' : ''}', style: AppColors.labelSmall(color: Colors.black54)),
                            ],
                          ),
                          Icon(Icons.library_books_rounded, color: AppColors.kDark, size: 32),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 40,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final cat = categories[index];
                            final isActive = _filtreCategorie == cat;
                            return GestureDetector(
                              onTap: () => setState(() => _filtreCategorie = cat),
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  gradient: isActive ? AppColors.buttonGradient : null,
                                  color: isActive ? null : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: Text(
                                    cat,
                                    style: AppColors.bodyMedium(
                                      color: isActive ? Colors.white : Colors.black54,
                                    ).copyWith(fontWeight: isActive ? FontWeight.w700 : FontWeight.w500),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.kDark))
                    : _achatsFiltres.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.black12),
                                const SizedBox(height: 16),
                                Text('Aucun achat', style: AppColors.headingMedium(color: Colors.black54)),
                                const SizedBox(height: 8),
                                Text('Explorez le catalogue pour acheter', style: AppColors.bodyMedium(color: Colors.black38)),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: () => context.go('/catalogue'),
                                  icon: const Icon(Icons.explore_rounded),
                                  label: const Text('Explorer'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.kDark,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadAchats,
                            color: AppColors.kDark,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(20),
                              itemCount: _achatsFiltres.length,
                              itemBuilder: (context, index) {
                                final achat = _achatsFiltres[index];
                                return FadeInUp(
                                  duration: const Duration(milliseconds: 600),
                                  delay: Duration(milliseconds: 100 * index),
                                  child: _achatCard(achat),
                                );
                              },
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _achatCard(Map<String, dynamic> achat) {
    final produit = achat['produit'] as Map<String, dynamic>;
    final dateAchat = DateTime.parse(achat['date_achat']);
    final isDownloading = _downloadingId == achat['id'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: produit['images'] != null && (produit['images'] as List).isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: produit['images'][0],
                    width: double.infinity,
                    height: 160,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: Colors.grey.shade200),
                    errorWidget: (_, __, ___) => Container(
                      height: 160,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.image_not_supported_outlined, size: 48),
                    ),
                  )
                : Container(
                    height: 160,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image_not_supported_outlined, size: 48),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.kPrimary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        produit['categorie'] ?? '',
                        style: AppColors.labelSmall(color: AppColors.kDark).copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.access_time_rounded, size: 14, color: Colors.black45),
                    const SizedBox(width: 4),
                    Text(
                      timeago.format(dateAchat, locale: 'fr'),
                      style: AppColors.labelSmall(color: Colors.black45),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  produit['titre'] ?? '',
                  style: AppColors.bodyLarge(color: Colors.black).copyWith(fontWeight: FontWeight.w700, fontSize: 16),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(_getFileIcon(produit['type_fichier']), size: 16, color: Colors.black54),
                    const SizedBox(width: 6),
                    Text(
                      '${produit['type_fichier']?.toUpperCase()} • ${produit['taille_fichier']}',
                      style: AppColors.bodyMedium(color: Colors.black54),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: isDownloading
                      ? Column(
                          children: [
                            LinearProgressIndicator(
                              value: _downloadProgress,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.kDark),
                              minHeight: 8,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${(_downloadProgress * 100).toInt()}% - Téléchargement...',
                              style: AppColors.bodyMedium(color: AppColors.kDark).copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        )
                      : ElevatedButton.icon(
                          onPressed: () => _telecharger(
                            achat['id'],
                            achat['fichier_url'],
                            produit['titre'],
                            produit['type_fichier'],
                          ),
                          icon: const Icon(Icons.download_rounded, size: 20),
                          label: const Text('Télécharger'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.kDark,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'mp4':
      case 'video':
        return Icons.video_library_rounded;
      case 'zip':
        return Icons.folder_zip_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }
}