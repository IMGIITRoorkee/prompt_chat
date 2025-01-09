import 'package:prompt_chat/cli/user.dart';

class Message {
  final String content;
  final User sender;
  final DateTime time;
  Message(this.content, this.sender, {DateTime? time})
      : time = time ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'sender': sender.toMap(),
      'time': time.toIso8601String(),
      'finder': "finder",
    };
  }

  static Message fromMap(Map<String, dynamic> map) {
    return Message(
      map['content'],
      User.fromMap(map['sender']),
      time: DateTime.tryParse(map['time'] ?? ""),
    );
  }
}
