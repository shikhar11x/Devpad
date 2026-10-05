/// User-presentable error. The data layer converts SDK exceptions into this.
class AppFailure implements Exception {
  const AppFailure(this.message, {this.isCancelled = false});

  final String message;

  /// True when the user dismissed a flow (e.g. closed the Google popup).
  final bool isCancelled;

  @override
  String toString() => 'AppFailure($message)';
}