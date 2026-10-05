import 'package:flutter/material.dart';

import '../../../../core/widgets/empty_state.dart';
import '../../domain/entities/snippet.dart';
import 'snippet_list_tile.dart';

/// Search box, "new snippet" button and the list of snippets.
class SnippetsListPane extends StatelessWidget {
  const SnippetsListPane({
    super.key,
    required this.snippets,
    required this.totalCount,
    required this.selectedId,
    required this.searchController,
    required this.onQueryChanged,
    required this.onSelect,
    required this.onCreate,
    required this.creating,
  });

  /// Snippets after search filtering and sorting.
  final List<Snippet> snippets;

  /// Number of snippets before filtering (0 = the Pad has none at all).
  final int totalCount;
  final String? selectedId;
  final TextEditingController searchController;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<Snippet> onSelect;
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
                      hintText: 'Search snippets',
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
                tooltip: 'New snippet',
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
        icon: Icons.code,
        title: 'No snippets yet.',
        message: 'Save reusable code, commands and configs for this Pad.',
        actionLabel: 'Create your first snippet →',
        onAction: creating ? null : onCreate,
      );
    }
    if (snippets.isEmpty) {
      return const EmptyState(
        icon: Icons.search_off,
        title: 'No matching snippets',
        message: 'Try a different search.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
      itemCount: snippets.length,
      separatorBuilder: (_, _) => const SizedBox(height: 2),
      itemBuilder: (context, i) {
        final snippet = snippets[i];
        return SnippetListTile(
          snippet: snippet,
          selected: snippet.id == selectedId,
          onTap: () => onSelect(snippet),
        );
      },
    );
  }
}