import 'package:flutter/material.dart';

import '../domain/entities/resource_link.dart';

IconData categoryIcon(LinkCategory category) => switch (category) {
      LinkCategory.docs => Icons.menu_book_outlined,
      LinkCategory.repo => Icons.account_tree_outlined,
      LinkCategory.design => Icons.palette_outlined,
      LinkCategory.video => Icons.play_circle_outline,
      LinkCategory.api => Icons.api,
      LinkCategory.tool => Icons.build_outlined,
      LinkCategory.other => Icons.link,
    };