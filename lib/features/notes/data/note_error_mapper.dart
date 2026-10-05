import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/errors/app_failure.dart';
import '../../pads/data/pad_error_mapper.dart';

AppFailure mapNoteException(Object error) {
  if (error is FirebaseException && error.code == 'not-found') {
    return const AppFailure('That note no longer exists.');
  }
  return mapPadException(error);
}