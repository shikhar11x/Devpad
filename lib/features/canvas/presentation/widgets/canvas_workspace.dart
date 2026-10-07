import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/errors/app_failure.dart';
// Shared with Notes for now; candidate to move into core/widgets later.
import '../../../notes/presentation/widgets/note_save_indicator.dart';
import '../../domain/entities/canvas_element.dart';
import '../../domain/repositories/canvas_repository.dart';
import '../canvas_controller.dart';
import '../canvas_tools.dart';
import '../providers/canvas_actions.dart';
import 'canvas_text_dialog.dart';
import 'canvas_toolbar.dart';
import 'canvas_view.dart';

/// Toolbar + drawing surface with autosave and keyboard shortcuts.
/// Edits made on another device while this is open are not merged in
/// (last write wins).
class CanvasWorkspace extends ConsumerStatefulWidget {
  const CanvasWorkspace({
    super.key,
    required this.padId,
    required this.initialElements,
  });

  final String padId;
  final List<CanvasElement> initialElements;

  @override
  ConsumerState<CanvasWorkspace> createState() => _CanvasWorkspaceState();
}

class _CanvasWorkspaceState extends ConsumerState<CanvasWorkspace> {
  static const _debounceDuration = Duration(seconds: 1);

  late final CanvasController _controller;
  late final CanvasActions _actions;
  final _focus = FocusNode();

  Timer? _debounce;
  bool _dirty = false;
  bool _saving = false;
  NoteSaveStatus _status = NoteSaveStatus.saved;
  String? _error;

  @override
  void initState() {
    super.initState();
    _actions = ref.read(canvasActionsProvider);
    _controller = CanvasController(initial: widget.initialElements)
      ..onContentChanged = _markDirty
      ..onTextRequested = _askForText;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    // Don't lose the last edits when leaving the tab. Best effort.
    if (_dirty) {
      unawaited(
        _actions
            .save(widget.padId, _controller.elements)
            .then<void>((_) {}, onError: (_) {}),
      );
    }
    _controller.dispose();
    _focus.dispose();
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

    final snapshot = _controller.elements;
    _dirty = false;
    _saving = true;
    _setStatus(NoteSaveStatus.saving);

    try {
      final outcome = await _actions.save(widget.padId, snapshot);
      _saving = false;
      _error = null;
      if (_dirty) {
        _setStatus(NoteSaveStatus.unsaved);
      } else {
        _setStatus(
          outcome == CanvasSaveOutcome.synced
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

  Future<void> _askForText(Offset world) async {
    final text = await showCanvasTextDialog(context, title: 'Add text');
    if (!mounted) return;
    if (text != null) _controller.addText(world, text);
    _focus.requestFocus();
  }

  Future<void> _editText() async {
    final selected = _controller.selected;
    if (selected == null || selected.type != CanvasElementType.text) return;
    final text = await showCanvasTextDialog(
      context,
      title: 'Edit text',
      initial: selected.text,
    );
    if (!mounted) return;
    if (text != null) _controller.updateText(selected.id, text);
    _focus.requestFocus();
  }

  Map<ShortcutActivator, VoidCallback> _bindings() {
    final c = _controller;
    final map = <ShortcutActivator, VoidCallback>{
      const SingleActivator(LogicalKeyboardKey.delete): c.deleteSelected,
      const SingleActivator(LogicalKeyboardKey.backspace): c.deleteSelected,
      const SingleActivator(LogicalKeyboardKey.escape): () => c.select(null),
    };
    for (final tool in CanvasTool.values) {
      map[SingleActivator(tool.key)] = () => c.setTool(tool);
    }
    for (final meta in const [false, true]) {
      map[SingleActivator(LogicalKeyboardKey.keyZ,
          control: !meta, meta: meta)] = c.undo;
      map[SingleActivator(LogicalKeyboardKey.keyZ,
          control: !meta, meta: meta, shift: true)] = c.redo;
      map[SingleActivator(LogicalKeyboardKey.keyY,
          control: !meta, meta: meta)] = c.redo;
      map[SingleActivator(LogicalKeyboardKey.keyS,
          control: !meta, meta: meta)] = _save;
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: _bindings(),
      child: Focus(
        focusNode: _focus,
        autofocus: true,
        child: Column(
          children: [
            DecoratedBox(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: CanvasToolbar(
                      controller: _controller,
                      onEditText: _editText,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: NoteSaveIndicator(
                      status: _status,
                      errorMessage: _error,
                      onRetry: _save,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CanvasView(
                controller: _controller,
                onActivated: _focus.requestFocus,
              ),
            ),
          ],
        ),
      ),
    );
  }
}