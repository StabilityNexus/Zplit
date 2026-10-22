import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Holds the app's ThemeMode and remembers it between launches.
/// Uses flutter_secure_storage (already in the project) so no new package
/// is needed.
class ThemeController {
  ThemeController._();
  static final ThemeController instance = ThemeController._();

  static const _key = 'theme_mode';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  /// Defaults to system, which is what the app did before this page existed,
  /// until the user picks something else.
  final ValueNotifier<ThemeMode> mode = ValueNotifier(ThemeMode.system);

  /// Call once in main() before runApp().
  Future<void> load() async {
    try {
      final saved = await _storage.read(key: _key);
      mode.value = switch (saved) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };
    } catch (_) {
      // Storage unavailable → keep the default.
    }
  }

  Future<void> setMode(ThemeMode newMode) async {
    mode.value = newMode; // update the UI instantly
    try {
      await _storage.write(key: _key, value: newMode.name);
    } catch (_) {
      // Not persisted this time; the choice still applies for this session.
    }
  }

  static String label(ThemeMode m) => switch (m) {
    ThemeMode.light => 'Light',
    ThemeMode.dark => 'Dark',
    ThemeMode.system => 'System',
  };
}

/// Theme page. Every colour and text style comes from the app's own
/// AppTheme (light / dark) via Theme.of(context) — nothing is hardcoded here,
/// so it automatically matches whichever mode is active.
class ThemeScreen extends StatelessWidget {
  const ThemeScreen({super.key});

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
            Icons.chevron_left,
            size: 28,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Theme',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: ValueListenableBuilder<ThemeMode>(
        valueListenable: ThemeController.instance.mode,
        builder: (context, selected, _) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              Text('Choose how Zplit looks', style: theme.textTheme.bodyMedium),
              const SizedBox(height: 16),
              _option(
                context,
                mode: ThemeMode.light,
                selected: selected,
                icon: Icons.light_mode_outlined,
                title: 'Light',
                subtitle: 'Bright background',
              ),
              const SizedBox(height: 12),
              _option(
                context,
                mode: ThemeMode.dark,
                selected: selected,
                icon: Icons.dark_mode_outlined,
                title: 'Dark',
                subtitle: 'Dark background, easier on the eyes at night',
              ),
              const SizedBox(height: 12),
              _option(
                context,
                mode: ThemeMode.system,
                selected: selected,
                icon: Icons.settings_suggest_outlined,
                title: 'System default',
                subtitle: "Match your phone's light / dark setting",
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _option(
    BuildContext context, {
    required ThemeMode mode,
    required ThemeMode selected,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isSelected = mode == selected;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => ThemeController.instance.setMode(mode),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? colors.primary : theme.dividerColor,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: colors.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? colors.primary : theme.dividerColor,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
