import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/theme/user_provider.dart';
import '../../../data/models/group_model.dart';
import '../../../data/repositories/group_repository.dart';
import '../../../data/repositories/expense_repository.dart';
import '../group_detail/group_detail_screen.dart';
import 'add_group_screen.dart';

/// Root screen: shows all groups and allows creating new ones.
class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  final _groupRepo = GroupRepository();
  final _expenseRepo = ExpenseRepository();

  List<GroupModel> _groups = [];
  Map<String, double> _groupTotals = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    if (!mounted) return;
    setState(() => _loading = true);

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final username = userProvider.userName;
    
    // Only fetch groups related to the logged-in user
    final groups = await _groupRepo.getGroupsForUser(username);

    final totals = <String, double>{};
    for (final g in groups) {
      totals[g.id] = await _expenseRepo.getTotalForGroup(g.id);
    }

    if (mounted) {
      setState(() {
        _groups = groups;
        _groupTotals = totals;
        _loading = false;
      });
    }
  }

  Future<void> _navigateToAddGroup() async {
    final created = await Navigator.push<GroupModel>(
      context,
      MaterialPageRoute(builder: (_) => const AddGroupScreen()),
    );
    if (created != null) _loadGroups();
  }

  Future<void> _openGroup(GroupModel group) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GroupDetailScreen(group: group),
      ),
    );
    _loadGroups();
  }

  Future<void> _deleteGroup(GroupModel group) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.deleteGroup),
        content: const Text(AppStrings.deleteGroupConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style:
                TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _groupRepo.deleteGroup(group.id);
      _loadGroups();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          AppStrings.appName,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddGroup,
        icon: const Icon(Icons.add),
        label: const Text(AppStrings.createGroup),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _groups.isEmpty
              ? _buildEmptyState()
              : _buildGroupList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group_outlined,
                size: 80,
                color: Theme.of(context).hintColor.withOpacity(0.35)),
            const SizedBox(height: 16),
            Text(
              AppStrings.noGroups,
              style: AppTextStyles.bodyLarge.copyWith(
                  color: Theme.of(context).hintColor.withOpacity(0.6)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupList() {
    return RefreshIndicator(
      onRefresh: _loadGroups,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: _groups.length,
        itemBuilder: (ctx, i) => _GroupCard(
          group: _groups[i],
          total: _groupTotals[_groups[i].id] ?? 0,
          onTap: () => _openGroup(_groups[i]),
          onDelete: () => _deleteGroup(_groups[i]),
        ),
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  final GroupModel group;
  final double total;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _GroupCard({
    required this.group,
    required this.total,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors
        .avatarColors[group.name.codeUnitAt(0) % AppColors.avatarColors.length];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: color.withOpacity(0.15),
                child: Text(
                  group.name.isNotEmpty
                      ? group.name[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
              ),
              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: AppTextStyles.titleMedium,
                    ),
                    if (group.description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(group.description,
                          style: AppTextStyles.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      'Total: TRY ${total.toStringAsFixed(2)}',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert,
                    color: Theme.of(context).hintColor),
                onSelected: (val) {
                  if (val == 'delete') onDelete();
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline,
                            color: AppColors.error, size: 18),
                        SizedBox(width: 8),
                        Text('Delete Group',
                            style: TextStyle(color: AppColors.error)),
                      ],
                    ),
                  ),
                ],
              ),
              Icon(Icons.chevron_right,
                  color: Theme.of(context).hintColor.withOpacity(0.35)),
            ],
          ),
        ),
      ),
    );
  }
}
