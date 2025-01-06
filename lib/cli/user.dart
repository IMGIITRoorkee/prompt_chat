import 'package:bcrypt/bcrypt.dart';

import 'package:prompt_chat/db/database_crud.dart';

class User {
  late String username;
  late String password;
  var loggedIn = false;
  User(this.username, this.password, this.loggedIn);
  //to be called upon object creation
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'password': password,
      'loggedIn': loggedIn,
      'finder': "finder",
    };
  }

  static User fromMap(Map<String, dynamic> map) {
    return User(
      map['username'],
      map['password'],
      map['loggedIn'],
    );
  }

  Future<void> login(String password) async {
    bool authed = BCrypt.checkpw(password, this.password);
    if (!(authed)) {
      throw Exception("Error : Incorrect password");
    }
    loggedIn = true;
    await UserIO.updateDB(User(username, this.password, true));
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
    hashPassword();
    await DatabaseIO.addToDB(this, "users");
  }

  void hashPassword() {
    var salt = BCrypt.gensalt();
    password = BCrypt.hashpw(password, salt);
  }

  Future<void> logout() async {
    //abhi ke liye no checks
    await UserIO.updateDB(User(username, password, false));
  }

  @override
  String toString() =>
      'User(username: $username, password: $password, loggedIn: $loggedIn)';
}
