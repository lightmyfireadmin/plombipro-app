import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../models/payment.dart';
import '../../services/supabase_service.dart';
import '../../config/plombipro_colors.dart';
import '../../widgets/glassmorphic/glass_card.dart';

/// Beautiful glassmorphic payment form page
class PaymentFormPage extends StatefulWidget {
  final String? paymentId;
  final String? invoiceId;

  const PaymentFormPage({super.key, this.paymentId, this.invoiceId});

  @override
  State<PaymentFormPage> createState() => _PaymentFormPageState();
}

class _PaymentFormPageState extends State<PaymentFormPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Form fields
  late String _invoiceId;
  late DateTime _paymentDate;
  late double _amount;
  String? _paymentMethod;
  String? _transactionReference;
  String? _notes;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> _paymentMethods = [
    {'value': 'cash', 'label': 'Espèces', 'icon': Icons.money},
    {'value': 'check', 'label': 'Chèque', 'icon': Icons.receipt_long},
    {'value': 'card', 'label': 'Carte bancaire', 'icon': Icons.credit_card},
    {'value': 'transfer', 'label': 'Virement', 'icon': Icons.account_balance},
    {'value': 'other', 'label': 'Autre', 'icon': Icons.payments},
  ];

  @override
  void initState() {
    super.initState();
    _invoiceId = widget.invoiceId ?? '';
    _paymentDate = DateTime.now();
    _amount = 0;

    // Fade animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _paymentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: PlombiProColors.secondaryOrange,
              surface: PlombiProColors.backgroundDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _paymentDate) {
      setState(() {
        _paymentDate = picked;
      });
    }
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
            SnackBar(
              content: const Text('✅ Paiement enregistré avec succès'),
              backgroundColor: PlombiProColors.success,
            ),
          );
          context.pop(true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: ${e.toString()}'),
              backgroundColor: PlombiProColors.error,
            ),
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
      body: Stack(
        children: [
          // Gradient background
          _buildGradientBackground(),

          // Content
          SafeArea(
            child: _isLoading
                ? _buildLoadingState()
                : FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        _buildGlassAppBar(),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(16.0),
                            child: _buildForm(),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PlombiProColors.primaryBlue,
            PlombiProColors.tertiaryTeal,
            PlombiProColors.primaryBlueDark,
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: GlassContainer(
        width: 80,
        height: 80,
        padding: const EdgeInsets.all(20),
        borderRadius: BorderRadius.circular(20),
        opacity: 0.2,
        child: const CircularProgressIndicator(
          strokeWidth: 3,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }

  Widget _buildGlassAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Back button
          AnimatedGlassContainer(
            width: 48,
            height: 48,
            padding: const EdgeInsets.all(0),
            borderRadius: BorderRadius.circular(12),
            opacity: 0.2,
            onTap: () => context.pop(),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),

          const SizedBox(width: 16),

          // Title
          Expanded(
            child: Text(
              widget.paymentId == null
                  ? 'Enregistrer un paiement'
                  : 'Modifier le paiement',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Save button
          AnimatedGlassContainer(
            width: 48,
            height: 48,
            padding: const EdgeInsets.all(0),
            borderRadius: BorderRadius.circular(12),
            opacity: 0.25,
            color: PlombiProColors.success,
            onTap: _isLoading ? null : _savePayment,
            child: const Icon(Icons.save, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      borderRadius: BorderRadius.circular(24),
      opacity: 0.15,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: PlombiProColors.success.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.payment, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Détails du paiement',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Invoice ID field
            _buildGlassTextField(
              labelText: 'ID de la facture *',
              hintText: 'INV-2024-001',
              initialValue: _invoiceId,
              prefixIcon: Icons.receipt,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer un ID de facture';
                }
                return null;
              },
              onSaved: (value) => _invoiceId = value!,
            ),

            const SizedBox(height: 20),

            // Payment date
            _buildGlassDateField(),

            const SizedBox(height: 20),

            // Amount field
            _buildGlassTextField(
              labelText: 'Montant payé *',
              hintText: '0.00 €',
              initialValue: _amount == 0 ? '' : _amount.toString(),
              prefixIcon: Icons.euro,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null ||
                    value.isEmpty ||
                    double.tryParse(value) == null) {
                  return 'Veuillez entrer un montant valide';
                }
                if (double.parse(value) <= 0) {
                  return 'Le montant doit être supérieur à 0';
                }
                return null;
              },
              onSaved: (value) => _amount = double.parse(value!),
            ),

            const SizedBox(height: 20),

            // Payment method dropdown
            _buildPaymentMethodDropdown(),

            const SizedBox(height: 20),

            // Transaction reference
            _buildGlassTextField(
              labelText: 'Référence de transaction',
              hintText: 'Optionnel',
              initialValue: _transactionReference ?? '',
              prefixIcon: Icons.tag,
              onSaved: (value) => _transactionReference = value?.trim(),
            ),

            const SizedBox(height: 20),

            // Notes
            _buildGlassTextField(
              labelText: 'Notes',
              hintText: 'Informations supplémentaires',
              initialValue: _notes ?? '',
              prefixIcon: Icons.notes,
              maxLines: 3,
              onSaved: (value) => _notes = value?.trim(),
            ),

            const SizedBox(height: 32),

            // Save button (large)
            AnimatedGlassContainer(
              width: double.infinity,
              height: 56,
              borderRadius: BorderRadius.circular(16),
              opacity: 0.25,
              color: PlombiProColors.success,
              onTap: _isLoading ? null : _savePayment,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.save, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    widget.paymentId == null
                        ? 'Enregistrer le paiement'
                        : 'Mettre à jour',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Required fields note
            Center(
              child: Text(
                '* Champs requis',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassTextField({
    required String labelText,
    required String hintText,
    required String? initialValue,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
    void Function(String?)? onSaved,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: TextFormField(
            initialValue: initialValue,
            keyboardType: keyboardType,
            maxLines: maxLines,
            validator: validator,
            onSaved: onSaved,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              prefixIcon: Icon(
                prefixIcon,
                color: Colors.white.withOpacity(0.7),
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGlassDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date du paiement *',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedGlassContainer(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          borderRadius: BorderRadius.circular(12),
          opacity: 0.1,
          onTap: _selectDate,
          child: Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: Colors.white.withOpacity(0.7),
                size: 20,
              ),
              const SizedBox(width: 16),
              Text(
                DateFormat('dd/MM/yyyy').format(_paymentDate),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Méthode de paiement',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: DropdownButtonFormField<String>(
            value: _paymentMethod,
            decoration: InputDecoration(
              hintText: 'Sélectionner une méthode',
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              prefixIcon: Icon(
                Icons.account_balance_wallet,
                color: Colors.white.withOpacity(0.7),
                size: 20,
              ),
            ),
            dropdownColor: PlombiProColors.backgroundDark,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            items: _paymentMethods.map((method) {
              return DropdownMenuItem<String>(
                value: method['value'],
                child: Row(
                  children: [
                    Icon(
                      method['icon'],
                      color: Colors.white.withOpacity(0.7),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(method['label']),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _paymentMethod = value;
              });
            },
            onSaved: (value) => _paymentMethod = value,
          ),
        ),
      ],
    );
  }
}
