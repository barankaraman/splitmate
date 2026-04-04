import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/user_provider.dart';
import '../../../data/models/group_model.dart';
import '../../../data/models/member_model.dart';
import '../../../data/repositories/member_repository.dart';
import '../../../app.dart';

class MembersTab extends StatefulWidget {
  final GroupModel group;
  const MembersTab({super.key, required this.group});

  @override
  State<MembersTab> createState() => MembersTabState();
}

class MembersTabState extends State<MembersTab> with AutomaticKeepAliveClientMixin {
  final _memberRepo = MemberRepository();
  List<MemberModel> _members = [];
  bool _loading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    try {
      final members = await _memberRepo.getMembersForGroup(widget.group.id);
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

  // Called from parent FAB
  Future<void> triggerAddMember() async {
    // 1. Get user info outside the dialog
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUserName = userProvider.userName;
    final isUserInGroup = _members.any((m) => m.name == currentUserName);

    // 2. Show Input Dialog
    final String? name = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text(AppStrings.addMember),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isUserInGroup)
                ListTile(
                  leading: const Icon(Icons.person_add, color: AppColors.primary),
                  title: const Text('Add Myself'),
                  subtitle: Text(currentUserName),
                  onTap: () => Navigator.pop(ctx, currentUserName),
                ),
              if (!isUserInGroup) const Divider(),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'Enter member name',
                ),
                textCapitalization: TextCapitalization.words,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final text = controller.text.trim();
                if (text.isNotEmpty) {
                  Navigator.pop(ctx, text);
                }
              },
              child: const Text('Next'),
            ),
          ],
        );
      },
    );

    if (name == null || !mounted) return;

    // 3. Show Confirmation Dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm'),
        content: Text('Add "$name" to the group?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _addMember(name);
    }
  }

  Future<void> _addMember(String name) async {
    if (_members.any((m) => m.name.toLowerCase() == name.toLowerCase())) {
      _showSnackBar('Member already exists!', isError: true);
      return;
    }

    try {
      final member = MemberModel(
        id: const Uuid().v4(),
        groupId: widget.group.id,
        name: name,
        joinedAt: DateTime.now(),
      );
      await _memberRepo.insertMember(member);
      
      _showSnackBar('Member added successfully!');
      await _load();
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_loading) return const Center(child: CircularProgressIndicator());
    
    if (_members.isEmpty) {
      return Center(
        child: Text(
          'No members yet.\nTap the + button to add someone.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _members.length,
      itemBuilder: (context, index) {
        final member = _members[index];
        final color = AppColors.avatarColors[index % AppColors.avatarColors.length];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              child: Text(
                member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(member.name, style: const TextStyle(fontWeight: FontWeight.w500)),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: () => _deleteMember(member),
            ),
          ),
        );
      },
    );
  }

  Future<void> _deleteMember(MemberModel member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Member'),
        content: Text('Remove "${member.name}" from the group?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _memberRepo.deleteMember(member.id);
      _load();
    }
  }
}
