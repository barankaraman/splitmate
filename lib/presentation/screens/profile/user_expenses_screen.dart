import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/user_provider.dart';
import '../../../data/models/expense_model.dart';
import '../../../data/repositories/expense_repository.dart';
import '../../../data/repositories/group_repository.dart';
import '../../../data/repositories/member_repository.dart';

class UserExpensesScreen extends StatefulWidget {
  const UserExpensesScreen({super.key});

  @override
  State<UserExpensesScreen> createState() => _UserExpensesScreenState();
}

class _UserExpensesScreenState extends State<UserExpensesScreen> {
  final _expenseRepo = ExpenseRepository();
  final _groupRepo = GroupRepository();
  final _memberRepo = MemberRepository();
  List<Map<String, dynamic>> _userExpensesWithGroup = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final userName = Provider.of<UserProvider>(context, listen: false).userName;
    final allGroups = await _groupRepo.getAllGroups();
    List<Map<String, dynamic>> matchedExpenses = [];

    for (var group in allGroups) {
      final members = await _memberRepo.getMembersForGroup(group.id);
      final userMember = members.where((m) => m.name == userName).firstOrNull;
      
      if (userMember != null) {
        final groupExpenses = await _expenseRepo.getExpensesForGroup(group.id);
        for (var expense in groupExpenses) {
          if (expense.payerId == userMember.id) {
            matchedExpenses.add({
              'expense': expense,
              'groupName': group.name,
            });
          }
        }
      }
    }

    if (mounted) {
      setState(() {
        _userExpensesWithGroup = matchedExpenses;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Expenses'),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _userExpensesWithGroup.isEmpty
              ? const Center(child: Text('You haven\'t made any expenses yet.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _userExpensesWithGroup.length,
                  itemBuilder: (context, index) {
                    final item = _userExpensesWithGroup[index];
                    final expense = item['expense'] as ExpenseModel;
                    final groupName = item['groupName'] as String;

                    return Card(
                      child: ListTile(
                        title: Text(expense.title),
                        subtitle: Text(groupName),
                        trailing: Text(
                          'TRY ${expense.amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
