import 'package:prompt_chat/cli/user.dart';
import 'package:prompt_chat/cli/role.dart';
import 'package:prompt_chat/cli/category.dart';
import 'package:prompt_chat/cli/message.dart';
import 'package:prompt_chat/enum/permissions.dart';
import 'package:prompt_chat/cli/channel.dart';
import 'package:prompt_chat/db/database_crud.dart';
import 'package:prompt_chat/enum/server_type.dart';

class Server {
  List<User> members;
  List<Role> roles;
  List<Category> categories;
  List<Channel> channels;
  late String serverName;
  late JoinPerm joinPerm;
  Server(
      {required this.serverName,
      required this.members,
      required this.roles,
      required this.categories,
      required this.channels,
      this.joinPerm = JoinPerm.open});
  //called only on server creation
  Future<void> instantiateServer(User owner) async {
    members.add(owner);
    var ownerRole =
        Role(roleName: "owner", accessLevel: Permission.owner, holders: []);
    roles.add(ownerRole);
    ownerRole.holders.add(owner);
    roles.add(
        Role(roleName: "member", accessLevel: Permission.member, holders: []));
    //database logic
    await DatabaseIO.addToDB(this, "servers");
  }

  Future<void> addMember(User newMember) async {
    if (members.contains(newMember)) {
      throw Exception("Already a member");
    }
    members.add(newMember);
    var memberRole = getRole("member");
    memberRole.holders.add(newMember);
    await ServerIO.updateDB(this);
  }

  Future<void> addCategory(Category newCategory) async {
    if (categories.contains(newCategory)) {
      throw Exception("Category already exists");
    }
    categories.add(newCategory);
    await ServerIO.updateDB(this);
  }

  Future<void> addChannel(Channel newChannel, String parentCategoryName) async {
    if (channels.contains(newChannel)) {
      throw Exception("Channel already exists");
    }
    channels.add(newChannel);
    var reqCat = getCategory(parentCategoryName);
    reqCat.channels.add(newChannel);
    await ServerIO.updateDB(this);
  }

  Future<void> addMessageToChannel(
      Channel channel, User sender, Message message) async {
    if (!(members.map((e) => e.username).toList().contains(sender.username))) {
      throw Exception("The user is not a member of the server");
    }
    if (!(channels.contains(channel))) {
      throw Exception("The channel does not exist on the specified server");
    }
    List<Role> senderRoles = extractRoles(sender);
    senderRoles.firstWhere(
        (role) => role.accessLevel.index >= channel.permission.index,
        orElse: () => throw Exception("Access not allowed for this channel"));
    channel.messages.add(message);
    await ServerIO.updateDB(this);
  }

  Map<String, dynamic> toMap() {
    var mappedMembers = members.map((member) => member.toMap()).toList();
    var mappedRoles = roles.map((role) => role.toMap()).toList();
    var mappedCategories =
        categories.map((category) => category.toMap()).toList();
    var mappedChannels = channels.map((channel) => channel.toMap()).toList();
    return {
      'serverName': serverName,
      'members': mappedMembers,
      'roles': mappedRoles,
      'categories': mappedCategories,
      "channels": mappedChannels,
      "joinPerm": joinPerm.toString(),
      'finder': 'finder',
    };
  }

  static Server fromMap(Map<String, dynamic> map) {
    late List<User> unmappedMembers;
    late List<Role> unmappedRoles;
    late List<Category> unmappedCategories;
    late List<Channel> unmappedChannels;
    late JoinPerm perm;
    if (map['members'] == null) {
      unmappedMembers = [];
    }
    if (map['roles'] == null) {
      unmappedRoles = [];
    }
    if (map['categories'] == null) {
      unmappedCategories = [];
    }
    if (map['channels'] == null) {
      unmappedChannels = [];
    }
    if (map['joinPerm'] == "JoinPerm.closed") {
      perm = JoinPerm.closed;
    } else {
      perm = JoinPerm.open;
    }
    unmappedMembers =
        (map['members'] as List).map((member) => User.fromMap(member)).toList();
    unmappedRoles =
        (map['roles'] as List).map((role) => Role.fromMap(role)).toList();
    unmappedCategories = (map['categories'] as List)
        .map((category) => Category.fromMap(category))
        .toList();
    unmappedChannels = (map['channels'] as List)
        .map((channel) => Channel.fromMap(channel))
        .toList();
    return Server(
        serverName: map["serverName"],
        members: unmappedMembers,
        roles: unmappedRoles,
        categories: unmappedCategories,
        channels: unmappedChannels,
        joinPerm: perm);
  }

  Future<void> addRole(Role newRole) async {
    for (Role role in roles) {
      if (role.roleName == newRole.roleName) {
        throw Exception("Role already exists on this server");
      }
    }
    roles.add(newRole);
    await ServerIO.updateDB(this);
  }

  Future<void> assignRole(Role role, User member) async {
    role.holders.add(member);
    await ServerIO.updateDB(this);
  }

  Future<void> assignChannel(String channelName, String categoryName) async {
    var reqChannel = getChannel(channelName);
    var reqCategory = getCategory(categoryName);
    for (Channel channel in reqCategory.channels) {
      if (channel.channelName == reqChannel.channelName) {
        throw Exception("Channel is already in the required category");
      }
    }
    for (Category category in categories) {
      if (category.channels
          .map((e) => e.channelName)
          .toList()
          .contains(channelName)) {
        category.channels.remove(reqChannel);
      }
    }
    reqCategory.channels.add(reqChannel);
    await ServerIO.updateDB(this);
  }

  Future<void> changePerm(String channelName, Permission perm) async {
    var reqChannel = getChannel(channelName);
    reqChannel.permission = perm;
    await ServerIO.updateDB(this);
  }

  Future<void> removeChannel(String channelName) async {
    var reqChannel = getChannel(channelName);
    outer_loop:
    for (Category category in categories) {
      for (Channel channel in category.channels) {
        if (channel.channelName == reqChannel.channelName) {
          category.channels.remove(channel);
          break outer_loop;
        }
      }
    }
    await ServerIO.updateDB(this);
  }

  Future<void> removeCategory(String categoryName) async {
    var reqCategory = getCategory(categoryName);
    categories.remove(reqCategory);
    await ServerIO.updateDB(this);
  }

  Future<void> removeRole(String roleName) async {
    var reqRole = getRole(roleName);
    roles.remove(reqRole);
    await ServerIO.updateDB(this);
  }

  Future<void> removeMember(String memberName) async {
    var reqMember = getMember(memberName);
    members.remove(reqMember);
    for (Role role in roles) {
      for (User holder in role.holders) {
        if (holder.username == reqMember.username) {
          role.holders.remove(holder);
        }
      }
    }
    await ServerIO.updateDB(this);
  }

  Future<void> swapOwner(String currOwner, String newOwner) async {
    var ownerRole = getRole("owner");
    var owner = getMember(newOwner);
    ownerRole.holders.removeLast();
    ownerRole.holders.add(owner);
    await ServerIO.updateDB(this);
  }

  User getMember(String name) {
    return members.firstWhere((member) => member.username == name,
        orElse: () => throw Exception("Member does not exist"));
  }

  bool isMember(String name) {
    for (User member in members) {
      if (member.username == name) {
        return true;
      }
    }
    return false;
  }

  Role getRole(String name) {
    return roles.firstWhere((role) => role.roleName == name,
        orElse: () => throw Exception("Role does not exist"));
  }

  Channel getChannel(String name) {
    return channels.firstWhere((channel) => channel.channelName == name,
        orElse: () => throw Exception("Channel does not exist"));
  }

  Category getCategory(String name) {
    return categories.firstWhere((category) => category.categoryName == name,
        orElse: () => throw Exception("Category does not exist"));
  }

  void checkAccessLevel(String username, int accessNo) {
    var user = getMember(username);
    if (!(user.loggedIn)) {
      throw Exception("User is not logged in");
    }
    List<Role> senderRoles = extractRoles(user);
    senderRoles.firstWhere((element) => element.accessLevel.index == accessNo,
        orElse: () =>
            throw Exception("You are not authorised for this action"));
  }

  void checkAccessLevels(String username, List<int> accessNos) {
    var user = getMember(username);
    if (!(user.loggedIn)) {
      throw Exception("User is not logged in");
    }
    List<Role> senderRoles = extractRoles(user);
    senderRoles.firstWhere((element) {
      for (int a in accessNos) {
        if (element.accessLevel.index == a) {
          return true;
        }
      }
      return false;
    }, orElse: () => throw Exception("You are not authorised for this action"));
  }

  bool isAccessAllowed(String username, int accessNo) {
    var user = getMember(username);

    List<Role> senderRoles = extractRoles(user);
    return senderRoles.any((role) => role.accessLevel.index == accessNo);
  }

  List<Role> extractRoles(User user) {
    List<Role> senderRoles = [];
    for (Role role in roles) {
      if (role.holders
          .map((e) => e.username)
          .toList()
          .contains(user.username)) {
        senderRoles.add(role);
      }
    }
    return senderRoles;
  }
}
