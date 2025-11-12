import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/invoice_template.dart';
import '../../services/supabase_service.dart';
import '../../services/error_handler.dart';
import '../../services/invoice_calculator.dart';
import '../../widgets/app_drawer.dart';

/// Invoice Template Management System (Phase 11)
/// Allows users to create, manage, and use reusable invoice templates
class InvoiceTemplatesPage extends StatefulWidget {
  const InvoiceTemplatesPage({super.key});

  @override
  State<InvoiceTemplatesPage> createState() => _InvoiceTemplatesPageState();
}

class _InvoiceTemplatesPageState extends State<InvoiceTemplatesPage> {
  List<InvoiceTemplate> _templates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTemplates();
  }

  Future<void> _fetchTemplates() async {
    setState(() => _isLoading = true);

    try {
      final templates = await SupabaseService.fetchInvoiceTemplates();
      if (mounted) {
        setState(() {
          _templates = templates;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        context.handleError(e, customMessage: 'Erreur de chargement des modèles');
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteTemplate(InvoiceTemplate template) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le modèle?'),
        content: Text('Êtes-vous sûr de vouloir supprimer "${template.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await SupabaseService.deleteInvoiceTemplate(template.id!);
        if (mounted) {
          context.showSuccess('Modèle supprimé');
          _fetchTemplates();
        }
      } catch (e) {
        if (mounted) {
          context.handleError(e, customMessage: 'Erreur lors de la suppression');
        }
      }
    }
  }

  Future<void> _duplicateTemplate(InvoiceTemplate template) async {
    final newTemplate = InvoiceTemplate(
      name: '${template.name} (Copie)',
      description: template.description,
      items: template.items,
      notes: template.notes,
      paymentTerms: template.paymentTerms,
      discountPercentage: template.discountPercentage,
      taxRate: template.taxRate,
    );

    try {
      await SupabaseService.createInvoiceTemplate(newTemplate);
      if (mounted) {
        context.showSuccess('Modèle dupliqué');
        _fetchTemplates();
      }
    } catch (e) {
      if (mounted) {
        context.handleError(e, customMessage: 'Erreur lors de la duplication');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modèles de facture'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelpDialog(),
            tooltip: 'Aide',
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _templates.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _fetchTemplates,
                  child: _buildTemplatesList(),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateTemplateDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Nouveau modèle'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 100,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 24),
            Text(
              'Aucun modèle de facture',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Créez des modèles pour générer rapidement vos factures récurrentes',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _showCreateTemplateDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Créer mon premier modèle'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplatesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _templates.length,
      itemBuilder: (context, index) {
        final template = _templates[index];
        return _buildTemplateCard(template);
      },
    );
  }

  Widget _buildTemplateCard(InvoiceTemplate template) {
    final totalHT = template.calculateTotalHT();
    final totalTTC = template.calculateTotalTTC();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showTemplateDetails(template),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          template.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (template.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            template.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          _showEditTemplateDialog(template);
                          break;
                        case 'duplicate':
                          _duplicateTemplate(template);
                          break;
                        case 'use':
                          _useTemplate(template);
                          break;
                        case 'delete':
                          _deleteTemplate(template);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'use',
                        child: Row(
                          children: [
                            Icon(Icons.receipt_long, size: 20),
                            SizedBox(width: 12),
                            Text('Créer une facture'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 12),
                            Text('Modifier'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'duplicate',
                        child: Row(
                          children: [
                            Icon(Icons.copy, size: 20),
                            SizedBox(width: 12),
                            Text('Dupliquer'),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 12),
                            Text('Supprimer', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoChip(
                      '${template.items.length} article${template.items.length > 1 ? 's' : ''}',
                      Icons.inventory_2,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInfoChip(
                      InvoiceCalculator.formatCurrency(totalHT),
                      Icons.euro,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInfoChip(
                      'TVA ${template.taxRate}%',
                      Icons.percent,
                      Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total TTC',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      InvoiceCalculator.formatCurrency(totalTTC),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
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

  Widget _buildInfoChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showTemplateDetails(InvoiceTemplate template) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  template.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  template.description,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Articles',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...template.items.map((item) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(item['name'] as String),
                        subtitle: Text('Qté: ${item['quantity']} × ${InvoiceCalculator.formatCurrency(item['unitPrice'] as double)}'),
                        trailing: Text(
                          InvoiceCalculator.formatCurrency(
                            (item['quantity'] as int) * (item['unitPrice'] as double),
                          ),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    )),
                const SizedBox(height: 24),
                if (template.notes.isNotEmpty) ...[
                  const Text(
                    'Notes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(template.notes),
                  const SizedBox(height: 24),
                ],
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _useTemplate(template);
                  },
                  icon: const Icon(Icons.receipt_long),
                  label: const Text('Créer une facture à partir de ce modèle'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size(double.infinity, 0),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showCreateTemplateDialog() {
    // Navigate to template creation page
    context.push('/invoices/templates/new').then((_) => _fetchTemplates());
  }

  void _showEditTemplateDialog(InvoiceTemplate template) {
    // Navigate to template edit page
    context.push('/invoices/templates/${template.id}').then((_) => _fetchTemplates());
  }

  void _useTemplate(InvoiceTemplate template) {
    // Navigate to invoice creation with template pre-filled
    context.push('/invoices/new', extra: {'template': template});
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modèles de facture'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Les modèles vous permettent de créer rapidement des factures récurrentes.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text('✓ Gagnez du temps sur les factures répétitives'),
              SizedBox(height: 8),
              Text('✓ Assurez la cohérence de vos tarifs'),
              SizedBox(height: 8),
              Text('✓ Créez autant de modèles que nécessaire'),
              SizedBox(height: 8),
              Text('✓ Modifiez et dupliquez facilement'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Compris'),
          ),
        ],
      ),
    );
  }
}
