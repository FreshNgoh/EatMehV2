import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatmehv2/core/constants/firebase_constants.dart';
import 'package:eatmehv2/data/models/chat/chat_room_model.dart';
import 'package:eatmehv2/data/models/chat/message_model.dart';

class ChatRoomService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<ChatRoomModel> get _chatRoomsCollection {
    return _firestore
        .collection(FirebaseConstants.chatRoomsCollection)
        .withConverter<ChatRoomModel>(
          fromFirestore:
              (snapshot, _) => ChatRoomModel.fromMap(snapshot.data()!),
          toFirestore: (application, _) => application.toMap(),
        );
  }

  // create unique room id
  String _generateRoomId(String uid1, String uid2) {
    final ids = [uid1, uid2]..sort();
    return ids.join('_');
  }

  // Send a new message
  Future<void> sendMessage(
    String senderUid,
    String receiverUid,
    String message,
  ) async {
    final roomId = _generateRoomId(senderUid, receiverUid);
    final chatRoomRef = _chatRoomsCollection.doc(roomId);

    final newMessage = MessageModel(
      senderUid: senderUid,
      receiverUid: receiverUid,
      message: message,
      timestamp: Timestamp.now(),
      status: 'Sent',
    );

    // Create or update chat room metadata
    await chatRoomRef.set(
      ChatRoomModel(
        participants: [senderUid, receiverUid],
        lastMessage: message,
        lastUpdated: Timestamp.now(),
      ),
      SetOptions(merge: true),
    );

    // Add message to subcollection
    await chatRoomRef.collection('messages').add(newMessage.toMap());
  }

  // Get real time messages
  Stream<List<MessageModel>> getMessages(String senderUid, String receiverUid) {
    final roomId = _generateRoomId(senderUid, receiverUid);

    return _chatRoomsCollection
        .doc(roomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => MessageModel.fromMap(doc.data()))
                  .toList(),
        );
  }
}
