abstract final class Validators {
  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? email(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return 'Email is required';
    if (!_email.hasMatch(value)) return 'Enter a valid email';
    return null;
  }

  static String? requiredPassword(String? v) =>
      (v == null || v.isEmpty) ? 'Password is required' : null;

  static String? newPassword(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 8) return 'Use at least 8 characters';
    return null;
  }

  static String? Function(String?) matches(String Function() other) {
    return (v) => v == other() ? null : 'Passwords do not match';
  }
}