import 'dart:core';
import 'package:prompt_chat/cli/category.dart';
import 'package:prompt_chat/cli/channel.dart';
import 'package:prompt_chat/cli/message.dart';
import 'package:prompt_chat/cli/user.dart';
import 'package:prompt_chat/cli/server.dart';
import 'package:prompt_chat/cli/role.dart';
import 'package:prompt_chat/cli/exceptions/invalid_creds.dart';
import 'package:prompt_chat/db/database_crud.dart';
import 'package:prompt_chat/enum/channel_type.dart';
import 'package:prompt_chat/enum/permissions.dart';
import 'package:prompt_chat/enum/server_type.dart';

class ChatAPI {
  List<User> users = [];
  List<Server> servers = [];
  bool someoneLoggedIn = false;
  Future<void> populateArrays() async {
    // users.forEach((element) {print(element.username);});
    users = await UserIO.getAllUsers();
    servers = await ServerIO.getAllServers();
  }

  //Users
  Future<void> registerUser(String? username, String? password) async {
    if (username == null || password == null) {
      throw InvalidCredentialsException();
    }
    validUsername(username);
    var newUser = User(username, password, false);

    users.add(newUser);
    await newUser.register();
  }

  void validUsername(String username) {
    var usernames = users.map((e) => e.username).toList();
    if (usernames.contains(username)) {
      throw Exception("User already exists");
    }
  }

  void displayMessages(String? serverName) {
    if (serverName == null) {
      throw Exception("Please enter a valid command");
    }
    var reqServer = getServer(serverName);
    for (Channel channel in reqServer.channels) {
      print("${channel.channelName} : ");
      for (Message message in channel.messages) {
        print("${message.sender.username} : ${message.content}");
      }
    }
  }

  Future<void> loginUser(String? username, String? password) async {
    if (password == null || username == null) {
      throw InvalidCredentialsException();
    }
    if (someoneLoggedIn) {
      throw Exception("Please logout of the current session to login again");
    }
    var reqUser = getUser(username);
    await reqUser.login(password);
    someoneLoggedIn = true;
  }

  Future<void> logoutUser(String? username) async {
    if (username == null) {
      throw InvalidCredentialsException();
    }
    var reqUser = getUser(username);
    reqUser.loggedIn = false;
    someoneLoggedIn = false;
    await reqUser.logout();
  }

  Future<void> updateUsername(String? username, String? oldPass) async {
    if (oldPass == null) {
      throw Exception("Current password must be provided!");
    } else if (getCurrentLoggedIn() == null) {
      throw Exception("You must be logged in to update info!");
    } else if (username == null) {
      throw Exception("Valid username must be provided");
    }
    validUsername(username);

    var user = getUser(getCurrentLoggedIn()!);
    await user.update(username, null, oldPass);
  }

  Future<void> updatePassword(String? newPass, String? oldPass) async {
    if (oldPass == null) {
      throw Exception("Current password must be provided!");
    } else if (getCurrentLoggedIn() == null) {
      throw Exception("You must be logged in to update info!");
    } else if (newPass == null) {
      throw Exception("Valid username must be provided");
    }

    var user = getUser(getCurrentLoggedIn()!);
    await user.update(null, newPass, oldPass);
  }

  User getUser(String name) {
    return users.firstWhere((user) => user.username == name,
        orElse: () => throw Exception("User does not exist"));
  }

  String? getCurrentLoggedIn() {
    for (User user in users) {
      if (user.loggedIn) {
        return user.username;
      }
    }
    return null;
  }

  void displayUsers() {
    for (User user in users) {
      print(user.username);
    }
  }

  //Servers
  Future<void> createServer(
      String? serverName, String? userName, String? serverPerm) async {
    late JoinPerm perm;
    if (serverName == null || userName == null) {
      throw Exception(
          "Please enter the required credentials, or login to continue.");
    }
    if (serverPerm == null) {
      perm = JoinPerm.open;
    }
    if (serverPerm == "closed") {
      perm = JoinPerm.closed;
    } else {
      perm = JoinPerm.open;
    }
    var creator = getUser(userName);
    var newServer = Server(
        serverName: serverName,
        members: [],
        roles: [],
        categories: [Category(categoryName: "none", channels: [])],
        channels: [],
        joinPerm: perm);
    servers.add(newServer);
    await newServer.instantiateServer(creator);
  }

  Server getServer(String name) {
    return servers.firstWhere((server) => server.serverName == name,
        orElse: () => throw Exception("Server does not exist"));
  }

  Future<void> addMemberToServer(
      String? serverName, String? userName, String? ownerName) async {
    if (serverName == null || userName == null || ownerName == null) {
      throw Exception(
          "Please enter the correct command, or login to continue.");
    }
    var reqUser = getUser(userName);
    var reqServer = getServer(serverName);
    reqServer.checkAccessLevel(ownerName, 2);
    await reqServer.addMember(reqUser);
  }

  Future<void> addCategoryToServer(
      String? serverName, String? categoryName, String? userName) async {
    if (serverName == null || categoryName == null || userName == null) {
      throw Exception(
          "Please enter the valid credentials, or login to continue.");
    }
    var reqServer = getServer(serverName);
    reqServer.checkAccessLevel(userName, 2);
    await reqServer
        .addCategory(Category(categoryName: categoryName, channels: []));
  }

  Future<void> addChannelToServer(
      String? serverName,
      String? channelName,
      String? channelPerm,
      String? channelType,
      String? parentCategoryName,
      String? userName) async {
    if (serverName == null ||
        channelName == null ||
        channelPerm == null ||
        channelType == null ||
        userName == null) {
      throw Exception(
          "Please enter the valid credentials, or login to continue.");
    }
    parentCategoryName ??= "none";
    late ChannelType chanType;
    late Permission perm;
    //bad pattern
    if (channelType == "video") {
      chanType = ChannelType.video;
    } else if (channelType == "voice") {
      chanType = ChannelType.voice;
    } else {
      chanType = ChannelType.text;
    }
    if (channelPerm == "owner") {
      perm = Permission.owner;
    } else if (channelPerm == "moderator") {
      perm = Permission.moderator;
    } else {
      perm = Permission.member;
    }

    var reqServer = getServer(serverName);
    reqServer.checkAccessLevel(userName, 2);
    await reqServer.addChannel(
        Channel(
            channelName: channelName,
            messages: [],
            type: chanType,
            permission: perm),
        parentCategoryName);
  }

  Future<void> sendMessageInServer(String? serverName, String? userName,
      String? channelName, String? messageContent) async {
    if (serverName == null ||
        userName == null ||
        channelName == null ||
        messageContent == null) {
      throw Exception("Please enter a valid command, or login to continue.");
    }
    var reqServer = getServer(serverName);
    var reqUser = getUser(userName);
    var reqChannel = reqServer.getChannel(channelName);
    if (reqChannel.type != ChannelType.text) {
      throw Exception("You can only send a message in a text channel");
    }
    if (!(reqUser.loggedIn)) {
      throw Exception("Not logged in");
    }
    await reqServer.addMessageToChannel(
        reqChannel, reqUser, Message(messageContent, reqUser));
  }

  Future<void> createRole(String? serverName, String? roleName,
      String? permLevel, String? callerName) async {
    late Permission newPerm;
    if (serverName == null ||
        roleName == null ||
        permLevel == null ||
        callerName == null) {
      throw Exception("Invalid command");
    }
    if (permLevel == "owner") {
      throw Exception("Owner privileges cannot be shared to other roles.");
    } else if (permLevel == "moderator") {
      newPerm = Permission.moderator;
    } else {
      newPerm = Permission.member;
    }
    var reqServer = getServer(serverName);
    reqServer.checkAccessLevel(callerName, 2);
    await reqServer
        .addRole(Role(roleName: roleName, accessLevel: newPerm, holders: []));
  }

  Future<void> addRoleToUser(String? serverName, String? roleName,
      String? memberName, String? callerName) async {
    if (serverName == null ||
        roleName == null ||
        memberName == null ||
        callerName == null) {
      throw Exception("Enter a valid command");
    }
    var reqServer = getServer(serverName);
    reqServer.checkAccessLevel(callerName, 2);
    if (!(reqServer.isMember(memberName))) {
      throw Exception("User is not a member of the server");
    }
    if (roleName == "owner") {
      throw Exception("There can only be one owner");
    }
    var reqRole = reqServer.getRole(roleName);
    var reqMember = reqServer.getMember(memberName);
    await reqServer.assignRole(reqRole, reqMember);
  }

  Future<void> addChannelToCategory(String? serverName, String? channelName,
      String? categoryName, String? callerName) async {
    if (serverName == null ||
        channelName == null ||
        categoryName == null ||
        callerName == null) {
      throw Exception("Please enter a valid command, or login to continue");
    }
    var reqServer = getServer(serverName);
    reqServer.checkAccessLevel(callerName, 2);
    await reqServer.assignChannel(channelName, categoryName);
  }

  Future<void> changePermission(String? serverName, String? channelName,
      String? newPerm, String? callerName) async {
    if (serverName == null ||
        channelName == null ||
        newPerm == null ||
        callerName == null) {
      throw Exception("Please enter a valid command, or login to continue");
    }
    late Permission perm;
    var reqServer = getServer(serverName);
    reqServer.checkAccessLevel(callerName, 2);
    if (newPerm == "owner") {
      perm = Permission.owner;
    } else if (newPerm == "moderator") {
      perm = Permission.moderator;
    } else if (newPerm == "member") {
      perm = Permission.member;
    } else {
      throw Exception("Please enter a valid permission");
    }
    await reqServer.changePerm(channelName, perm);
  }

  Future<void> changeOwnership(
      String? serverName, String? currentOwner, String? newOwner) async {
    if (currentOwner == null || newOwner == null || serverName == null) {
      throw Exception("Please enter a valid command, or login to continue");
    }
    var reqServer = getServer(serverName);
    getUser(currentOwner);
    getUser(newOwner);
    reqServer.checkAccessLevel(currentOwner, 2);
    if (!(reqServer.isMember(newOwner))) {
      throw Exception("The specified user is not a member of the server");
    }
    await reqServer.swapOwner(currentOwner, newOwner);
  }

  Future<void> joinServer(String? serverName, String? joinerName) async {
    if (serverName == null || joinerName == null) {
      throw Exception("Please enter a valid command, or login to continue");
    }
    var reqUser = getUser(joinerName);
    var reqServer = getServer(serverName);
    if (reqServer.isMember(reqUser.username)) {
      throw Exception("The user is already a member of the server");
    }
    if (reqServer.joinPerm == JoinPerm.closed) {
      throw Exception(
          "The server is not open to join, ask to be added to the server by the owner");
    }
    await reqServer.addMember(reqUser);
  }

  Future<void> leaveServer(String? serverName, String? callerName) async {
    if (serverName == null || callerName == null) {
      throw Exception("Please enter a valid command, or login to continue");
    }
    var reqServer = getServer(serverName);
    getUser(callerName);
    if (!(reqServer.isMember(callerName))) {
      throw Exception("The user is not a member of the server");
    }
    //if user leaving is owner
    if (reqServer.getRole("owner").holders[0].username == callerName) {
      throw Exception(
          "Please change ownership before leaving your server, as you are the owner");
    }
    await reqServer.removeMember(callerName);
  }

  void displayChannels() {
    for (Server server in servers) {
      for (Category category in server.categories) {
        print(category.categoryName);
        for (Channel channel in category.channels) {
          print(channel.channelName);
        }
      }
    }
  }
}
