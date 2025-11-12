import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import '../../models/client.dart';
import '../../models/line_item.dart';
import '../../models/product.dart';
import '../../models/quote.dart';
import '../../models/profile.dart';
import '../../services/invoice_calculator.dart';
import '../../services/supabase_service.dart';
import '../../services/template_service.dart';
import '../../services/pdf_generator.dart';
import '../../config/plombipro_colors.dart';
import '../../config/glassmorphism_theme.dart';

/// Premium glassmorphism quote wizard with 6 intuitive steps
/// Surpasses iOS design quality with fluid animations and modern aesthetics
class QuoteWizardPage extends StatefulWidget {
  final String? quoteId;

  const QuoteWizardPage({super.key, this.quoteId});

  @override
  State<QuoteWizardPage> createState() => _QuoteWizardPageState();
}

class _QuoteWizardPageState extends State<QuoteWizardPage>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  final _formKey = GlobalKey<FormState>();

  int _currentStep = 0;
  bool get _isEditing => widget.quoteId != null;
  Quote? _quote;
  Profile? _profile;

  // Animation controllers
  late AnimationController _backgroundController;
  late Animation<double> _backgroundAnimation;

  // Step 1: Client Selection
  Client? _selectedClient;
  List<Client> _clients = [];
  final TextEditingController _clientSearchController = TextEditingController();
  List<Client> _filteredClients = [];

  // Step 2: Quote Details
  DateTime _date = DateTime.now();
  DateTime _expiryDate = DateTime.now().add(const Duration(days: 30));

  // Step 3: Template (Optional)
  List<TemplateInfo> _availableTemplates = [];
  TemplateInfo? _selectedTemplate;
  String _selectedCategory = 'Tous';

  // Step 4: Line Items
  List<LineItem> _lineItems = [];
  List<Product> _products = [];

  // Step 5: Calculations & Options
  double _totalHT = 0;
  double _totalTVA = 0;
  double _totalTTC = 0;
  double _tvaRate = 20.0;
  static const List<double> _availableVatRates = [20.0, 10.0, 5.5, 2.1];
  final TextEditingController _notesController = TextEditingController();
  bool _requiresSignature = false;
  bool _sendAfterCreation = false;

  bool _isLoading = true;
  bool _isSaving = false;

  final List<String> _stepTitles = [
    'Client',
    'Détails',
    'Modèle',
    'Articles',
    'Calculs',
    'Révision',
  ];

  final List<IconData> _stepIcons = [
    Icons.person_outline,
    Icons.calendar_today_outlined,
    Icons.description_outlined,
    Icons.shopping_cart_outlined,
    Icons.calculate_outlined,
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
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      if (_isEditing) {
        final quote = await SupabaseService.fetchQuoteById(widget.quoteId!);
        setState(() => _quote = quote);
      }

      final results = await Future.wait([
        SupabaseService.fetchClients(),
        SupabaseService.fetchProducts(),
        TemplateService.getTemplatesList(),
        SupabaseService.fetchUserProfile(),
      ]);

      setState(() {
        _clients = results[0] as List<Client>;
        _filteredClients = _clients;
        _products = results[1] as List<Product>;
        _availableTemplates = results[2] as List<TemplateInfo>;
        _profile = results[3] as Profile?;

        if (_isEditing && _quote != null) {
          _populateExistingQuote();
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

  void _populateExistingQuote() {
    final quote = _quote!;
    _selectedClient = _clients.firstWhere(
      (c) => c.id == quote.clientId,
      orElse: () => _clients.first,
    );
    _date = quote.date;
    _expiryDate = quote.expiryDate ?? DateTime.now().add(const Duration(days: 30));
    _lineItems = List<LineItem>.from(quote.items);
    _notesController.text = quote.notes ?? '';
    _calculateTotals();
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

  Future<void> _applyTemplate(TemplateInfo templateInfo) async {
    try {
      final template = await TemplateService.loadTemplate(templateInfo.id);
      if (template == null) {
        _showError('Erreur lors du chargement du modèle');
        return;
      }

      setState(() {
        _selectedTemplate = templateInfo;
        _lineItems = List<LineItem>.from(template.lineItems);
        if (template.termsConditions != null && template.termsConditions!.isNotEmpty) {
          _notesController.text = template.termsConditions!;
        }
        _calculateTotals();
      });

      _showSuccess('Modèle "${templateInfo.name}" appliqué (${template.lineItems.length} articles)');
    } catch (e) {
      _showError('Erreur: ${e.toString()}');
    }
  }

  Future<void> _saveQuote() async {
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
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final quote = Quote(
        id: _quote?.id,
        userId: userId,
        quoteNumber: _quote?.quoteNumber ?? 'DRAFT',
        clientId: _selectedClient!.id!,
        date: _date,
        expiryDate: _expiryDate,
        items: _lineItems,
        totalHt: _totalHT,
        totalTva: _totalTVA,
        totalTtc: _totalTTC,
        notes: _notesController.text,
        status: 'draft',
      );

      if (_isEditing) {
        await SupabaseService.updateQuote(quote.id!, quote);
      } else {
        final newQuoteId = await SupabaseService.createQuote(quote);
        await SupabaseService.createLineItems(newQuoteId, _lineItems);
      }

      if (mounted) {
        _showSuccess('Devis enregistré avec succès!');
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

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: PlombiProColors.error,
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: PlombiProColors.success,
      ),
    );
  }

  void _nextStep() {
    if (_currentStep < 5) {
      // Validate current step before proceeding
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
                    _buildStep1ClientSelection(),
                    _buildStep2QuoteDetails(),
                    _buildStep3TemplateSelection(),
                    _buildStep4LineItems(),
                    _buildStep5Calculations(),
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
                PlombiProColors.primaryBlue,
                PlombiProColors.tertiaryTeal,
                PlombiProColors.primaryBlueDark,
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
          _isEditing ? 'Éditer Devis' : 'Nouveau Devis',
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

  // ===== STEP 1: CLIENT SELECTION =====
  Widget _buildStep1ClientSelection() {
    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sélectionner un client',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Recherchez et sélectionnez le client pour ce devis',
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
                            hintText: 'Rechercher par nom, email ou ville...',
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
                                // Avatar
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        PlombiProColors.primaryBlue,
                                        PlombiProColors.tertiaryTeal,
                                      ],
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      client.name.isNotEmpty
                                          ? client.name[0].toUpperCase()
                                          : '?',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Client info
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
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.email_outlined,
                                              size: 14,
                                              color: Colors.white.withOpacity(0.7),
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                client.email!,
                                                style: TextStyle(
                                                  color: Colors.white.withOpacity(0.7),
                                                  fontSize: 12,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                      if (client.city != null && client.city!.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.location_on_outlined,
                                              size: 14,
                                              color: Colors.white.withOpacity(0.7),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              client.city!,
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(0.7),
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                // Selection indicator
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

  // ===== STEP 2: QUOTE DETAILS =====
  Widget _buildStep2QuoteDetails() {
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
                    'Détails du devis',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Définissez les dates importantes',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Date du devis
                  _buildGlassDateField(
                    label: 'Date du devis',
                    icon: Icons.calendar_today,
                    date: _date,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _date,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                        builder: (context, child) {
                          return Theme(
                            data: ThemeData.dark().copyWith(
                              colorScheme: ColorScheme.dark(
                                primary: PlombiProColors.primaryBlue,
                                surface: PlombiProColors.primaryBlueDark,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (date != null) {
                        setState(() {
                          _date = date;
                          // Update expiry date if it's before the new date
                          if (_expiryDate.isBefore(_date)) {
                            _expiryDate = _date.add(const Duration(days: 30));
                          }
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  // Date de validité
                  _buildGlassDateField(
                    label: 'Valide jusqu\'au',
                    icon: Icons.event_available,
                    date: _expiryDate,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _expiryDate,
                        firstDate: _date,
                        lastDate: _date.add(const Duration(days: 365)),
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
                      if (date != null) setState(() => _expiryDate = date);
                    },
                  ),
                  const SizedBox(height: 24),
                  // Validity period indicator
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
                                'Période de validité: ${_expiryDate.difference(_date).inDays} jours',
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

  // ===== STEP 3: TEMPLATE SELECTION =====
  Widget _buildStep3TemplateSelection() {
    final grouped = TemplateService.groupByCategory(_availableTemplates);
    final categories = ['Tous', ...grouped.keys];

    List<TemplateInfo> displayedTemplates = _selectedCategory == 'Tous'
        ? _availableTemplates
        : (grouped[_selectedCategory] ?? []);

    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Modèle de devis',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Optionnel: Choisissez un modèle pré-configuré',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_selectedTemplate != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: PlombiProColors.success.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: PlombiProColors.success.withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle, color: PlombiProColors.success),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Modèle "${_selectedTemplate!.name}" appliqué',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.white),
                                onPressed: () {
                                  setState(() {
                                    _selectedTemplate = null;
                                    _lineItems.clear();
                                    _notesController.clear();
                                    _calculateTotals();
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Category selector
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = category == _selectedCategory;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = category),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? PlombiProColors.secondaryOrange.withOpacity(0.3)
                                  : Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? PlombiProColors.secondaryOrange
                                    : Colors.white.withOpacity(0.3),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Text(
                              category,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // Template cards
            if (displayedTemplates.isEmpty)
              _buildGlassCard(
                child: Center(
                  child: Text(
                    'Aucun modèle disponible',
                    style: TextStyle(color: Colors.white.withOpacity(0.8)),
                  ),
                ),
              )
            else
              ...List.generate(displayedTemplates.length, (index) {
                final template = displayedTemplates[index];

                return FadeInUp(
                  delay: Duration(milliseconds: 50 * index),
                  duration: const Duration(milliseconds: 400),
                  child: GestureDetector(
                    onTap: () => _applyTemplate(template),
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
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: PlombiProColors.tertiaryTeal.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.description,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        template.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${template.itemsCount} articles • ${template.estimatedPriceRange}€',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.7),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right,
                                  color: Colors.white,
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

  // ===== STEP 4: LINE ITEMS =====
  Widget _buildStep4LineItems() {
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
                    'Ajoutez les lignes de votre devis',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Line items
            if (_lineItems.isEmpty)
              _buildGlassCard(
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        color: Colors.white.withOpacity(0.5),
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aucun article ajouté',
                        style: TextStyle(color: Colors.white.withOpacity(0.8)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Cliquez sur le bouton ci-dessous pour ajouter',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _lineItems.length,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) newIndex -= 1;
                    final item = _lineItems.removeAt(oldIndex);
                    _lineItems.insert(newIndex, item);
                  });
                },
                itemBuilder: (context, index) {
                  return _buildLineItemCard(index, key: ValueKey(_lineItems[index]));
                },
              ),
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
                      Icon(Icons.drag_indicator, color: Colors.white.withOpacity(0.5)),
                      const SizedBox(width: 8),
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
                  // Description field with product autocomplete
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

  // ===== STEP 5: CALCULATIONS & OPTIONS =====
  Widget _buildStep5Calculations() {
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
                    'Calculs et options',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Vérifiez les montants et ajoutez des options',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Totals
                  _buildTotalRow('Total HT', _totalHT),
                  const SizedBox(height: 12),
                  // TVA selector
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'TVA',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: PlombiProColors.secondaryOrange.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: DropdownButton<double>(
                                    value: _tvaRate,
                                    dropdownColor: PlombiProColors.primaryBlueDark,
                                    underline: Container(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    items: _availableVatRates.map((rate) {
                                      return DropdownMenuItem<double>(
                                        value: rate,
                                        child: Text(
                                          '${rate.toStringAsFixed(rate == rate.roundToDouble() ? 0 : 1)}%',
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      if (value != null) {
                                        setState(() {
                                          _tvaRate = value;
                                          _calculateTotals();
                                        });
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  InvoiceCalculator.formatCurrency(_totalTVA),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(height: 2, color: Colors.white.withOpacity(0.3)),
                  const SizedBox(height: 12),
                  _buildTotalRow('Total TTC', _totalTTC, isBold: true, isLarge: true),
                  const SizedBox(height: 12),
                  Container(height: 2, color: Colors.white.withOpacity(0.3)),
                  const SizedBox(height: 12),
                  _buildTotalRow(
                    'Acompte (20%)',
                    InvoiceCalculator.calculateDeposit(total: _totalTTC, depositPercent: 20),
                    color: PlombiProColors.tertiaryTeal,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Notes
            _buildGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Notes et conditions',
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
                    maxLines: 4,
                    onChanged: (value) => _notesController.text = value,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Options
            _buildGlassCard(
              child: Column(
                children: [
                  _buildGlassCheckbox(
                    label: 'Nécessite une signature',
                    value: _requiresSignature,
                    onChanged: (value) => setState(() => _requiresSignature = value!),
                  ),
                  const SizedBox(height: 12),
                  _buildGlassCheckbox(
                    label: 'Envoyer après création',
                    value: _sendAfterCreation,
                    onChanged: (value) => setState(() => _sendAfterCreation = value!),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalRow(String label, double amount, {
    bool isBold = false,
    bool isLarge = false,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: color ?? Colors.white,
            fontSize: isLarge ? 20 : 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        Text(
          InvoiceCalculator.formatCurrency(amount),
          style: TextStyle(
            color: color ?? Colors.white,
            fontSize: isLarge ? 24 : 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ===== STEP 6: REVIEW & CONFIRM =====
  Widget _buildStep6Review() {
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
                  Row(
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
                              'Prêt à enregistrer!',
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
                      const Icon(Icons.person, color: PlombiProColors.primaryBlue, size: 20),
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
                  if (_selectedClient?.email != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _selectedClient!.email!,
                      style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Dates summary
            _buildGlassCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, color: PlombiProColors.tertiaryTeal, size: 16),
                            const SizedBox(width: 8),
                            const Text(
                              'Date',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          InvoiceCalculator.formatDate(_date),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.event_available, color: PlombiProColors.secondaryOrange, size: 16),
                            const SizedBox(width: 8),
                            const Text(
                              'Validité',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          InvoiceCalculator.formatDate(_expiryDate),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
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
                  _buildSummaryRow('Total HT', _totalHT),
                  const SizedBox(height: 8),
                  _buildSummaryRow('TVA ($_tvaRate%)', _totalTVA),
                  const SizedBox(height: 8),
                  Container(height: 2, color: Colors.white.withOpacity(0.3)),
                  const SizedBox(height: 8),
                  _buildSummaryRow('Total TTC', _totalTTC, isBold: true, isLarge: true),
                ],
              ),
            ),
            // IBAN Warning if missing
            if (_profile?.iban == null || _profile!.iban!.isEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: PlombiProColors.warning.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: PlombiProColors.warning.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: PlombiProColors.warning,
                      size: 28,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'IBAN manquant',
                            style: TextStyle(
                              color: PlombiProColors.warning,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Ajoutez vos coordonnées bancaires dans les paramètres de l\'entreprise pour qu\'elles apparaissent sur les devis PDF',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 13,
                            ),
                          ),
                        ],
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

  Widget _buildSummaryRow(String label, double amount, {bool isBold = false, bool isLarge = false}) {
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

  Widget _buildGlassCheckbox({
    required String label,
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
                          ? (_isSaving ? 'Enregistrement...' : 'Enregistrer')
                          : 'Suivant',
                      icon: _currentStep == 5 ? Icons.check : Icons.arrow_forward,
                      onPressed: _currentStep == 5 ? _saveQuote : _nextStep,
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
