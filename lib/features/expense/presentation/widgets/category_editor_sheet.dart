import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../data/models/custom_category_model.dart';

/// Predefined icon options shown in [CategoryEditorSheet].
const List<({String key, IconData icon})> categoryIconOptions = [
  (key: 'restaurant', icon: Icons.restaurant_outlined),
  (key: 'transport', icon: Icons.directions_bus_outlined),
  (key: 'shopping', icon: Icons.shopping_bag_outlined),
  (key: 'home', icon: Icons.home_outlined),
  (key: 'health', icon: Icons.health_and_safety_outlined),
  (key: 'education', icon: Icons.school_outlined),
  (key: 'entertainment', icon: Icons.movie_outlined),
  (key: 'gym', icon: Icons.fitness_center_outlined),
  (key: 'pets', icon: Icons.pets_outlined),
  (key: 'gift', icon: Icons.card_giftcard_outlined),
  (key: 'work', icon: Icons.work_outline_rounded),
  (key: 'star', icon: Icons.star_outline_rounded),
];

/// Predefined colour hex strings (no '#') for category colours.
const List<String> categoryColorOptions = [
  'FFB648',
  '61A7FF',
  'FF8C7A',
  'FF72B6',
  '9B8CFF',
  '4BB7A6',
  '7B8BAA',
  '6D8FFF',
  '85FFB8',
  'FFE38A',
  'B4EFB4',
  'FFC0CB',
];

/// Shows a bottom sheet for creating or editing a [CustomCategoryModel].
///
/// Returns the created/updated model on save, or `null` on cancel.
/// When [category] is non-null the sheet is in edit mode and a Delete button
/// is shown.
Future<CustomCategoryModel?> showCategoryEditorSheet(
  BuildContext context, {
  CustomCategoryModel? category,
}) {
  return showModalBottomSheet<CustomCategoryModel>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _CategoryEditorSheet(category: category),
  );
}

class _CategoryEditorSheet extends StatefulWidget {
  const _CategoryEditorSheet({this.category});

  final CustomCategoryModel? category;

  @override
  State<_CategoryEditorSheet> createState() => _CategoryEditorSheetState();
}

class _CategoryEditorSheetState extends State<_CategoryEditorSheet> {
  late final TextEditingController _nameController;
  late String _iconKey;
  late String _colorHex;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.category?.name ?? '');
    _iconKey =
        widget.category?.iconKey ?? categoryIconOptions.first.key;
    _colorHex =
        widget.category?.colorHex ?? categoryColorOptions.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.of(context).viewInsets;
    final isEditing = widget.category != null;

    return Padding(
      padding: EdgeInsets.only(bottom: insets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Center(
                child: SizedBox(
                  width: 46,
                  child:
                      Divider(thickness: 4, color: AppColors.backgroundLight),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                isEditing ? 'Edit Category' : 'Add Category',
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Give your custom category a name, icon, and colour.',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                autofocus: !isEditing,
                textCapitalization: TextCapitalization.words,
                decoration: _inputDecoration('Category name'),
              ),
              const SizedBox(height: 18),
              const Text(
                'Icon',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: categoryIconOptions.map((option) {
                  final isSelected = option.key == _iconKey;
                  return ChoiceChip(
                    label: Icon(
                      option.icon,
                      color: isSelected
                          ? Colors.white
                          : AppColors.primaryBlue,
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.primaryBlue,
                    backgroundColor: AppColors.lightBlueBg,
                    onSelected: (_) {
                      setState(() => _iconKey = option.key);
                    },
                  );
                }).toList(growable: false),
              ),
              const SizedBox(height: 18),
              const Text(
                'Colour',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: categoryColorOptions.map((hex) {
                  final color = Color(int.parse('FF$hex', radix: 16));
                  final isSelected = hex == _colorHex;
                  return GestureDetector(
                    onTap: () => setState(() => _colorHex = hex),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(
                                color: AppColors.textDark,
                                width: 3,
                              )
                            : null,
                        boxShadow: isSelected
                            ? const <BoxShadow>[
                                BoxShadow(
                                  color: AppColors.cardShadow,
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 18,
                            )
                          : null,
                    ),
                  );
                }).toList(growable: false),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    isEditing ? 'Save Changes' : 'Create Category',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              if (isEditing) ...<Widget>[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _delete,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: const BorderSide(color: AppColors.danger),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Delete Category',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: AppColors.surfaceLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
    );
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      context.showSnackBar('Enter a category name.');
      return;
    }

    final result = widget.category != null
        ? widget.category!.copyWith(
            name: name,
            iconKey: _iconKey,
            colorHex: _colorHex,
          )
        : CustomCategoryModel.create(
            name: name,
            iconKey: _iconKey,
            colorHex: _colorHex,
          );

    Navigator.of(context).pop(result);
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: const Text(
          'This will remove the category. Past transactions using it will still show the category name.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Delete',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // Return the existing category with a special colorHex sentinel
      // so the caller knows this is a delete request (colorHex == '__delete__').
      Navigator.of(context).pop(
        CustomCategoryModel(
          id: widget.category!.id,
          name: widget.category!.name,
          iconKey: widget.category!.iconKey,
          colorHex: '__delete__',
        ),
      );
    }
  }
}
