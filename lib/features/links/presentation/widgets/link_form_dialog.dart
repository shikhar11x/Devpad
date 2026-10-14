import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/utils/web_url.dart';
import '../../../../core/widgets/devpad_button.dart';
import '../../../../core/widgets/devpad_text_field.dart';
import '../../domain/entities/resource_link.dart';
import '../link_category_ui.dart';
import '../providers/link_actions.dart';

/// Opens the add dialog, or the edit dialog when [link] is given.
Future<void> showLinkFormDialog(
  BuildContext context, {
  required String padId,
  ResourceLink? link,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => LinkFormDialog(padId: padId, link: link),
  );
}

class LinkFormDialog extends ConsumerStatefulWidget {
  const LinkFormDialog({super.key, required this.padId, this.link});

  final String padId;
  final ResourceLink? link;

  @override
  ConsumerState<LinkFormDialog> createState() => _LinkFormDialogState();
}

class _LinkFormDialogState extends ConsumerState<LinkFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _url;
  late final TextEditingController _title;
  late final TextEditingController _description;
  late LinkCategory _category;
  bool _saving = false;
  String? _error;

  bool get _editing => widget.link != null;

  @override
  void initState() {
    super.initState();
    final l = widget.link;
    _url = TextEditingController(text: l?.url ?? '');
    _title = TextEditingController(text: l?.title ?? '');
    _description = TextEditingController(text: l?.description ?? '');
    _category = l?.category ?? LinkCategory.other;
  }

  @override
  void dispose() {
    _url.dispose();
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    final url = normalizeWebUrl(_url.text);
    if (url == null) return; // validator already reported it

    var title = _title.text.trim().isEmpty ? hostOf(url) : _title.text.trim();
    if (title.length > 120) title = title.substring(0, 120);

    setState(() {
      _saving = true;
      _error = null;
    });
    final actions = ref.read(linkActionsProvider);
    try {
      final link = widget.link;
      if (link == null) {
        await actions.create(
          widget.padId,
          title: title,
          url: url,
          description: _description.text,
          category: _category,
        );
      } else {
        await actions.update(
          widget.padId,
          link.id,
          title: title,
          url: url,
          description: _description.text,
          category: _category,
        );
      }
      if (mounted) Navigator.of(context).pop();
    } on AppFailure catch (f) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = f.message;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Something went wrong. Try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceSecondary,
      surfaceTintColor: Colors.transparent,
      elevation: 24,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppColors.cyan.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      actionsPadding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColors.cyan.withValues(alpha: 0.12),
              border: Border.all(
                color: AppColors.cyan.withValues(alpha: 0.4),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.cyan.withValues(alpha: 0.2),
                  blurRadius: 10,
                ),
              ],
            ),
            child: const Icon(Icons.link_rounded, size: 20, color: AppColors.cyan),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _editing ? 'CONFIG // RECORD' : 'NEW RESOURCE // URL',
                  style: AppTheme.mono.copyWith(
                    fontSize: 10,
                    letterSpacing: 1.5,
                    color: AppColors.cyan,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _editing ? 'Edit Resource' : 'Add Resource Link',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 18, color: AppColors.error),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _error!,
                            style: const TextStyle(
                              color: AppColors.error,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                DevPadTextField(
                  controller: _url,
                  label: 'URL',
                  hint: 'https://docs.flutter.dev',
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.next,
                  maxLength: 2000,
                  enabled: !_saving,
                  validator: (v) => normalizeWebUrl(v ?? '') == null
                      ? 'Enter a valid web address, e.g. flutter.dev'
                      : null,
                ),
                const SizedBox(height: 16),
                DevPadTextField(
                  controller: _title,
                  label: 'TITLE (OPTIONAL)',
                  hint: 'Defaults to the website name',
                  maxLength: 120,
                  textInputAction: TextInputAction.next,
                  enabled: !_saving,
                ),
                const SizedBox(height: 16),
                DevPadTextField(
                  controller: _description,
                  label: 'DESCRIPTION (OPTIONAL)',
                  maxLength: 500,
                  maxLines: 2,
                  enabled: !_saving,
                ),
                const SizedBox(height: 16),
                Text(
                  '// CATEGORY CLASSIFICATION',
                  style: AppTheme.mono.copyWith(
                    fontSize: 11,
                    letterSpacing: 0.8,
                    color: AppColors.textDim,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final c in LinkCategory.values)
                      ChoiceChip(
                        avatar: Icon(
                          categoryIcon(c),
                          size: 15,
                          color: c == _category ? AppColors.cyan : AppColors.textMuted,
                        ),
                        label: Text(
                          c.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: c == _category ? FontWeight.w600 : FontWeight.w400,
                            color: c == _category ? AppColors.cyan : AppColors.textDim,
                          ),
                        ),
                        selected: c == _category,
                        selectedColor: AppColors.cyan.withValues(alpha: 0.15),
                        backgroundColor: AppColors.surfaceElevated,
                        side: BorderSide(
                          color: c == _category
                              ? AppColors.cyan.withValues(alpha: 0.6)
                              : AppColors.border,
                        ),
                        showCheckmark: false,
                        onSelected:
                            _saving ? null : (_) => setState(() => _category = c),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textMuted,
            side: const BorderSide(color: AppColors.border),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        DevPadButton(
          label: _editing ? 'Save Changes' : 'Register Link',
          icon: const Icon(Icons.check, size: 16),
          isLoading: _saving,
          expand: false,
          onPressed: _submit,
        ),
      ],
    );
  }
}