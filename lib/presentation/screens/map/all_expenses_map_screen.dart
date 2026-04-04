import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/expense_model.dart';
import '../../../data/models/group_model.dart';
import '../../../data/repositories/expense_repository.dart';
import '../../../data/repositories/group_repository.dart';

class AllExpensesMapScreen extends StatefulWidget {
  const AllExpensesMapScreen({super.key});

  @override
  State<AllExpensesMapScreen> createState() => _AllExpensesMapScreenState();
}

class _AllExpensesMapScreenState extends State<AllExpensesMapScreen> {
  final _expenseRepo = ExpenseRepository();
  final _groupRepo = GroupRepository();
  Set<Marker> _markers = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMarkers();
  }

  Future<void> _loadMarkers() async {
    final groups = await _groupRepo.getAllGroups();
    final Set<Marker> newMarkers = {};

    for (var group in groups) {
      final expenses = await _expenseRepo.getExpensesForGroup(group.id);
      for (var expense in expenses) {
        if (expense.hasLocation) {
          final participantIds = await _expenseRepo.getParticipantIds(expense.id);
          
          newMarkers.add(
            Marker(
              markerId: MarkerId(expense.id),
              position: LatLng(expense.latitude!, expense.longitude!),
              onTap: () => _showExpenseDetails(expense, group, participantIds.length),
            ),
          );
        }
      }
    }

    if (mounted) {
      setState(() {
        _markers = newMarkers;
        _loading = false;
      });
    }
  }

  void _showExpenseDetails(ExpenseModel expense, GroupModel group, int participantCount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(expense.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow(Icons.payments_outlined, 'Amount', '₺${expense.amount.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            _detailRow(Icons.group_outlined, 'Group', group.name),
            const SizedBox(height: 8),
            _detailRow(Icons.people_outline, 'Participants', '$participantCount people'),
            const SizedBox(height: 8),
            _detailRow(Icons.calendar_today_outlined, 'Date', expense.createdAt.toString().split(' ')[0]),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Locations'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(41.0082, 28.9784),
                zoom: 10,
              ),
              markers: _markers,
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
            ),
    );
  }
}
