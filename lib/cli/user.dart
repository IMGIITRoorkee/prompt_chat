import 'package:prompt_chat/db/database_crud.dart';
import 'package:bcrypt/bcrypt.dart';

class User {
  late String username;
  late String password;
  var loggedIn = false;
  List<String> blockedUsers;
  User(this.username, this.password, this.loggedIn,
      {List<String>? blockedUsers})
      : this.blockedUsers = blockedUsers ?? [];
  //to be called upon object creation
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'password': password,
      'loggedIn': loggedIn,
      'finder': "finder",
      'blockedUsers': blockedUsers,
    };
  }

  static User fromMap(Map<String, dynamic> map) {
    return User(
      map['username'],
      map['password'],
      map['loggedIn'],
      blockedUsers: List<String>.from(map['blockedUsers'] ?? []),
    );
  }

  Future<void> login(String password) async {
    bool authed = BCrypt.checkpw(password, this.password);
    if (!(authed)) {
      throw Exception("Error : Incorrect password");
    }
    loggedIn = true;
    await UserIO.updateDB(User(username, password, true));
  }

  Future<void> update(String? username, String? newPass, String oldPass) async {
    bool authed = BCrypt.checkpw(oldPass, this.password);
    if (!(authed)) {
      throw Exception("Error : Incorrect password");
    }
    await UserIO.updateDB(
        User(username ?? this.username, newPass ?? password, true));
  }

  Future<void> register() async {
    var salt = BCrypt.gensalt();
    password = BCrypt.hashpw(password, salt);
    await DatabaseIO.addToDB(this, "users");
  }

  Future<void> delete() async {
    await DatabaseIO.deleteDB(username);
  }

  Future<void> logout() async {
    //abhi ke liye no checks
    await UserIO.updateDB(User(username, password, false));
  }

  Future<void> blockUser(String usernameToBlock) async {
    if (username == usernameToBlock) {
      throw Exception("Error: Cannot block yourself");
    }

    if (!blockedUsers.contains(usernameToBlock)) {
      blockedUsers.add(usernameToBlock);
      await UserIO.updateDB(this);
    }
  }

  Future<void> unblockUser(String usernameToUnblock) async {
    if (blockedUsers.contains(usernameToUnblock)) {
      blockedUsers.remove(usernameToUnblock);
      await UserIO.updateDB(this);
    } else {
      throw Exception("Error: User is not blocked");
    }
  }

  bool isUserBlocked(String username) {
    return blockedUsers.contains(username);
  }
}
