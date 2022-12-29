import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');
  CollectionReference userPostCollection =
      FirebaseFirestore.instance.collection('userPost');
  CollectionReference userProfileCollection =
      FirebaseFirestore.instance.collection('userProfile');

  Stream<QuerySnapshot<Map<String, dynamic>>> getCommentStream(
      {required String postId}) {
    return userPostCollection.doc(postId).collection('comments').snapshots();
  }
}
