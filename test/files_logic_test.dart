import 'package:devpad/core/utils/file_format.dart';
import 'package:devpad/features/files/domain/file_rules.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formatBytes', () {
    expect(formatBytes(512), '512 B');
    expect(formatBytes(1536), '1.5 KB');
    expect(formatBytes(5 * 1024 * 1024), '5.0 MB');
  });

  test('expiryLabel', () {
    final now = DateTime(2026, 1, 10, 12);
    expect(expiryLabel(DateTime(2026, 1, 13, 13), now: now), 'Expires in 3d');
    expect(expiryLabel(DateTime(2026, 1, 10, 17), now: now), 'Expires in 5h');
    expect(expiryLabel(DateTime(2026, 1, 9), now: now), 'Expired');
  });

  test('FileRules.extensionOf accepts only images and pdf', () {
    expect(FileRules.extensionOf('Diagram.PNG'), 'png');
    expect(FileRules.extensionOf('spec.pdf'), 'pdf');
    expect(FileRules.extensionOf('run.exe'), isNull);
    expect(FileRules.extensionOf('noext'), isNull);
  });
}