import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:zplit/domain/models/group/group_model.dart';
import 'package:zplit/domain/models/user/user_model.dart';
import 'package:zplit/ui/group/view_models/group_bloc.dart';
import 'package:zplit/ui/group/view_models/group_event.dart';
import 'package:zplit/ui/group/view_models/group_state.dart';
import 'package:zplit/ui/group/widgets/group_form_screen.dart';
import 'package:zplit/ui/users/view_model/user_bloc.dart';
import 'package:zplit/ui/users/view_model/user_event.dart';
import 'package:zplit/ui/users/view_model/user_state.dart';

class ManageGroupsScreen extends StatefulWidget {
  const ManageGroupsScreen({super.key});

  @override
  State<ManageGroupsScreen> createState() => _ManageGroupsScreenState();
}

class _ManageGroupsScreenState extends State<ManageGroupsScreen> {
  String? _me;

  @override
  void initState() {
    super.initState();
    context.read<GroupBloc>().add(LoadAllGroups());
    context.read<UserBloc>().add(LoadAllUsers());
    const FlutterSecureStorage().read(key: 'evm_address').then((addr) {
      if (mounted) setState(() => _me = addr);
    });
  }

  void _openForm({GroupModel? group}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GroupFormScreen(group: group)),
    );
  }

  String _memberSummary(GroupModel group, List<UserModel> users) {
    final names = <String>[];
    for (final key in group.users) {
      if (key == _me) {
        names.add('You');
        continue;
      }
      final match = users.where((u) => u.publicKey == key);
      if (match.isNotEmpty) {
        names.add(match.first.displayName);
      } else if (key.length > 10) {
        names.add('${key.substring(0, 6)}…${key.substring(key.length - 4)}');
      } else {
        names.add(key);
      }
    }
    if (names.length <= 3) return names.join(', ');
    return '${names.take(3).join(', ')} +${names.length - 3}';
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
          'Groups',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        backgroundColor: colors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.group_add_outlined),
        label: const Text(
          'Create Group',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: BlocConsumer<GroupBloc, GroupState>(
        listenWhen: (prev, curr) => curr is GroupError,
        listener: (context, state) {
          if (state is GroupError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Group error: ${state.message}'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is GroupLoading || state is GroupInitial) {
            return Center(
              child: CircularProgressIndicator(color: colors.primary),
            );
          }

          if (state is GroupError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, color: colors.error, size: 32),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () =>
                        context.read<GroupBloc>().add(LoadAllGroups()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final groups = state is GroupLoaded ? state.groups : <GroupModel>[];

          if (groups.isEmpty) return _emptyState(theme, colors);

          return BlocBuilder<UserBloc, UserState>(
            builder: (context, userState) {
              final users = userState is UserLoaded
                  ? userState.users
                  : <UserModel>[];
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                itemCount: groups.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) =>
                    _groupTile(theme, colors, groups[i], users),
              );
            },
          );
        },
      ),
    );
  }

  Widget _groupTile(
    ThemeData theme,
    ColorScheme colors,
    GroupModel group,
    List<UserModel> users,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _openForm(group: group),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: colors.primary.withValues(alpha: 0.12),
              child: Text(
                group.name.isNotEmpty ? group.name[0].toUpperCase() : '?',
                style: TextStyle(
                  color: colors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.name,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${group.users.length} '
                    '${group.users.length == 1 ? 'member' : 'members'}'
                    ' · ${_memberSummary(group, users)}',
                    style: theme.textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: colors.onSurface.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(ThemeData theme, ColorScheme colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.groups_outlined,
              size: 80,
              color: colors.primary.withValues(alpha: 0.25),
            ),
            const SizedBox(height: 16),
            Text(
              'No groups yet',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Create a group with your friends to keep things together.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
