import 'package:prompt_chat/cli/message.dart';
import 'package:prompt_chat/enum/channel_type.dart';
import 'package:prompt_chat/enum/permissions.dart';

class Channel {
  late String channelName;
  late Permission permission;
  late ChannelType type;
  List<Message> messages = [];
  Channel(
      {required this.channelName,
      required this.messages,
      required this.type,
      this.permission = Permission.member});
  Map<String, dynamic> toMap() {
    var mappedMessages = messages.map((message) => message.toMap()).toList();
    return {
      'channelName': channelName,
      'permission': permission.toString(),
      'channelType': type.toString(),
      'messages': mappedMessages,
      'finder': "finder",
    };
  }

  Map<String, dynamic> toMapWithoutUserInfo() {
    var mappedMessages =
        messages.map((message) => message.toMapWithoutUserInfo()).toList();

    return {
      'channelName': channelName,
      'permission': permission.toString(),
      'channelType': type.toString(),
      'messages': mappedMessages,
    };
  }

  static Channel fromMap(Map<String, dynamic> map) {
    late Permission perm;
    late ChannelType chanType;
    if (map['permission'] == "Permission.owner") {
      perm = Permission.owner;
    }
    if (map['permission'] == "Permission.moderator") {
      perm = Permission.moderator;
    }
    if (map['permission'] == "Permission.member") {
      perm = Permission.member;
    }
    if (map['channelType'] == "ChannelType.text") {
      chanType = ChannelType.text;
    }
    if (map['channelType'] == "ChannelType.voice") {
      chanType = ChannelType.voice;
    }
    if (map['channelType'] == "ChannelType.video") {
      chanType = ChannelType.video;
    }
    var unmappedMessages = (map['messages'] as List)
        .map((message) => Message.fromMap(message))
        .toList();

    return Channel(
        channelName: map['channelName'],
        messages: unmappedMessages,
        type: chanType,
        permission: perm);
  }

  @override
  bool operator ==(Object other) {
    return other is Channel &&
        other.channelName == channelName &&
        other.permission == permission &&
        other.type == type;
  }

  @override
  int get hashCode {
    return channelName.hashCode ^ permission.hashCode ^ type.hashCode;
  }
}
