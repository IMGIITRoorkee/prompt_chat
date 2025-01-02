import 'package:dotenv/dotenv.dart';
import 'package:prompt_chat/cli/server.dart';
import 'package:prompt_chat/db/connect.dart';
import 'package:prompt_chat/cli/user.dart';

class DatabaseIO {
  DatabaseIO();
  static Future<void> addToDB(dynamic document, String collectionName) async {
    var env = DotEnv(includePlatformEnvironment: true)..load(['.env']);
    var db = await connectDB(env['MONGO_URI']!);
    //db logic
    var reqCollection = db.collection(collectionName);
    await reqCollection.insertOne(document.toMap());
    db.close();
  }

  static Future<void> deleteDB(dynamic document) async {
    var env = DotEnv(includePlatformEnvironment: true)..load(['.env']);
    var db = await connectDB(env['MONGO_URI']!);
    var reqCollection = db.collection("users");
    await reqCollection.deleteOne({'username': document});
    db.close();
  }
}

class UserIO extends DatabaseIO {
  UserIO._();
  static Future<List<User>> getAllUsers() async {
    var env = DotEnv(includePlatformEnvironment: true)..load(['.env']);
    var db = await connectDB(env['MONGO_URI']!);
    var reqUsers =
        await db.collection("users").find({"finder": "finder"}).toList();
    db.close();
    return reqUsers.map((e) => User.fromMap(e)).toList();
  }

  static Future<void> updateDB(dynamic document) async {
    var env = DotEnv(includePlatformEnvironment: true)..load(['.env']);
    var db = await connectDB(env['MONGO_URI']!);
    var reqCollection = db.collection("users");
    await reqCollection
        .replaceOne({'username': document.username}, document.toMap());
    db.close();
  }
}

class ServerIO extends DatabaseIO {
  ServerIO._();
  static Future<List<Server>> getAllServers() async {
    var env = DotEnv(includePlatformEnvironment: true)..load(['.env']);
    var db = await connectDB(env['MONGO_URI']!);
    var reqServers =
        await db.collection("servers").find({"finder": "finder"}).toList();
    db.close();
    if (reqServers == [null]) {}
    return reqServers.map((e) => Server.fromMap(e)).toList();
  }

  static Future<void> updateDB(dynamic document) async {
    var env = DotEnv(includePlatformEnvironment: true)..load(['.env']);
    var db = await connectDB(env['MONGO_URI']!);
    var reqCollection = db.collection("servers");
    await reqCollection
        .replaceOne({'serverName': document.serverName}, document.toMap());
    db.close();
  }
}
