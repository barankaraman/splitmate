import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/group_model.dart';
import '../groups/add_group_screen.dart';
import 'expenses_tab.dart';
import 'members_tab.dart';
import 'summary_tab.dart';

/// Group detail screen with a SINGLE Scaffold.
///
/// The FAB is tab-aware: it delegates to the active tab via GlobalKey,
/// which eliminates the nested-Scaffold crash caused by having a Scaffold
/// with a FAB inside each tab widget.
class GroupDetailScreen extends StatefulWidget {
  final GroupModel group;
  const GroupDetailScreen({super.key, required this.group});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late GroupModel _group;
  int _currentTab = 0;

  // Keys let us call public methods on the tab states from this parent.
  final _expensesKey = GlobalKey<ExpensesTabState>();
  final _membersKey = GlobalKey<MembersTabState>();

  @override
  void initState() {
    super.initState();
    _group = widget.group;
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging && mounted) {
        setState(() => _currentTab = _tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ─── Tab-aware FAB ────────────────────────────────────────────────────────────

  Widget? _buildFab() {
    switch (_currentTab) {
      case 0: // Expenses tab
        return FloatingActionButton(
          heroTag: 'fab_expenses',
          onPressed: () =>
              _expensesKey.currentState?.triggerAddExpense(),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          tooltip: AppStrings.addExpense,
          child: const Icon(Icons.add),
        );
      case 1: // Members tab
        return FloatingActionButton(
          heroTag: 'fab_members',
          onPressed: () =>
              _membersKey.currentState?.triggerAddMember(),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          tooltip: AppStrings.addMember,
          child: const Icon(Icons.person_add_outlined),
        );
      default:
        return null; // Summary tab — no FAB needed
    }
  }

  // ─── Group edit ───────────────────────────────────────────────────────────────

  Future<void> _editGroup() async {
    final updated = await Navigator.push<GroupModel>(
      context,
      MaterialPageRoute(
          builder: (_) => AddGroupScreen(existingGroup: _group)),
    );
    if (updated != null && mounted) {
      setState(() => _group = updated);
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_group.name,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 18)),
            if (_group.description.isNotEmpty)
              Text(_group.description,
                  style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                      fontWeight: FontWeight.normal)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Grubu Düzenle',
            onPressed: _editGroup,
          ),
        ],
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: const [
            Tab(
                icon: Icon(Icons.receipt_long_outlined),
                text: AppStrings.expenses),
            Tab(
                icon: Icon(Icons.people_outline),
                text: AppStrings.members),
            Tab(
                icon: Icon(Icons.pie_chart_outline),
                text: AppStrings.summary),
          ],
        ),
      ),
      // Single FAB — changes based on the active tab.
      floatingActionButton: _buildFab(),
      body: TabBarView(
        controller: _tabController,
        children: [
          ExpensesTab(key: _expensesKey, group: _group),
          MembersTab(key: _membersKey, group: _group),
          SummaryTab(group: _group),
        ],
      ),
    );
  }
}
