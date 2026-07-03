import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:zplit/routing/App_router.dart';
import 'package:zplit/ui/users/view_model/user_bloc.dart';
import 'package:zplit/ui/users/view_model/user_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _address;

  @override
  void initState() {
    super.initState();
    _loadAddress();
  }

  Future<void> _loadAddress() async {
    const storage = FlutterSecureStorage();
    final address = await storage.read(key: 'evm_address');
    setState(() => _address = address);
  }

  void _navigateToInvite(BuildContext context) {
    final userState = context.read<UserBloc>().state;
    if (userState is UserLoaded && userState.users.isNotEmpty) {
      final me = userState.users.first;
      Navigator.pushNamed(
        context,
        AppRoutes.inviteFriends,
        arguments: {
          'id': me.publicKey,
          'name': me.displayName,
          'address': _address ?? '',
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final userState = context.watch<UserBloc>().state;
    final displayName = userState is UserLoaded && userState.users.isNotEmpty
        ? userState.users.first.displayName
        : 'My Profile';

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
          'Profile',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.edit_outlined,
              color: theme.colorScheme.onSurface,
              size: 22,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.qr_code_2, color: colors.primary, size: 26),
            onPressed: () => _navigateToInvite(context),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 52,
                    backgroundColor: colors.primary.withOpacity(0.12),
                    child: Icon(Icons.person, size: 52, color: colors.primary),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    displayName,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _address != null
                        ? '${_address!.substring(0, 6)}...${_address!.substring(_address!.length - 4)}'
                        : '',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.45),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'General',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            _buildSettingsCard(theme, [
              _buildTile(
                theme,
                icon: Icons.palette_outlined,
                title: 'Theme',
                trailing: Text(
                  'Light',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
                onTap: () {},
              ),
              _buildDivider(theme),
              _buildTile(
                theme,
                icon: Icons.history_outlined,
                title: 'Payment History',
                onTap: () {},
              ),
              _buildDivider(theme),
              _buildTile(
                theme,
                icon: Icons.group_outlined,
                title: 'Manage Friends and Groups',
                onTap: () {},
              ),
              _buildDivider(theme),
              _buildTile(
                theme,
                icon: Icons.person_add_outlined,
                title: 'Invite Friends',
                onTap: () => _navigateToInvite(context),
              ),
            ]),
            const SizedBox(height: 24),
            _buildSettingsCard(theme, [
              _buildTile(
                theme,
                icon: Icons.feedback_outlined,
                title: 'Feedback',
                onTap: () {},
              ),
              _buildDivider(theme),
              _buildTile(
                theme,
                icon: Icons.mail_outlined,
                title: 'Contact Us',
                onTap: () {},
              ),
            ]),
            const SizedBox(height: 32),
            Center(
              child: TextButton(
                onPressed: () {},
                child: const Text(
                  'Log Out',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard(ThemeData theme, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildTile(
    ThemeData theme, {
    required IconData icon,
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(child: Text(title, style: theme.textTheme.bodyLarge)),
            trailing ??
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
      color: theme.dividerColor.withOpacity(0.5),
    );
  }
}
