import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> updateItineraryPartial(
  String userId,
  String itineraryId,
  Map<String, dynamic> partialData,
) async {
  final docRef = FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('itineraries')
      .doc(itineraryId);

  try {
    await docRef.update(partialData);
    print('更新成功：$itineraryId');
  } on FirebaseException catch (e) {
    print('Firestore 更新失敗: ${e.code} ${e.message}');
    if (e.code == 'not-found') {
      print('文件不存在，無法更新');
    }
  }
}
