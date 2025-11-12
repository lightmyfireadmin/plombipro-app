import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'dart:io';
import 'dart:ui';

import '../../models/invoice.dart';
import '../../services/invoice_calculator.dart';
import '../../services/supabase_service.dart';
import '../../services/pdf_generator.dart';
import '../../config/plombipro_colors.dart';
import '../../config/glassmorphism_theme.dart';
import '../../widgets/glassmorphic/glass_card.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/app_bottom_nav.dart';
import 'package:animate_do/animate_do.dart';

/// Premium glassmorphic invoices list with modern design
class InvoicesListPage extends StatefulWidget {
  const InvoicesListPage({super.key});

  @override
  State<InvoicesListPage> createState() => _InvoicesListPageState();
}

class _InvoicesListPageState extends State<InvoicesListPage> with SingleTickerProviderStateMixin {
  List<Invoice> _invoices = [];
  List<Invoice> _filteredInvoices = [];
  bool _isLoading = true;
  String _selectedStatus = 'Toutes';
  final TextEditingController _searchController = TextEditingController();

  // Batch selection
  bool _isSelectionMode = false;
  final Set<String> _selectedInvoiceIds = {};

  // Sort options
  String _sortBy = 'date_desc';

  final List<String> _statuses = ['Toutes', 'Brouillon', 'Envoyée', 'Payée', 'Payée partiellement', 'En retard', 'Annulée'];

  late AnimationController _fabAnimationController;

  @override
  void initState() {
    super.initState();
    _fetchInvoices();
    _searchController.addListener(_filterInvoices);

    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterInvoices);
    _searchController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  Future<void> _fetchInvoices() async {
    setState(() => _isLoading = true);
    try {
      final invoices = await SupabaseService.fetchInvoices();
      if (mounted) {
        setState(() {
          _invoices = invoices;
          _filterInvoices();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur de chargement des factures: ${e.toString()}"),
            backgroundColor: PlombiProColors.error,
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  void _filterInvoices() {
    List<Invoice> filtered = List.from(_invoices);

    // Filter by payment status
    if (_selectedStatus != 'Toutes') {
      filtered = filtered.where((inv) {
        final status = inv.paymentStatus.toLowerCase();
        final selected = _selectedStatus.toLowerCase();

        if (selected == 'brouillon') return status == 'draft' || status == 'brouillon';
        if (selected == 'envoyée') return status == 'sent' || status == 'envoyée';
        if (selected == 'payée') return status == 'paid' || status == 'payée';
        if (selected == 'payée partiellement') return status == 'partial' || status.contains('partiel');
        if (selected == 'en retard') return status == 'overdue' || status.contains('retard');
        if (selected == 'annulée') return status == 'cancelled' || status.contains('annul');

        return false;
      }).toList();
    }

    // Filter by search term
    final searchTerm = _searchController.text.toLowerCase();
    if (searchTerm.isNotEmpty) {
      filtered = filtered.where((inv) {
        final clientName = inv.client?.name.toLowerCase() ?? '';
        final invoiceNumber = inv.number.toLowerCase();
        return clientName.contains(searchTerm) || invoiceNumber.contains(searchTerm);
      }).toList();
    }

    // Sort
    switch (_sortBy) {
      case 'date_desc':
        filtered.sort((a, b) => b.date.compareTo(a.date));
        break;
      case 'date_asc':
        filtered.sort((a, b) => a.date.compareTo(b.date));
        break;
      case 'amount_desc':
        filtered.sort((a, b) => b.totalTtc.compareTo(a.totalTtc));
        break;
      case 'amount_asc':
        filtered.sort((a, b) => a.totalTtc.compareTo(b.totalTtc));
        break;
      case 'client_asc':
        filtered.sort((a, b) => (a.client?.name ?? '').compareTo(b.client?.name ?? ''));
        break;
      case 'due_date_asc':
        filtered.sort((a, b) => (a.dueDate ?? DateTime.now()).compareTo(b.dueDate ?? DateTime.now()));
        break;
    }

    setState(() {
      _filteredInvoices = filtered;
    });
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedInvoiceIds.clear();
      }
    });
  }

  void _toggleInvoiceSelection(String invoiceId) {
    setState(() {
      if (_selectedInvoiceIds.contains(invoiceId)) {
        _selectedInvoiceIds.remove(invoiceId);
      } else {
        _selectedInvoiceIds.add(invoiceId);
      }
    });
  }

  void _selectAll() {
    setState(() {
      if (_selectedInvoiceIds.length == _filteredInvoices.length) {
        _selectedInvoiceIds.clear();
      } else {
        _selectedInvoiceIds.clear();
        for (var invoice in _filteredInvoices) {
          if (invoice.id != null) _selectedInvoiceIds.add(invoice.id!);
        }
      }
    });
  }

  Future<void> _batchDelete() async {
    final confirm = await _showGlassDialog(
      title: 'Confirmer la suppression',
      content: 'Voulez-vous vraiment supprimer ${_selectedInvoiceIds.length} factures ?',
      confirmText: 'Supprimer',
      isDestructive: true,
    );

    if (confirm != true) return;

    try {
      for (var invoiceId in _selectedInvoiceIds) {
        await SupabaseService.deleteInvoice(invoiceId);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_selectedInvoiceIds.length} factures supprimées avec succès'),
            backgroundColor: PlombiProColors.success,
          ),
        );
        _toggleSelectionMode();
        _fetchInvoices();
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
    }
  }

  Future<void> _batchExportPdf() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export de ${_selectedInvoiceIds.length} factures en cours...'),
          backgroundColor: PlombiProColors.info,
        ),
      );

      for (var invoiceId in _selectedInvoiceIds) {
        final invoice = _filteredInvoices.firstWhere((inv) => inv.id == invoiceId);
        final pdfBytes = await PdfGenerator.generateInvoicePdf(
          invoiceNumber: invoice.number,
          clientName: invoice.client?.name ?? 'Client inconnu',
          totalTtc: invoice.totalTtc,
        );

        final output = await getTemporaryDirectory();
        final file = File("${output.path}/${invoice.number}.pdf");
        await file.writeAsBytes(pdfBytes);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_selectedInvoiceIds.length} PDF générés avec succès'),
            backgroundColor: PlombiProColors.success,
          ),
        );
        _toggleSelectionMode();
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
    }
  }

  Future<bool?> _showGlassDialog({
    required String title,
    required String content,
    required String confirmText,
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: PlombiProColors.primaryBlueDark.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      content,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              backgroundColor: Colors.white.withOpacity(0.1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Annuler',
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              backgroundColor: isDestructive
                                  ? PlombiProColors.error
                                  : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              confirmText,
                              style: TextStyle(
                                color: isDestructive ? Colors.white : PlombiProColors.primary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: PlombiProColors.backgroundLight,
      appBar: _buildGlassAppBar(),
      drawer: const AppDrawer(),
      body: Stack(
        children: [
          // Gradient background
          _buildGradientBackground(),

          // Main content
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 8),
                _buildGlassSearchBar(),
                const SizedBox(height: 12),
                _buildStatusFilters(),
                const SizedBox(height: 12),
                _buildInvoicesHeader(),
                const SizedBox(height: 12),
                Expanded(
                  child: _isLoading
                      ? _buildLoadingState()
                      : RefreshIndicator(
                          onRefresh: _fetchInvoices,
                          color: Colors.white,
                          backgroundColor: PlombiProColors.primaryBlue,
                          child: _filteredInvoices.isEmpty
                              ? _buildEmptyState()
                              : _buildInvoicesList(),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _isSelectionMode ? null : _buildGlassFAB(),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
    );
  }

  PreferredSizeWidget _buildGlassAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: _isSelectionMode
          ? ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: _toggleSelectionMode,
                  ),
                ),
              ),
            )
          : ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => context.pop(),
                  ),
                ),
              ),
            ),
      title: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              _isSelectionMode ? '${_selectedInvoiceIds.length} sélectionné(s)' : 'Mes Factures',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
      centerTitle: true,
      actions: _isSelectionMode
          ? [
              Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.select_all, color: Colors.white),
                      onPressed: _selectAll,
                      tooltip: 'Tout sélectionner',
                    ),
                    IconButton(
                      icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                      onPressed: _selectedInvoiceIds.isEmpty ? null : _batchExportPdf,
                      tooltip: 'Exporter PDF',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.white),
                      onPressed: _selectedInvoiceIds.isEmpty ? null : _batchDelete,
                      tooltip: 'Supprimer',
                    ),
                  ],
                ),
              ),
            ]
          : [
              Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.sort, color: Colors.white),
                      color: PlombiProColors.primaryBlueDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      onSelected: (value) {
                        setState(() {
                          _sortBy = value;
                          _filterInvoices();
                        });
                      },
                      itemBuilder: (context) => [
                        _buildMenuItem('date_desc', Icons.calendar_today, 'Date (récent)'),
                        _buildMenuItem('date_asc', Icons.calendar_today, 'Date (ancien)'),
                        _buildMenuItem('amount_desc', Icons.euro, 'Montant ↓'),
                        _buildMenuItem('amount_asc', Icons.euro, 'Montant ↑'),
                        _buildMenuItem('client_asc', Icons.person, 'Client (A-Z)'),
                        _buildMenuItem('due_date_asc', Icons.event, 'Échéance'),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.checklist, color: Colors.white),
                      onPressed: _toggleSelectionMode,
                      tooltip: 'Sélection',
                    ),
                  ],
                ),
              ),
            ],
    );
  }

  PopupMenuItem<String> _buildMenuItem(String value, IconData icon, String text) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(color: Colors.white)),
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
            PlombiProColors.secondaryOrange,
            PlombiProColors.primaryBlue,
            PlombiProColors.tertiaryTeal,
          ],
        ),
      ),
    );
  }

  Widget _buildGlassSearchBar() {
    return FadeInDown(
      duration: const Duration(milliseconds: 600),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'Rechercher une facture...',
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear_rounded,
                            color: Colors.white.withOpacity(0.7),
                          ),
                          onPressed: () => _searchController.clear(),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusFilters() {
    return FadeInLeft(
      duration: const Duration(milliseconds: 600),
      child: Container(
        height: 50,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _statuses.length,
          itemBuilder: (context, index) {
            final status = _statuses[index];
            final isSelected = _selectedStatus == status;
            return Container(
              margin: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedStatus = status;
                    _filterInvoices();
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withOpacity(0.3)
                        : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? Colors.white.withOpacity(0.5)
                          : Colors.white.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInvoicesHeader() {
    return FadeInRight(
      duration: const Duration(milliseconds: 600),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
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
                    '${_filteredInvoices.length} facture${_filteredInvoices.length > 1 ? 's' : ''}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    Text(
                      'sur ${_invoices.length} total',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.7),
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

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Chargement des factures...',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: FadeIn(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(48),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                size: 80,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Aucune facture trouvée',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _searchController.text.isEmpty
                  ? 'Commencez par créer votre première facture'
                  : 'Aucun résultat pour votre recherche',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            GlassCard(
              onTap: () => context.push('/invoices/new'),
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.add_rounded, color: Colors.white, size: 24),
                  SizedBox(width: 12),
                  Text(
                    'Créer une facture',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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

  Widget _buildInvoicesList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: _filteredInvoices.length,
      itemBuilder: (context, index) {
        final invoice = _filteredInvoices[index];
        return FadeInUp(
          delay: Duration(milliseconds: 50 * index),
          duration: const Duration(milliseconds: 400),
          child: _GlassInvoiceCard(
            invoice: invoice,
            isSelectionMode: _isSelectionMode,
            isSelected: _selectedInvoiceIds.contains(invoice.id),
            onSelectionToggle: () => _toggleInvoiceSelection(invoice.id!),
            onActionSelected: _fetchInvoices,
          ),
        );
      },
    );
  }

  Widget _buildGlassFAB() {
    return FadeInUp(
      duration: const Duration(milliseconds: 800),
      child: GestureDetector(
        onTapDown: (_) => _fabAnimationController.forward(),
        onTapUp: (_) {
          _fabAnimationController.reverse();
          context.push('/invoices/new');
        },
        onTapCancel: () => _fabAnimationController.reverse(),
        child: AnimatedBuilder(
          animation: _fabAnimationController,
          builder: (context, child) {
            return Transform.scale(
              scale: 1 - (_fabAnimationController.value * 0.1),
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      PlombiProColors.secondaryOrange,
                      PlombiProColors.secondaryOrangeDark,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: PlombiProColors.secondaryOrange.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Glassmorphic invoice card widget
class _GlassInvoiceCard extends StatelessWidget {
  final Invoice invoice;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback? onSelectionToggle;
  final VoidCallback onActionSelected;

  const _GlassInvoiceCard({
    required this.invoice,
    required this.isSelectionMode,
    required this.isSelected,
    this.onSelectionToggle,
    required this.onActionSelected,
  });

  Color _getStatusColor() {
    switch (invoice.paymentStatus.toLowerCase()) {
      case 'paid':
      case 'payée':
        return PlombiProColors.success;
      case 'sent':
      case 'envoyée':
        return PlombiProColors.info;
      case 'overdue':
      case 'en retard':
        return PlombiProColors.error;
      case 'partial':
      case 'payée partiellement':
        return PlombiProColors.warning;
      case 'cancelled':
      case 'annulée':
        return PlombiProColors.gray500;
      default:
        return PlombiProColors.gray400;
    }
  }

  String _getStatusLabel() {
    switch (invoice.paymentStatus.toLowerCase()) {
      case 'paid':
        return 'PAYÉE';
      case 'sent':
        return 'ENVOYÉE';
      case 'overdue':
        return 'EN RETARD';
      case 'partial':
        return 'PARTIEL';
      case 'cancelled':
        return 'ANNULÉE';
      case 'draft':
        return 'BROUILLON';
      default:
        return invoice.paymentStatus.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final daysUntilDue = invoice.dueDate != null
        ? invoice.dueDate!.difference(DateTime.now()).inDays
        : null;
    final isOverdue = daysUntilDue != null && daysUntilDue < 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        onTap: isSelectionMode ? onSelectionToggle : null,
        color: isSelected ? PlombiProColors.primaryBlueLight : Colors.white,
        borderRadius: BorderRadius.circular(20),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (isSelectionMode)
                  Container(
                    margin: const EdgeInsets.only(right: 16),
                    child: Icon(
                      isSelected ? Icons.check_circle : Icons.circle_outlined,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            invoice.number,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          if (isOverdue) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: PlombiProColors.error.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                '⚠️ RETARD',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        invoice.client?.name ?? 'Client inconnu',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isSelectionMode)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert_rounded,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      color: PlombiProColors.primaryBlueDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      onSelected: (value) => _handleMenuSelection(value, context),
                      itemBuilder: (context) => [
                        _buildMenuItem('edit', Icons.edit_rounded, 'Éditer'),
                        _buildMenuItem('download', Icons.download_rounded, 'Télécharger PDF'),
                        _buildMenuItem('send', Icons.email_rounded, 'Envoyer par email'),
                        const PopupMenuDivider(),
                        _buildMenuItem('delete', Icons.delete_rounded, 'Supprimer', isDestructive: true),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getStatusColor().withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _getStatusLabel(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Émise: ${InvoiceCalculator.formatDate(invoice.date)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    if (invoice.dueDate != null)
                      Text(
                        'Échéance: ${InvoiceCalculator.formatDate(invoice.dueDate!)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isOverdue ? PlombiProColors.error : Colors.white.withOpacity(0.8),
                          fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Montant TTC',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                Text(
                  InvoiceCalculator.formatCurrency(invoice.totalTtc),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildMenuItem(
    String value,
    IconData icon,
    String text, {
    bool isDestructive = false,
  }) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            color: isDestructive ? PlombiProColors.error : Colors.white,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              color: isDestructive ? PlombiProColors.error : Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuSelection(String value, BuildContext context) async {
    switch (value) {
      case 'edit':
        final result = await context.push('/invoices/${invoice.id}', extra: invoice);
        if (result == true) onActionSelected();
        break;
      case 'download':
        try {
          final pdfBytes = await PdfGenerator.generateInvoicePdf(
            invoiceNumber: invoice.number,
            clientName: invoice.client?.name ?? 'Client inconnu',
            totalTtc: invoice.totalTtc,
          );

          final output = await getTemporaryDirectory();
          final file = File("${output.path}/${invoice.number}.pdf");
          await file.writeAsBytes(pdfBytes);

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('PDF généré avec succès'),
                backgroundColor: PlombiProColors.success,
              ),
            );
            OpenFilex.open(file.path);
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Erreur: ${e.toString()}"),
                backgroundColor: PlombiProColors.error,
              ),
            );
          }
        }
        break;
      case 'send':
        // TODO: Implement email sending
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Fonction email à venir'),
            backgroundColor: PlombiProColors.info,
          ),
        );
        break;
      case 'delete':
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Dialog(
              backgroundColor: Colors.transparent,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: PlombiProColors.primaryBlueDark.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Confirmer la suppression',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Voulez-vous vraiment supprimer cette facture ?',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.9),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  backgroundColor: Colors.white.withOpacity(0.1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Annuler',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  backgroundColor: PlombiProColors.error,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Supprimer',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        if (confirm == true) {
          try {
            await SupabaseService.deleteInvoice(invoice.id!);
            onActionSelected();
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Erreur: ${e.toString()}"),
                  backgroundColor: PlombiProColors.error,
                ),
              );
            }
          }
        }
        break;
    }
  }
}
