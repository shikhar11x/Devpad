import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/errors/app_failure.dart';
import '../../domain/entities/pad.dart';
import '../providers/pad_actions.dart';
import 'pad_form_dialog.dart';

enum PadMenuAction { edit, archive, delete }

Future<bool?> _confirmDelete(BuildContext context, Pad pad) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radius),
        side: const BorderSide(color: AppColors.border),
      ),
      title: const Text('Delete Pad?'),
      content: Text(
        '"${pad.title}" will be permanently deleted. This cannot be undone.\n\n'
        'Tip: archive it instead if you might need it later.',
      ),
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
}

/// Runs a Pad menu action and reports the outcome in a SnackBar.
Future<void> runPadMenuAction(
  BuildContext context,
  WidgetRef ref,
  Pad pad,
  PadMenuAction action, {
  bool leaveOnDelete = false,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final router = GoRouter.of(context);
  final actions = ref.read(padActionsProvider);

  void say(String text) =>
      messenger.showSnackBar(SnackBar(content: Text(text)));

  if (action == PadMenuAction.edit) {
    await showPadFormDialog(context, pad: pad);
    return;
  }

  if (action == PadMenuAction.archive) {
    try {
      await actions.setArchived(pad.id, !pad.archived);
      say(pad.archived ? 'Pad restored' : 'Pad archived');
    } on AppFailure catch (f) {
      say(f.message);
    }
    return;
  }

  final confirmed = await _confirmDelete(context, pad);
  if (confirmed != true) return;
  try {
    await actions.delete(pad.id);
    if (leaveOnDelete) router.go(AppRoutes.pads);
    say('Pad deleted');
  } on AppFailure catch (f) {
    say(f.message);
  }
}

/// "..." menu with Rename/edit, Archive/Restore and Delete.
class PadMenuButton extends ConsumerWidget {
  const PadMenuButton({super.key, required this.pad, this.leaveOnDelete = false});

  final Pad pad;

  /// Navigate back to the Pads list after deleting (used on the detail page).
  final bool leaveOnDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<PadMenuAction>(
      tooltip: 'Pad options',
      color: AppColors.surfaceHigh,
      icon: const Icon(Icons.more_vert, size: 18),
      onSelected: (action) => runPadMenuAction(
        context,
        ref,
        pad,
        action,
        leaveOnDelete: leaveOnDelete,
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: PadMenuAction.edit,
          child: Row(children: [
            Icon(Icons.edit_outlined, size: 18),
            SizedBox(width: 8),
            Text('Rename / edit'),
          ]),
        ),
        PopupMenuItem(
          value: PadMenuAction.archive,
          child: Row(children: [
            Icon(
              pad.archived ? Icons.unarchive_outlined : Icons.archive_outlined,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(pad.archived ? 'Restore' : 'Archive'),
          ]),
        ),
        const PopupMenuItem(
          value: PadMenuAction.delete,
          child: Row(children: [
            Icon(Icons.delete_outline, size: 18, color: AppColors.error),
            SizedBox(width: 8),
            Text('Delete', style: TextStyle(color: AppColors.error)),
          ]),
        ),
      ],
    );
  }
}