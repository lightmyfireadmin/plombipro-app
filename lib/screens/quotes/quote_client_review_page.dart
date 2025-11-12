import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/quote.dart';
import '../../models/line_item.dart';
import '../../services/supabase_service.dart';
import '../../services/invoice_calculator.dart';
import '../../services/error_handler.dart';
import '../../config/plombipro_colors.dart';
import '../../widgets/glassmorphic/glass_card.dart';
import 'package:intl/intl.dart';

/// Beautiful glassmorphic client-facing Quote Review Page
class QuoteClientReviewPage extends StatefulWidget {
  final String quoteId;

  const QuoteClientReviewPage({super.key, required this.quoteId});

  @override
  State<QuoteClientReviewPage> createState() => _QuoteClientReviewPageState();
}

class _QuoteClientReviewPageState extends State<QuoteClientReviewPage>
    with SingleTickerProviderStateMixin {
  Quote? _quote;
  bool _isLoading = true;
  bool _isProcessing = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fetchQuote();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
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
        _fadeController.forward();
      }
    } catch (e) {
      if (mounted) {
        context.handleError(e, customMessage: 'Erreur de chargement du devis');
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _acceptQuote() async {
    final confirmed = await _showGlassDialog(
      title: 'Accepter le devis?',
      content: 'En acceptant ce devis, vous confirmez votre accord avec les termes et conditions proposés.',
      icon: Icons.check_circle,
      iconColor: PlombiProColors.success,
      confirmText: 'Accepter',
      confirmColor: PlombiProColors.success,
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
          status: 'accepted',
          totalHt: _quote!.totalHt,
          totalTva: _quote!.totalTva,
          totalTtc: _quote!.totalTtc,
          notes: _quote!.notes,
          items: _quote!.items,
        );

        await SupabaseService.updateQuote(widget.quoteId, updatedQuote);

        if (mounted) {
          context.showSuccess('Devis accepté avec succès!');
          await _fetchQuote();
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
    final commentController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => _buildRejectDialog(commentController),
    );

    if (result == true) {
      setState(() => _isProcessing = true);

      try {
        final comment = commentController.text.trim();
        final notesWithComment = _quote!.notes != null && _quote!.notes!.isNotEmpty
            ? '${_quote!.notes}\n\n--- Client Rejection Reason ---\n$comment'
            : '--- Client Rejection Reason ---\n$comment';

        final updatedQuote = Quote(
          id: _quote!.id,
          userId: _quote!.userId,
          quoteNumber: _quote!.quoteNumber,
          clientId: _quote!.clientId,
          date: _quote!.date,
          expiryDate: _quote!.expiryDate,
          status: 'rejected',
          totalHt: _quote!.totalHt,
          totalTva: _quote!.totalTva,
          totalTtc: _quote!.totalTtc,
          notes: notesWithComment,
          items: _quote!.items,
        );

        await SupabaseService.updateQuote(widget.quoteId, updatedQuote);

        if (mounted) {
          context.showSuccess('Votre réponse a été enregistrée');
          await _fetchQuote();
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
    commentController.dispose();
  }

  Future<bool?> _showGlassDialog({
    required String title,
    required String content,
    required IconData icon,
    required Color iconColor,
    required String confirmText,
    required Color confirmColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AlertDialog(
            backgroundColor: PlombiProColors.backgroundDark.withOpacity(0.95),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Row(
              children: [
                Icon(icon, color: iconColor, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(title, style: const TextStyle(color: Colors.white)),
                ),
              ],
            ),
            content: Text(content, style: TextStyle(color: Colors.white.withOpacity(0.9))),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Annuler', style: TextStyle(color: PlombiProColors.gray300)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: confirmColor,
                  foregroundColor: Colors.white,
                ),
                child: Text(confirmText),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRejectDialog(TextEditingController controller) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AlertDialog(
          backgroundColor: PlombiProColors.backgroundDark.withOpacity(0.95),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              Icon(Icons.cancel, color: PlombiProColors.error, size: 28),
              const SizedBox(width: 12),
              const Text('Refuser le devis?', style: TextStyle(color: Colors.white)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Veuillez indiquer la raison du refus (optionnel):',
                style: TextStyle(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: TextField(
                  controller: controller,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Votre commentaire...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Annuler', style: TextStyle(color: PlombiProColors.gray300)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: PlombiProColors.error,
                foregroundColor: Colors.white,
              ),
              child: const Text('Refuser'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          Container(
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
          ),

          // Content
          SafeArea(
            child: _isLoading
                ? _buildLoadingState()
                : _quote == null
                    ? _buildErrorState()
                    : _buildQuoteContent(),
          ),
        ],
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

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: GlassContainer(
          padding: const EdgeInsets.all(32),
          borderRadius: BorderRadius.circular(24),
          opacity: 0.15,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 80, color: Colors.white.withOpacity(0.7)),
              const SizedBox(height: 16),
              const Text('Devis introuvable', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                'Le devis demandé n\'existe pas ou a été supprimé',
                style: TextStyle(color: Colors.white.withOpacity(0.7)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              AnimatedGlassContainer(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                borderRadius: BorderRadius.circular(12),
                opacity: 0.25,
                color: PlombiProColors.primaryBlue,
                onTap: () => context.go('/'),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.home, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Retour à l\'accueil', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuoteContent() {
    final canRespond = _quote!.status != 'accepted' && _quote!.status != 'rejected';

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          _buildGlassAppBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildStatusBanner(),
                  const SizedBox(height: 16),
                  _buildQuoteHeader(),
                  const SizedBox(height: 16),
                  _buildLineItems(),
                  const SizedBox(height: 16),
                  _buildTotals(),
                  if (_quote!.notes != null && _quote!.notes!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildNotes(),
                  ],
                  if (canRespond) ...[
                    const SizedBox(height: 24),
                    _buildActionButtons(),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
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
          const Expanded(
            child: Text(
              'Détails du devis',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBanner() {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (_quote!.status) {
      case 'accepted':
        statusColor = PlombiProColors.success;
        statusText = 'Devis accepté';
        statusIcon = Icons.check_circle;
        break;
      case 'rejected':
        statusColor = PlombiProColors.error;
        statusText = 'Devis refusé';
        statusIcon = Icons.cancel;
        break;
      case 'sent':
        statusColor = PlombiProColors.info;
        statusText = 'En attente de réponse';
        statusIcon = Icons.schedule;
        break;
      default:
        statusColor = PlombiProColors.warning;
        statusText = 'Brouillon';
        statusIcon = Icons.edit;
    }

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(16),
      opacity: 0.2,
      color: statusColor,
      child: Row(
        children: [
          Icon(statusIcon, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              statusText,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuoteHeader() {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(20),
      opacity: 0.15,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: PlombiProColors.primaryBlue.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.description, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Devis', style: TextStyle(color: Colors.white70, fontSize: 14)),
                    Text(_quote!.quoteNumber, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.calendar_today, 'Date', InvoiceCalculator.formatDate(_quote!.date)),
          if (_quote!.expiryDate != null)
            _buildInfoRow(Icons.event_busy, 'Expire le', InvoiceCalculator.formatDate(_quote!.expiryDate!)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.white70),
          const SizedBox(width: 8),
          Text('$label: ', style: TextStyle(color: Colors.white70, fontSize: 14)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildLineItems() {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(20),
      opacity: 0.15,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Articles', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ..._quote!.items.asMap().entries.map((entry) {
            final item = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.description,
                            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text(
                          InvoiceCalculator.formatCurrency(item.lineTotal),
                          style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'Qté: ${item.quantity}',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Prix unitaire: ${InvoiceCalculator.formatCurrency(item.unitPrice)}',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTotals() {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(20),
      opacity: 0.2,
      color: PlombiProColors.primaryBlue,
      child: Column(
        children: [
          _buildTotalRow('Sous-total HT', InvoiceCalculator.formatCurrency(_quote!.totalHt), false),
          const SizedBox(height: 8),
          _buildTotalRow('TVA (20%)', InvoiceCalculator.formatCurrency(_quote!.totalTva), false),
          const Divider(color: Colors.white30, height: 24),
          _buildTotalRow('Total TTC', InvoiceCalculator.formatCurrency(_quote!.totalTtc), true),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, String value, bool isTotal) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: isTotal ? 18 : 15,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: isTotal ? 20 : 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildNotes() {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(20),
      opacity: 0.15,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notes, color: Colors.white70, size: 20),
              const SizedBox(width: 8),
              const Text('Notes', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Text(_quote!.notes!, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    if (_isProcessing) {
      return Center(
        child: GlassContainer(
          width: 60,
          height: 60,
          padding: const EdgeInsets.all(16),
          borderRadius: BorderRadius.circular(15),
          opacity: 0.2,
          child: const CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: AnimatedGlassContainer(
            height: 56,
            borderRadius: BorderRadius.circular(16),
            opacity: 0.25,
            color: PlombiProColors.error,
            onTap: _rejectQuote,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.close, color: Colors.white, size: 24),
                SizedBox(width: 12),
                Text('Refuser', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: AnimatedGlassContainer(
            height: 56,
            borderRadius: BorderRadius.circular(16),
            opacity: 0.25,
            color: PlombiProColors.success,
            onTap: _acceptQuote,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check, color: Colors.white, size: 24),
                SizedBox(width: 12),
                Text('Accepter', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
