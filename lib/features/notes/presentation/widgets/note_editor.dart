import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/edit_fingerprints.dart';
import '../../../../core/widgets/conflict_banner.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../markdown_formatter.dart';
import '../providers/note_actions.dart';
import 'markdown_toolbar.dart';
import 'note_preview.dart';
import 'note_save_indicator.dart';

enum _Mode { edit, preview }

/// Edits one note with autosave. Create it with `key: ValueKey(note.id)` so
/// switching notes starts fresh.
///
/// While open it follows changes made elsewhere: if you have no unsaved
/// edits the newer version is loaded; if you do, saving pauses and you
/// choose Keep mine / Use theirs / Keep both.
class NoteEditor extends ConsumerStatefulWidget {
  const NoteEditor({
    super.key,
    required this.padId,
    required this.note,
    required this.onClosed,
    this.showBack = false,
  });

  final String padId;
  final Note note;

  /// Called on the back button and after the note is deleted.
  final VoidCallback onClosed;
  final bool showBack;

  @override
  ConsumerState<NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends ConsumerState<NoteEditor> {
  static const _debounceDuration = Duration(milliseconds: 800);

  late final TextEditingController _title;
  late final TextEditingController _content;
  late final NoteActions _actions;
  final _contentFocus = FocusNode();
  final _known = EditFingerprints();

  Timer? _debounce;
  bool _dirty = false;
  bool _saving = false;
  NoteSaveStatus _status = NoteSaveStatus.saved;
  String? _error;
  _Mode _mode = _Mode.edit;

  /// A version from elsewhere that conflicts with unsaved local edits.
  Note? _remote;

  bool get _hasConflict => _remote != null;

  static String _fp(String title, String content) =>
      EditFingerprints.of([title, content]);

  @override
  void initState() {
    super.initState();
    _actions = ref.read(noteActionsProvider);
    _title = TextEditingController(text: widget.note.title);
    _content = TextEditingController(text: widget.note.content);
    _known.remember(_fp(widget.note.title, widget.note.content));
  }

  @override
  void didUpdateWidget(NoteEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    final n = widget.note;
    final fp = _fp(n.title, n.content);
    if (_known.contains(fp)) return; // our own save echoing back

    if (_title.text == n.title && _content.text == n.content) {
      _known.remember(fp);
      return;
    }
    if (!_dirty && !_saving) {
      _adopt(n); // nothing to lose: show the newer version
      return;
    }
    _debounce?.cancel();
    _remote = n; // local edits differ: ask the user
  }

  @override
  void dispose() {
    _debounce?.cancel();
    final title = _title.text;
    final content = _content.text;
    if (_hasConflict) {
      // Never overwrite the other version, and never drop local edits.
      unawaited(
        _saveCopy(title, content).then<void>((_) {}, onError: (_) {}),
      );
    } else if (_dirty) {
      // Don't lose the last edits when leaving the note. Best effort.
      unawaited(
        _actions
            .save(widget.padId, widget.note.id, title: title, content: content)
            .then<void>((_) {}, onError: (_) {}),
      );
    }
    _title.dispose();
    _content.dispose();
    _contentFocus.dispose();
    super.dispose();
  }

  /// Replaces the editor text with [n]. Call inside setState if needed.
  void _adopt(Note n) {
    _debounce?.cancel();
    _title.text = n.title;
    _content.text = n.content;
    _known.remember(_fp(n.title, n.content));
    _dirty = false;
    _remote = null;
    _error = null;
    _status = NoteSaveStatus.saved;
  }

  Future<void> _saveCopy(String title, String content) async {
    final base = title.trim().isEmpty ? 'Untitled note' : title.trim();
    var copyTitle = '$base (my version)';
    if (copyTitle.length > 120) copyTitle = copyTitle.substring(0, 120);
    final id = await _actions.create(widget.padId);
    await _actions.save(
      widget.padId,
      id,
      title: copyTitle,
      content: content,
    );
  }

  void _keepMine() {
    setState(() => _remote = null);
    _markDirty();
  }

  void _useTheirs() {
    final remote = _remote;
    if (remote == null) return;
    setState(() => _adopt(remote));
  }

  Future<void> _keepBoth() async {
    final remote = _remote;
    if (remote == null) return;
    final messenger = ScaffoldMessenger.of(context);
    final title = _title.text;
    final content = _content.text;
    setState(() => _adopt(remote));
    try {
      await _saveCopy(title, content);
      messenger.showSnackBar(
        const SnackBar(content: Text('Your version was saved as a new note')),
      );
    } on AppFailure catch (f) {
      messenger.showSnackBar(SnackBar(content: Text(f.message)));
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not save your version.')),
      );
    }
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
    if (!_dirty || !mounted || _hasConflict) return;
    if (_saving) {
      // A save is in flight; try again shortly.
      _debounce = Timer(const Duration(milliseconds: 300), _save);
      return;
    }

    final title = _title.text;
    final content = _content.text;
    _known.remember(_fp(title, content)); // before the echo can arrive
    _dirty = false;
    _saving = true;
    _setStatus(NoteSaveStatus.saving);

    try {
      final outcome = await _actions.save(
        widget.padId,
        widget.note.id,
        title: title,
        content: content,
      );
      _saving = false;
      _error = null;
      if (_dirty) {
        _setStatus(NoteSaveStatus.unsaved);
      } else {
        _setStatus(
          outcome == SaveOutcome.synced
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

  void _format(MarkdownAction action) {
    if (_mode != _Mode.edit) return;
    _content.value = MarkdownFormatter.apply(_content.value, action);
    _contentFocus.requestFocus();
    _markDirty();
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
        title: const Text('Delete note?'),
        content: const Text('This note will be permanently deleted.'),
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

    // Nothing left to autosave or to resolve.
    _debounce?.cancel();
    _dirty = false;
    _remote = null;

    final messenger = ScaffoldMessenger.of(context);
    final actions = _actions;
    final padId = widget.padId;
    final noteId = widget.note.id;

    widget.onClosed(); // leave first so the editor never shows a deleted note
    try {
      await actions.delete(padId, noteId);
      messenger.showSnackBar(const SnackBar(content: Text('Note deleted')));
    } on AppFailure catch (f) {
      messenger.showSnackBar(SnackBar(content: Text(f.message)));
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not delete the note.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final editing = _mode == _Mode.edit;
    final untouched =
        widget.note.title.isEmpty && widget.note.content.isEmpty;

    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.keyB, control: true): () =>
            _format(MarkdownAction.bold),
        const SingleActivator(LogicalKeyboardKey.keyB, meta: true): () =>
            _format(MarkdownAction.bold),
        const SingleActivator(LogicalKeyboardKey.keyI, control: true): () =>
            _format(MarkdownAction.italic),
        const SingleActivator(LogicalKeyboardKey.keyI, meta: true): () =>
            _format(MarkdownAction.italic),
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
                    tooltip: 'All notes',
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
                      value: _Mode.preview,
                      icon: Icon(Icons.visibility_outlined, size: 16),
                      tooltip: 'Preview',
                    ),
                  ],
                  selected: {_mode},
                  onSelectionChanged: (s) => setState(() => _mode = s.first),
                ),
                IconButton(
                  tooltip: 'Delete note',
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
          if (_hasConflict)
            ConflictBanner(
              what: 'note',
              onKeepMine: _keepMine,
              onUseTheirs: _useTheirs,
              onKeepBoth: _keepBoth,
            ),
          if (editing) MarkdownToolbar(onAction: _format),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _title,
              autofocus: untouched,
              maxLines: 1,
              textInputAction: TextInputAction.next,
              inputFormatters: [LengthLimitingTextInputFormatter(120)],
              onChanged: (_) => _markDirty(),
              onSubmitted: (_) => _contentFocus.requestFocus(),
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
              decoration: const InputDecoration.collapsed(
                hintText: 'Untitled note',
                hintStyle: TextStyle(color: AppColors.textMuted),
              ),
            ),
          ),
          Expanded(
            child: editing
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: TextField(
                      controller: _content,
                      focusNode: _contentFocus,
                      expands: true,
                      maxLines: null,
                      minLines: null,
                      textAlignVertical: TextAlignVertical.top,
                      keyboardType: TextInputType.multiline,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(100000),
                      ],
                      onChanged: (_) => _markDirty(),
                      style: AppTheme.mono.copyWith(
                        fontSize: 14,
                        height: 1.55,
                        color: AppColors.text,
                      ),
                      decoration: InputDecoration.collapsed(
                        hintText: 'Write in Markdown...',
                        hintStyle: AppTheme.mono.copyWith(
                          fontSize: 14,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  )
                : NotePreview(content: _content.text),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Text(
              'Last edited ${DateFormatter.relative(widget.note.updatedAt)}'
              ' · ${_content.text.length} chars',
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