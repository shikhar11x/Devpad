import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/loading_state.dart';
import '../../../pads/presentation/pad_section.dart';
import '../../../pads/presentation/providers/pad_providers.dart';
import '../../domain/entities/note.dart';
import '../providers/note_actions.dart';
import '../providers/note_providers.dart';
import 'note_editor.dart';
import 'notes_list_pane.dart';

/// The Notes tab of a Pad. Wide: list + editor side by side.
/// Narrow: the list, and the editor as a full page when a note is open.
class NotesSection extends ConsumerStatefulWidget {
  const NotesSection({super.key, required this.padId, this.selectedNoteId});

  final String padId;
  final String? selectedNoteId;

  @override
  ConsumerState<NotesSection> createState() => _NotesSectionState();
}

class _NotesSectionState extends ConsumerState<NotesSection> {
  static const _wideBreakpoint = 640.0;

  final _search = TextEditingController();
  String _query = '';
  bool _creating = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  String _noteUrl(String? noteId) => AppRoutes.padDetail(
        widget.padId,
        section: PadSection.notes.key,
        note: noteId,
      );

  void _open(Note note) => context.go(_noteUrl(note.id));

  void _closeEditor() => context.go(_noteUrl(null));

  void _onQueryChanged(String value) => setState(() => _query = value);

  Future<void> _create() async {
    if (_creating) return;
    setState(() => _creating = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final id = await ref.read(noteActionsProvider).create(widget.padId);
      if (!mounted) return;
      _search.clear();
      _query = '';
      context.go(_noteUrl(id));
    } on AppFailure catch (f) {
      messenger.showSnackBar(SnackBar(content: Text(f.message)));
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not create the note.')),
      );
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(notesProvider(widget.padId));
    return notesAsync.when(
      loading: () => const LoadingState(),
      error: (e, _) => ErrorState(
        message: padErrorMessage(e),
        onRetry: () => ref.invalidate(notesProvider(widget.padId)),
      ),
      data: _buildData,
    );
  }

  Widget _buildData(List<Note> notes) {
    final q = _query.trim().toLowerCase();
    final visible = notes
        .where((n) =>
            q.isEmpty ||
            n.title.toLowerCase().contains(q) ||
            n.content.toLowerCase().contains(q))
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    final selectedId = widget.selectedNoteId;
    final selected = selectedId == null
        ? null
        : notes.where((n) => n.id == selectedId).firstOrNull;

    final list = NotesListPane(
      notes: visible,
      totalCount: notes.length,
      selectedId: selectedId,
      searchController: _search,
      onQueryChanged: _onQueryChanged,
      onSelect: _open,
      onCreate: _create,
      creating: _creating,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= _wideBreakpoint;

        Widget detail({required bool showBack}) {
          if (selectedId == null) {
            return EmptyState(
              icon: Icons.sticky_note_2_outlined,
              title: 'Select a note',
              message: 'Choose a note from the list, or create a new one.',
              actionLabel: 'New note',
              onAction: _creating ? null : _create,
            );
          }
          if (selected == null) {
            return EmptyState(
              icon: Icons.search_off,
              title: 'Note not found',
              message: 'It may have been deleted.',
              actionLabel: 'Back to notes',
              onAction: _closeEditor,
            );
          }
          return NoteEditor(
            key: ValueKey(selected.id),
            padId: widget.padId,
            note: selected,
            showBack: showBack,
            onClosed: _closeEditor,
          );
        }

        if (wide) {
          return Row(
            children: [
              SizedBox(width: 280, child: list),
              const VerticalDivider(width: 1),
              Expanded(child: detail(showBack: false)),
            ],
          );
        }
        return selectedId == null ? list : detail(showBack: true);
      },
    );
  }
}