import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/group_model.dart';
import '../../../data/models/member_model.dart';
import '../../../data/repositories/member_repository.dart';

/// Tab for managing group members.
///
/// NOTE: No nested Scaffold or FAB here.
/// The parent [GroupDetailScreen] calls [triggerAddMember] via GlobalKey.
class MembersTab extends StatefulWidget {
  final GroupModel group;
  const MembersTab({super.key, required this.group});

  @override
  // Public so GroupDetailScreen can hold a GlobalKey<MembersTabState>.
  State<MembersTab> createState() => MembersTabState();
}

class MembersTabState extends State<MembersTab>
    with AutomaticKeepAliveClientMixin {
  final _memberRepo = MemberRepository();
  List<MemberModel> _members = [];
  bool _loading = true;
  bool _dialogShowing = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  // ─── Data ─────────────────────────────────────────────────────────────────────

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final members =
          await _memberRepo.getMembersForGroup(widget.group.id);
      if (mounted) {
        setState(() {
          _members = members;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ─── Public API (called by parent via GlobalKey) ──────────────────────────────

  Future<void> triggerAddMember() async {
    if (_dialogShowing) return;
    _showAddMemberDialog();
  }

  // ─── Dialog ───────────────────────────────────────────────────────────────────

  Future<void> _showAddMemberDialog() async {
    if (!mounted || _dialogShowing) return;
    _dialogShowing = true;

    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool? confirmed;
    String name = '';

    try {
      confirmed = await showDialog<bool>(
        context: context,
        barrierDismissible: true,
        builder: (ctx) => AlertDialog(
          title: const Text(AppStrings.addMember),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: AppStrings.memberName,
                hintText: AppStrings.memberNameHint,
              ),
              textCapitalization: TextCapitalization.words,
              autofocus: true,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(ctx, true);
                }
              },
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? AppStrings.fieldRequired
                  : null,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text(AppStrings.cancel),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(ctx, true);
                }
              },
              child: const Text(AppStrings.add),
            ),
          ],
        ),
      );
      name = controller.text.trim();
    } finally {
      controller.dispose();
      _dialogShowing = false;
    }

    if (!mounted || confirmed != true || name.isEmpty) return;

    try {
      final member = MemberModel(
        id: const Uuid().v4(),
        groupId: widget.group.id,
        name: name,
        joinedAt: DateTime.now(),
      );
      await _memberRepo.insertMember(member);
      if (mounted) await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Üye eklenemedi: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _deleteMember(MemberModel member) async {
    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.removeMember),
        content: Text('"${member.name}" kişisini gruptan çıkar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) return;

    try {
      await _memberRepo.deleteMember(member.id);
      if (mounted) _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Üye silinemedi: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_members.isEmpty) return _buildEmptyState();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: _members.length,
      itemBuilder: (_, i) => _MemberCard(
        key: ValueKey(_members[i].id),
        member: _members[i],
        index: i,
        onDelete: () => _deleteMember(_members[i]),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline,
                size: 72,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35)),
            const SizedBox(height: 12),
            Text(
              AppStrings.noMembers,
              style: AppTextStyles.bodyLarge.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Member Card ──────────────────────────────────────────────────────────────

class _MemberCard extends StatelessWidget {
  final MemberModel member;
  final int index;
  final VoidCallback onDelete;

  const _MemberCard({
    super.key,
    required this.member,
    required this.index,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        AppColors.avatarColors[index % AppColors.avatarColors.length];

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Text(
            member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        title: Text(member.name, style: AppTextStyles.titleMedium),
        subtitle:
            Text('Üye #${index + 1}', style: AppTextStyles.bodySmall),
        trailing: IconButton(
          icon: const Icon(Icons.person_remove_outlined,
              color: AppColors.error),
          tooltip: AppStrings.removeMember,
          onPressed: onDelete,
        ),
      ),
    );
  }
}
