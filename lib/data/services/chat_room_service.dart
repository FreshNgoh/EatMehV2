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
    return uid1.hashCode <= uid2.hashCode ? '${uid1}_$uid2' : '${uid2}_$uid1';
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
      id: chatRoomRef.id,
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
        lastSenderUid: senderUid,
      ),
      SetOptions(merge: true),
    );

    // Add message to subcollection
    await chatRoomRef.collection('messages').add(newMessage.toMap());
  }

  // Get real time messages
  Stream<List<MessageModel>> getMessages(
    String senderUid,
    String receiverUid,
  ) async* {
    final roomId = _generateRoomId(senderUid, receiverUid);
    final chatRoomRef = _chatRoomsCollection.doc(roomId);

    // Check if chat room exists, if not create it
    final chatRoomDoc = await chatRoomRef.get();
    if (!chatRoomDoc.exists) {
      await chatRoomRef.set(
        ChatRoomModel(
          participants: [senderUid, receiverUid],
          lastMessage: 'Added by',
          lastUpdated: Timestamp.now(),
          lastSenderUid: senderUid,
        ),
      );
    }

    // Now stream the messages
    yield* chatRoomRef
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return MessageModel.fromMap(doc.data());
          }).toList();
        });
  }
}
