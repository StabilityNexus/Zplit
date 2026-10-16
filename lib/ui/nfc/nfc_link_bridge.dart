import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zplit/ui/nfc/view_model/nfc_bloc.dart';
import 'package:zplit/ui/nfc/view_model/nfc_event.dart';
import 'package:zplit/ui/nfc/view_model/nfc_state.dart';
import 'package:zplit/ui/deep_link/view_model/deep_link_bloc.dart';

/// Mirrors BluetoothLinkBridge. The only place NFC and Bluetooth logic
/// diverge — everything downstream (accept/reject sheet, ack handling,
/// balance refresh) is identical regardless of transport.
class NfcLinkBridge extends StatelessWidget {
  final Widget child;
  const NfcLinkBridge({required this.child, super.key});

  void _handlePayload(BuildContext context, String rawPayload) {
    final nfcBloc = context.read<NfcBloc>();

    try {
      final decoded = jsonDecode(rawPayload);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Payload is not a JSON object');
      }

      if (decoded.containsKey('outcome')) {
        context.read<DeepLinkBloc>().add(NfcAckReceived(rawPayload));
      } else if (decoded.containsKey('sig')) {
        context.read<DeepLinkBloc>().add(NfcTransactionReceived(rawPayload));
      } else {
        context.read<DeepLinkBloc>().add(NfcInviteReceived(rawPayload));
      }
    } catch (e) {
      debugPrint('[NfcLinkBridge] unreadable payload: $rawPayload ($e)');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Received an unreadable payload over NFC'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      // NfcBloc has no lastReceivedFromEndpointId (no persistent
      // connection like Bluetooth) — NfcReset() clears both the
      // consumed payload and any stale error.
      nfcBloc.add(NfcReset());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NfcBloc, NfcState>(
      listenWhen: (prev, curr) =>
          curr.lastReceivedPayload != null &&
          curr.lastReceivedPayload != prev.lastReceivedPayload,
      listener: (context, state) {
        if (state.lastReceivedPayload != null) {
          _handlePayload(context, state.lastReceivedPayload!);
        }
      },
      child: child,
    );
  }
}
