import 'package:flutter/material.dart';

/// "I owe" / "Owes me" segmented toggle shown at the top of the Analytics
/// screen.
class OweToggle extends StatelessWidget {
  final bool showOwedToMe;
  final ValueChanged<bool> onChanged;

  const OweToggle({
    super.key,
    required this.showOwedToMe,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _segment(
            theme,
            label: 'I owe',
            selected: !showOwedToMe,
            onTap: () => onChanged(false),
          ),
          _segment(
            theme,
            label: 'Owes me',
            selected: showOwedToMe,
            onTap: () => onChanged(true),
          ),
        ],
      ),
    );
  }

  Widget _segment(
    ThemeData theme, {
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? theme.cardColor : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected
                ? theme.colorScheme.onSurface
                : theme.textTheme.bodySmall?.color,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
