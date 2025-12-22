import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat_2/dash_chat_2.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

const String CHAT_ROOM_ID = "global_chat";

Future<void> sendChatMessage(ChatMessage message) async {
  final now = DateTime.now();

  await _firestore
      .collection('chat_rooms')
      .doc(CHAT_ROOM_ID)
      .collection('messages')
      .add({
    'text': message.text,
    'senderId': message.user.id,
    'senderName': message.user.firstName,
    'senderPic': message.user.profileImage,
    'createdAt': FieldValue.serverTimestamp(),
    'createdAtLocal': now.millisecondsSinceEpoch,
  });
}

Stream<List<ChatMessage>> chatStream() {
  return _firestore
      .collection('chat_rooms')
      .doc(CHAT_ROOM_ID)
      .collection('messages')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      final d = doc.data();

      return ChatMessage(
        text: d['text'] ?? '',
        createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        user: ChatUser(
          id: d['senderId'] ?? '',
          firstName: d['senderName'] ?? '',
          profileImage: d['senderPic'],
        ),
      );
    }).toList();
  });
}
