
import 'package:prompt_chat/cli/user.dart';
import 'package:prompt_chat/db/database_crud.dart';

class DirectMessage{
  User sender;
  User receiver;
  String message;
  DirectMessage(this.sender, this.receiver, this.message);

  Map<String, dynamic> toMap() {
    return {
      'sender': sender.username,
      'receiver': receiver.username,
      'message': message,
    };
  }

  static DirectMessage fromMap(Map<String, dynamic> map) {
    return DirectMessage(
      User(map['sender'], "password", false),
      User(map['receiver'], "password", false),
      map['message'],
    );
  }

  Future<void> send() async {
    await DatabaseIO.addToDB(this, "direct_messages");
  }

  static Future<List<DirectMessage>> getMessages(User user) async {
    List<Map<String, dynamic>> messages = await DatabaseIO.getFromDB("direct_messages");
    List<DirectMessage> userMessages = [];
    for (var message in messages) {
      if (message['sender'] == user.username || message['receiver'] == user.username) {
        userMessages.add(DirectMessage.fromMap(message));
      }
    }
    return userMessages;
  }
}
