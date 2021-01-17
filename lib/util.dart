import 'package:cloud_firestore/cloud_firestore.dart';

String convertTimeStampToString(Timestamp timestamp) {
  return "${timestamp.toDate().day}/${timestamp.toDate().month}/${timestamp.toDate().year}";
}
