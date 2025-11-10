import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';

import '../../models/client.dart';
import '../../services/supabase_service.dart';
import '../../services/error_handler.dart';
import '../../config/plombipro_colors.dart';
import '../../config/plombipro_spacing.dart';
import '../../config/plombipro_text_styles.dart';
import '../../widgets/modern/feedback_widgets.dart';
import 'package:animate_do/animate_do.dart';

/// Modern step-by-step client creation wizard with OCR support
///
/// Steps:
/// 1. Scan or Manual Entry Choice
/// 2. Basic Information (Name, Type)
/// 3. Contact Details (Email, Phone)
/// 4. Address Information
/// 5. Additional Details (Company info if applicable)
/// 6. Review & Save
class AddClientWizardPage extends StatefulWidget {
  const AddClientWizardPage({super.key});

  @override
  State<AddClientWizardPage> createState() => _AddClientWizardPageState();
}

class _AddClientWizardPageState extends State<AddClientWizardPage> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isLoading = false;
  bool _useOCR = false;

  // Form keys for validation
  final _basicInfoFormKey = GlobalKey<FormState>();
  final _contactFormKey = GlobalKey<FormState>();
  final _addressFormKey = GlobalKey<FormState>();
  final _companyFormKey = GlobalKey<FormState>();

  // Form controllers
  final _nameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _mobilePhoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController(text: 'France');
  final _companyNameController = TextEditingController();
  final _siretController = TextEditingController();
  final _vatNumberController = TextEditingController();
  final _notesController = TextEditingController();

  // Client type
  String _clientType = 'individual';
  String _salutation = 'M.';
  bool _isFavorite = false;

  // Animation controllers
  late AnimationController _progressAnimationController;

  @override
  void initState() {
    super.initState();
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressAnimationController.dispose();
    _nameController.dispose();
    _firstNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _mobilePhoneController.dispose();
    _addressController.dispose();
    _postalCodeController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _companyNameController.dispose();
    _siretController.dispose();
    _vatNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 5) {
      // Validate current step before proceeding
      if (_validateCurrentStep()) {
        setState(() => _currentStep++);
        _pageController.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOutCubic,
        );
        _progressAnimationController.forward(from: 0);
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return true; // Choice step, no validation needed
      case 1:
        return _basicInfoFormKey.currentState?.validate() ?? false;
      case 2:
        return _contactFormKey.currentState?.validate() ?? false;
      case 3:
        return _addressFormKey.currentState?.validate() ?? false;
      case 4:
        if (_clientType == 'company') {
          return _companyFormKey.currentState?.validate() ?? false;
        }
        return true;
      case 5:
        return true; // Review step
      default:
        return true;
    }
  }

  Future<void> _scanBusinessCard() async {
    setState(() => _isLoading = true);

    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image == null) {
        setState(() => _isLoading = false);
        return;
      }

      // TODO: Implement OCR processing via Supabase Edge Function
      // For now, just show a placeholder
      if (mounted) {
        ModernSnackBar.info(
          context,
          'Analyse de la carte en cours... (Fonctionnalité OCR à venir)',
        );
      }

      setState(() {
        _useOCR = true;
        _isLoading = false;
      });

      _nextStep();
    } catch (e) {
      if (mounted) {
        ErrorHandler.handleError(context, e);
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveClient() async {
    if (!_validateCurrentStep()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final client = Client(
        id: '',
        userId: '',
        clientType: _clientType,
        salutation: _salutation,
        firstName: _firstNameController.text.trim(),
        name: _nameController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        mobilePhone: _mobilePhoneController.text.trim().isEmpty ? null : _mobilePhoneController.text.trim(),
        address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        postalCode: _postalCodeController.text.trim().isEmpty ? null : _postalCodeController.text.trim(),
        city: _cityController.text.trim().isEmpty ? null : _cityController.text.trim(),
        country: _countryController.text.trim(),
        billingAddress: null,
        siret: _siretController.text.trim().isEmpty ? null : _siretController.text.trim(),
        vatNumber: _vatNumberController.text.trim().isEmpty ? null : _vatNumberController.text.trim(),
        defaultPaymentTerms: 30,
        defaultDiscount: 0.0,
        tags: null,
        isFavorite: _isFavorite,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      await SupabaseService.createClient(client);

      if (mounted) {
        ModernSnackBar.success(context, '✓ Client créé avec succès!');
        context.pop(true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.handleError(
          context,
          e,
          customMessage: 'Impossible de créer le client',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouveau Client'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (page) => setState(() => _currentStep = page),
              children: [
                _buildChoiceStep(),
                _buildBasicInfoStep(),
                _buildContactStep(),
                _buildAddressStep(),
                _buildCompanyDetailsStep(),
                _buildReviewStep(),
              ],
            ),
          ),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: PlombiProSpacing.pagePadding,
      decoration: BoxDecoration(
        color: PlombiProColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Étape $_currentStep sur 5',
            style: PlombiProTextStyles.bodySmall.copyWith(
              color: PlombiProColors.textSecondary,
            ),
          ),
          PlombiProSpacing.verticalXS,
          ClipRRect(
            borderRadius: PlombiProSpacing.borderRadiusSM,
            child: LinearProgressIndicator(
              value: _currentStep / 5,
              backgroundColor: PlombiProColors.surfaceLight,
              valueColor: AlwaysStoppedAnimation<Color>(PlombiProColors.primary),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceStep() {
    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      child: Padding(
        padding: PlombiProSpacing.pagePadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_add,
              size: 80,
              color: PlombiProColors.primary,
            ),
            PlombiProSpacing.verticalLG,
            Text(
              'Comment souhaitez-vous ajouter ce client?',
              style: PlombiProTextStyles.headingMedium,
              textAlign: TextAlign.center,
            ),
            PlombiProSpacing.verticalXL,
            _buildChoiceCard(
              icon: Icons.camera_alt,
              title: 'Scanner une carte',
              subtitle: 'Utilisez l\'appareil photo pour scanner une carte de visite',
              onTap: _scanBusinessCard,
            ),
            PlombiProSpacing.verticalMD,
            _buildChoiceCard(
              icon: Icons.edit,
              title: 'Saisie manuelle',
              subtitle: 'Entrez les informations manuellement étape par étape',
              onTap: () {
                setState(() => _useOCR = false);
                _nextStep();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return FadeInUp(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: PlombiProSpacing.borderRadiusMD,
        ),
        child: InkWell(
          onTap: _isLoading ? null : onTap,
          borderRadius: PlombiProSpacing.borderRadiusMD,
          child: Padding(
            padding: PlombiProSpacing.cardPaddingLarge,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(PlombiProSpacing.md),
                  decoration: BoxDecoration(
                    color: PlombiProColors.primary.withOpacity(0.1),
                    borderRadius: PlombiProSpacing.borderRadiusMD,
                  ),
                  child: Icon(icon, color: PlombiProColors.primary, size: 32),
                ),
                PlombiProSpacing.horizontalMD,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: PlombiProTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      )),
                      PlombiProSpacing.verticalXXS,
                      Text(
                        subtitle,
                        style: PlombiProTextStyles.bodySmall.copyWith(
                          color: PlombiProColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 16, color: PlombiProColors.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoStep() {
    return FadeInRight(
      duration: const Duration(milliseconds: 400),
      child: SingleChildScrollView(
        padding: PlombiProSpacing.pagePadding,
        child: Form(
          key: _basicInfoFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Informations de base', style: PlombiProTextStyles.headingMedium),
              PlombiProSpacing.verticalMD,
              Text(
                'Type de client',
                style: PlombiProTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              PlombiProSpacing.verticalSM,
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'individual', label: Text('Particulier'), icon: Icon(Icons.person)),
                  ButtonSegment(value: 'company', label: Text('Entreprise'), icon: Icon(Icons.business)),
                ],
                selected: {_clientType},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() => _clientType = newSelection.first);
                },
              ),
              PlombiProSpacing.verticalLG,
              if (_clientType == 'individual') ...[
                DropdownButtonFormField<String>(
                  value: _salutation,
                  decoration: const InputDecoration(
                    labelText: 'Civilité',
                    border: OutlineInputBorder(),
                  ),
                  items: ['M.', 'Mme', 'Mlle'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() => _salutation = newValue);
                    }
                  },
                ),
                PlombiProSpacing.verticalMD,
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'Prénom',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                PlombiProSpacing.verticalMD,
              ],
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: _clientType == 'individual' ? 'Nom de famille' : 'Nom de l\'entreprise',
                  border: const OutlineInputBorder(),
                  prefixIcon: Icon(_clientType == 'individual' ? Icons.person : Icons.business),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ce champ est obligatoire';
                  }
                  return null;
                },
              ),
              if (_clientType == 'company') ...[
                PlombiProSpacing.verticalMD,
                TextFormField(
                  controller: _companyNameController,
                  decoration: const InputDecoration(
                    labelText: 'Raison sociale (si différente)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.business_center),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
              ],
              PlombiProSpacing.verticalLG,
              SwitchListTile(
                title: const Text('Marquer comme favori'),
                subtitle: const Text('Accès rapide à ce client'),
                value: _isFavorite,
                onChanged: (bool value) {
                  setState(() => _isFavorite = value);
                },
                secondary: Icon(
                  _isFavorite ? Icons.star : Icons.star_border,
                  color: _isFavorite ? PlombiProColors.warning : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactStep() {
    return FadeInRight(
      duration: const Duration(milliseconds: 400),
      child: SingleChildScrollView(
        padding: PlombiProSpacing.pagePadding,
        child: Form(
          key: _contactFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Coordonnées', style: PlombiProTextStyles.headingMedium),
              PlombiProSpacing.verticalMD,
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email_outlined),
                  hintText: 'exemple@email.fr',
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Email invalide';
                    }
                  }
                  return null;
                },
              ),
              PlombiProSpacing.verticalMD,
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Téléphone fixe',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone_outlined),
                  hintText: '01 23 45 67 89',
                ),
              ),
              PlombiProSpacing.verticalMD,
              TextFormField(
                controller: _mobilePhoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Téléphone portable',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.smartphone_outlined),
                  hintText: '06 12 34 56 78',
                ),
                validator: (value) {
                  // At least one phone number is required
                  if ((value == null || value.trim().isEmpty) &&
                      _phoneController.text.trim().isEmpty) {
                    return 'Au moins un numéro de téléphone est requis';
                  }
                  return null;
                },
              ),
              PlombiProSpacing.verticalSM,
              Container(
                padding: PlombiProSpacing.cardPadding,
                decoration: BoxDecoration(
                  color: PlombiProColors.info.withOpacity(0.1),
                  borderRadius: PlombiProSpacing.borderRadiusSM,
                  border: Border.all(color: PlombiProColors.info.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: PlombiProColors.info, size: 20),
                    PlombiProSpacing.horizontalSM,
                    Expanded(
                      child: Text(
                        'Au moins un numéro de téléphone est requis',
                        style: PlombiProTextStyles.bodySmall.copyWith(
                          color: PlombiProColors.info,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddressStep() {
    return FadeInRight(
      duration: const Duration(milliseconds: 400),
      child: SingleChildScrollView(
        padding: PlombiProSpacing.pagePadding,
        child: Form(
          key: _addressFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Adresse', style: PlombiProTextStyles.headingMedium),
              PlombiProSpacing.verticalMD,
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Adresse',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.home_outlined),
                  hintText: 'Numéro et nom de rue',
                ),
                textCapitalization: TextCapitalization.words,
                maxLines: 2,
              ),
              PlombiProSpacing.verticalMD,
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _postalCodeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Code postal',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.markunread_mailbox_outlined),
                        hintText: '75001',
                      ),
                      maxLength: 5,
                    ),
                  ),
                  PlombiProSpacing.horizontalMD,
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(
                        labelText: 'Ville',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_city_outlined),
                      ),
                      textCapitalization: TextCapitalization.words,
                    ),
                  ),
                ],
              ),
              PlombiProSpacing.verticalMD,
              TextFormField(
                controller: _countryController,
                decoration: const InputDecoration(
                  labelText: 'Pays',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.public_outlined),
                ),
                textCapitalization: TextCapitalization.words,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompanyDetailsStep() {
    if (_clientType != 'company') {
      return FadeInRight(
        duration: const Duration(milliseconds: 400),
        child: Center(
          child: Padding(
            padding: PlombiProSpacing.pagePadding,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline, size: 80, color: PlombiProColors.success),
                PlombiProSpacing.verticalLG,
                Text(
                  'Informations optionnelles',
                  style: PlombiProTextStyles.headingMedium,
                ),
                PlombiProSpacing.verticalMD,
                Text(
                  'Vous pouvez passer cette étape pour un particulier',
                  style: PlombiProTextStyles.bodyMedium.copyWith(
                    color: PlombiProColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return FadeInRight(
      duration: const Duration(milliseconds: 400),
      child: SingleChildScrollView(
        padding: PlombiProSpacing.pagePadding,
        child: Form(
          key: _companyFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Informations entreprise', style: PlombiProTextStyles.headingMedium),
              PlombiProSpacing.verticalMD,
              TextFormField(
                controller: _siretController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'SIRET',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.badge_outlined),
                  hintText: '14 chiffres',
                ),
                maxLength: 14,
                validator: (value) {
                  if (value != null && value.isNotEmpty && value.length != 14) {
                    return 'Le SIRET doit contenir 14 chiffres';
                  }
                  return null;
                },
              ),
              PlombiProSpacing.verticalMD,
              TextFormField(
                controller: _vatNumberController,
                decoration: const InputDecoration(
                  labelText: 'Numéro de TVA',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.receipt_long_outlined),
                  hintText: 'FR12345678901',
                ),
                textCapitalization: TextCapitalization.characters,
              ),
              PlombiProSpacing.verticalMD,
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note_outlined),
                  hintText: 'Informations complémentaires...',
                ),
                maxLines: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewStep() {
    return FadeInRight(
      duration: const Duration(milliseconds: 400),
      child: SingleChildScrollView(
        padding: PlombiProSpacing.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Récapitulatif', style: PlombiProTextStyles.headingMedium),
            PlombiProSpacing.verticalMD,
            _buildReviewCard(
              title: 'Type',
              value: _clientType == 'individual' ? 'Particulier' : 'Entreprise',
              icon: _clientType == 'individual' ? Icons.person : Icons.business,
            ),
            PlombiProSpacing.verticalSM,
            _buildReviewCard(
              title: 'Nom',
              value: _clientType == 'individual'
                  ? '${_salutation} ${_firstNameController.text} ${_nameController.text}'
                  : _nameController.text,
              icon: Icons.badge,
            ),
            PlombiProSpacing.verticalSM,
            if (_emailController.text.isNotEmpty)
              _buildReviewCard(
                title: 'Email',
                value: _emailController.text,
                icon: Icons.email,
              ),
            PlombiProSpacing.verticalSM,
            if (_phoneController.text.isNotEmpty || _mobilePhoneController.text.isNotEmpty)
              _buildReviewCard(
                title: 'Téléphone',
                value: [
                  if (_phoneController.text.isNotEmpty) _phoneController.text,
                  if (_mobilePhoneController.text.isNotEmpty) _mobilePhoneController.text,
                ].join(' / '),
                icon: Icons.phone,
              ),
            PlombiProSpacing.verticalSM,
            if (_addressController.text.isNotEmpty)
              _buildReviewCard(
                title: 'Adresse',
                value: [
                  _addressController.text,
                  if (_postalCodeController.text.isNotEmpty || _cityController.text.isNotEmpty)
                    '${_postalCodeController.text} ${_cityController.text}'.trim(),
                  _countryController.text,
                ].where((s) => s.isNotEmpty).join(', '),
                icon: Icons.location_on,
              ),
            PlombiProSpacing.verticalSM,
            if (_clientType == 'company' && _siretController.text.isNotEmpty)
              _buildReviewCard(
                title: 'SIRET',
                value: _siretController.text,
                icon: Icons.badge,
              ),
            if (_isFavorite) ...[
              PlombiProSpacing.verticalSM,
              Container(
                padding: PlombiProSpacing.cardPadding,
                decoration: BoxDecoration(
                  color: PlombiProColors.warning.withOpacity(0.1),
                  borderRadius: PlombiProSpacing.borderRadiusMD,
                  border: Border.all(color: PlombiProColors.warning.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.star, color: PlombiProColors.warning),
                    PlombiProSpacing.horizontalMD,
                    Text(
                      'Marqué comme favori',
                      style: PlombiProTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: PlombiProColors.warning,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: PlombiProSpacing.cardPadding,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(PlombiProSpacing.sm),
              decoration: BoxDecoration(
                color: PlombiProColors.primary.withOpacity(0.1),
                borderRadius: PlombiProSpacing.borderRadiusSM,
              ),
              child: Icon(icon, color: PlombiProColors.primary, size: 20),
            ),
            PlombiProSpacing.horizontalMD,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: PlombiProTextStyles.bodySmall.copyWith(
                      color: PlombiProColors.textSecondary,
                    ),
                  ),
                  PlombiProSpacing.verticalXXS,
                  Text(
                    value,
                    style: PlombiProTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: PlombiProSpacing.pagePadding,
      decoration: BoxDecoration(
        color: PlombiProColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : _previousStep,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Précédent'),
                style: OutlinedButton.styleFrom(
                  padding: PlombiProSpacing.buttonPadding,
                ),
              ),
            ),
          if (_currentStep > 0) PlombiProSpacing.horizontalMD,
          Expanded(
            flex: _currentStep == 0 ? 1 : 1,
            child: ElevatedButton.icon(
              onPressed: _isLoading
                  ? null
                  : (_currentStep == 5 ? _saveClient : _nextStep),
              icon: Icon(_currentStep == 5 ? Icons.check : Icons.arrow_forward),
              label: Text(_currentStep == 5 ? 'Créer le client' : 'Suivant'),
              style: ElevatedButton.styleFrom(
                padding: PlombiProSpacing.buttonPadding,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
