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
    // Default: all members participate.
    _participantIds =
        widget.members.map((m) => m.id).toSet();
    // Default payer: first member.
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

    final amount = double.tryParse(
        _amountController.text.replaceAll(',', '.'));
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
      SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error),
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

  // ─── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
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
              // ── Title ────────────────────────────────────────────────────────
              _SectionLabel(AppStrings.expenseTitle),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: _inputDeco(
                    hint: AppStrings.expenseTitleHint,
                    icon: Icons.label_outline),
                textCapitalization: TextCapitalization.sentences,
                validator: (v) =>
                    (v == null || v.trim().isEmpty)
                        ? AppStrings.fieldRequired
                        : null,
              ),
              const SizedBox(height: 18),

              // ── Amount ───────────────────────────────────────────────────────
              _SectionLabel(AppStrings.amount),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountController,
                decoration: _inputDeco(
                    hint: AppStrings.amountHint,
                    icon: Icons.attach_money_outlined),
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*[.,]?\d{0,2}'))
                ],
                validator: (v) {
                  final parsed =
                      double.tryParse(v?.replaceAll(',', '.') ?? '');
                  if (parsed == null || parsed <= 0) {
                    return AppStrings.invalidAmount;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),

              // ── Payer dropdown ───────────────────────────────────────────────
              _SectionLabel(AppStrings.paidBy),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _payerId,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down,
                        color: AppColors.primary),
                    items: widget.members
                        .map((m) => DropdownMenuItem(
                              value: m.id,
                              child: Row(
                                children: [
                                  const Icon(Icons.person_outline,
                                      size: 18,
                                      color: AppColors.primary),
                                  const SizedBox(width: 8),
                                  Text(m.name,
                                      style: AppTextStyles.bodyLarge),
                                ],
                              ),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _payerId = v),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // ── Participants ─────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _SectionLabel(AppStrings.splitAmong),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => _toggleAllParticipants(true),
                        style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary),
                        child: const Text('All',
                            style: TextStyle(fontSize: 12)),
                      ),
                      TextButton(
                        onPressed: () => _toggleAllParticipants(false),
                        style: TextButton.styleFrom(
                            foregroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                        child: const Text('None',
                            style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: widget.members.map((m) {
                    final isSelected =
                        _participantIds.contains(m.id);
                    return CheckboxListTile(
                      value: isSelected,
                      onChanged: (checked) {
                        setState(() {
                          if (checked == true) {
                            _participantIds.add(m.id);
                          } else {
                            _participantIds.remove(m.id);
                          }
                        });
                      },
                      title: Text(m.name,
                          style: AppTextStyles.bodyLarge),
                      activeColor: AppColors.primary,
                      checkColor: Colors.white,
                      secondary: CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.primary
                            .withValues(alpha: 0.12),
                        child: Text(
                          m.name.isNotEmpty
                              ? m.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12),
                        ),
                      ),
                      controlAffinity:
                          ListTileControlAffinity.trailing,
                      dense: true,
                    );
                  }).toList(),
                ),
              ),

              // Per-person share preview
              if (_participantIds.isNotEmpty &&
                  _amountController.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Builder(builder: (ctx) {
                    final amt = double.tryParse(
                        _amountController.text.replaceAll(',', '.'));
                    if (amt == null || amt <= 0) {
                      return const SizedBox.shrink();
                    }
                    final share =
                        amt / _participantIds.length;
                    return Text(
                      '₺${share.toStringAsFixed(2)} kişi başı',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.primary),
                      textAlign: TextAlign.center,
                    );
                  }),
                ),

              const SizedBox(height: 18),

              // ── Location ─────────────────────────────────────────────────────
              OutlinedButton.icon(
                onPressed: _pickLocation,
                icon: Icon(
                  _selectedLocation != null
                      ? Icons.location_on
                      : Icons.add_location_outlined,
                  color: _selectedLocation != null
                      ? AppColors.success
                      : AppColors.primary,
                ),
                label: Text(
                  _selectedLocation != null
                      ? (_locationLabel ?? AppStrings.locationAttached)
                      : AppStrings.selectLocation,
                  style: TextStyle(
                    color: _selectedLocation != null
                        ? AppColors.success
                        : AppColors.primary,
                    fontSize: 14,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: _selectedLocation != null
                        ? AppColors.success
                        : AppColors.primary,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 28),

              // ── Save ─────────────────────────────────────────────────────────
              ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text(AppStrings.save,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco(
          {required String hint, required IconData icon}) =>
      InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primary),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.primary, width: 2)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error)),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14),
      );
}

// ─── Helper ───────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: AppTextStyles.labelLarge,
      );
}
