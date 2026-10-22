import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:zplit/domain/models/group/group_model.dart';
import 'package:zplit/domain/models/user/user_model.dart';
import 'package:zplit/ui/group/view_models/group_bloc.dart';
import 'package:zplit/ui/group/view_models/group_event.dart';
import 'package:zplit/ui/users/view_model/user_bloc.dart';
import 'package:zplit/ui/users/view_model/user_state.dart';

/// Create a group (when [group] is null) or edit/delete an existing one.
class GroupFormScreen extends StatefulWidget {
  final GroupModel? group;
  const GroupFormScreen({super.key, this.group});

  @override
  State<GroupFormScreen> createState() => _GroupFormScreenState();
}

class _GroupFormScreenState extends State<GroupFormScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();

  /// Public keys of the selected FRIENDS (never includes me — I'm added
  /// automatically on save).
  final Set<String> _selected = {};
  String? _me;

  bool get _isEditing => widget.group != null;

  @override
  void initState() {
    super.initState();
    final g = widget.group;
    if (g != null) {
      _nameController.text = g.name;
      _descController.text = g.description ?? '';
      _selected.addAll(g.users);
    }
    const FlutterSecureStorage().read(key: 'evm_address').then((addr) {
      if (!mounted) return;
      setState(() {
        _me = addr;
        if (addr != null) _selected.remove(addr);
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showSnack('Enter a group name');
      return;
    }
    if (_selected.isEmpty) {
      _showSnack('Pick at least one friend');
      return;
    }
    final desc = _descController.text.trim();

    context.read<GroupBloc>().add(
      UpsertGroup(
        id: widget.group?.id,
        name: name,
        description: desc.isEmpty ? null : desc,
        users: [if (_me != null) _me!, ..._selected],
      ),
    );
    Navigator.pop(context);
  }

  Future<void> _confirmDelete() async {
    final group = widget.group;
    if (group == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete group?'),
        content: Text(
          '"${group.name}" will be removed. Your friends and expenses are '
          'not affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Delete',
              style: TextStyle(color: Theme.of(ctx).colorScheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<GroupBloc>().add(DeleteGroup(group.id));
      Navigator.pop(context);
    }
  }

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
          icon: Icon(Icons.chevron_left, size: 28, color: colors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEditing ? 'Edit Group' : 'New Group',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_isEditing)
            IconButton(
              icon: Icon(Icons.delete_outline, color: colors.error),
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label(theme, 'Group Name'),
            const SizedBox(height: 8),
            _field(
              theme,
              controller: _nameController,
              hint: 'e.g. Goa Trip, Flatmates',
            ),
            const SizedBox(height: 20),
            _label(theme, 'Description (optional)'),
            const SizedBox(height: 8),
            _field(
              theme,
              controller: _descController,
              hint: 'What is this group for?',
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _label(theme, 'Add Friends'),
                Text(
                  '${_selected.length} selected',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            _friendPicker(theme, colors),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  _isEditing ? 'Save Changes' : 'Create Group',
                  style: const TextStyle(
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

  Widget _friendPicker(ThemeData theme, ColorScheme colors) {
    if (_me == null) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        final users = state is UserLoaded ? state.users : <UserModel>[];
        final friends = users.where((u) => u.publicKey != _me).toList();

        if (friends.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: _boxDecoration(theme),
            child: Text(
              'No contacts yet — share your invite link first.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          );
        }

        // Friends already in the group but missing from the contact list
        // (e.g. removed later) stay in the group untouched; only contacts
        // are shown for picking.
        return Container(
          decoration: _boxDecoration(theme),
          child: Column(
            children: [
              for (var i = 0; i < friends.length; i++) ...[
                _friendRow(theme, colors, friends[i]),
                if (i != friends.length - 1)
                  Divider(
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                    color: theme.dividerColor,
                  ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _friendRow(ThemeData theme, ColorScheme colors, UserModel friend) {
    final isSelected = _selected.contains(friend.publicKey);
    return InkWell(
      onTap: () => setState(() {
        if (isSelected) {
          _selected.remove(friend.publicKey);
        } else {
          _selected.add(friend.publicKey);
        }
      }),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: colors.primary.withValues(alpha: 0.12),
              child: Text(
                friend.displayName.isNotEmpty
                    ? friend.displayName[0].toUpperCase()
                    : '?',
                style: TextStyle(
                  color: colors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                friend.displayName,
                style: theme.textTheme.bodyLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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

  Widget _label(ThemeData theme, String text) {
    return Text(
      text,
      style: theme.textTheme.bodySmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
        fontSize: 12,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _field(
    ThemeData theme, {
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return Container(
      decoration: _boxDecoration(theme),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        textCapitalization: TextCapitalization.sentences,
        style: theme.textTheme.bodyLarge,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          hintText: hint,
          hintStyle: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
          ),
        ),
      ),
    );
  }

  BoxDecoration _boxDecoration(ThemeData theme) {
    return BoxDecoration(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: theme.dividerColor.withValues(alpha: 0.7)),
    );
  }
}
