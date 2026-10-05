import 'package:devpad/core/utils/web_url.dart';
import 'package:devpad/features/links/domain/entities/resource_link.dart';
import 'package:devpad/features/links/presentation/link_filters.dart';
import 'package:flutter_test/flutter_test.dart';

ResourceLink _l(
  String id, {
  LinkCategory category = LinkCategory.other,
  DateTime? created,
}) =>
    ResourceLink(
      id: id,
      padId: 'p1',
      title: id,
      url: 'https://example.com/$id',
      category: category,
      createdAt: created ?? DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

void main() {
  group('normalizeWebUrl', () {
    test('adds https when the scheme is missing', () {
      expect(normalizeWebUrl('flutter.dev'), 'https://flutter.dev');
      expect(
        normalizeWebUrl('  docs.flutter.dev/get-started '),
        'https://docs.flutter.dev/get-started',
      );
    });

    test('keeps valid http and https URLs', () {
      expect(normalizeWebUrl('https://a.com/x?y=1'), 'https://a.com/x?y=1');
      expect(normalizeWebUrl('http://localhost:3000'), 'http://localhost:3000');
    });

    test('rejects other schemes, spaces and bare words', () {
      expect(normalizeWebUrl(''), isNull);
      expect(normalizeWebUrl('example'), isNull);
      expect(normalizeWebUrl('ftp://example.com'), isNull);
      expect(normalizeWebUrl('javascript:alert(1)'), isNull);
      expect(normalizeWebUrl('two words.com'), isNull);
    });

    test('hostOf returns the host', () {
      expect(hostOf('https://docs.flutter.dev/x'), 'docs.flutter.dev');
    });
  });

  group('link filters', () {
    test('filterLinks filters by category', () {
      final links = [
        _l('a', category: LinkCategory.docs),
        _l('b', category: LinkCategory.repo),
        _l('c', category: LinkCategory.docs),
      ];

      expect(
        filterLinks(links, category: LinkCategory.docs).map((l) => l.id),
        ['a', 'c'],
      );
      expect(filterLinks(links), hasLength(3));
    });

    test('sortLinks puts the newest first', () {
      final links = [
        _l('old', created: DateTime(2026, 1, 1)),
        _l('new', created: DateTime(2026, 3, 1)),
        _l('mid', created: DateTime(2026, 2, 1)),
      ];

      expect(sortLinks(links).map((l) => l.id), ['new', 'mid', 'old']);
    });
  });
}