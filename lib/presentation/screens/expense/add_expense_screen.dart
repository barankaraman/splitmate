import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/expense_model.dart';
import '../../../data/models/group_model.dart';
import '../../../data/models/member_model.dart';
import '../../../data/repositories/expense_repository.dart';
import '../map/map_screen.dart';

/// Form screen for recording a new expense in a group.
class AddExpenseScreen extends StatefulWidget {
  final GroupModel group;
  final List<MemberModel> members;

  const AddExpenseScreen({
    super.key,
    required this.group,
    required this.members,
  });

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _expenseRepo = ExpenseRepository();

  String? _payerId;
  Set<String> _participantIds = {};
  bool _saving = false;

  // Optional location data
  LatLng? _selectedLocation;
  String? _locationLabel;

  @override
  void initState() {
    super.initState();
    _participantIds = widget.members.map((m) => m.id).toSet();
    if (widget.members.isNotEmpty) {
      _payerId = widget.members.first.id;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const MapScreen()),
    );

    if (result != null) {
      setState(() {
        _selectedLocation = result['location'] as LatLng;
        _locationLabel = result['label'] as String?;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_payerId == null) {
      _showError(AppStrings.selectPayer);
      return;
    }

    if (_participantIds.isEmpty) {
      _showError(AppStrings.selectAtLeastOneMember);
      return;
    }

    final amount = double.tryParse(_amountController.text.replaceAll(',', '.'));
    if (amount == null || amount <= 0) {
      _showError(AppStrings.invalidAmount);
      return;
    }

    setState(() => _saving = true);

    final expense = ExpenseModel(
      id: const Uuid().v4(),
      groupId: widget.group.id,
      title: _titleController.text.trim(),
      amount: amount,
      payerId: _payerId!,
      createdAt: DateTime.now(),
      latitude: _selectedLocation?.latitude,
      longitude: _selectedLocation?.longitude,
      locationLabel: _locationLabel,
    );

    await _expenseRepo.insertExpenseWithParticipants(
      expense,
      _participantIds.toList(),
    );

    if (mounted) Navigator.pop(context, true);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  void _toggleAllParticipants(bool selectAll) {
    setState(() {
      if (selectAll) {
        _participantIds = widget.members.map((m) => m.id).toSet();
      } else {
        _participantIds = {};
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.addExpense),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SectionLabel(AppStrings.expenseTitle),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: _inputDeco(hint: AppStrings.expenseTitleHint, icon: Icons.label_outline),
                textCapitalization: TextCapitalization.sentences,
                validator: (v) => (v == null || v.trim().isEmpty) ? AppStrings.fieldRequired : null,
              ),
              const SizedBox(height: 18),

              _SectionLabel(AppStrings.amount),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountController,
                decoration: _inputDeco(hint: AppStrings.amountHint, icon: Icons.money_rounded, suffixText: 'TRY'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*[.,]?\d{0,2}'))],
                validator: (v) {
                  final parsed = double.tryParse(v?.replaceAll(',', '.') ?? '');
                  if (parsed == null || parsed <= 0) return AppStrings.invalidAmount;
                  return null;
                },
              ),
              const SizedBox(height: 18),

              _SectionLabel(AppStrings.paidBy),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _payerId,
                decoration: _inputDeco(hint: '', icon: Icons.person_outline),
                items: widget.members
                    .map((m) => DropdownMenuItem(
                          value: m.id,
                          child: Text(m.name),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _payerId = v),
              ),
              const SizedBox(height: 18),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _SectionLabel(AppStrings.splitAmong),
                  Row(
                    children: [
                      TextButton(onPressed: () => _toggleAllParticipants(true), child: const Text('All')),
                      TextButton(onPressed: () => _toggleAllParticipants(false), child: const Text('None')),
                    ],
                  ),
                ],
              ),
              Card(
                child: Column(
                  children: widget.members.map((m) {
                    final isSelected = _participantIds.contains(m.id);
                    return CheckboxListTile(
                      value: isSelected,
                      onChanged: (checked) {
                        setState(() {
                          if (checked == true) _participantIds.add(m.id);
                          else _participantIds.remove(m.id);
                        });
                      },
                      title: Text(m.name),
                      activeColor: AppColors.primary,
                      secondary: CircleAvatar(
                        radius: 14,
                        child: Text(m.name.isNotEmpty ? m.name[0].toUpperCase() : '?', style: const TextStyle(fontSize: 12)),
                      ),
                      controlAffinity: ListTileControlAffinity.trailing,
                      dense: true,
                    );
                  }).toList(),
                ),
              ),

              if (_participantIds.isNotEmpty && _amountController.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Builder(builder: (ctx) {
                    final amt = double.tryParse(_amountController.text.replaceAll(',', '.'));
                    if (amt == null || amt <= 0) return const SizedBox.shrink();
                    final share = amt / _participantIds.length;
                    return Text(
                      'TRY ${share.toStringAsFixed(2)} per person',
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    );
                  }),
                ),

              const SizedBox(height: 24),

              OutlinedButton.icon(
                onPressed: _pickLocation,
                icon: Icon(_selectedLocation != null ? Icons.location_on : Icons.add_location_outlined),
                label: Text(_selectedLocation != null ? (_locationLabel ?? AppStrings.locationAttached) : AppStrings.selectLocation),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 28),

              ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: _saving
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text(AppStrings.save, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco({required String hint, required IconData icon, String? suffixText}) => InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixText: suffixText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      );
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(text, style: AppTextStyles.labelLarge);
}
