import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

class InviteFriendsScreen extends StatefulWidget {
  final String username;

  const InviteFriendsScreen({super.key, required this.username});

  @override
  State<InviteFriendsScreen> createState() => _InviteFriendsScreenState();
}

class _InviteFriendsScreenState extends State<InviteFriendsScreen> {
  bool _bluetoothEnabled = false;
  bool _proximityEnabled = false;
  bool _nfcEnabled = false;
  String _proximityFilter = 'Contacts Only';

  String get _inviteLink => 'zplit.com/invite/${widget.username}';

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInviteLink(theme),
            const SizedBox(height: 24),
            _buildQRCode(theme),
            const SizedBox(height: 24),
            _buildToggleSection(
              theme,
              title: 'Bluetooth Pairing',
              value: _bluetoothEnabled,
              onChanged: (val) => setState(() => _bluetoothEnabled = val),
              child: _bluetoothEnabled
                  ? _buildNearbyDevices(theme, Icons.bluetooth_rounded)
                  : _buildDisabledHint(
                      theme,
                      'Enable Bluetooth to see nearby devices.',
                    ),
            ),
            const SizedBox(height: 24),
            _buildProximitySection(theme),
            const SizedBox(height: 24),
            _buildToggleSection(
              theme,
              title: 'NFC',
              value: _nfcEnabled,
              onChanged: (val) => setState(() => _nfcEnabled = val),
              child: _nfcEnabled
                  ? _buildNfcContent(theme)
                  : _buildDisabledHint(
                      theme,
                      'Enable NFC to share with nearby devices.',
                    ),
            ),
          ],
        ),
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
                  _inviteLink,
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
                data: 'https://$_inviteLink',
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
                  onPressed: () {},
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

  /// Generic toggleable section
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

  /// Proximity Sharing with dropdown filter
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
              ? _buildNearbyDevices(theme, Icons.wifi_tethering_rounded)
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

  Widget _buildNearbyDevices(ThemeData theme, IconData icon) {
    final colors = theme.colorScheme;
    final devices = ["Krishna's Phone", 'Iphone2', "Garima's Iphone"];
    return Column(
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.primary,
          ),
          child: Icon(icon, color: Colors.white, size: 44),
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
        ...devices.map((name) => _buildDeviceTile(name, theme)),
      ],
    );
  }

  Widget _buildNfcContent(ThemeData theme) {
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
          child: const Icon(Icons.nfc_rounded, color: Colors.white, size: 44),
        ),
        const SizedBox(height: 16),
        Text(
          'Hold your device near another\nNFC-enabled phone to connect.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceTile(String name, ThemeData theme) {
    final colors = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: theme.textTheme.bodyLarge),
          GestureDetector(
            onTap: () {},
            child: Text(
              'Connect',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
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
    Clipboard.setData(ClipboardData(text: 'https://$_inviteLink'));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Link copied to clipboard'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
