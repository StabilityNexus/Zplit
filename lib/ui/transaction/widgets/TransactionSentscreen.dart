import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

class TransactionSentScreen extends StatelessWidget {
  final String friendName;
  final double totalAmount;
  final double splitAmount;
  final String splitType;
  final String description;
  final String? tag;
  final String deepLink;

  const TransactionSentScreen({
    super.key,
    required this.friendName,
    required this.totalAmount,
    required this.splitAmount,
    required this.splitType,
    required this.description,
    this.tag,
    required this.deepLink,
  });

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
          'Transaction',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),

            // ── Success icon ──
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.primary.withOpacity(0.1),
              ),
              child: Icon(
                Icons.check_circle_outline_rounded,
                color: colors.primary,
                size: 44,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Expense Sent!',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$friendName needs to accept this request',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.55),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // ── Summary card ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.dividerColor.withOpacity(0.7)),
              ),
              child: Column(
                children: [
                  _summaryRow(theme, 'To', friendName),
                  const SizedBox(height: 12),
                  _summaryRow(
                    theme,
                    'Total Bill',
                    '₹${totalAmount.toStringAsFixed(2)}',
                  ),
                  const SizedBox(height: 12),
                  _summaryRow(theme, 'Split', splitType),
                  const SizedBox(height: 12),
                  _summaryRow(
                    theme,
                    '$friendName owes',
                    '₹${splitAmount.toStringAsFixed(2)}',
                    highlight: true,
                    colors: colors,
                  ),
                  const SizedBox(height: 12),
                  _summaryRow(theme, 'For', description),
                  if (tag != null) ...[
                    const SizedBox(height: 12),
                    _summaryRow(theme, 'Category', tag!),
                  ],
                  const SizedBox(height: 16),
                  Divider(color: theme.dividerColor.withOpacity(0.5)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.pending_outlined,
                        size: 16,
                        color: colors.primary.withOpacity(0.7),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Waiting for $friendName to accept',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.primary.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── QR Code — Week 6 ──
            Text(
              'Scan to receive',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
              ),
              child: QrImageView(
                data: deepLink,
                version: QrVersions.auto,
                size: 200,
                backgroundColor: Colors.white,
                eyeStyle: QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: colors.primary,
                ),
                dataModuleStyle: QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Let $friendName scan this QR with Zplit',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 28),

            // ── Share button ──
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () =>
                    Share.share(deepLink, subject: 'Transaction from Zplit'),
                icon: const Icon(Icons.ios_share_rounded, size: 20),
                label: Text('Send Link to $friendName'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/home',
                  (route) => false,
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  side: BorderSide(color: theme.dividerColor),
                ),
                child: const Text('Back to Home'),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(
    ThemeData theme,
    String label,
    String value, {
    bool highlight = false,
    ColorScheme? colors,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: highlight ? colors?.primary : null,
          ),
        ),
      ],
    );
  }
}
