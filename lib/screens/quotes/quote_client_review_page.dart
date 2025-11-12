import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/quote.dart';
import '../../models/line_item.dart';
import '../../services/supabase_service.dart';
import '../../services/invoice_calculator.dart';
import '../../services/error_handler.dart';
import 'package:intl/intl.dart';

/// Client-facing Quote Review Page (Phase 11)
///
/// Features:
/// - Beautiful quote presentation for clients
/// - Accept/Reject buttons with workflow
/// - Optional rejection comments
/// - Status tracking and visual feedback
/// - Responsive design for mobile/tablet
/// - Shareable link capability
class QuoteClientReviewPage extends StatefulWidget {
  final String quoteId;

  const QuoteClientReviewPage({super.key, required this.quoteId});

  @override
  State<QuoteClientReviewPage> createState() => _QuoteClientReviewPageState();
}

class _QuoteClientReviewPageState extends State<QuoteClientReviewPage> {
  Quote? _quote;
  bool _isLoading = true;
  bool _isProcessing = false;
  String? _rejectionComment;

  @override
  void initState() {
    super.initState();
    _fetchQuote();
  }

  Future<void> _fetchQuote() async {
    setState(() => _isLoading = true);

    try {
      final quote = await SupabaseService.getQuoteById(widget.quoteId);
      if (mounted) {
        setState(() {
          _quote = quote;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        context.handleError(e, customMessage: 'Erreur de chargement du devis');
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _acceptQuote() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 12),
            Text('Accepter le devis?'),
          ],
        ),
        content: const Text(
          'En acceptant ce devis, vous confirmez votre accord avec les termes et conditions proposés.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Accepter'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isProcessing = true);

      try {
        final updatedQuote = Quote(
          id: _quote!.id,
          userId: _quote!.userId,
          quoteNumber: _quote!.quoteNumber,
          clientId: _quote!.clientId,
          date: _quote!.date,
          expiryDate: _quote!.expiryDate,
          status: 'accepté',
          totalHt: _quote!.totalHt,
          totalTva: _quote!.totalTva,
          totalTtc: _quote!.totalTtc,
          notes: _quote!.notes,
          items: _quote!.items,
        );

        await SupabaseService.updateQuote(widget.quoteId, updatedQuote);

        if (mounted) {
          context.showSuccess('Devis accepté avec succès!');
          await _fetchQuote(); // Refresh to show new status
        }
      } catch (e) {
        if (mounted) {
          context.handleError(e, customMessage: 'Erreur lors de l\'acceptation');
        }
      } finally {
        if (mounted) {
          setState(() => _isProcessing = false);
        }
      }
    }
  }

  Future<void> _rejectQuote() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        final commentController = TextEditingController();

        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.cancel, color: Colors.red, size: 28),
              SizedBox(width: 12),
              Text('Refuser le devis?'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Veuillez indiquer la raison du refus (optionnel):',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: commentController,
                decoration: const InputDecoration(
                  hintText: 'Exemple: Budget trop élevé, délai trop long...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.comment),
                ),
                maxLines: 3,
                maxLength: 500,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop({
                'confirmed': true,
                'comment': commentController.text.trim(),
              }),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Refuser'),
            ),
          ],
        );
      },
    );

    if (result != null && result['confirmed'] == true) {
      setState(() => _isProcessing = true);

      try {
        final comment = result['comment'] as String;
        final notesWithComment = comment.isNotEmpty
            ? '${_quote!.notes ?? ''}\n\n[Rejeté par client] $comment'
            : _quote!.notes;

        final updatedQuote = Quote(
          id: _quote!.id,
          userId: _quote!.userId,
          quoteNumber: _quote!.quoteNumber,
          clientId: _quote!.clientId,
          date: _quote!.date,
          expiryDate: _quote!.expiryDate,
          status: 'rejeté',
          totalHt: _quote!.totalHt,
          totalTva: _quote!.totalTva,
          totalTtc: _quote!.totalTtc,
          notes: notesWithComment,
          items: _quote!.items,
        );

        await SupabaseService.updateQuote(widget.quoteId, updatedQuote);

        if (mounted) {
          context.showSuccess('Votre réponse a été enregistrée');
          await _fetchQuote(); // Refresh to show new status
        }
      } catch (e) {
        if (mounted) {
          context.handleError(e, customMessage: 'Erreur lors du refus');
        }
      } finally {
        if (mounted) {
          setState(() => _isProcessing = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du devis'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _quote == null
              ? _buildErrorState()
              : _buildQuoteContent(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Devis introuvable',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Le devis demandé n\'existe pas ou a été supprimé',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go('/'),
              icon: const Icon(Icons.home),
              label: const Text('Retour à l\'accueil'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuoteContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeader(),
          _buildStatusBanner(),
          _buildQuoteDetails(),
          _buildLineItems(),
          _buildTotals(),
          _buildNotes(),
          _buildActionButtons(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DEVIS',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.9),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _quote!.quoteNumber,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Text(
                'Date: ${DateFormat('dd/MM/yyyy').format(_quote!.date)}',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
          if (_quote!.expiryDate != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.event_busy, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Valid until: ${DateFormat('dd/MM/yyyy').format(_quote!.expiryDate!)}',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBanner() {
    final status = _quote!.status.toLowerCase();
    Color backgroundColor;
    Color textColor;
    IconData icon;
    String message;

    switch (status) {
      case 'accepté':
        backgroundColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        icon = Icons.check_circle;
        message = 'Ce devis a été accepté';
        break;
      case 'rejeté':
        backgroundColor = Colors.red.shade50;
        textColor = Colors.red.shade700;
        icon = Icons.cancel;
        message = 'Ce devis a été refusé';
        break;
      case 'envoyé':
        backgroundColor = Colors.blue.shade50;
        textColor = Colors.blue.shade700;
        icon = Icons.pending;
        message = 'En attente de votre réponse';
        break;
      default:
        backgroundColor = Colors.grey.shade50;
        textColor = Colors.grey.shade700;
        icon = Icons.info;
        message = 'Statut: ${_quote!.status}';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: backgroundColor,
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuoteDetails() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Informations client',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Divider(height: 24),
              if (_quote!.client != null) ...[
                _buildDetailRow('Nom', _quote!.client!.name),
                if (_quote!.client!.email != null && _quote!.client!.email!.isNotEmpty)
                  _buildDetailRow('Email', _quote!.client!.email!),
                if (_quote!.client!.phone != null && _quote!.client!.phone!.isNotEmpty)
                  _buildDetailRow('Téléphone', _quote!.client!.phone!),
                if (_quote!.client!.address != null && _quote!.client!.address!.isNotEmpty)
                  _buildDetailRow('Adresse', _quote!.client!.address!),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineItems() {
    if (_quote!.items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Détail des prestations',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Divider(height: 24),
              ..._quote!.items.map((item) => _buildLineItem(item)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLineItem(LineItem item) {
    final total = item.quantity * item.unitPrice;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.description,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quantité: ${item.quantity} × ${InvoiceCalculator.formatCurrency(item.unitPrice)}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                InvoiceCalculator.formatCurrency(total),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotals() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Theme.of(context).primaryColor.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              _buildTotalRow('Sous-total HT', _quote!.totalHt, false),
              const SizedBox(height: 8),
              _buildTotalRow('TVA', _quote!.totalTva, false),
              const Divider(height: 24, thickness: 2),
              _buildTotalRow('Total TTC', _quote!.totalTtc, true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTotalRow(String label, double amount, bool isTotal) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 15,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        Text(
          InvoiceCalculator.formatCurrency(amount),
          style: TextStyle(
            fontSize: isTotal ? 22 : 16,
            fontWeight: FontWeight.bold,
            color: isTotal ? Theme.of(context).primaryColor : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildNotes() {
    if (_quote!.notes == null || _quote!.notes!.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.note, color: Theme.of(context).primaryColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Notes',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const Divider(height: 16),
              Text(
                _quote!.notes!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    final status = _quote!.status.toLowerCase();

    // Only show action buttons if quote is in 'envoyé' status
    if (status != 'envoyé') {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Text(
            'Que souhaitez-vous faire?',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isProcessing ? null : _rejectQuote,
                  icon: const Icon(Icons.cancel),
                  label: const Text('Refuser'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isProcessing ? null : _acceptQuote,
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Accepter'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_isProcessing) ...[
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text('Traitement en cours...'),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
