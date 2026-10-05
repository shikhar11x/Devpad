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
import '../../domain/entities/snippet.dart';
import '../code_languages.dart';
import '../providers/snippet_actions.dart';
import '../providers/snippet_providers.dart';
import 'snippet_editor.dart';
import 'snippets_list_pane.dart';

/// The Code tab of a Pad. Wide: list + editor side by side.
/// Narrow: the list, and the editor as a full page when a snippet is open.
class SnippetsSection extends ConsumerStatefulWidget {
  const SnippetsSection({
    super.key,
    required this.padId,
    this.selectedSnippetId,
  });

  final String padId;
  final String? selectedSnippetId;

  @override
  ConsumerState<SnippetsSection> createState() => _SnippetsSectionState();
}

class _SnippetsSectionState extends ConsumerState<SnippetsSection> {
  static const _wideBreakpoint = 640.0;

  final _search = TextEditingController();
  String _query = '';
  bool _creating = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  String _url(String? snippetId) => AppRoutes.padDetail(
        widget.padId,
        section: PadSection.code.key,
        snippet: snippetId,
      );

  void _open(Snippet snippet) => context.go(_url(snippet.id));

  void _closeEditor() => context.go(_url(null));

  void _onQueryChanged(String value) => setState(() => _query = value);

  Future<void> _create() async {
    if (_creating) return;
    setState(() => _creating = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final id = await ref
          .read(snippetActionsProvider)
          .create(widget.padId, language: defaultCodeLanguage);
      if (!mounted) return;
      _search.clear();
      _query = '';
      context.go(_url(id));
    } on AppFailure catch (f) {
      messenger.showSnackBar(SnackBar(content: Text(f.message)));
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not create the snippet.')),
      );
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(snippetsProvider(widget.padId));
    return async.when(
      loading: () => const LoadingState(),
      error: (e, _) => ErrorState(
        message: padErrorMessage(e),
        onRetry: () => ref.invalidate(snippetsProvider(widget.padId)),
      ),
      data: _buildData,
    );
  }

  Widget _buildData(List<Snippet> snippets) {
    final q = _query.trim().toLowerCase();
    final visible = snippets
        .where((s) =>
            q.isEmpty ||
            s.title.toLowerCase().contains(q) ||
            s.code.toLowerCase().contains(q) ||
            languageLabel(s.language).toLowerCase().contains(q))
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    final selectedId = widget.selectedSnippetId;
    final selected = selectedId == null
        ? null
        : snippets.where((s) => s.id == selectedId).firstOrNull;

    final list = SnippetsListPane(
      snippets: visible,
      totalCount: snippets.length,
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
              icon: Icons.code,
              title: 'Select a snippet',
              message: 'Choose a snippet from the list, or create a new one.',
              actionLabel: 'New snippet',
              onAction: _creating ? null : _create,
            );
          }
          if (selected == null) {
            return EmptyState(
              icon: Icons.search_off,
              title: 'Snippet not found',
              message: 'It may have been deleted.',
              actionLabel: 'Back to snippets',
              onAction: _closeEditor,
            );
          }
          return SnippetEditor(
            key: ValueKey(selected.id),
            padId: widget.padId,
            snippet: selected,
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