import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:zplit/ui/bluetooth/view_model/bluetooth_bloc.dart';
import 'package:zplit/ui/bluetooth/view_model/bluetooth_event.dart';
import 'package:zplit/ui/nfc/view_model/nfc_bloc.dart';
import 'package:zplit/ui/nfc/view_model/nfc_event.dart';
import 'package:zplit/ui/nfc/view_model/nfc_state.dart';

class TransactionSentScreen extends StatefulWidget {
  final String friendName;
  final double totalAmount;
  final double splitAmount;
  final String splitType;
  final String description;
  final String? tag;
  final String deepLink;

  final bool sentViaBluetooth;
  final String? bluetoothEndpointId;
  final String? bluetoothJsonPayload;

  // NFC has no persistent "connection" the way Bluetooth does, so
  // there's no sentViaNfc flag — sending only ever happens when the
  // user explicitly taps the button here and holds devices together.
  final String? nfcJsonPayload;

  const TransactionSentScreen({
    super.key,
    required this.friendName,
    required this.totalAmount,
    required this.splitAmount,
    required this.splitType,
    required this.description,
    this.tag,
    required this.deepLink,
    this.sentViaBluetooth = false,
    this.bluetoothEndpointId,
    this.bluetoothJsonPayload,
    this.nfcJsonPayload,
  });

  @override
  State<TransactionSentScreen> createState() => _TransactionSentScreenState();
}

class _TransactionSentScreenState extends State<TransactionSentScreen> {
  bool _resent = false;
  bool _nfcSentOnce = false;

  void _resendViaBluetooth() {
    if (widget.bluetoothEndpointId == null ||
        widget.bluetoothJsonPayload == null) {
      return;
    }
    context.read<BluetoothBloc>().add(
      BluetoothSendPayload(
        widget.bluetoothEndpointId!,
        widget.bluetoothJsonPayload!,
      ),
    );
    setState(() => _resent = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Resent to ${widget.friendName} via Bluetooth'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _sendViaNfc() {
    if (widget.nfcJsonPayload == null) return;
    context.read<NfcBloc>().add(NfcSendPayload(widget.nfcJsonPayload!));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return BlocListener<NfcBloc, NfcState>(
      // NfcSendPayload doesn't have a dedicated "sent" event — success
      // is inferred from isBusy going true -> false with no error.
      listenWhen: (prev, curr) => prev.isBusy && !curr.isBusy,
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.read<NfcBloc>().add(NfcReset());
        } else {
          setState(() => _nfcSentOnce = true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sent to ${widget.friendName} via NFC'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
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
                '${widget.friendName} needs to accept this request',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.55),
                ),
                textAlign: TextAlign.center,
              ),

              // Persistent Bluetooth-sent status card.
              if (widget.sentViaBluetooth) ...[
                const SizedBox(height: 20),
                _buildBluetoothStatusCard(theme, colors),
              ],

              // NFC send card — always offered when a payload is
              // available, regardless of whether Bluetooth already
              // sent it, since NFC requires its own explicit tap.
              if (widget.nfcJsonPayload != null) ...[
                const SizedBox(height: 12),
                _buildNfcSendCard(theme, colors),
              ],

              const SizedBox(height: 32),

              // ── Summary card ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.dividerColor.withOpacity(0.7),
                  ),
                ),
                child: Column(
                  children: [
                    _summaryRow(theme, 'To', widget.friendName),
                    const SizedBox(height: 12),
                    _summaryRow(
                      theme,
                      'Total Bill',
                      '₹${widget.totalAmount.toStringAsFixed(2)}',
                    ),
                    const SizedBox(height: 12),
                    _summaryRow(theme, 'Split', widget.splitType),
                    const SizedBox(height: 12),

                    _summaryRow(
                      theme,

                      widget.splitAmount >= 0
                          ? 'You owe'
                          : '${widget.friendName} owes',
                      '₹${widget.splitAmount.abs().toStringAsFixed(2)}',
                      highlight: true,
                      colors: colors,
                    ),
                    const SizedBox(height: 12),
                    _summaryRow(theme, 'For', widget.description),
                    if (widget.tag != null) ...[
                      const SizedBox(height: 12),
                      _summaryRow(theme, 'Category', widget.tag!),
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
                            'Waiting for ${widget.friendName} to accept',
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

              Text(
                widget.sentViaBluetooth
                    ? 'Or share as backup'
                    : 'Scan to receive',
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
                  border: Border.all(
                    color: theme.dividerColor.withOpacity(0.5),
                  ),
                ),
                child: QrImageView(
                  data: widget.deepLink,
                  version: QrVersions.auto,
                  size: 200,
                  backgroundColor: Colors.white,
                  eyeStyle: QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: colors.primary,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Let ${widget.friendName} scan this with Zplit',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Share.share(
                    widget.deepLink,
                    subject: 'Transaction from Zplit',
                  ),
                  icon: const Icon(Icons.ios_share_rounded, size: 20),
                  label: Text('Send Link to ${widget.friendName}'),
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
      ),
    );
  }

  Widget _buildBluetoothStatusCard(ThemeData theme, ColorScheme colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.primary.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.bluetooth_connected_rounded, color: colors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _resent
                  ? 'Resent to ${widget.friendName} via Bluetooth'
                  : 'Sent to ${widget.friendName} via Bluetooth',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (widget.bluetoothEndpointId != null)
            TextButton(
              onPressed: _resendViaBluetooth,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Resend',
                style: TextStyle(
                  color: colors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNfcSendCard(ThemeData theme, ColorScheme colors) {
    return BlocBuilder<NfcBloc, NfcState>(
      builder: (context, nfcState) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: colors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.primary.withOpacity(0.25)),
          ),
          child: Row(
            children: [
              nfcState.isBusy
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colors.primary,
                      ),
                    )
                  : Icon(Icons.nfc_rounded, color: colors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  nfcState.isBusy
                      ? 'Hold devices together...'
                      : _nfcSentOnce
                      ? 'Sent to ${widget.friendName} via NFC'
                      : 'Send via NFC — hold devices together',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: nfcState.isBusy ? null : _sendViaNfc,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  _nfcSentOnce ? 'Resend' : 'Send',
                  style: TextStyle(
                    color: colors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
