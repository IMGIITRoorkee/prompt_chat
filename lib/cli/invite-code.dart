import 'dart:math';

import 'package:prompt_chat/cli/server.dart';
import 'package:prompt_chat/cli/user.dart';

class InviteCode {
  User inviter;
  String code;
  Server server;
  List<User> invitedUsers;

  // Constructor with proper initialization
  InviteCode(this.inviter, this.code, this.server, [List<User>? invitedUsers])
      : invitedUsers = invitedUsers ?? [] {
    this.code = code.isEmpty ? generateCode() : code;
  }

  // Generate a random code
  static String generateCode() {
    const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    Random random = Random();
    return List.generate(6, (index) => chars[random.nextInt(chars.length)]).join();
  }

  // Convert object to a map
  Map<String, dynamic> toMap() {
    return {
      'inviter': inviter.toMap(),
      'code': code,
      'server': server.toMap(),
      'invitedUsers': invitedUsers.map((e) => e.toMap()).toList(),
      'finder' : "finder",
    };
  }

  // Create an object from a map
  static InviteCode fromMap(Map<String, dynamic> map) {
    return InviteCode(
      User.fromMap(map['inviter']),
      map['code'] ?? generateCode(),
      Server.fromMap(map['server']),
      (map['invitedUsers'] as List<dynamic>).map((e) => User.fromMap(e)).toList(),
    );
  }
}
