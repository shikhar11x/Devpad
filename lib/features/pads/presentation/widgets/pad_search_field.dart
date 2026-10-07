import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../providers/pad_providers.dart';

class PadSearchField extends ConsumerStatefulWidget {
  const PadSearchField({super.key});

  @override
  ConsumerState<PadSearchField> createState() => _PadSearchFieldState();
}

class _PadSearchFieldState extends ConsumerState<PadSearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: ref.read(padSearchQueryProvider));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(padSearchQueryProvider);

    // Keep the box in sync if the query is changed elsewhere.
    ref.listen<String>(padSearchQueryProvider, (_, next) {
      if (_controller.text != next) _controller.text = next;
    });

    return TextField(
      controller: _controller,
      style: AppTheme.mono.copyWith(fontSize: 12, color: AppColors.text),
      onChanged: (v) => ref.read(padSearchQueryProvider.notifier).set(v),
      decoration: InputDecoration(
        hintText: 'FILTER // SEARCH PADS...',
        hintStyle: AppTheme.mono.copyWith(fontSize: 11, color: AppColors.textDim),
        prefixIcon: const Icon(Icons.search, size: 17, color: AppColors.textMuted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        suffixIcon: query.isEmpty
            ? null
            : IconButton(
                tooltip: 'Clear',
                icon: const Icon(Icons.close, size: 15),
                color: AppColors.textDim,
                onPressed: () =>
                    ref.read(padSearchQueryProvider.notifier).set(''),
              ),
      ),
    );
  }
}