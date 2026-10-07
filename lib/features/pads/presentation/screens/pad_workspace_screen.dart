import 'package:flutter/material.dart';
import '../../../links/presentation/widgets/links_section.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../canvas/presentation/widgets/canvas_section.dart';
import '../../../tasks/presentation/widgets/tasks_section.dart';
import '../../../../app/router/app_router.dart';
import '../../../../core/widgets/coming_soon.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/loading_state.dart';
import '../../../notes/presentation/widgets/notes_section.dart';
import '../../../snippets/presentation/widgets/snippets_section.dart';
import '../../../files/presentation/widgets/files_section.dart';
import '../../domain/entities/pad.dart';
import '../pad_section.dart';
import '../providers/pad_actions.dart';
import '../providers/pad_providers.dart';
import '../widgets/pad_header.dart';
import '../widgets/pad_overview.dart';
import '../widgets/pad_section_bar.dart';

/// A single Pad with its section bar. The selected [section] and the open
/// note/snippet come from the URL, so they survive refresh and back.
class PadWorkspaceScreen extends ConsumerStatefulWidget {
  const PadWorkspaceScreen({
    super.key,
    required this.padId,
    required this.section,
    this.noteId,
    this.snippetId,
  });

  final String padId;
  final PadSection section;
  final String? noteId;
  final String? snippetId;

  @override
  ConsumerState<PadWorkspaceScreen> createState() =>
      _PadWorkspaceScreenState();
}

class _PadWorkspaceScreenState extends ConsumerState<PadWorkspaceScreen> {
  bool _markedOpened = false;

  void _markOpenedOnce(Pad pad) {
    if (_markedOpened) return;
    _markedOpened = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(padActionsProvider).markOpened(pad.id);
    });
  }

  void _select(PadSection section) {
    context.go(AppRoutes.padDetail(widget.padId, section: section.key));
  }

  @override
  Widget build(BuildContext context) {
    final padsAsync = ref.watch(padsProvider);
    final pad = ref.watch(padByIdProvider(widget.padId));

    if (pad == null) {
      if (!padsAsync.hasValue) {
        if (padsAsync.hasError) {
          return ErrorState(
            message: padErrorMessage(padsAsync.error!),
            onRetry: () => ref.invalidate(padsProvider),
          );
        }
        return const LoadingState();
      }
      return EmptyState(
        icon: Icons.search_off,
        title: 'Pad not found',
        message: 'It may have been deleted.',
        actionLabel: 'Back to Pads',
        onAction: () => context.go(AppRoutes.pads),
      );
    }

    _markOpenedOnce(pad);

    return Column(
      children: [
        PadHeader(pad: pad),
        PadSectionBar(selected: widget.section, onSelected: _select),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            child: KeyedSubtree(
              key: ValueKey(widget.section),
              child: _body(pad, widget.section),
            ),
          ),
        ),
      ],
    );
  }

  /// Each later stage replaces one placeholder here with the real feature.
    /// Every section is implemented.
  Widget _body(Pad pad, PadSection section) {
    switch (section) {
      case PadSection.overview:
        return PadOverview(pad: pad);
      case PadSection.notes:
        return NotesSection(padId: pad.id, selectedNoteId: widget.noteId);
      case PadSection.canvas:
        return CanvasSection(padId: pad.id);
      case PadSection.code:
        return SnippetsSection(
          padId: pad.id,
          selectedSnippetId: widget.snippetId,
        );
      case PadSection.tasks:
        return TasksSection(padId: pad.id);
      case PadSection.links:
        return LinksSection(padId: pad.id);
      case PadSection.files:
        return FilesSection(padId: pad.id);
    }
  }
}