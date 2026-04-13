import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

class AjouterProduitScreen extends StatefulWidget {
  const AjouterProduitScreen({super.key});
  @override
  State<AjouterProduitScreen> createState() => _AjouterProduitScreenState();
}

class _AjouterProduitScreenState extends State<AjouterProduitScreen> {
  final supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();
  final _titreCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _prixCtrl = TextEditingController();
  final _langageCtrl = TextEditingController();
  final _logicielCtrl = TextEditingController();
  String _categorie = 'ebook';
  String _formatEbook = 'pdf';
  String _formatTemplate = 'figma';
  String _formatScript = 'zip';
  bool _loading = false;

  static const Color kBlue1 = Color(0xFF1565C0);
  static const Color kBlue2 = Color(0xFF1E88E5);
  static const Color kBlueBg = Color(0xFFE3F2FD);

  @override
  void dispose() {
    _titreCtrl.dispose(); _descCtrl.dispose(); _prixCtrl.dispose();
    _langageCtrl.dispose(); _logicielCtrl.dispose();
    super.dispose();
  }

  Future<void> _creerProduit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await supabase.rpc('creer_produit', params: {
        'p_titre': _titreCtrl.text.trim(),
        'p_description': _descCtrl.text.trim(),
        'p_description_courte': _descCtrl.text.trim().substring(0, _descCtrl.text.trim().length.clamp(0, 100)),
        'p_prix_dzd': double.parse(_prixCtrl.text),
        'p_categorie_type': _categorie,
        if (_categorie == 'ebook') 'p_format_ebook': _formatEbook,
        if (_categorie == 'ebook') 'p_langue': 'Français',
        if (_categorie == 'template') 'p_logiciel': _logicielCtrl.text.trim(),
        if (_categorie == 'template') 'p_format_template': _formatTemplate,
        if (_categorie == 'script') 'p_langage': _langageCtrl.text.trim(),
        if (_categorie == 'script') 'p_format_script': _formatScript,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produit créé avec succès !'), backgroundColor: Colors.green),
      );
      context.go('/vendeur/produits');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: kBlue1,
        title: const Text('Ajouter un produit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type de produit
              _section('Type de produit'),
              Row(children: [
                _catCard('ebook', 'Ebook', Icons.menu_book_rounded, const Color(0xFF1565C0)),
                const SizedBox(width: 10),
                _catCard('template', 'Template', Icons.palette_rounded, const Color(0xFF6A1B9A)),
                const SizedBox(width: 10),
                _catCard('script', 'Script', Icons.code_rounded, const Color(0xFF00695C)),
              ]),
              const SizedBox(height: 20),

              _section('Informations générales'),
              _field(_titreCtrl, 'Titre du produit', Icons.title, validator: (v) => v!.isEmpty ? 'Requis' : null),
              const SizedBox(height: 12),
              _field(_descCtrl, 'Description complète', Icons.description, maxLines: 4, validator: (v) => v!.isEmpty ? 'Requis' : null),
              const SizedBox(height: 12),
              _field(_prixCtrl, 'Prix (DZD)', Icons.payments_outlined, keyboardType: TextInputType.number, validator: (v) {
                if (v!.isEmpty) return 'Requis';
                if (double.tryParse(v) == null) return 'Prix invalide';
                return null;
              }),
              const SizedBox(height: 20),

              // Champs spécifiques par catégorie
              if (_categorie == 'ebook') ...[
                _section('Détails Ebook'),
                const Text('Format', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1A237E))),
                const SizedBox(height: 8),
                Wrap(spacing: 8, children: ['pdf', 'epub', 'mobi'].map((f) => GestureDetector(
                  onTap: () => setState(() => _formatEbook = f),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _formatEbook == f ? kBlue1 : kBlueBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(f.toUpperCase(), style: TextStyle(color: _formatEbook == f ? Colors.white : kBlue1, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                )).toList()),
              ],

              if (_categorie == 'template') ...[
                _section('Détails Template'),
                _field(_logicielCtrl, 'Logiciel (ex: Figma, Adobe XD...)', Icons.design_services),
                const SizedBox(height: 12),
                const Text('Format', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1A237E))),
                const SizedBox(height: 8),
                Wrap(spacing: 8, children: ['figma', 'psd', 'ai', 'xd', 'sketch'].map((f) => GestureDetector(
                  onTap: () => setState(() => _formatTemplate = f),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: _formatTemplate == f ? const Color(0xFF6A1B9A) : const Color(0xFFF3E5F5), borderRadius: BorderRadius.circular(20)),
                    child: Text(f.toUpperCase(), style: TextStyle(color: _formatTemplate == f ? Colors.white : const Color(0xFF6A1B9A), fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                )).toList()),
              ],

              if (_categorie == 'script') ...[
                _section('Détails Script'),
                _field(_langageCtrl, 'Langage (ex: Python, JavaScript...)', Icons.code),
                const SizedBox(height: 12),
                const Text('Format', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1A237E))),
                const SizedBox(height: 8),
                Wrap(spacing: 8, children: ['zip', 'js', 'py', 'ts', 'php'].map((f) => GestureDetector(
                  onTap: () => setState(() => _formatScript = f),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: _formatScript == f ? const Color(0xFF00695C) : const Color(0xFFE0F2F1), borderRadius: BorderRadius.circular(20)),
                    child: Text('.${f.toUpperCase()}', style: TextStyle(color: _formatScript == f ? Colors.white : const Color(0xFF00695C), fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                )).toList()),
              ],

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _creerProduit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kBlue1,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _loading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Créer le produit', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
  );

  Widget _catCard(String key, String label, IconData icon, Color color) => Expanded(
    child: GestureDetector(
      onTap: () => setState(() => _categorie = key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: _categorie == key ? color : color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color, width: _categorie == key ? 2 : 1),
        ),
        child: Column(children: [
          Icon(icon, color: _categorie == key ? Colors.white : color, size: 26),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(color: _categorie == key ? Colors.white : color, fontWeight: FontWeight.bold, fontSize: 12)),
        ]),
      ),
    ),
  );

  Widget _field(TextEditingController ctrl, String hint, IconData icon, {int maxLines = 1, TextInputType? keyboardType, String? Function(String?)? validator}) => TextFormField(
    controller: ctrl,
    maxLines: maxLines,
    keyboardType: keyboardType,
    validator: validator,
    decoration: InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: kBlue1),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kBlue1, width: 2)),
      filled: true,
      fillColor: Colors.white,
    ),
  );
}
