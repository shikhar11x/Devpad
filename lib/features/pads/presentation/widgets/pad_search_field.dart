import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      onChanged: (v) => ref.read(padSearchQueryProvider.notifier).set(v),
      decoration: InputDecoration(
        hintText: 'Search pads',
        prefixIcon: const Icon(Icons.search, size: 18),
        suffixIcon: query.isEmpty
            ? null
            : IconButton(
                tooltip: 'Clear',
                icon: const Icon(Icons.close, size: 16),
                onPressed: () =>
                    ref.read(padSearchQueryProvider.notifier).set(''),
              ),
      ),
    );
  }
}