import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/loading_state.dart';
import '../../../pads/presentation/providers/pad_providers.dart';
import '../providers/canvas_providers.dart';
import 'canvas_workspace.dart';

/// The Canvas tab of a Pad: loads the saved drawing, then opens the editor.
class CanvasSection extends ConsumerWidget {
  const CanvasSection({super.key, required this.padId});

  final String padId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(canvasElementsProvider(padId));
    return async.when(
      loading: () => const LoadingState(message: 'Loading canvas...'),
      error: (e, _) => ErrorState(
        message: padErrorMessage(e),
        onRetry: () => ref.invalidate(canvasElementsProvider(padId)),
      ),
      data: (elements) => CanvasWorkspace(
        key: ValueKey(padId),
        padId: padId,
        initialElements: elements,
      ),
    );
  }
}