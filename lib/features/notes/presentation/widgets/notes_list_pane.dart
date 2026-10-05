import 'package:flutter/material.dart';

import '../../../../core/widgets/empty_state.dart';
import '../../domain/entities/note.dart';
import 'note_list_tile.dart';

/// Search box, "new note" button and the list of notes.
class NotesListPane extends StatelessWidget {
  const NotesListPane({
    super.key,
    required this.notes,
    required this.totalCount,
    required this.selectedId,
    required this.searchController,
    required this.onQueryChanged,
    required this.onSelect,
    required this.onCreate,
    required this.creating,
  });

  /// Notes after search filtering and sorting.
  final List<Note> notes;

  /// Number of notes before filtering (0 means the Pad has no notes at all).
  final int totalCount;
  final String? selectedId;
  final TextEditingController searchController;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<Note> onSelect;
  final VoidCallback onCreate;
  final bool creating;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 4, 8),
          child: Row(
            children: [
              Expanded(
                child: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: searchController,
                  builder: (context, value, _) => TextField(
                    controller: searchController,
                    onChanged: onQueryChanged,
                    decoration: InputDecoration(
                      hintText: 'Search notes',
                      prefixIcon: const Icon(Icons.search, size: 18),
                      suffixIcon: value.text.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Clear',
                              icon: const Icon(Icons.close, size: 16),
                              onPressed: () {
                                searchController.clear();
                                onQueryChanged('');
                              },
                            ),
                    ),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'New note',
                onPressed: creating ? null : onCreate,
                icon: creating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add),
              ),
            ],
          ),
        ),
        Expanded(child: _content()),
      ],
    );
  }

  Widget _content() {
    if (totalCount == 0) {
      return EmptyState(
        icon: Icons.sticky_note_2_outlined,
        title: 'No notes yet.',
        message: 'Capture ideas, decisions and documentation for this Pad.',
        actionLabel: 'Create your first note →',
        onAction: creating ? null : onCreate,
      );
    }
    if (notes.isEmpty) {
      return const EmptyState(
        icon: Icons.search_off,
        title: 'No matching notes',
        message: 'Try a different search.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
      itemCount: notes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 2),
      itemBuilder: (context, i) {
        final note = notes[i];
        return NoteListTile(
          note: note,
          selected: note.id == selectedId,
          onTap: () => onSelect(note),
        );
      },
    );
  }
}