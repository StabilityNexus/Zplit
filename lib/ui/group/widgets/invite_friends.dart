import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:zplit/core/services/bluetooth_service.dart' show BtEndpoint;
import 'package:zplit/ui/bluetooth/view_model/bluetooth_bloc.dart';
import 'package:zplit/ui/bluetooth/view_model/bluetooth_event.dart';
import 'package:zplit/ui/bluetooth/view_model/bluetooth_state.dart';
import 'package:zplit/ui/users/view_model/user_bloc.dart';
import 'package:zplit/ui/users/view_model/user_state.dart';
import 'package:zplit/ui/nfc/view_model/nfc_bloc.dart';
import 'package:zplit/ui/nfc/view_model/nfc_event.dart';
import 'package:zplit/ui/nfc/view_model/nfc_state.dart';
import 'package:zplit/ui/wifi/view_model/Wifi_direct_bloc.dart';
import 'package:zplit/ui/wifi/view_model/Wifi_direct_event.dart';
import 'package:zplit/ui/wifi/view_model/Wifi_direct_state.dart';

class InviteFriendsScreen extends StatefulWidget {
  final String userId;
  final String name;
  final String address;
  const InviteFriendsScreen({
    super.key,
    required this.userId,
    required this.name,
    required this.address,
  });

  @override
  State<InviteFriendsScreen> createState() => _InviteFriendsScreenState();
}

class _InviteFriendsScreenState extends State<InviteFriendsScreen> {
  bool _proximityEnabled = false;
  String _proximityFilter = 'Contacts Only';

  String? _myProfilePicturePath;

  final Set<String> _autoSentTo = {};

  @override
  void initState() {
    super.initState();
    _loadMyProfilePicture();
  }

  void _loadMyProfilePicture() {
    final userState = context.read<UserBloc>().state;
    if (userState is UserLoaded) {
      final matches = userState.users.where(
        (u) => u.publicKey == widget.userId,
      );
      if (matches.isNotEmpty) {
        setState(() => _myProfilePicturePath = matches.first.profilePicture);
      }
    }
  }

  String get _inviteDeepLink {
    final payload = {
      'id': widget.userId,
      'name': widget.name,
      'addr': widget.address,
      'ts': DateTime.now().millisecondsSinceEpoch ~/ 1000,
    };
    final encoded = base64Url.encode(utf8.encode(jsonEncode(payload)));
    return 'https://zplit.aossie.org/invite?d=$encoded';
  }

  String get _displayLink => 'zplit.aossie.org/invite';

  String get _inviteJsonPayload {
    String? picBase64;
    final path = _myProfilePicturePath;
    if (path != null && File(path).existsSync()) {
      try {
        picBase64 = base64Encode(File(path).readAsBytesSync());
      } catch (e) {
        debugPrint('Failed to read profile picture for invite payload: $e');
        picBase64 = null;
      }
    }

    return jsonEncode({
      'id': widget.userId,
      'name': widget.name,
      'addr': widget.address,
      'pic': picBase64,
      'ts': DateTime.now().millisecondsSinceEpoch ~/ 1000,
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left_rounded,
            color: theme.textTheme.bodyLarge?.color,
            size: 28,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Invite Friends', style: theme.textTheme.headlineSmall),
        centerTitle: true,
      ),

      body: BlocListener<BluetoothBloc, BluetoothState>(
        listenWhen: (prev, curr) =>
            prev.errorMessage != curr.errorMessage ||
            prev.connectionStatus != curr.connectionStatus,
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }

          // the instant any endpoint becomes connected, automatically
          // send our own profile (name + picture) without waiting for the
          // user to tap "Send". Both devices run this same logic, so a
          // single connection syncs profile pictures in both directions.
          state.connectionStatus.forEach((endpointId, status) {
            if (status == BtConnectionStatus.connected &&
                !_autoSentTo.contains(endpointId)) {
              _autoSentTo.add(endpointId);
              context.read<BluetoothBloc>().add(
                BluetoothSendPayload(endpointId, _inviteJsonPayload),
              );
            }
          });
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInviteLink(theme),
              const SizedBox(height: 24),
              _buildQRCode(theme),
              const SizedBox(height: 24),
              _buildBluetoothSection(theme),
              const SizedBox(height: 24),
              _buildProximitySection(theme),
              const SizedBox(height: 24),
              _buildNfcSection(theme),
              const SizedBox(height: 24),
              _buildWifiSection(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBluetoothSection(ThemeData theme) {
    return BlocBuilder<BluetoothBloc, BluetoothState>(
      builder: (context, state) {
        return _buildToggleSection(
          theme,
          title: 'Bluetooth Pairing',
          value: state.enabled,
          onChanged: (val) {
            context.read<BluetoothBloc>().add(
              BluetoothToggled(val, widget.name),
            );
          },
          child: !state.enabled
              ? (state.permissionDenied
                    ? _buildDisabledHint(
                        theme,
                        'Bluetooth & nearby-device permissions are required. '
                        'Enable them in system settings.',
                      )
                    : _buildDisabledHint(
                        theme,
                        'Enable Bluetooth to see nearby devices.',
                      ))
              : _buildRealNearbyDevices(theme, state),
        );
      },
    );
  }

  Widget _buildRealNearbyDevices(ThemeData theme, BluetoothState state) {
    final colors = theme.colorScheme;
    return Column(
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.primary,
          ),
          child: const Icon(
            Icons.bluetooth_rounded,
            color: Colors.white,
            size: 44,
          ),
        ),
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Nearby Devices',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (state.nearbyEndpoints.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.primary.withOpacity(0.6),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Searching for nearby Zplit users...',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          ...state.nearbyEndpoints.map(
            (d) => _buildDeviceTile(d, theme, state.connectionStatus[d.id]),
          ),
      ],
    );
  }

  Widget _buildDeviceTile(
    BtEndpoint device,
    ThemeData theme,
    BtConnectionStatus? status,
  ) {
    final colors = theme.colorScheme;
    final s = status ?? BtConnectionStatus.none;

    Widget trailing;
    switch (s) {
      case BtConnectionStatus.connected:
        trailing = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: 18, color: colors.primary),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () {
                context.read<BluetoothBloc>().add(
                  BluetoothSendPayload(device.id, _inviteJsonPayload),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Invite sent to ${device.name}'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Text(
                'Send',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
        break;
      case BtConnectionStatus.connecting:
      case BtConnectionStatus.pending:
        trailing = SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: colors.primary,
          ),
        );
        break;
      case BtConnectionStatus.disconnected:
        trailing = GestureDetector(
          onTap: () => context.read<BluetoothBloc>().add(
            BluetoothConnectRequested(device.id, widget.name),
          ),
          child: Text(
            'Retry',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
        break;
      case BtConnectionStatus.none:
        trailing = GestureDetector(
          onTap: () => context.read<BluetoothBloc>().add(
            BluetoothConnectRequested(device.id, widget.name),
          ),
          child: Text(
            'Connect',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(device.name, style: theme.textTheme.bodyLarge),
          trailing,
        ],
      ),
    );
  }

  Widget _buildInviteLink(ThemeData theme) {
    final colors = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Invite via Link', style: theme.textTheme.headlineMedium),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.dividerColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(
                  theme.brightness == Brightness.dark ? 0.08 : 0.03,
                ),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.link_rounded, color: colors.primary, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _displayLink,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.primary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: _copyLink,
                child: Icon(
                  Icons.copy_rounded,
                  color: theme.textTheme.bodySmall?.color,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQRCode(ThemeData theme) {
    final colors = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Share QR Code', style: theme.textTheme.headlineMedium),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: theme.dividerColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(
                  theme.brightness == Brightness.dark ? 0.08 : 0.03,
                ),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              QrImageView(
                data: _inviteDeepLink,
                version: QrVersions.auto,
                size: 180,
                eyeStyle: QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: colors.primary,
                ),
                dataModuleStyle: QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: theme.brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 140,
                child: ElevatedButton.icon(
                  onPressed: _shareLink,
                  icon: const Icon(Icons.ios_share_rounded, size: 18),
                  label: const Text('Share'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToggleSection(
    ThemeData theme, {
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Widget child,
  }) {
    final colors = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: theme.textTheme.headlineMedium),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: colors.primary,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: theme.dividerColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(
                  theme.brightness == Brightness.dark ? 0.08 : 0.03,
                ),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _buildProximitySection(ThemeData theme) {
    final colors = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Proximity Sharing', style: theme.textTheme.headlineMedium),
            Row(
              children: [
                if (_proximityEnabled)
                  GestureDetector(
                    onTap: () => _showProximityFilterMenu(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.dividerColor),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Text(
                            _proximityFilter,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.keyboard_arrow_down,
                            size: 16,
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                Switch(
                  value: _proximityEnabled,
                  onChanged: (val) => setState(() => _proximityEnabled = val),
                  activeColor: colors.primary,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: theme.dividerColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(
                  theme.brightness == Brightness.dark ? 0.08 : 0.03,
                ),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: _proximityEnabled
              ? _buildDisabledHint(
                  theme,
                  'Proximity Sharing will reuse the Bluetooth transport — '
                  'wire this to BluetoothBloc the same way once you decide '
                  'whether it should be a separate discovery scope.',
                )
              : _buildDisabledHint(
                  theme,
                  'Enable Proximity Sharing to find nearby contacts.',
                ),
        ),
      ],
    );
  }

  void _showProximityFilterMenu(BuildContext context) {
    final theme = Theme.of(context);
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(200, 200, 20, 0),
      items: ['Contacts Only', 'Everyone Nearby'].map((option) {
        return PopupMenuItem<String>(
          value: option,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(option),
              if (_proximityFilter == option)
                Icon(Icons.check, size: 18, color: theme.colorScheme.primary),
            ],
          ),
        );
      }).toList(),
    ).then((value) {
      if (value != null) setState(() => _proximityFilter = value);
    });
  }

  // ── NFC section — backed by NfcBloc ──

  Widget _buildNfcSection(ThemeData theme) {
    return BlocConsumer<NfcBloc, NfcState>(
      listenWhen: (prev, curr) =>
          prev.errorMessage != curr.errorMessage && curr.errorMessage != null,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.errorMessage!),
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.read<NfcBloc>().add(NfcReset());
      },
      builder: (context, nfcState) {
        return _buildToggleSection(
          theme,
          title: 'NFC',
          value: nfcState.enabled,
          onChanged: (val) => context.read<NfcBloc>().add(NfcToggled(val)),
          child: nfcState.enabled
              ? _buildNfcContent(theme, nfcState)
              : _buildDisabledHint(
                  theme,
                  'Enable NFC to share with nearby devices.',
                ),
        );
      },
    );
  }

  Widget _buildNfcContent(ThemeData theme, NfcState nfcState) {
    final colors = theme.colorScheme;
    return Column(
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.primary,
          ),
          child: nfcState.isBusy
              ? const Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                )
              : const Icon(Icons.nfc_rounded, color: Colors.white, size: 44),
        ),
        const SizedBox(height: 16),
        Text(
          nfcState.isBusy
              ? 'Hold devices together...'
              : 'Hold your device near another\nNFC-enabled phone to connect.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: 200,
          child: ElevatedButton.icon(
            onPressed: nfcState.isBusy
                ? null
                : () {
                    context.read<NfcBloc>().add(
                      NfcSendPayload(_inviteJsonPayload),
                    );
                  },
            icon: const Icon(Icons.nfc_rounded, size: 18),
            label: const Text('Tap to Share Invite'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }

  // ── WiFi Direct section — host/client roles handled invisibly under
  // the hood by WifiDirectTransportService's scan-then-host heuristic;
  // same one-toggle UX as Bluetooth/NFC, per project decision. ──

  Widget _buildWifiSection(ThemeData theme) {
    return BlocConsumer<WifiBloc, WifiState>(
      listenWhen: (prev, curr) =>
          prev.errorMessage != curr.errorMessage && curr.errorMessage != null,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.errorMessage!),
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.read<WifiBloc>().add(WifiReset());
      },
      builder: (context, wifiState) {
        return _buildToggleSection(
          theme,
          title: 'WiFi Direct',
          value: wifiState.enabled,
          onChanged: (val) =>
              context.read<WifiBloc>().add(WifiToggled(val, widget.name)),
          child: !wifiState.enabled
              ? (wifiState!.permissionDenied
                    ? _buildDisabledHint(
                        theme,
                        'WiFi Direct & nearby-device permissions are '
                        'required. Enable them in system settings.',
                      )
                    : _buildDisabledHint(
                        theme,
                        'Enable WiFi Direct for faster nearby sharing.',
                      ))
              : _buildWifiContent(theme, wifiState),
        );
      },
    );
  }

  Widget _buildWifiContent(ThemeData theme, WifiState wifiState) {
    final colors = theme.colorScheme;
    return Column(
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.primary,
          ),
          child: wifiState.isSearching
              ? const Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                )
              : Icon(
                  wifiState.isConnected
                      ? Icons.wifi_rounded
                      : Icons.wifi_find_rounded,
                  color: Colors.white,
                  size: 44,
                ),
        ),
        const SizedBox(height: 16),
        Text(
          wifiState.isSearching
              ? 'Looking for nearby Zplit users...'
              : wifiState.isConnected
              ? 'Connected to ${wifiState.peerName ?? "a nearby device"}'
              : 'Waiting to connect...',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        if (wifiState.isConnected) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: 200,
            child: ElevatedButton.icon(
              onPressed: () {
                context.read<WifiBloc>().add(
                  WifiSendPayload(_inviteJsonPayload),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Invite sent to ${wifiState.peerName ?? "device"} via WiFi',
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.send_rounded, size: 18),
              label: const Text('Send Invite'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDisabledHint(ThemeData theme, String message) {
    return Center(
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.5),
        ),
      ),
    );
  }

  void _copyLink() {
    Clipboard.setData(ClipboardData(text: _inviteDeepLink));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Invite link copied!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _shareLink() {
    Share.share(_inviteDeepLink, subject: 'Join me on Zplit!');
  }
}
