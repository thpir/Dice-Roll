import 'dart:io';

import 'package:dice_roll/data/services/image_storage_service.dart';
import 'package:dice_roll/domain/use_cases/dice_validation.dart';
import 'package:dice_roll/ui/core/theme/extensions/app_colors_ext.dart';
import 'package:dice_roll/ui/core/theme/tokens/app_colors.dart';
import 'package:dice_roll/ui/core/theme/tokens/app_radii.dart';
import 'package:dice_roll/ui/core/theme/tokens/app_spacing.dart';
import 'package:dice_roll/ui/core/theme/tokens/app_typography.dart';
import 'package:dice_roll/ui/core/widgets/buttons/app_icon_button.dart';
import 'package:dice_roll/ui/core/widgets/buttons/app_outlined_button.dart';
import 'package:dice_roll/ui/core/widgets/buttons/app_text_button.dart';
import 'package:dice_roll/ui/core/widgets/display/app_drag_handle.dart';
import 'package:dice_roll/ui/core/widgets/display/app_section_label.dart';
import 'package:dice_roll/ui/core/widgets/feedback/app_loading_indicator.dart';
import 'package:dice_roll/ui/core/widgets/inputs/app_color_swatch.dart';
import 'package:dice_roll/ui/core/widgets/inputs/app_image_slot.dart';
import 'package:dice_roll/ui/core/widgets/inputs/app_text_field.dart';
import 'package:dice_roll/ui/core/widgets/layout/app_app_bar.dart';
import 'package:dice_roll/ui/core/widgets/layout/app_scaffold.dart';
import 'package:dice_roll/ui/core/widgets/stored_image.dart';
import 'package:dice_roll/ui/core/widgets/surfaces/app_card.dart';
import 'package:dice_roll/ui/features/dice_editor/view_model/dice_editor_view_model.dart';
import 'package:dice_roll/ui/providers/dice_game_provider.dart';
import 'package:dice_roll/ui/providers/dice_management_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class DiceEditorView extends StatelessWidget {
  final String? diceId;

  const DiceEditorView({super.key, required this.diceId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DiceEditorViewModel>(
      create: (context) => DiceEditorViewModel(
        management: context.read<DiceManagementProvider>(),
        imageStorageService: context.read<ImageStorageService>(),
      )..load(diceId),
      child: _DiceEditorBody(isCreating: diceId == null),
    );
  }
}

class _DiceEditorBody extends StatefulWidget {
  final bool isCreating;

  const _DiceEditorBody({required this.isCreating});

  @override
  State<_DiceEditorBody> createState() => _DiceEditorBodyState();
}

enum _FaceImageSlot { background, foreground }

class _DiceEditorBodyState extends State<_DiceEditorBody> {
  final _titleController = TextEditingController();
  final _picker = ImagePicker();
  var _initialised = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialised) {
      return;
    }
    final vm = context.read<DiceEditorViewModel>();
    if (!vm.isLoading) {
      _titleController.text = vm.title;
      _initialised = true;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(int index, _FaceImageSlot slot) async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null || !mounted) {
      return;
    }
    final vm = context.read<DiceEditorViewModel>();
    final file = File(picked.path);
    switch (slot) {
      case _FaceImageSlot.background:
        vm.setPendingBackgroundImage(index, file);
      case _FaceImageSlot.foreground:
        vm.setPendingImage(index, file);
    }
  }

  void _clearImage(int index, _FaceImageSlot slot) {
    final vm = context.read<DiceEditorViewModel>();
    switch (slot) {
      case _FaceImageSlot.background:
        vm.clearBackgroundImage(index);
      case _FaceImageSlot.foreground:
        vm.clearFaceImage(index);
    }
  }

  Future<void> _pickColor(int index, int currentColor) async {
    final result = await showDialog<Color>(
      context: context,
      builder: (_) => _HexColorPickerDialog(initial: Color(currentColor)),
    );
    if (result == null || !mounted) {
      return;
    }
    // ignore: deprecated_member_use
    context.read<DiceEditorViewModel>().setFaceColor(index, result.value);
  }

  Future<void> _save() async {
    final vm = context.read<DiceEditorViewModel>();
    final activeDice = context.read<DiceGameProvider>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final saved = await vm.save();
    if (saved == null) {
      final error = vm.errorMessage;
      if (error != null) {
        messenger.showSnackBar(SnackBar(content: Text(error)));
      }
      return;
    }
    await activeDice.refresh();
    if (!mounted) {
      return;
    }
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DiceEditorViewModel>();
    if (vm.isLoading) {
      return const AppScaffold(body: Center(child: AppLoadingIndicator()));
    }
    if (!_initialised) {
      _titleController.text = vm.title;
      _initialised = true;
    }
    return AppScaffold(
      appBar: AppAppBar(
        title: widget.isCreating ? 'New dice' : 'Edit dice',
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.s),
            child: AppTextButton(
              onPressed: vm.isSaving ? null : _save,
              label: 'Save',
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
        child: Column(
          spacing: AppSpacing.s,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppSectionLabel(label: 'Title'),
            AppTextField(
              controller: _titleController,
              hintText: 'Title',
              onChanged: vm.setTitle,
            ),
            const SizedBox(width: AppSpacing.m),
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: AppSpacing.s,
                    children: [
                      const AppSectionLabel(
                        label: 'Faces',
                        color: AppColors.ink,
                      ),
                      AppSectionLabel(
                        label: vm.faces.length.toString(),
                        color: AppColors.acid,
                      ),
                      const AppSectionLabel(label: '/'),
                      AppSectionLabel(
                        label: DiceValidation.maxFaces.toString(),
                      ),
                    ],
                  ),
                ),
                AppOutlinedButton(
                  onPressed: vm.canAddFace ? vm.addFace : null,
                  label: 'Add face',
                  icon: Icons.add,
                  variant: AppOutlinedButtonVariant.pink,
                ),
              ],
            ),
            Expanded(
              child: ReorderableListView.builder(
                buildDefaultDragHandles: false,
                itemCount: vm.faces.length,
                onReorder: vm.reorderFaces,
                itemBuilder: (context, index) {
                  final face = vm.faces[index];
                  return _FaceTile(
                    key: ValueKey(face.id),
                    index: index,
                    face: face,
                    canDelete: vm.canRemoveFace,
                    onPickColor: () => _pickColor(index, face.backgroundColor),
                    onPickImage: _pickImage,
                    onClearImage: _clearImage,
                    onDelete: () =>
                        context.read<DiceEditorViewModel>().removeFaceAt(index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FaceTile extends StatelessWidget {
  final int index;
  final EditableFace face;
  final bool canDelete;
  final VoidCallback onPickColor;
  final void Function(int index, _FaceImageSlot slot) onPickImage;
  final void Function(int index, _FaceImageSlot slot) onClearImage;
  final VoidCallback onDelete;

  const _FaceTile({
    super.key,
    required this.index,
    required this.face,
    required this.canDelete,
    required this.onPickColor,
    required this.onPickImage,
    required this.onClearImage,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.s),
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.s),
        borderColor: AppColors.outline,
        child: Row(
          spacing: AppSpacing.m,
          children: [
            ReorderableDragStartListener(
              index: index,
              child: const AppDragHandle(),
            ),
            AppSectionLabel(label: '${index + 1}', color: AppColors.acid),
            AppColorSwatch(
              onTap: onPickColor,
              color: Color(face.backgroundColor),
            ),
            Expanded(
              child: AppImageSlot(
                height: 56,
                label: 'BG',
                placeholderIcon: Icons.wallpaper_outlined,
                imageChild: _faceImageChild(
                  pendingFile: face.pendingBackgroundImageFile,
                  savedPath: face.backgroundImagePath,
                ),
                onTap: () => onPickImage(index, _FaceImageSlot.background),
                onClear:
                    face.pendingBackgroundImageFile != null ||
                        face.backgroundImagePath != null
                    ? () => onClearImage(index, _FaceImageSlot.background)
                    : null,
              ),
            ),
            Expanded(
              child: AppImageSlot(
                height: 56,
                label: 'FG',
                placeholderIcon: Icons.add_photo_alternate_outlined,
                imageChild: _faceImageChild(
                  pendingFile: face.pendingImageFile,
                  savedPath: face.imagePath,
                ),
                onTap: () => onPickImage(index, _FaceImageSlot.foreground),
                onClear: face.pendingImageFile != null || face.imagePath != null
                    ? () => onClearImage(index, _FaceImageSlot.foreground)
                    : null,
              ),
            ),
            AppIconButton(
              icon: Icons.delete_forever_outlined,
              color: AppColors.pink,
              onPressed: canDelete ? onDelete : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget? _faceImageChild({
    required File? pendingFile,
    required String? savedPath,
  }) {
    if (pendingFile != null) {
      return Image.file(pendingFile, fit: BoxFit.cover, cacheWidth: 120);
    }
    if (savedPath != null) {
      return StoredImage(path: savedPath, fit: BoxFit.cover, cacheWidth: 120);
    }
    return null;
  }
}

class _HexColorPickerDialog extends StatefulWidget {
  final Color initial;

  const _HexColorPickerDialog({required this.initial});

  @override
  State<_HexColorPickerDialog> createState() => _HexColorPickerDialogState();
}

class _HexColorPickerDialogState extends State<_HexColorPickerDialog> {
  late var _color = widget.initial;
  late final _hexController = TextEditingController(text: _hex(_color));

  static String _hex(Color c) {
    // ignore: deprecated_member_use
    final rgb = c.value & 0xFFFFFF;
    return rgb.toRadixString(16).padLeft(6, '0').toUpperCase();
  }

  void _onPickerChanged(Color c) {
    setState(() {
      _color = c;
      final next = _hex(c);
      if (_hexController.text.toUpperCase() != next) {
        _hexController.value = TextEditingValue(
          text: next,
          selection: TextSelection.collapsed(offset: next.length),
        );
      }
    });
  }

  void _onHexChanged(String value) {
    final cleaned = value.replaceAll('#', '').trim();
    if (cleaned.length != 6) {
      return;
    }
    final parsed = int.tryParse(cleaned, radix: 16);
    if (parsed == null) {
      return;
    }
    setState(() {
      _color = Color(0xFF000000 | parsed);
    });
  }

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return AlertDialog(
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.sBR),
      title: Text(
        'Pick a colour',
        style: AppTypography.titleL.copyWith(color: colors.ink),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ColorPicker(
              pickerColor: _color,
              onColorChanged: _onPickerChanged,
              enableAlpha: false,
              labelTypes: const [],
            ),
            const SizedBox(height: 8),
            AppTextField(
              controller: _hexController,
              hintText: 'Copy or paste a colour value',
              prefixText: '#',
              onChanged: _onHexChanged,
            ),
          ],
        ),
      ),
      actions: [
        AppTextButton(
          onPressed: () => Navigator.of(context).pop(),
          label: 'Cancel',
          color: colors.inkMute,
        ),
        AppTextButton(
          onPressed: () => Navigator.of(context).pop(_color),
          label: 'OK',
          color: colors.acid,
        ),
      ],
    );
  }
}
