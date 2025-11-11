import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../models/purchase.dart';
import '../../services/supabase_service.dart';

class PurchaseFormPage extends StatefulWidget {
  final String? purchaseId;

  const PurchaseFormPage({super.key, this.purchaseId});

  @override
  State<PurchaseFormPage> createState() => _PurchaseFormPageState();
}

class _PurchaseFormPageState extends State<PurchaseFormPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Form fields
  String? _supplierName;
  String? _invoiceNumber;
  DateTime? _invoiceDate;
  DateTime? _dueDate;
  double? _totalTtc;

  @override
  void initState() {
    super.initState();
    if (widget.purchaseId != null) {
      _fetchPurchase();
    }
  }

  Future<void> _fetchPurchase() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final purchase = await SupabaseService.getPurchaseById(widget.purchaseId!);
      if (purchase != null) {
        setState(() {
          _supplierName = purchase.supplierName;
          _invoiceNumber = purchase.invoiceNumber;
          _invoiceDate = purchase.invoiceDate;
          _dueDate = purchase.dueDate;
          _totalTtc = purchase.totalTtc;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur de chargement de l'achat: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _savePurchase() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });

      try {
        final newPurchase = Purchase(
          id: widget.purchaseId ?? const Uuid().v4(),
          userId: Supabase.instance.client.auth.currentUser!.id,
          supplierName: _supplierName,
          invoiceNumber: _invoiceNumber,
          invoiceDate: _invoiceDate,
          dueDate: _dueDate,
          totalTtc: _totalTtc,
          createdAt: DateTime.now(),
        );

        if (widget.purchaseId == null) {
          await SupabaseService.addPurchase(newPurchase);
        } else {
          await SupabaseService.updatePurchase(widget.purchaseId!, newPurchase);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Achat enregistré avec succès')),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.purchaseId == null ? 'Nouvel Achat' : 'Modifier l\'achat'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Retour',
        ),
        actions: [ 
          IconButton(
            onPressed: _isLoading ? null : _savePurchase,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      initialValue: _supplierName,
                      decoration: const InputDecoration(labelText: 'Fournisseur'),
                      onSaved: (value) => _supplierName = value,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _invoiceNumber,
                      decoration: const InputDecoration(labelText: 'Numéro de facture'),
                      onSaved: (value) => _invoiceNumber = value,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _totalTtc?.toString(),
                      decoration: const InputDecoration(labelText: 'Total TTC'),
                      keyboardType: TextInputType.number,
                      onSaved: (value) => _totalTtc = double.tryParse(value!),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
