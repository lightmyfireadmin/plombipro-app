import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import '../../config/plombipro_colors.dart';
import '../../config/plombipro_spacing.dart';
import '../../config/plombipro_text_styles.dart';
import '../../widgets/modern/gradient_button.dart';

/// Modern signature pad widget for capturing e-signatures
/// Supports drawing, clearing, and exporting signatures
class SignaturePadWidget extends StatefulWidget {
  final Function(String signatureData) onSignatureConfirmed;
  final VoidCallback? onCancel;
  final String? initialSignature; // Base64 encoded
  final Color penColor;
  final double penStrokeWidth;
  final bool showInstructions;

  const SignaturePadWidget({
    super.key,
    required this.onSignatureConfirmed,
    this.onCancel,
    this.initialSignature,
    this.penColor = PlombiProColors.primaryBlue,
    this.penStrokeWidth = 2.0,
    this.showInstructions = true,
  });

  @override
  State<SignaturePadWidget> createState() => _SignaturePadWidgetState();
}

class _SignaturePadWidgetState extends State<SignaturePadWidget> {
  late SignatureController _controller;
  bool _hasSignature = false;

  @override
  void initState() {
    super.initState();
    _controller = SignatureController(
      penStrokeWidth: widget.penStrokeWidth,
      penColor: widget.penColor,
      exportBackgroundColor: Colors.transparent,
    );

    _controller.addListener(() {
      setState(() {
        _hasSignature = _controller.isNotEmpty;
      });
    });

    // Load initial signature if provided
    if (widget.initialSignature != null) {
      _loadInitialSignature();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadInitialSignature() async {
    try {
      final bytes = base64Decode(widget.initialSignature!);
      await _controller.fromRawBytes(bytes);
      setState(() {
        _hasSignature = true;
      });
    } catch (e) {
      debugPrint('Error loading initial signature: $e');
    }
  }

  Future<void> _confirmSignature() async {
    if (_controller.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez signer avant de confirmer'),
          backgroundColor: PlombiProColors.error,
        ),
      );
      return;
    }

    try {
      // Export signature as PNG bytes
      final Uint8List? bytes = await _controller.toPngBytes();
      if (bytes == null) {
        throw Exception('Failed to export signature');
      }

      // Convert to base64
      final String base64Signature = base64Encode(bytes);

      // Call callback
      widget.onSignatureConfirmed(base64Signature);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la capture de la signature: $e'),
          backgroundColor: PlombiProColors.error,
        ),
      );
    }
  }

  void _clearSignature() {
    _controller.clear();
    setState(() {
      _hasSignature = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: PlombiProSpacing.elevationMD,
      shape: RoundedRectangleBorder(
        borderRadius: PlombiProSpacing.borderRadiusLG,
      ),
      child: Padding(
        padding: PlombiProSpacing.cardPaddingLarge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(PlombiProSpacing.sm),
                  decoration: BoxDecoration(
                    gradient: PlombiProColors.primaryGradient,
                    borderRadius: PlombiProSpacing.borderRadiusMD,
                  ),
                  child: const Icon(
                    Icons.edit,
                    color: PlombiProColors.white,
                    size: PlombiProSpacing.iconMD,
                  ),
                ),
                PlombiProSpacing.horizontalMD,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Signature électronique',
                        style: PlombiProTextStyles.titleLarge.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (widget.showInstructions)
                        Text(
                          'Signez dans le cadre ci-dessous',
                          style: PlombiProTextStyles.bodySmall.copyWith(
                            color: PlombiProColors.textSecondaryLight,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            PlombiProSpacing.verticalLG,

            // Signature pad
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(
                  color: PlombiProColors.gray300,
                  width: 2,
                ),
                borderRadius: PlombiProSpacing.borderRadiusMD,
                color: PlombiProColors.white,
              ),
              child: ClipRRect(
                borderRadius: PlombiProSpacing.borderRadiusMD,
                child: Stack(
                  children: [
                    // Watermark when empty
                    if (!_hasSignature)
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.draw,
                              size: 48,
                              color: PlombiProColors.gray300,
                            ),
                            PlombiProSpacing.verticalSM,
                            Text(
                              'Signez ici',
                              style: PlombiProTextStyles.bodyLarge.copyWith(
                                color: PlombiProColors.gray400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    // Signature canvas
                    Signature(
                      controller: _controller,
                      backgroundColor: Colors.transparent,
                    ),
                  ],
                ),
              ),
            ),

            PlombiProSpacing.verticalMD,

            // Action buttons
            Row(
              children: [
                // Clear button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _hasSignature ? _clearSignature : null,
                    icon: const Icon(Icons.clear),
                    label: const Text('Effacer'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: PlombiProSpacing.md,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: PlombiProSpacing.borderRadiusMD,
                      ),
                    ),
                  ),
                ),
                PlombiProSpacing.horizontalMD,
                // Cancel button (if provided)
                if (widget.onCancel != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: widget.onCancel,
                      icon: const Icon(Icons.close),
                      label: const Text('Annuler'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: PlombiProSpacing.md,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: PlombiProSpacing.borderRadiusMD,
                        ),
                      ),
                    ),
                  ),
                PlombiProSpacing.horizontalMD,
                // Confirm button
                Expanded(
                  flex: 2,
                  child: GradientButton.primary(
                    text: 'Confirmer',
                    icon: Icons.check,
                    onPressed: _hasSignature ? _confirmSignature : null,
                    isFullWidth: true,
                  ),
                ),
              ],
            ),

            // Legal notice
            if (widget.showInstructions) ...[
              PlombiProSpacing.verticalMD,
              Container(
                padding: PlombiProSpacing.cardPadding,
                decoration: BoxDecoration(
                  color: PlombiProColors.info.withOpacity(0.1),
                  borderRadius: PlombiProSpacing.borderRadiusSM,
                  border: Border.all(
                    color: PlombiProColors.info.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: PlombiProSpacing.iconSM,
                      color: PlombiProColors.info,
                    ),
                    PlombiProSpacing.horizontalSM,
                    Expanded(
                      child: Text(
                        'Votre signature électronique a la même valeur légale qu\'une signature manuscrite selon le règlement eIDAS (UE) n°910/2014.',
                        style: PlombiProTextStyles.bodySmall.copyWith(
                          color: PlombiProColors.info,
                        ),
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
}

/// Dialog version of the signature pad for modal use
class SignatureDialog extends StatelessWidget {
  final Function(String signatureData) onSignatureConfirmed;
  final String? initialSignature;

  const SignatureDialog({
    super.key,
    required this.onSignatureConfirmed,
    this.initialSignature,
  });

  static Future<String?> show(
    BuildContext context, {
    String? initialSignature,
  }) async {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: PlombiProSpacing.borderRadiusLG,
        ),
        child: SingleChildScrollView(
          child: SignatureDialog(
            initialSignature: initialSignature,
            onSignatureConfirmed: (signature) {
              Navigator.of(context).pop(signature);
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SignaturePadWidget(
      onSignatureConfirmed: onSignatureConfirmed,
      onCancel: () => Navigator.of(context).pop(),
      initialSignature: initialSignature,
      showInstructions: true,
    );
  }
}

/// Widget to display a saved signature
class SignatureDisplay extends StatelessWidget {
  final String signatureData; // Base64 encoded
  final double height;
  final bool showBorder;
  final String? caption;

  const SignatureDisplay({
    super.key,
    required this.signatureData,
    this.height = 100,
    this.showBorder = true,
    this.caption,
  });

  @override
  Widget build(BuildContext context) {
    final bytes = base64Decode(signatureData);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: height,
          decoration: BoxDecoration(
            border: showBorder
                ? Border.all(color: PlombiProColors.gray300)
                : null,
            borderRadius: PlombiProSpacing.borderRadiusMD,
            color: PlombiProColors.white,
          ),
          child: ClipRRect(
            borderRadius: PlombiProSpacing.borderRadiusMD,
            child: Image.memory(
              bytes,
              fit: BoxFit.contain,
            ),
          ),
        ),
        if (caption != null) ...[
          PlombiProSpacing.verticalXS,
          Text(
            caption!,
            style: PlombiProTextStyles.bodySmall.copyWith(
              color: PlombiProColors.textSecondaryLight,
            ),
          ),
        ],
      ],
    );
  }
}
