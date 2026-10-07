/// Remembers the versions of a document this editor has loaded or sent.
/// A snapshot matching one of them is our own save echoing back; anything
/// else came from somewhere else.
class EditFingerprints {
  EditFingerprints({this.capacity = 40});

  final int capacity;
  final List<String> _items = [];

  static String of(List<String> parts) => parts.join('\u0000');

  void remember(String fingerprint) {
    _items.remove(fingerprint);
    _items.add(fingerprint);
    if (_items.length > capacity) _items.removeAt(0);
  }

  bool contains(String fingerprint) => _items.contains(fingerprint);
}