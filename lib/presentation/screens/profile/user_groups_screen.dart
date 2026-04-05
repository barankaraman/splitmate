import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/user_provider.dart';
import '../../../data/models/group_model.dart';
import '../../../data/repositories/group_repository.dart';
import '../../../data/repositories/member_repository.dart';
import '../group_detail/group_detail_screen.dart';

class UserGroupsScreen extends StatefulWidget {
  const UserGroupsScreen({super.key});

  @override
  State<UserGroupsScreen> createState() => _UserGroupsScreenState();
}

class _UserGroupsScreenState extends State<UserGroupsScreen> {
  final _groupRepo = GroupRepository();
  final _memberRepo = MemberRepository();
  List<GroupModel> _userGroups = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    final userName = Provider.of<UserProvider>(context, listen: false).userName;
    final allGroups = await _groupRepo.getAllGroups();
    List<GroupModel> matchedGroups = [];

    for (var group in allGroups) {
      final members = await _memberRepo.getMembersForGroup(group.id);
      if (members.any((m) => m.name == userName)) {
        matchedGroups.add(group);
      }
    }

    if (mounted) {
      setState(() {
        _userGroups = matchedGroups;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Groups'),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _userGroups.isEmpty
              ? const Center(child: Text('You are not in any groups yet.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _userGroups.length,
                  itemBuilder: (context, index) {
                    final group = _userGroups[index];
                    return Card(
                      child: ListTile(
                        title: Text(group.name),
                        subtitle: Text(group.description),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GroupDetailScreen(group: group),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
