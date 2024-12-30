import 'package:prompt_chat/db/database_crud.dart';
import 'package:bcrypt/bcrypt.dart';

class User {
  late String username;
  late String password;
  var loggedIn = false;

  Map<String, dynamic>? _snapshot;

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

  Future<void> register() async {
    _snapshot = toMap();

    var salt = BCrypt.gensalt();
    password = BCrypt.hashpw(password, salt);
    bool res = await DatabaseIO.addToDB(this, "users");

    if (!res) _rollbackToSnapshot();
  }

  Future<void> logout() async {
    _snapshot = toMap();
    //abhi ke liye no checks
    bool res = await UserIO.updateDB(User(username, password, false));
    if (!res) _rollbackToSnapshot();
  }
}
