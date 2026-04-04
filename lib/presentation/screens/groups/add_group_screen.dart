import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/group_model.dart';
import '../../../data/repositories/group_repository.dart';

/// Form screen for creating OR editing a group.
class AddGroupScreen extends StatefulWidget {
  final GroupModel? existingGroup;

  const AddGroupScreen({super.key, this.existingGroup});

  bool get isEditing => existingGroup != null;

  @override
  State<AddGroupScreen> createState() => _AddGroupScreenState();
}

class _AddGroupScreenState extends State<AddGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  final _groupRepo = GroupRepository();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.existingGroup?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.existingGroup?.description ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    GroupModel result;

    if (widget.isEditing) {
      result = widget.existingGroup!.copyWith(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
      );
      await _groupRepo.updateGroup(result);
    } else {
      result = GroupModel(
        id: const Uuid().v4(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        createdAt: DateTime.now(),
      );
      await _groupRepo.insertGroup(result);
    }

    if (mounted) Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.isEditing;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Group' : AppStrings.createGroup),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Group name
              Text(AppStrings.groupName, style: AppTextStyles.labelLarge),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration(
                  hint: AppStrings.groupNameHint,
                  icon: Icons.group_outlined,
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? AppStrings.fieldRequired
                    : null,
              ),
              const SizedBox(height: 20),

              // Description (optional)
              Text(AppStrings.groupDescription,
                  style: AppTextStyles.labelLarge),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                decoration: _inputDecoration(
                  hint: 'e.g. Europe Tour 2024',
                  icon: Icons.notes_outlined,
                ),
                textCapitalization: TextCapitalization.sentences,
                maxLines: 2,
              ),
              const SizedBox(height: 36),

              // Save button
              ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Text(
                        isEditing ? 'Update' : AppStrings.save,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
          {required String hint, required IconData icon}) =>
      InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      );
}
