import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../models/payment.dart';
import '../../services/supabase_service.dart';

class PaymentFormPage extends StatefulWidget {
  final String? paymentId;
  final String? invoiceId;

  const PaymentFormPage({super.key, this.paymentId, this.invoiceId});

  @override
  State<PaymentFormPage> createState() => _PaymentFormPageState();
}

class _PaymentFormPageState extends State<PaymentFormPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Form fields
  late String _invoiceId;
  late DateTime _paymentDate;
  late double _amount;
  String? _paymentMethod;
  String? _transactionReference;
  String? _notes;

  @override
  void initState() {
    super.initState();
    _invoiceId = widget.invoiceId ?? '';
    _paymentDate = DateTime.now();
    _amount = 0;
  }

  Future<void> _savePayment() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });

      try {
        final newPayment = Payment(
          id: widget.paymentId ?? const Uuid().v4(),
          userId: Supabase.instance.client.auth.currentUser!.id,
          invoiceId: _invoiceId,
          paymentDate: _paymentDate,
          amount: _amount,
          paymentMethod: _paymentMethod,
          transactionReference: _transactionReference,
          notes: _notes,
          createdAt: DateTime.now(),
        );

        if (widget.paymentId == null) {
          await SupabaseService.recordPayment(newPayment);
        } else {
          await SupabaseService.updatePayment(widget.paymentId!, newPayment);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Paiement enregistré avec succès')),
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
        title: Text(widget.paymentId == null ? 'Enregistrer un paiement' : 'Modifier le paiement'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Retour',
        ),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _savePayment,
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
                      initialValue: _invoiceId,
                      decoration: const InputDecoration(labelText: 'Facture ID'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un ID de facture';
                        }
                        return null;
                      },
                      onSaved: (value) => _invoiceId = value!,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _amount.toString(),
                      decoration: const InputDecoration(labelText: 'Montant payé'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty || double.tryParse(value) == null) {
                          return 'Veuillez entrer un montant valide';
                        }
                        return null;
                      },
                      onSaved: (value) => _amount = double.parse(value!),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Méthode de paiement'),
                      onSaved: (value) => _paymentMethod = value,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}