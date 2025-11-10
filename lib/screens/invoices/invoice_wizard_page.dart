import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:animate_do/animate_do.dart';
import '../../models/client.dart';
import '../../models/line_item.dart';
import '../../models/product.dart';
import '../../models/invoice.dart';
import '../../services/invoice_calculator.dart';
import '../../services/supabase_service.dart';
import '../../services/facturx_service.dart';
import '../../services/chorus_pro_service.dart';
import '../../config/env_config.dart';
import '../../config/plombipro_colors.dart';
import '../../config/glassmorphism_theme.dart';

/// Premium glassmorphism invoice wizard with 6 professional steps
/// Features Factur-X e-invoicing & Chorus Pro government portal integration
class InvoiceWizardPage extends StatefulWidget {
  final String? invoiceId;

  const InvoiceWizardPage({super.key, this.invoiceId});

  @override
  State<InvoiceWizardPage> createState() => _InvoiceWizardPageState();
}

class _InvoiceWizardPageState extends State<InvoiceWizardPage>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  final _formKey = GlobalKey<FormState>();

  int _currentStep = 0;
  bool get _isEditing => widget.invoiceId != null;
  Invoice? _invoice;

  // Animation controllers
  late AnimationController _backgroundController;
  late Animation<double> _backgroundAnimation;

  // Step 1: Client & Type
  Client? _selectedClient;
  List<Client> _clients = [];
  final TextEditingController _clientSearchController = TextEditingController();
  List<Client> _filteredClients = [];
  String _invoiceType = 'standard'; // standard, deposit, progress, credit_note

  // Step 2: Details & Dates
  DateTime _invoiceDate = DateTime.now();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));
  final TextEditingController _invoiceNumberController = TextEditingController();

  // Step 3: Line Items
  List<LineItem> _lineItems = [];
  List<Product> _products = [];

  // Step 4: Payment & Bank
  String _paymentStatus = 'Brouillon';
  String _paymentMethod = 'Virement bancaire';
  String? _companyIban;
  String? _companyBic;

  // Step 5: Legal & Terms
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _termsConditionsController = TextEditingController();
  final TextEditingController _legalMentionsController = TextEditingController();
  String? _companySiret;
  String? _companyVatNumber;

  // Step 6: Options
  bool _generateFacturX = false;
  bool _submitToChorusPro = false;
  String? _xmlUrl;

  // Calculations
  double _totalHT = 0;
  double _totalTVA = 0;
  double _totalTTC = 0;
  double _tvaRate = 20.0;
  static const List<double> _availableVatRates = [20.0, 10.0, 5.5, 2.1];

  bool _isLoading = true;
  bool _isSaving = false;

  final List<String> _stepTitles = [
    'Client',
    'Détails',
    'Articles',
    'Paiement',
    'Légal',
    'Révision',
  ];

  final List<IconData> _stepIcons = [
    Icons.person_outline,
    Icons.receipt_long_outlined,
    Icons.shopping_cart_outlined,
    Icons.payment_outlined,
    Icons.gavel_outlined,
    Icons.check_circle_outline,
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadInitialData();
  }

  void _setupAnimations() {
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat(reverse: true);

    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _backgroundController.dispose();
    _clientSearchController.dispose();
    _invoiceNumberController.dispose();
    _notesController.dispose();
    _termsConditionsController.dispose();
    _legalMentionsController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      if (_isEditing) {
        final invoice = await SupabaseService.getInvoiceById(widget.invoiceId!);
        setState(() => _invoice = invoice);
      }

      final results = await Future.wait([
        SupabaseService.fetchClients(),
        SupabaseService.fetchProducts(),
      ]);

      // Load company profile
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;
      Map<String, dynamic>? companyProfile;
      Map<String, dynamic>? userSettings;

      if (userId != null) {
        try {
          companyProfile = await supabase
              .from('profiles')
              .select('company_name, siret, vat_number, iban, bic, address, postal_code, city')
              .eq('id', userId)
              .maybeSingle();

          userSettings = await supabase
              .from('settings')
              .select('default_invoice_footer, default_payment_terms_days')
              .eq('user_id', userId)
              .maybeSingle();
        } catch (e) {
          debugPrint('Error loading company profile: $e');
        }
      }

      setState(() {
        _clients = results[0] as List<Client>;
        _filteredClients = _clients;
        _products = results[1] as List<Product>;

        if (companyProfile != null) {
          _companyIban = companyProfile['iban'] as String?;
          _companyBic = companyProfile['bic'] as String?;
          _companySiret = companyProfile['siret'] as String?;
          _companyVatNumber = companyProfile['vat_number'] as String?;

          _legalMentionsController.text = _generateLegalMentions(
            companyName: companyProfile['company_name'] as String? ?? 'Votre Entreprise',
            address: companyProfile['address'] as String? ?? '',
            postalCode: companyProfile['postal_code'] as String? ?? '',
            city: companyProfile['city'] as String? ?? '',
            siret: _companySiret,
            vatNumber: _companyVatNumber,
          );
        }

        if (userSettings != null && userSettings['default_invoice_footer'] != null) {
          _termsConditionsController.text = userSettings['default_invoice_footer'] as String;
        } else {
          _termsConditionsController.text = _getDefaultTermsConditions();
        }

        if (_isEditing && _invoice != null) {
          _populateExistingInvoice();
        } else {
          _invoiceNumberController.text = 'DRAFT';
        }

        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        _showError("Erreur de chargement: ${e.toString()}");
        setState(() => _isLoading = false);
      }
    }
  }

  void _populateExistingInvoice() {
    final invoice = _invoice!;
    _invoiceNumberController.text = invoice.number;
    _selectedClient = _clients.firstWhere(
      (c) => c.id == invoice.clientId,
      orElse: () => _clients.first,
    );
    _invoiceDate = invoice.date;
    _dueDate = invoice.dueDate ?? _invoiceDate.add(const Duration(days: 30));
    _lineItems = List<LineItem>.from(invoice.items);
    _totalHT = invoice.totalHt;
    _totalTVA = invoice.totalTva;
    _totalTTC = invoice.totalTtc;
    _paymentStatus = invoice.paymentStatus;
    _paymentMethod = invoice.paymentMethod ?? 'Virement bancaire';
    _notesController.text = invoice.notes ?? '';
    _generateFacturX = invoice.isElectronic ?? false;
    _xmlUrl = invoice.xmlUrl;
    _calculateTotals();
  }

  String _generateLegalMentions({
    required String companyName,
    required String address,
    required String postalCode,
    required String city,
    String? siret,
    String? vatNumber,
  }) {
    final buffer = StringBuffer();
    buffer.writeln(companyName);
    if (address.isNotEmpty) {
      buffer.writeln(address);
      buffer.writeln('$postalCode $city');
    }
    if (siret != null && siret.isNotEmpty) {
      buffer.writeln('SIRET: $siret');
    }
    if (vatNumber != null && vatNumber.isNotEmpty) {
      buffer.writeln('TVA intracommunautaire: $vatNumber');
    }
    buffer.writeln('\nDispense d\'immatriculation au RCS ou au RM');
    buffer.writeln('Assurance professionnelle: Garantie décennale');
    return buffer.toString();
  }

  String _getDefaultTermsConditions() {
    return '''Conditions de paiement: Règlement à 30 jours
En cas de retard de paiement, des pénalités de retard au taux de 10% seront appliquées.
Indemnité forfaitaire pour frais de recouvrement: 40€

Aucun escompte ne sera accordé en cas de paiement anticipé.
TVA non applicable, art. 293 B du CGI (si applicable)
Garantie décennale et responsabilité civile professionnelle''';
  }

  void _calculateTotals() {
    double subtotal = 0;
    for (var item in _lineItems) {
      subtotal += item.lineTotal;
    }
    setState(() {
      _totalHT = subtotal;
      _totalTVA = InvoiceCalculator.calculateVAT(
        subtotal: _totalHT,
        tvaRate: _tvaRate,
      );
      _totalTTC = _totalHT + _totalTVA;
    });
  }

  void _filterClients(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredClients = _clients;
      } else {
        _filteredClients = _clients.where((client) {
          return client.name.toLowerCase().contains(query.toLowerCase()) ||
              (client.email?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
              (client.city?.toLowerCase().contains(query.toLowerCase()) ?? false);
        }).toList();
      }
    });
  }

  Future<void> _saveInvoice() async {
    if (_selectedClient == null) {
      _showError('Veuillez sélectionner un client');
      return;
    }

    if (_lineItems.isEmpty) {
      _showError('Veuillez ajouter au moins un article');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final invoice = Invoice(
        id: _invoice?.id,
        number: _invoiceNumberController.text,
        clientId: _selectedClient!.id!,
        date: _invoiceDate,
        dueDate: _dueDate,
        totalHt: _totalHT,
        totalTva: _totalTVA,
        totalTtc: _totalTTC,
        paymentStatus: _paymentStatus,
        notes: _notesController.text,
        paymentMethod: _paymentMethod,
        isElectronic: _generateFacturX,
        xmlUrl: _xmlUrl,
        client: _selectedClient,
        items: _lineItems,
      );

      String invoiceId;
      if (_isEditing) {
        await SupabaseService.updateInvoice(invoice.id!, invoice);
        invoiceId = invoice.id!;
      } else {
        invoiceId = await SupabaseService.createInvoice(invoice);
        await SupabaseService.createInvoiceLineItems(invoiceId, _lineItems);
      }

      // Generate Factur-X if requested
      if (_generateFacturX) {
        await _handleFacturX(invoiceId);
      }

      if (mounted) {
        _showSuccess('Facture enregistrée avec succès!');
        await Future.delayed(const Duration(seconds: 1));
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      _showError("Erreur lors de l'enregistrement: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _handleFacturX(String invoiceId) async {
    try {
      final validation = await FacturXService.validateForFacturX(invoiceId);

      if (!validation.isValid) {
        _showError(
          'Impossible de générer Factur-X:\n${validation.errors.join("\n")}',
        );
        return;
      }

      if (validation.hasWarnings) {
        _showWarning(
          'Avertissements Factur-X:\n${validation.warnings.join("\n")}',
        );
      }

      final result = await FacturXService.generateFacturX(invoiceId);

      if (result != null && mounted) {
        setState(() => _xmlUrl = result['xml_url']);
        _showSuccess('Factur-X généré avec succès! Niveau: ${result['level']}');

        if (_submitToChorusPro) {
          await _handleChorusPro(invoiceId);
        }
      }
    } catch (e) {
      _showError('Erreur Factur-X: ${e.toString()}');
    }
  }

  Future<void> _handleChorusPro(String invoiceId) async {
    try {
      final chorusProUrl = EnvConfig.chorusProSubmitterUrl;
      if (chorusProUrl.isEmpty) {
        _showWarning('URL Chorus Pro non configurée');
        return;
      }

      final chorusProService = ChorusProService(
        cloudFunctionUrl: chorusProUrl,
        testMode: EnvConfig.environment != 'production',
      );

      final chorusResult = await chorusProService.submitInvoice(invoiceId);

      if (mounted) {
        if (chorusResult['success'] == true) {
          _showSuccess(
            'Facture soumise à Chorus Pro!\nID: ${chorusResult['chorus_invoice_id']}\nStatut: ${ChorusProService.getStatusText(chorusResult['status'])}',
          );
        } else {
          _showError('Erreur Chorus Pro: ${chorusResult['error']}');
        }
      }
    } catch (e) {
      _showError('Erreur Chorus Pro: ${e.toString()}');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: PlombiProColors.error,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void _showWarning(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: PlombiProColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _nextStep() {
    if (_currentStep < 5) {
      if (_currentStep == 0 && _selectedClient == null) {
        _showError('Veuillez sélectionner un client');
        return;
      }

      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: _buildAnimatedBackground(
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildGlassAppBar(),
      body: _buildAnimatedBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildGlassProgressIndicator(),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) => setState(() => _currentStep = index),
                  children: [
                    _buildStep1ClientAndType(),
                    _buildStep2DetailsAndDates(),
                    _buildStep3LineItems(),
                    _buildStep4PaymentAndBank(),
                    _buildStep5LegalAndTerms(),
                    _buildStep6Review(),
                  ],
                ),
              ),
              _buildGlassNavigationButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground({required Widget child}) {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                PlombiProColors.secondaryOrange,
                PlombiProColors.primaryBlue,
                PlombiProColors.tertiaryTeal,
              ],
              stops: [
                _backgroundAnimation.value * 0.3,
                0.5 + _backgroundAnimation.value * 0.2,
                1.0 - _backgroundAnimation.value * 0.1,
              ],
            ),
          ),
          child: child,
        );
      },
    );
  }

  PreferredSizeWidget _buildGlassAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
              iconSize: 20,
            ),
          ),
        ),
      ),
      title: FadeIn(
        child: Text(
          _isEditing ? 'Éditer Facture' : 'Nouvelle Facture',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildGlassProgressIndicator() {
    return FadeInDown(
      duration: const Duration(milliseconds: 600),
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(_stepTitles.length, (index) {
                  final isCompleted = index < _currentStep;
                  final isCurrent = index == _currentStep;

                  return Expanded(
                    child: Column(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isCompleted || isCurrent
                                ? PlombiProColors.secondaryOrange
                                : Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.5),
                              width: 2,
                            ),
                            boxShadow: isCompleted || isCurrent
                                ? [
                                    BoxShadow(
                                      color: PlombiProColors.secondaryOrange.withOpacity(0.5),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                : [],
                          ),
                          child: Icon(
                            isCompleted ? Icons.check : _stepIcons[index],
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _stepTitles[index],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Continue in next message due to length...

  // ===== STEP 1: CLIENT & TYPE =====
  Widget _buildStep1ClientAndType() {
    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Client et type de facture',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sélectionnez le client et le type de facture',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Search bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: TextField(
                          controller: _clientSearchController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Rechercher un client...',
                            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                            prefixIcon: const Icon(Icons.search, color: Colors.white),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(16),
                          ),
                          onChanged: _filterClients,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Invoice type selector
            _buildGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Type de facture',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...['standard', 'deposit', 'progress', 'credit_note'].map((type) {
                    final isSelected = _invoiceType == type;
                    final labels = {
                      'standard': 'Facture standard',
                      'deposit': 'Facture d\'acompte',
                      'progress': 'Facture de situation',
                      'credit_note': 'Avoir (crédit)',
                    };
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: () => setState(() => _invoiceType = type),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? PlombiProColors.tertiaryTeal.withOpacity(0.3)
                                    : Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? PlombiProColors.tertiaryTeal
                                      : Colors.white.withOpacity(0.3),
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    labels[type]!,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Client cards
            if (_filteredClients.isEmpty)
              _buildGlassCard(
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.search_off, color: Colors.white.withOpacity(0.5), size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'Aucun client trouvé',
                        style: TextStyle(color: Colors.white.withOpacity(0.8)),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...List.generate(_filteredClients.length, (index) {
                final client = _filteredClients[index];
                final isSelected = _selectedClient?.id == client.id;

                return FadeInUp(
                  delay: Duration(milliseconds: 50 * index),
                  duration: const Duration(milliseconds: 400),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedClient = client),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? PlombiProColors.secondaryOrange.withOpacity(0.3)
                                  : Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? PlombiProColors.secondaryOrange
                                    : Colors.white.withOpacity(0.3),
                                width: isSelected ? 2.5 : 1.5,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: PlombiProColors.secondaryOrange.withOpacity(0.3),
                                        blurRadius: 15,
                                        spreadRadius: 2,
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        PlombiProColors.secondaryOrange,
                                        PlombiProColors.secondaryOrangeDark,
                                      ],
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      client.name.isNotEmpty ? client.name[0].toUpperCase() : '?',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        client.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (client.email != null && client.email!.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          client.email!,
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.7),
                                            fontSize: 12,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(
                                    Icons.check_circle,
                                    color: PlombiProColors.secondaryOrange,
                                    size: 28,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  // ===== STEP 2: DETAILS & DATES =====
  Widget _buildStep2DetailsAndDates() {
    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Détails de la facture',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Dates et informations importantes',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Invoice date
                  _buildGlassDateField(
                    label: 'Date de facture',
                    icon: Icons.calendar_today,
                    date: _invoiceDate,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _invoiceDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                        builder: (context, child) {
                          return Theme(
                            data: ThemeData.dark().copyWith(
                              colorScheme: ColorScheme.dark(
                                primary: PlombiProColors.secondaryOrange,
                                surface: PlombiProColors.primaryBlueDark,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (date != null) {
                        setState(() {
                          _invoiceDate = date;
                          if (_dueDate.isBefore(_invoiceDate)) {
                            _dueDate = _invoiceDate.add(const Duration(days: 30));
                          }
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  // Due date
                  _buildGlassDateField(
                    label: 'Date d\'échéance',
                    icon: Icons.event_available,
                    date: _dueDate,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _dueDate,
                        firstDate: _invoiceDate,
                        lastDate: _invoiceDate.add(const Duration(days: 365)),
                        builder: (context, child) {
                          return Theme(
                            data: ThemeData.dark().copyWith(
                              colorScheme: ColorScheme.dark(
                                primary: PlombiProColors.tertiaryTeal,
                                surface: PlombiProColors.primaryBlueDark,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (date != null) setState(() => _dueDate = date);
                    },
                  ),
                  const SizedBox(height: 24),
                  // Days until due
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: PlombiProColors.tertiaryTeal.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: PlombiProColors.tertiaryTeal.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, color: Colors.white, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Délai de paiement: ${_dueDate.difference(_invoiceDate).inDays} jours',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
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
          ],
        ),
      ),
    );
  }

  // ===== STEP 3: LINE ITEMS =====
  Widget _buildStep3LineItems() {
    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Articles et services',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ajoutez les lignes de votre facture',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (_lineItems.isEmpty)
              _buildGlassCard(
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long, color: Colors.white.withOpacity(0.5), size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'Aucun article ajouté',
                        style: TextStyle(color: Colors.white.withOpacity(0.8)),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...List.generate(_lineItems.length, (index) {
                return _buildLineItemCard(index, key: ValueKey(_lineItems[index]));
              }),
            const SizedBox(height: 16),
            // Add button
            GestureDetector(
              onTap: () {
                setState(() {
                  _lineItems.add(LineItem(
                    description: '',
                    quantity: 1,
                    unitPrice: 0,
                  ));
                });
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: PlombiProColors.secondaryOrange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: PlombiProColors.secondaryOrange,
                        width: 2,
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Ajouter une ligne',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineItemCard(int index, {Key? key}) {
    final item = _lineItems[index];

    return FadeInUp(
      key: key,
      delay: Duration(milliseconds: 50 * index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Article ${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _lineItems.removeAt(index);
                            _calculateTotals();
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildGlassTextField(
                    label: 'Description',
                    initialValue: item.description,
                    onChanged: (value) {
                      _lineItems[index] = item.copyWith(description: value);
                      _calculateTotals();
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildGlassTextField(
                          label: 'Qté',
                          initialValue: item.quantity.toString(),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            final qty = double.tryParse(value) ?? 1;
                            _lineItems[index] = item.copyWith(quantity: qty);
                            _calculateTotals();
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: _buildGlassTextField(
                          label: 'Prix unitaire',
                          initialValue: item.unitPrice.toStringAsFixed(2),
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          suffix: '€',
                          onChanged: (value) {
                            final price = double.tryParse(value) ?? 0;
                            _lineItems[index] = item.copyWith(unitPrice: price);
                            _calculateTotals();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: PlombiProColors.tertiaryTeal.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total ligne:',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          InvoiceCalculator.formatCurrency(item.lineTotal),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Continue in next part...

  // ===== STEP 4: PAYMENT & BANK =====
  Widget _buildStep4PaymentAndBank() {
    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informations de paiement',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Payment method
                  _buildGlassDropdown(
                    label: 'Moyen de paiement',
                    value: _paymentMethod,
                    items: [
                      'Virement bancaire',
                      'Chèque',
                      'Espèces',
                      'Carte bancaire',
                      'Prélèvement',
                    ],
                    onChanged: (value) => setState(() => _paymentMethod = value!),
                  ),
                  const SizedBox(height: 16),
                  // Payment status
                  _buildGlassDropdown(
                    label: 'Statut de paiement',
                    value: _paymentStatus,
                    items: [
                      'Brouillon',
                      'Envoyée',
                      'Partiel',
                      'Payée',
                      'Annulée',
                    ],
                    onChanged: (value) => setState(() => _paymentStatus = value!),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Bank details
            _buildGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Coordonnées bancaires',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_companyIban != null && _companyIban!.isNotEmpty) ...[
                    _buildInfoRow('IBAN', _companyIban!),
                    const SizedBox(height: 12),
                  ],
                  if (_companyBic != null && _companyBic!.isNotEmpty) ...[
                    _buildInfoRow('BIC', _companyBic!),
                  ],
                  if ((_companyIban == null || _companyIban!.isEmpty) &&
                      (_companyBic == null || _companyBic!.isEmpty))
                    Text(
                      'Aucune coordonnée bancaire configurée',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Calculations preview
            _buildGlassCard(
              child: Column(
                children: [
                  _buildTotalRow('Total HT', _totalHT),
                  const SizedBox(height: 8),
                  _buildTotalRow('TVA ($_tvaRate%)', _totalTVA),
                  const SizedBox(height: 8),
                  Container(height: 2, color: Colors.white.withOpacity(0.3)),
                  const SizedBox(height: 8),
                  _buildTotalRow('Total TTC', _totalTTC, isBold: true, isLarge: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== STEP 5: LEGAL & TERMS =====
  Widget _buildStep5LegalAndTerms() {
    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Conditions de paiement',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildGlassTextField(
                    label: 'Conditions et modalités',
                    initialValue: _termsConditionsController.text,
                    maxLines: 6,
                    onChanged: (value) => _termsConditionsController.text = value,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mentions légales',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildGlassTextField(
                    label: 'Informations légales',
                    initialValue: _legalMentionsController.text,
                    maxLines: 8,
                    onChanged: (value) => _legalMentionsController.text = value,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Notes additionnelles',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildGlassTextField(
                    label: 'Notes (optionnel)',
                    initialValue: _notesController.text,
                    maxLines: 3,
                    onChanged: (value) => _notesController.text = value,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== STEP 6: REVIEW & OPTIONS =====
  Widget _buildStep6Review() {
    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildGlassCard(
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          PlombiProColors.success,
                          PlombiProColors.tertiaryTeal,
                        ],
                      ),
                    ),
                    child: const Icon(
                      Icons.check_circle_outline,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Prêt à émettre!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Vérifiez le récapitulatif ci-dessous',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Client summary
            _buildGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person, color: PlombiProColors.secondaryOrange, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Client',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _selectedClient?.name ?? 'Non défini',
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Invoice type & dates
            _buildGlassCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.receipt_long, color: PlombiProColors.tertiaryTeal, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Type et dates',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('Type', {
                    'standard': 'Standard',
                    'deposit': 'Acompte',
                    'progress': 'Situation',
                    'credit_note': 'Avoir',
                  }[_invoiceType]!),
                  const SizedBox(height: 8),
                  _buildInfoRow('Date', InvoiceCalculator.formatDate(_invoiceDate)),
                  const SizedBox(height: 8),
                  _buildInfoRow('Échéance', InvoiceCalculator.formatDate(_dueDate)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Items summary
            _buildGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.shopping_cart, color: PlombiProColors.secondaryOrange, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Articles (${_lineItems.length})',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(_lineItems.length, (index) {
                    final item = _lineItems[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.description.isEmpty ? 'Article ${index + 1}' : item.description,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          Text(
                            InvoiceCalculator.formatCurrency(item.lineTotal),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Totals summary
            _buildGlassCard(
              child: Column(
                children: [
                  _buildTotalRow('Total HT', _totalHT),
                  const SizedBox(height: 8),
                  _buildTotalRow('TVA ($_tvaRate%)', _totalTVA),
                  const SizedBox(height: 8),
                  Container(height: 2, color: Colors.white.withOpacity(0.3)),
                  const SizedBox(height: 8),
                  _buildTotalRow('Total TTC', _totalTTC, isBold: true, isLarge: true),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Advanced options
            _buildGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Options avancées',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildGlassCheckbox(
                    label: 'Générer Factur-X (e-facture)',
                    subtitle: 'Format électronique conforme',
                    value: _generateFacturX,
                    onChanged: (value) => setState(() => _generateFacturX = value!),
                  ),
                  if (_generateFacturX) ...[
                    const SizedBox(height: 12),
                    _buildGlassCheckbox(
                      label: 'Soumettre à Chorus Pro',
                      subtitle: 'Portail gouvernemental',
                      value: _submitToChorusPro,
                      onChanged: (value) => setState(() => _submitToChorusPro = value!),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== HELPER WIDGETS =====
  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildGlassDateField({
    required String label,
    required IconData icon,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        InvoiceCalculator.formatDate(date),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassTextField({
    required String label,
    required String initialValue,
    required ValueChanged<String> onChanged,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? suffix,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: TextFormField(
            initialValue: initialValue,
            style: const TextStyle(color: Colors.white),
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
              suffixText: suffix,
              suffixStyle: const TextStyle(color: Colors.white),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  Widget _buildGlassDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            dropdownColor: PlombiProColors.primaryBlueDark,
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
              border: InputBorder.none,
            ),
            style: const TextStyle(color: Colors.white),
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  Widget _buildGlassCheckbox({
    required String label,
    String? subtitle,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: CheckboxListTile(
            title: Text(
              label,
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: subtitle != null
                ? Text(
                    subtitle,
                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                  )
                : null,
            value: value,
            onChanged: onChanged,
            activeColor: PlombiProColors.secondaryOrange,
            checkColor: Colors.white,
            side: BorderSide(color: Colors.white.withOpacity(0.5)),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildTotalRow(String label, double amount, {
    bool isBold = false,
    bool isLarge = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: isLarge ? 18 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          InvoiceCalculator.formatCurrency(amount),
          style: TextStyle(
            color: Colors.white,
            fontSize: isLarge ? 22 : 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildGlassNavigationButtons() {
    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: _buildNavButton(
                        label: 'Précédent',
                        icon: Icons.arrow_back,
                        onPressed: _previousStep,
                        isPrimary: false,
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: _buildNavButton(
                      label: _currentStep == 5
                          ? (_isSaving ? 'Enregistrement...' : 'Émettre la facture')
                          : 'Suivant',
                      icon: _currentStep == 5 ? Icons.check : Icons.arrow_forward,
                      onPressed: _currentStep == 5 ? _saveInvoice : _nextStep,
                      isPrimary: true,
                      isLoading: _isSaving,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    required bool isPrimary,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: isPrimary
              ? LinearGradient(
                  colors: [
                    PlombiProColors.secondaryOrange,
                    PlombiProColors.secondaryOrangeDark,
                  ],
                )
              : null,
          color: isPrimary ? null : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPrimary
                ? PlombiProColors.secondaryOrange
                : Colors.white.withOpacity(0.5),
            width: 2,
          ),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: PlombiProColors.secondaryOrange.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isPrimary && !isLoading) Icon(icon, color: Colors.white),
            if (!isPrimary && !isLoading) const SizedBox(width: 8),
            if (isLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            else
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (isPrimary && !isLoading) const SizedBox(width: 8),
            if (isPrimary && !isLoading) Icon(icon, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
