import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../widgets/section_header.dart';
import '../../models/purchase.dart';
import '../../services/supabase_service.dart';
import 'package:uuid/uuid.dart';

// As per the guide, the OCR service logic is integrated here.
// The OcrResult class is defined based on the Edge Function's response.
class OcrResult {
  final String supplier;
  final double amount;
  final String rawText;
  final double confidence; // Placeholder for confidence score

  OcrResult({required this.supplier, required this.amount, required this.rawText, this.confidence = 0.9});

  factory OcrResult.fromJson(Map<String, dynamic> json) {
    return OcrResult(
      supplier: json['supplier'] ?? 'Inconnu',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      rawText: json['rawText'] ?? '',
      // Confidence is not yet implemented in the Edge function, so we use a placeholder
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.9,
    );
  }
}

class ScanInvoicePage extends StatefulWidget {
  const ScanInvoicePage({super.key});

  @override
  State<ScanInvoicePage> createState() => _ScanInvoicePageState();
}

class _ScanInvoicePageState extends State<ScanInvoicePage> {
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  bool _isLoading = false;
  OcrResult? _ocrResult;
  bool _isVerified = false;

  late final TextEditingController _supplierController;
  late final TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _supplierController = TextEditingController();
    _amountController = TextEditingController();
  }

  @override
  void dispose() {
    _supplierController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      setState(() {
        _imageFile = pickedFile;
        _ocrResult = null; // Reset result when image changes
        _isVerified = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur de sélection d'image: $e")));
    }
  }

  Future<void> _processOcr() async {
    if (_imageFile == null) return;

    setState(() { _isLoading = true; });

    try {
      final bytes = await _imageFile!.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await Supabase.instance.client.functions.invoke(
        'ocr-process-invoice',
        body: {'image_base64': base64Image},
      );

      if (response.data['success'] == true) {
        setState(() {
          _ocrResult = OcrResult.fromJson(response.data['result']);
          _supplierController.text = _ocrResult!.supplier;
          _amountController.text = _ocrResult!.amount.toStringAsFixed(2);
        });
      } else {
        throw Exception(response.data['error'] ?? 'Échec de l\'OCR');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur OCR: ${e.toString()}")));
    }
    finally {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scanner une facture')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SectionHeader(title: 'Étape 1: Capturer l\'image'),
            _buildImageCaptureSection(),
            const SizedBox(height: 24),
            if (_imageFile != null)
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _processOcr,
                icon: const Icon(Icons.document_scanner_outlined),
                label: const Text('Lancer le scan OCR'),
              ),
            if (_isLoading) _buildLoadingIndicator(),
            if (_ocrResult != null) _buildResultsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCaptureSection() {
    if (_imageFile == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Icon(Icons.camera_alt_outlined, size: 48, color: Colors.grey),
              const SizedBox(height: 8),
              const Text('Prendre ou choisir une photo'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(onPressed: () => _pickImage(ImageSource.camera), icon: const Icon(Icons.photo_camera), label: const Text('Caméra')),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(onPressed: () => _pickImage(ImageSource.gallery), icon: const Icon(Icons.photo_library), label: const Text('Galerie')),
                ],
              ),
            ],
          ),
        ),
      );
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.file(File(_imageFile!.path), height: 300),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(onPressed: () => setState(() => _imageFile = null), icon: const Icon(Icons.delete_outline), label: const Text('Retirer')),
                TextButton.icon(onPressed: () => _pickImage(ImageSource.gallery), icon: const Icon(Icons.edit), label: const Text('Modifier')),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 32.0),
      child: Column(
        children: [
          LinearProgressIndicator(),
          SizedBox(height: 8),
          Text('Traitement OCR en cours...'),
        ],
      ),
    );
  }

  Widget _buildResultsSection() {
    final confidenceColor = _ocrResult!.confidence > 0.85 ? Colors.green : (_ocrResult!.confidence > 0.65 ? Colors.orange : Colors.red);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        const SectionHeader(title: 'Étape 2: Vérifier les résultats'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextFormField(controller: _supplierController, decoration: const InputDecoration(labelText: 'Fournisseur')),
                const SizedBox(height: 12),
                TextFormField(controller: _amountController, decoration: const InputDecoration(labelText: 'Montant Total', suffixText: '€'), keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                const SizedBox(height: 12),
                Row(children: [const Text('Confiance'), const SizedBox(width: 8), Expanded(child: LinearProgressIndicator(value: _ocrResult!.confidence, color: confidenceColor, minHeight: 8,))]),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        const SectionHeader(title: 'Vérification'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text('Les données extraites semblent-elles correctes ?'),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(onPressed: () => setState(() => _ocrResult = null), child: const Text('Non, recommencer')),
                    const SizedBox(width: 16),
                    ElevatedButton(onPressed: () => setState(() => _isVerified = true), child: const Text('Oui, continuer')),
                  ],
                )
              ],
            ),
          ),
        ),
        if (_isVerified) _buildCreateInvoiceSection(),
      ],
    );
  }

  Widget _buildCreateInvoiceSection() {
    return Column(
      children: [
        const SizedBox(height: 24),
        const SectionHeader(title: 'Étape 3: Actions'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text('Enregistrer en tant qu\'achat ou générer un devis.'),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _savePurchase,
                      child: const Text('Enregistrer l\'achat'),
                    ),
                    ElevatedButton(
                      onPressed: _generateQuote,
                      child: const Text('Générer un devis'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _savePurchase() async {
    if (_ocrResult == null) return;

    setState(() { _isLoading = true; });

    try {
      final newPurchase = Purchase(
        id: const Uuid().v4(),
        userId: Supabase.instance.client.auth.currentUser!.id,
        supplierName: _supplierController.text,
        totalTtc: double.tryParse(_amountController.text) ?? 0.0,
        invoiceDate: DateTime.now(), // Placeholder
        createdAt: DateTime.now(),
      );

      await SupabaseService.addPurchase(newPurchase);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Achat enregistré avec succès')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  Future<void> _generateQuote() async {
    // Placeholder for quote generation logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Génération de devis non implémentée.')),
    );
  }
}
