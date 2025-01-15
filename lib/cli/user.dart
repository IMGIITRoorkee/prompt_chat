import 'package:bcrypt/bcrypt.dart';

import 'package:prompt_chat/db/database_crud.dart';

class User {
  late String username;
  late String password;
  var loggedIn = false;
  List<String> blockedUsers;

  Map<String, dynamic>? _snapshot;

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

  void _rollbackToSnapshot() {
    if (_snapshot == null) return;
    username = _snapshot!['username'];
    password = _snapshot!['password'];
    loggedIn = _snapshot!['loggedIn'];
  }

  Future<void> login(String password) async {
    bool authed = BCrypt.checkpw(password, this.password);
    if (!(authed)) {
      throw Exception("Error : Incorrect password");
    }
    _snapshot = toMap();

    loggedIn = true;
    bool res = await UserIO.updateDB(
      User(username, password, true),
    );

    if (!res) _rollbackToSnapshot();
  }

  Future<void> update(String? username, String? newPass, String oldPass) async {
    bool authed = BCrypt.checkpw(oldPass, this.password);
    if (!(authed)) {
      throw Exception("Error : Incorrect password");
    }
    if (newPass != null) {
      this.password = newPass;
      hashPassword();
    }
    await UserIO.updateDB(User(username ?? this.username, this.password, true));
  }

  Future<void> register() async {
    _snapshot = toMap();
    hashPassword();
    await DatabaseIO.addToDB(this, "users");
  }

  void hashPassword() {
    var salt = BCrypt.gensalt();
    password = BCrypt.hashpw(password, salt);
  }

  Future<void> delete() async {
    await DatabaseIO.deleteDB(username);
  }

  Future<void> logout() async {
    _snapshot = toMap();
    //abhi ke liye no checks
    bool res = await UserIO.updateDB(User(username, password, false));
    if (!res) _rollbackToSnapshot();
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

  @override
  String toString() =>
      'User(username: $username, password: $password, loggedIn: $loggedIn)';
}
