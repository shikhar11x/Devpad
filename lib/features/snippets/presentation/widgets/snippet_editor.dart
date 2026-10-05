import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/utils/date_formatter.dart';
// Shared with Notes for now; candidate to move into core/widgets later.
import '../../../notes/presentation/widgets/note_save_indicator.dart';
import '../../domain/entities/snippet.dart';
import '../../domain/repositories/snippet_repository.dart';
import '../code_languages.dart';
import '../providers/snippet_actions.dart';
import 'highlighted_code.dart';

enum _Mode { edit, view }

/// Edits one snippet with autosave. Create it with `key: ValueKey(id)` so
/// switching snippets starts fresh. Edits made on another device while this
/// editor is open are not merged in (last write wins).
class SnippetEditor extends ConsumerStatefulWidget {
  const SnippetEditor({
    super.key,
    required this.padId,
    required this.snippet,
    required this.onClosed,
    this.showBack = false,
  });

  final String padId;
  final Snippet snippet;

  /// Called on the back button and after the snippet is deleted.
  final VoidCallback onClosed;
  final bool showBack;

  @override
  ConsumerState<SnippetEditor> createState() => _SnippetEditorState();
}

class _SnippetEditorState extends ConsumerState<SnippetEditor> {
  static const _debounceDuration = Duration(milliseconds: 800);

  late final TextEditingController _title;
  late final TextEditingController _code;
  late final SnippetActions _actions;
  final _codeFocus = FocusNode();

  late String _language;
  late _Mode _mode;
  Timer? _debounce;
  bool _dirty = false;
  bool _saving = false;
  NoteSaveStatus _status = NoteSaveStatus.saved;
  String? _error;

  @override
  void initState() {
    super.initState();
    _actions = ref.read(snippetActionsProvider);
    _title = TextEditingController(text: widget.snippet.title);
    _code = TextEditingController(text: widget.snippet.code);
    _language = widget.snippet.language;
    final untouched =
        widget.snippet.title.isEmpty && widget.snippet.code.isEmpty;
    _mode = untouched ? _Mode.edit : _Mode.view;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    // Don't lose the last edits when leaving. Best effort.
    if (_dirty) {
      unawaited(
        _actions
            .save(
              widget.padId,
              widget.snippet.id,
              title: _title.text,
              language: _language,
              code: _code.text,
            )
            .then<void>((_) {}, onError: (_) {}),
      );
    }
    _title.dispose();
    _code.dispose();
    _codeFocus.dispose();
    super.dispose();
  }

  void _setStatus(NoteSaveStatus status) {
    if (!mounted) return;
    setState(() => _status = status);
  }

  void _markDirty() {
    _dirty = true;
    _debounce?.cancel();
    _debounce = Timer(_debounceDuration, _save);
    if (mounted) setState(() => _status = NoteSaveStatus.unsaved);
  }

  Future<void> _save() async {
    _debounce?.cancel();
    if (!_dirty || !mounted) return;
    if (_saving) {
      _debounce = Timer(const Duration(milliseconds: 300), _save);
      return;
    }

    final title = _title.text;
    final language = _language;
    final code = _code.text;
    _dirty = false;
    _saving = true;
    _setStatus(NoteSaveStatus.saving);

    try {
      final outcome = await _actions.save(
        widget.padId,
        widget.snippet.id,
        title: title,
        language: language,
        code: code,
      );
      _saving = false;
      _error = null;
      if (_dirty) {
        _setStatus(NoteSaveStatus.unsaved);
      } else {
        _setStatus(
          outcome == SnippetSaveOutcome.synced
              ? NoteSaveStatus.saved
              : NoteSaveStatus.queued,
        );
      }
    } on AppFailure catch (f) {
      _saving = false;
      _dirty = true;
      _error = f.message;
      _setStatus(NoteSaveStatus.error);
    } catch (_) {
      _saving = false;
      _dirty = true;
      _error = 'Something went wrong. Try again.';
      _setStatus(NoteSaveStatus.error);
    }
  }

  /// Tab inserts two spaces instead of moving focus.
  void _insertTab() {
    final value = _code.value;
    final sel = value.selection;
    if (!sel.isValid) return;
    _code.value = TextEditingValue(
      text: value.text.replaceRange(sel.start, sel.end, '  '),
      selection: TextSelection.collapsed(offset: sel.start + 2),
    );
    _markDirty();
  }

  Future<void> _copy() async {
    final messenger = ScaffoldMessenger.of(context);
    await Clipboard.setData(ClipboardData(text: _code.text));
    messenger.showSnackBar(const SnackBar(content: Text('Code copied')));
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radius),
          side: const BorderSide(color: AppColors.border),
        ),
        title: const Text('Delete snippet?'),
        content: const Text('This snippet will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    // Nothing left to autosave.
    _debounce?.cancel();
    _dirty = false;

    final messenger = ScaffoldMessenger.of(context);
    final actions = _actions;
    final padId = widget.padId;
    final snippetId = widget.snippet.id;

    widget.onClosed(); // leave first so the editor never shows a deleted item
    try {
      await actions.delete(padId, snippetId);
      messenger.showSnackBar(const SnackBar(content: Text('Snippet deleted')));
    } on AppFailure catch (f) {
      messenger.showSnackBar(SnackBar(content: Text(f.message)));
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not delete the snippet.')),
      );
    }
  }

  Widget _languagePicker() {
    final items = [...codeLanguages];
    if (!items.any((l) => l.id == _language)) {
      items.insert(0, CodeLanguage(_language, _language));
    }
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: _language,
        isDense: true,
        dropdownColor: AppColors.surfaceHigh,
        style: AppTheme.mono.copyWith(fontSize: 12, color: AppColors.text),
        items: [
          for (final l in items)
            DropdownMenuItem(value: l.id, child: Text(l.label)),
        ],
        onChanged: (value) {
          if (value == null || value == _language) return;
          setState(() => _language = value);
          _markDirty();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final editing = _mode == _Mode.edit;
    final text = _code.text;
    final lines = text.isEmpty ? 0 : '\n'.allMatches(text).length + 1;

    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.keyS, control: true): () =>
            _save(),
        const SingleActivator(LogicalKeyboardKey.keyS, meta: true): () =>
            _save(),
      },
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(widget.showBack ? 4 : 16, 6, 4, 6),
            child: Row(
              children: [
                if (widget.showBack)
                  IconButton(
                    tooltip: 'All snippets',
                    icon: const Icon(Icons.arrow_back, size: 20),
                    onPressed: widget.onClosed,
                  ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: NoteSaveIndicator(
                      status: _status,
                      errorMessage: _error,
                      onRetry: _save,
                    ),
                  ),
                ),
                SegmentedButton<_Mode>(
                  showSelectedIcon: false,
                  style: const ButtonStyle(
                    visualDensity: VisualDensity.compact,
                  ),
                  segments: const [
                    ButtonSegment(
                      value: _Mode.edit,
                      icon: Icon(Icons.edit_outlined, size: 16),
                      tooltip: 'Edit',
                    ),
                    ButtonSegment(
                      value: _Mode.view,
                      icon: Icon(Icons.visibility_outlined, size: 16),
                      tooltip: 'View with highlighting',
                    ),
                  ],
                  selected: {_mode},
                  onSelectionChanged: (s) => setState(() => _mode = s.first),
                ),
                IconButton(
                  tooltip: 'Copy code',
                  icon: const Icon(Icons.copy_outlined, size: 18),
                  onPressed: _code.text.isEmpty ? null : _copy,
                ),
                IconButton(
                  tooltip: 'Delete snippet',
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: AppColors.error,
                  ),
                  onPressed: _delete,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _title,
                    autofocus: editing && _title.text.isEmpty,
                    maxLines: 1,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [LengthLimitingTextInputFormatter(120)],
                    onChanged: (_) => _markDirty(),
                    onSubmitted: (_) {
                      if (editing) _codeFocus.requestFocus();
                    },
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                    decoration: const InputDecoration.collapsed(
                      hintText: 'Untitled snippet',
                      hintStyle: TextStyle(color: AppColors.textMuted),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _languagePicker(),
              ],
            ),
          ),
          Expanded(
            child: editing
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: CallbackShortcuts(
                      bindings: <ShortcutActivator, VoidCallback>{
                        const SingleActivator(LogicalKeyboardKey.tab):
                            _insertTab,
                      },
                      child: TextField(
                        controller: _code,
                        focusNode: _codeFocus,
                        expands: true,
                        maxLines: null,
                        minLines: null,
                        textAlignVertical: TextAlignVertical.top,
                        keyboardType: TextInputType.multiline,
                        autocorrect: false,
                        enableSuggestions: false,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(50000),
                        ],
                        onChanged: (_) => _markDirty(),
                        style: AppTheme.mono.copyWith(
                          fontSize: 13,
                          height: 1.5,
                          color: AppColors.text,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Paste or write code...',
                          hintStyle: AppTheme.mono.copyWith(
                            fontSize: 13,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                  )
                : Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: HighlightedCode(code: text, language: _language),
                  ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Text(
              'Last edited ${DateFormatter.relative(widget.snippet.updatedAt)}'
              ' · $lines lines · ${text.length} chars',
              style: AppTheme.mono.copyWith(
                fontSize: 11,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}