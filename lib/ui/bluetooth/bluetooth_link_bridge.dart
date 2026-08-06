import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zplit/ui/bluetooth/view_model/bluetooth_bloc.dart';
import 'package:zplit/ui/bluetooth/view_model/bluetooth_state.dart';
import 'package:zplit/ui/deep_link/view_model/deep_link_bloc.dart';

class BluetoothLinkBridge extends StatelessWidget {
  final Widget child;
  const BluetoothLinkBridge({required this.child, super.key});

  void _handlePayload(BuildContext context, String rawPayload) {
    final bluetoothBloc = context.read<BluetoothBloc>();

    try {
      final decoded = jsonDecode(rawPayload);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Payload is not a JSON object');
      }

      if (decoded.containsKey('outcome')) {
        context.read<DeepLinkBloc>().add(BluetoothAckReceived(rawPayload));
      } else if (decoded.containsKey('sig')) {
        context.read<DeepLinkBloc>().add(
          BluetoothTransactionReceived(rawPayload),
        );
      } else {
        context.read<DeepLinkBloc>().add(BluetoothInviteReceived(rawPayload));
      }
    } catch (e) {
      debugPrint('[BluetoothLinkBridge] unreadable payload: $rawPayload ($e)');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Received an unreadable payload over Bluetooth'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      bluetoothBloc.clearReceivedPayload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BluetoothBloc, BluetoothState>(
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
