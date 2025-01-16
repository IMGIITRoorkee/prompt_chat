import 'dart:core';
import 'dart:io';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:intl/intl.dart' as intl;
import 'package:prompt_chat/cli/category.dart';
import 'package:prompt_chat/cli/channel.dart';
import 'package:prompt_chat/cli/direct_message.dart';
import 'package:prompt_chat/cli/exceptions/weak_pass.dart';
import 'package:prompt_chat/cli/invite-code.dart';
import 'package:prompt_chat/cli/message.dart';
import 'package:prompt_chat/cli/user.dart';
import 'package:prompt_chat/cli/server.dart';
import 'package:prompt_chat/cli/role.dart';
import 'package:prompt_chat/cli/exceptions/invalid_creds.dart';
import 'package:prompt_chat/db/database_crud.dart';
import 'package:prompt_chat/enum/channel_type.dart';
import 'package:prompt_chat/enum/permissions.dart';
import 'package:prompt_chat/enum/server_type.dart';
import 'dart:convert';

class ChatAPI {
  List<User> users = [];
  List<Server> servers = [];
  List<InviteCode> inviteCodes = [];
  bool someoneLoggedIn = false;

  // Populate users & servers array from db
  Future<void> populateArrays() async {
    // users.forEach((element) {print(element.username);});
    users = await UserIO.getAllUsers();
    servers = await ServerIO.getAllServers();
    inviteCodes = await InviteCodeIO.getAllInviteCodes();
  }

  // Check if a given username exists
  Future<bool> isUsernameExists(String username) async {
    var usernames = users.map((e) => e.username).toList();
    return usernames.contains(username);
  }

  // Register a user
  Future<void> registerUser(String? username, String? password) async {
    if (username == null || password == null) {
      throw InvalidCredentialsException();
    }
    if (!isPasswordValid(password)) {
      print(
          "Password must be atleast 8 characters long, having atleast a number & a special character. Please try again.");
      throw WeakPasswordException();
    }
    validUsername(username);
    var newUser = User(username, password, false);

    await newUser.register();
    users.add(newUser);
  }

  Future<void> deleteUser(String? username) async {
    if (username == null) {
      throw Exception("Please enter a valid command");
    }

    var reqUser = getUser(username);
    users.remove(reqUser);

    for (var server in servers) {
      server.roles.forEach((role) => role.holders.remove(reqUser));
      server.channels.forEach((channel) {
        channel.messages.removeWhere((mssg) => mssg.sender == reqUser);
      });
      server.members.remove(reqUser);
    }
    await reqUser.delete();
  }

  void validUsername(String username) {
    var usernames = users.map((e) => e.username).toList();
    if (usernames.contains(username)) {
      throw Exception("User already exists");
    }
  }

  // Display all the messages in a given server
  void displayMessages(String? serverName) {
    if (serverName == null) {
      throw Exception("Please enter a valid command");
    }
    var reqServer = getServer(serverName);
    var currentUser = getCurrentLoggedIn();
    if (currentUser == null) {
      throw Exception("You must be logged in to view messages");
    }
    var user = getUser(currentUser);

    for (Channel channel in reqServer.channels) {
      print("${channel.channelName} : ");
      for (Message message in channel.messages) {
        // Only display message if sender is not blocked
        if (!user.blockedUsers.contains(message.sender.username)) {
          String formattedDate =
              intl.DateFormat('dd/MM/yyyy h:mm a').format(message.time);
          print(
              "${message.sender.username} ($formattedDate): ${message.content}");
        }
      }
    }
  }

  // Display all the servers, categories and channels associated with the user.
  void displayUserServers() {
    // Create indentation using '\t' repeated 'level' times
    void printIndented(String text, int level) {
      print('${'\t' * level}- $text');
    }

    var username = getCurrentLoggedIn();
    if (username == null) throw Exception("You must be logged in!");
    List<Server> userServers =
        servers.where((element) => element.isMember(username)).toList();

    for (var server in userServers) {
      print(server.serverName);

      for (var category in server.categories) {
        printIndented("Category: ${category.categoryName}", 1);

        List<Channel> channels = [];
        if (server.isAccessAllowed(username, 2)) {
          channels = category.channels;
        } else if (server.isAccessAllowed(username, 1)) {
          channels = category.channels
              .where((element) => element.permission != Permission.owner)
              .toList();
        }

        for (var channel in channels) {
          printIndented("Channel: ${channel.channelName}", 2);
        }
      }
    }
  }

  // Login a user
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

  // Checks if the password is atleast 8 characters long, having atleast a number & a special character
  bool isPasswordValid(String password) {
    if (password.length < 8) {
      return false;
    }
    bool hasNum = password.contains(RegExp(r'[0-9]'));
    bool hasChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    return hasNum && hasChar;
  }

  // Logout a user
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

  // Get user object from username
  User getUser(String name) {
    return users.firstWhere((user) => user.username == name,
        orElse: () => throw Exception("User does not exist"));
  }

  // Get username of current logged in user
  String? getCurrentLoggedIn() {
    for (User user in users) {
      if (user.loggedIn) {
        return user.username;
      }
    }
    return null;
  }

  // Display the list of all users
  void displayUsers() {
    for (User user in users) {
      print(user.username);
    }
  }

  // Create a new server with given config
  Future<void> createServer(
      String? serverName, String? userName, String? serverPerm) async {
    if (serverName == null || userName == null) {
      throw Exception(
          "Please enter the required credentials, or login to continue.");
    }
    JoinPerm joinPerm = getJoinPerm(serverPerm);
    var creator = getUser(userName);
    var newServer = createNewServer(serverName, joinPerm);
    servers.add(newServer);
    await newServer.instantiateServer(creator);
  }

  // Get JoinPerm object
  JoinPerm getJoinPerm(String? serverPerm) {
    if (serverPerm == "closed") {
      return JoinPerm.closed;
    }
    return JoinPerm.open;
  }

  // Creates a new server with given name and join permission
  Server createNewServer(String serverName, JoinPerm perm) {
    return Server(
      serverName: serverName,
      members: [],
      roles: [],
      categories: [Category(categoryName: "none", channels: [])],
      channels: [],
      joinPerm: perm,
    );
  }

  // Get Server object by server name
  Server getServer(String name) {
    return servers.firstWhere((server) => server.serverName == name,
        orElse: () => throw Exception("Server does not exist"));
  }

  // Add member to server if they have requried access level
  Future<void> addMemberToServer(
      String? serverName, String? userName, String? ownerName) async {
    if (serverName == null || userName == null || ownerName == null) {
      throw Exception(
          "Please enter the correct command, or login to continue.");
    }
    var reqUser = getUser(userName);
    var reqServer = getServer(serverName);
    reqServer.checkAccessLevels(ownerName, [1, 2]);
    await reqServer.addMember(reqUser);
  }

  // Allows mods & owner to remove member from server.
  Future<void> kickoutFromServer(
      String? serverName, String? userName, String? callerName) async {
    if (serverName == null || userName == null || callerName == null) {
      throw Exception(
          "Please enter the correct command, or login to continue.");
    }
    var reqServer = getServer(serverName);

    if (reqServer.getRole("owner").holders[0].username == userName) {
      throw Exception("The owner cannot be kicked out of the server.");
    }

    // check if the caller is owner
    if (reqServer.getRole("owner").holders[0].username == callerName) {
      leaveServer(serverName, userName);
    } else {
      // confirm that the caller is moderator
      reqServer.checkAccessLevel(callerName, 1);

      // check if the user being kicked out is not another moderator
      if (reqServer.isAccessAllowed(userName, 1)) {
        throw Exception("A moderator cannot kick out another moderator.");
      }
      leaveServer(serverName, userName);
    }
  }

  // Add a category to server
  Future<void> addCategoryToServer(
      String? serverName, String? categoryName, String? userName) async {
    if (serverName == null || categoryName == null || userName == null) {
      throw Exception(
          "Please enter the valid credentials, or login to continue.");
    }
    if (categoryName.isEmpty) {
      throw Exception("Category name must not be empty!");
    }
    var reqServer = getServer(serverName);
    reqServer.checkAccessLevels(userName, [1, 2]);
    await reqServer
        .addCategory(Category(categoryName: categoryName, channels: []));
  }

  // Add a channel to server
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

    var chanType = getChannelType(channelType);
    var perm = getPermission(channelPerm);
    var reqServer = getServer(serverName);
    reqServer.checkAccessLevels(userName, [1, 2]);
    await reqServer.addChannel(
        Channel(
            channelName: channelName,
            messages: [],
            type: chanType,
            permission: perm),
        parentCategoryName);
  }

  // Get the ChannelType object from string
  ChannelType getChannelType(String channelType) {
    switch (channelType) {
      case "video":
        return ChannelType.video;
      case "voice":
        return ChannelType.voice;
      default:
        return ChannelType.text;
    }
  }

  // Get the Permission object from string
  Permission getPermission(String channelPerm) {
    switch (channelPerm) {
      case "owner":
        return Permission.owner;
      case "moderator":
        return Permission.moderator;
      default:
        return Permission.member;
    }
  }

  // Send message in a server
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

    // Check if any member in the channel has blocked the sender
    for (var member in reqServer.members) {
      if (member.blockedUsers.contains(userName)) {
        // We still add the message but inform the sender they're blocked
        print(
            "Note: Some members won't see this message as they have blocked you");
        break;
      }
    }

    await reqServer.addMessageToChannel(
        reqChannel, reqUser, Message(messageContent, reqUser));
  }

  // Create a new role in server with given permision
  Future<void> createRole(String? serverName, String? roleName,
      String? permLevel, String? callerName) async {
    if (serverName == null ||
        roleName == null ||
        permLevel == null ||
        callerName == null) {
      throw Exception("Invalid command");
    }

    var newPerm = getRolePermission(permLevel);
    var reqServer = getServer(serverName);
    reqServer.checkAccessLevel(callerName, 2);
    await reqServer
        .addRole(Role(roleName: roleName, accessLevel: newPerm, holders: []));
  }

  // Get the role Permission from string
  Permission getRolePermission(String? permLevel) {
    if (permLevel == "owner") {
      throw Exception("Owner privileges cannot be shared to other roles.");
    } else if (permLevel == "moderator") {
      return Permission.moderator;
    } else {
      return Permission.member;
    }
  }

  // Assign role to user in the server
  Future<void> addRoleToUser(String? serverName, String? roleName,
      String? memberName, String? callerName) async {
    if (serverName == null ||
        roleName == null ||
        memberName == null ||
        callerName == null) {
      throw Exception("Enter a valid command");
    }
    var reqServer = getServer(serverName);
    reqServer.checkAccessLevels(callerName, [1, 2]);
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

  // Add channel to given category in the server
  Future<void> addChannelToCategory(String? serverName, String? channelName,
      String? categoryName, String? callerName) async {
    if (serverName == null ||
        channelName == null ||
        categoryName == null ||
        callerName == null) {
      throw Exception("Please enter a valid command, or login to continue");
    }
    var reqServer = getServer(serverName);

    reqServer.checkAccessLevels(callerName, [1, 2]);
    await reqServer.assignChannel(channelName, categoryName);
  }

  // Change permission level of channel in the server
  Future<void> changePermission(String? serverName, String? channelName,
      String? newPerm, String? callerName) async {
    if (serverName == null ||
        channelName == null ||
        newPerm == null ||
        callerName == null) {
      throw Exception("Please enter a valid command, or login to continue");
    }
    var perm = getPermission(newPerm);
    var reqServer = getServer(serverName);
    reqServer.checkAccessLevel(callerName, 2);
    await reqServer.changePerm(channelName, perm);
  }

  // Change ownership of the server
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

  // Allow user to join server
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

  // Allow user to leave the server
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

  void searchServers(String? term) {
    if (term == null) {
      throw Exception("Valid search term must be provided.");
    }
    extractTop<Server>(
      query: term,
      choices: servers,
      limit: 5,
      cutoff: 50,
      getter: (obj) => obj.serverName,
    ).forEach(
      (element) {
        print(element.choice.serverName);
      },
    );
  }

  void searchUsers(String? term) {
    if (term == null) {
      throw Exception("Valid search term must be provided.");
    }
    extractTop<User>(
      query: term,
      choices: users,
      limit: 5,
      cutoff: 50,
      getter: (obj) => obj.username,
    ).forEach(
      (element) {
        print(element.choice.username);
      },
    );
  }

  // Display all the channels in every category in every server
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

  // create a new invite code
  Future<String> createInviteCode(String servername, String username) async {
    var reqServer = getServer(servername);
    var reqUser = getUser(username);
    reqServer.checkAccessLevels(username, [1, 2]);
    var inviteCode = InviteCode(reqUser, "", reqServer);
    for (var invitecode in reqServer.inviteCodes) {
      if (invitecode.code == inviteCode.code) {
        return createInviteCode(servername, username);
      } else if (invitecode.inviter == reqUser) {
        return invitecode.code;
      }
    }
    reqServer.inviteCodes.add(inviteCode);
    await DatabaseIO.addToDB(inviteCode, "invitecodes");
    inviteCodes.add(inviteCode);
    return inviteCode.code;
  }

  // join server using invite code
  Future<void> joinServerWithCode(String inviteCode, String username) async {
    var invite = inviteCodes.firstWhere((element) => element.code == inviteCode,
        orElse: () => throw Exception("Invalid invite code"));
    var reqUser = getUser(username);
    var reqServer = invite.server;
    if (reqServer.isMember(reqUser.username)) {
      throw Exception("The user is already a member of the server");
    }
    await reqServer.addMember(reqUser);
    invite.invitedUsers.add(reqUser);
  }

  void sendDm(String recieverusername, String message, String senderusername) {
    User sender = getUser(senderusername);
    User reciever = getUser(recieverusername);
    DirectMessage dm = DirectMessage(sender, reciever, message);
    dm.send();
  }

  Future<List<String>> getRecievedDms(String username) async {
    User user = getUser(username);
    List<DirectMessage> dms = await DirectMessage.getMessages(user);
    List<String> messages = [];
    for (DirectMessage dm in dms) {
      // Only show messages if sender is not blocked
      if (dm.receiver.username == user.username &&
          !user.blockedUsers.contains(dm.sender.username)) {

        messages.add("${dm.sender.username} : ${dm.message}");
      }
    }
    return messages;
  }

  Future<List<String>> getSentDms(String username) async {
    User user = getUser(username);
    List<DirectMessage> dms = await DirectMessage.getMessages(user);
    List<String> messages = [];
    for (DirectMessage dm in dms) {
      if (dm.sender.username == user.username) {
        messages.add("${dm.receiver.username} : ${dm.message}");
      }
    }
    return messages;
  }

  Future<void> exportServerData(String? serverName, String? username) async {
    if (serverName == null || username == null) {
      throw Exception("Please provide valid server name and username");
    }

    var reqServer = getServer(serverName);
    reqServer.checkAccessLevel(username, 2); // Ensure only owner can export

    // Convert server to JSON
    final serverJson = reqServer.toMap();

    // Create timestamp for unique filename
    final timestamp =
        DateTime.now().toIso8601String().replaceAll(RegExp(r'[:.]'), '-');
    final fileName =
        'server_${serverName.replaceAll(' ', '_')}_$timestamp.json';

    try {
      // Create a backup directory if it doesn't exist
      var backupDir = Directory('backups');
      if (!await backupDir.exists()) {
        await backupDir.create();
      }

      // Write JSON to file in backups directory
      final file = File('${backupDir.path}${Platform.pathSeparator}$fileName');
      await file.writeAsString(jsonEncode(serverJson), flush: true);
      print('Server data exported successfully to ${file.path}');
    } catch (e) {
      throw Exception('Failed to export server data: $e');
    }
  }

  Future<void> importServerData(String? filePath, String? username) async {
    if (filePath == null || username == null) {
      throw Exception("Please provide valid file path and username");
    }

    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File not found: $filePath');
      }

      // Read and parse JSON file
      final jsonString = await file.readAsString();
      final serverData = jsonDecode(jsonString);

      // Basic validation of JSON structure
      if (!serverData.containsKey('serverName') ||
          !serverData.containsKey('members') ||
          !serverData.containsKey('roles')) {
        throw Exception('Invalid server data format');
      }

      // Check if server name already exists
      final serverName = serverData['serverName'];
      if (servers.any((server) => server.serverName == serverName)) {
        throw Exception('A server with this name already exists');
      }

      // Create new server instance
      var newServer = Server.fromMap(serverData);

      // Validate that the importing user exists and will be the owner
      var importingUser = getUser(username);
      if (!newServer.isAccessAllowed(username, 2)) {
        // Ensure the importing user becomes the owner
        await newServer.swapOwner(
            newServer.getRole('owner').holders[0].username, username);
      }

      // Add server to the list and database
      servers.add(newServer);
      await DatabaseIO.addToDB(newServer, 'servers');

      print('Server data imported successfully');
    } catch (e) {
      throw Exception('Failed to import server data: $e');
    }
  }
    Future<void> blockUser(String? blockerUsername, String? userToBlock) async {

    if (blockerUsername == null || userToBlock == null) {
      throw Exception("Please enter valid usernames");
    }
    if (blockerUsername == userToBlock) {
      throw Exception("You cannot block yourself");
    }

    var blocker = getUser(blockerUsername);
    var userBeingBlocked =
        getUser(userToBlock); // This will verify the user exists

    if (blocker.blockedUsers.contains(userToBlock)) {
      throw Exception("User is already blocked");
    }

    // Create a new list with the existing blocked users plus the new one
    List<String> updatedBlockedUsers = List<String>.from(blocker.blockedUsers)
      ..add(userToBlock);

    // Update the blockedUsers list
    blocker.blockedUsers = updatedBlockedUsers;

    // Save to database
    await UserIO.updateDB(blocker);
  }

  Future<void> unblockUser(
      String? blockerUsername, String? userToUnblock) async {
    if (blockerUsername == null || userToUnblock == null) {
      throw Exception("Please enter valid usernames");
    }

    var blocker = getUser(blockerUsername);
    var userBeingUnblocked =
        getUser(userToUnblock); // This will verify the user exists

    if (!blocker.blockedUsers.contains(userToUnblock)) {
      throw Exception("User is not blocked");
    }

    // Create a new list without the unblocked user
    List<String> updatedBlockedUsers = List<String>.from(blocker.blockedUsers)
      ..remove(userToUnblock);

    // Update the blockedUsers list
    blocker.blockedUsers = updatedBlockedUsers;

    // Save to database
    await UserIO.updateDB(blocker);
  }
}
