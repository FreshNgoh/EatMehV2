import 'package:eatmehv2/data/models/chat/message_model.dart';
import 'package:eatmehv2/data/services/chat_room_service.dart';

class ChatRoomRepo {
  final ChatRoomService _chatRoomService;
  ChatRoomRepo(this._chatRoomService);

  Future<void> sendMessage(
    String senderUid,
    String receiverUid,
    String message,
  ) async {
    return await _chatRoomService.sendMessage(senderUid, receiverUid, message);
  }

  Stream<List<MessageModel>> getMessages(String senderUid, String receiverUid) {
    return _chatRoomService.getMessages(senderUid, receiverUid);
  }
}
