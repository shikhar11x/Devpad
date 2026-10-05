import 'package:cloud_firestore/cloud_firestore.dart';

/// Enables Firestore's local cache so recently loaded data is readable
/// offline and edits made offline sync later. Call once, right after
/// Firebase.initializeApp and before any other Firestore use.
void configureFirestore() {
  try {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
    );
  } catch (_) {
    // Settings can only be changed before first use (e.g. after hot restart).
  }
}