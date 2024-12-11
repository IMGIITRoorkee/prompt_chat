import 'package:prompt_chat/db/database_crud.dart';
import 'package:bcrypt/bcrypt.dart';

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
    await UserIO.updateDB(
        User(
            username,
            password,
            true
            ));
  }

  Future<void> register() async {
    var salt = BCrypt.gensalt();
    password = BCrypt.hashpw(password, salt);
    await DatabaseIO.addToDB(this, "users");
  }

  Future<void> logout() async {
    //abhi ke liye no checks
    await UserIO.updateDB(
        User(
            username,
            password,
            false
            ));
  }
}