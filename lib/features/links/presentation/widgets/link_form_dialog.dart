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
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radius),
        side: const BorderSide(color: AppColors.border),
      ),
      title: Text(_editing ? 'Edit link' : 'Add link'),
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
                  Row(
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
                  const SizedBox(height: 16),
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
                  'CATEGORY',
                  style: AppTheme.mono.copyWith(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final c in LinkCategory.values)
                      ChoiceChip(
                        avatar: Icon(categoryIcon(c), size: 16),
                        label: Text(c.label),
                        selected: c == _category,
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
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        DevPadButton(
          label: _editing ? 'Save' : 'Add link',
          isLoading: _saving,
          expand: false,
          onPressed: _submit,
        ),
      ],
    );
  }
}