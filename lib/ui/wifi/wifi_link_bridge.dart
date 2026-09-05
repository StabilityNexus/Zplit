import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:zplit/ui/deep_link/view_model/deep_link_bloc.dart';
import 'package:zplit/ui/wifi/view_model/Wifi_direct_bloc.dart';
import 'package:zplit/ui/wifi/view_model/Wifi_direct_event.dart';
import 'package:zplit/ui/wifi/view_model/Wifi_direct_state.dart';

/// Same triage pattern as BluetoothLinkBridge / NfcLinkBridge.
class WifiLinkBridge extends StatelessWidget {
  final Widget child;
  const WifiLinkBridge({required this.child, super.key});

  void _handlePayload(BuildContext context, String rawPayload) {
    final wifiBloc = context.read<WifiBloc>();

    try {
      final decoded = jsonDecode(rawPayload);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Payload is not a JSON object');
      }

      if (decoded.containsKey('outcome')) {
        context.read<DeepLinkBloc>().add(WifiAckReceived(rawPayload));
      } else if (decoded.containsKey('sig')) {
        context.read<DeepLinkBloc>().add(WifiTransactionReceived(rawPayload));
      } else {
        context.read<DeepLinkBloc>().add(WifiInviteReceived(rawPayload));
      }
    } catch (e) {
      debugPrint('[WifiLinkBridge] unreadable payload: $rawPayload ($e)');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Received an unreadable payload over WiFi Direct'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      wifiBloc.add(WifiReset());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WifiBloc, WifiState>(
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
