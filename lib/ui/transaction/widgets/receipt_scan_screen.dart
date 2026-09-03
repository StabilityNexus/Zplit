import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zplit/core/services/ocr_service.dart';

/// Result handed back to AddExpenseScreen when the user confirms a
/// scanned receipt.
class ReceiptScanOutcome {
  final String imagePath;
  final double? amount;
  final DateTime? date;
  final String? merchantName;

  const ReceiptScanOutcome({
    required this.imagePath,
    this.amount,
    this.date,
    this.merchantName,
  });
}

enum _ScanStage { capturing, review, confirm }

class ReceiptScanScreen extends StatefulWidget {
  const ReceiptScanScreen({super.key});

  @override
  State<ReceiptScanScreen> createState() => _ReceiptScanScreenState();
}

class _ReceiptScanScreenState extends State<ReceiptScanScreen> {
  final _ocrService = OcrService();
  final _amountController = TextEditingController();

  _ScanStage _stage = _ScanStage.capturing;
  File? _imageFile;
  DateTime? _extractedDate;
  String? _merchantName;
  bool _isScanning = false;
  bool _ocrFoundNothing = false;

  @override
  void initState() {
    super.initState();
    // Kick off capture immediately so the user isn't looking at a
    // blank screen — mirrors the design, which goes straight to the
    // camera/photo review.
    WidgetsBinding.instance.addPostFrameCallback((_) => _capturePhoto());
  }

  Future<void> _capturePhoto() async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.camera,
        maxWidth: 1600,
        imageQuality: 90,
      );
      if (picked == null) {
        // User backed out of the camera — close this flow entirely
        // rather than leaving them stuck on a blank screen.
        if (mounted) Navigator.pop(context);
        return;
      }
      setState(() {
        _imageFile = File(picked.path);
        _stage = _ScanStage.review;
      });
    } catch (e) {
      debugPrint('Receipt capture error: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not open camera: $e')));
        Navigator.pop(context);
      }
    }
  }

  Future<void> _retake() async {
    setState(() {
      _imageFile = null;
      _stage = _ScanStage.capturing;
    });
    await _capturePhoto();
  }

  Future<void> _usePhoto() async {
    if (_imageFile == null) return;
    setState(() => _isScanning = true);

    try {
      final result = await _ocrService.scanReceipt(_imageFile!.path);
      setState(() {
        _ocrFoundNothing = result.isEmpty;
        if (result.amount != null) {
          _amountController.text = result.amount!.toStringAsFixed(2);
        }
        _extractedDate = result.date;
        _merchantName = result.merchantName;
        _stage = _ScanStage.confirm;
        _isScanning = false;
      });
    } catch (e) {
      debugPrint('OCR error: $e');
      setState(() {
        _ocrFoundNothing = true;
        _stage = _ScanStage.confirm;
        _isScanning = false;
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _extractedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _extractedDate = picked);
  }

  void _confirm() {
    if (_imageFile == null) return;
    final amount = double.tryParse(_amountController.text.trim());
    Navigator.pop(
      context,
      ReceiptScanOutcome(
        imagePath: _imageFile!.path,
        amount: amount,
        date: _extractedDate,
        merchantName: _merchantName,
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }

  @override
  void dispose() {
    _amountController.dispose();
    _ocrService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left,
            size: 28,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _stage == _ScanStage.confirm ? 'Add Receipt' : 'Add Receipt',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: switch (_stage) {
        _ScanStage.capturing => const Center(
          child: CircularProgressIndicator(),
        ),
        _ScanStage.review => _buildReviewStage(theme, colors),
        _ScanStage.confirm => _buildConfirmStage(theme, colors),
      },
    );
  }

  Widget _buildReviewStage(ThemeData theme, ColorScheme colors) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colors.primary, width: 2),
                ),
                clipBehavior: Clip.antiAlias,
                child: _imageFile != null
                    ? Image.file(_imageFile!, fit: BoxFit.contain)
                    : const SizedBox.shrink(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _retake,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      side: BorderSide(color: theme.dividerColor),
                    ),
                    child: const Text('Retake'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isScanning ? null : _usePhoto,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: _isScanning
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Use this Photo'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmStage(ThemeData theme, ColorScheme colors) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_ocrFoundNothing) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colors.error.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.error.withOpacity(0.25)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: colors.error, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Couldn't read this receipt clearly — enter the "
                        "details manually below.",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.dividerColor),
              ),
              clipBehavior: Clip.antiAlias,
              child: _imageFile != null
                  ? Image.file(_imageFile!, fit: BoxFit.cover)
                  : const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),
            Text(
              'Amount',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withOpacity(0.55),
                fontSize: 12,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.dividerColor.withOpacity(0.7)),
              ),
              child: TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                style: theme.textTheme.bodyLarge,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  prefixText: '₹ ',
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Date',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withOpacity(0.55),
                fontSize: 12,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.dividerColor.withOpacity(0.7),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _extractedDate != null
                            ? _formatDate(_extractedDate!)
                            : 'Select date',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: _extractedDate != null
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.onSurface.withOpacity(0.4),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.calendar_month_outlined,
                      color: colors.primary,
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _confirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Confirm',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
