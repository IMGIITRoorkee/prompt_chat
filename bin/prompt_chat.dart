import 'package:prompt_chat/cli/exceptions/timeout.dart';
import 'package:prompt_chat/cli/logsysten/logger_service.dart';
import 'package:prompt_chat/constants/helpString.dart';
import 'package:prompt_chat/prompt_chat.dart';
import 'dart:io';
import 'dart:async';
import 'package:prompt_chat/utils/get_flag.dart';

// Create a broadcast stream that can be listened to multiple times
final stdinBroadcast = stdin.asBroadcastStream();

Future<String?> getUserInputWithTimeout() async {
  Completer<String?> completer = Completer<String?>();
  StreamSubscription? subscription;

  // Set timeout
  Timer timeout = Timer(Duration(minutes: 10), () {
    if (!completer.isCompleted) {
      completer.complete(null);
      subscription?.cancel();
    }
  });

  // Listen to the broadcast stream
  subscription = stdinBroadcast.listen(
    (List<int> event) {
      if (!completer.isCompleted) {
        String input = String.fromCharCodes(event).trim();
        completer.complete(input);
        timeout.cancel();
      }
    },
    onError: (error) {
      if (!completer.isCompleted) {
        completer.completeError(error);
        timeout.cancel();
      }
    },
  );

  try {
    return await completer.future;
  } finally {
    subscription.cancel();
    timeout.cancel();
  }
}


void main(List<String> arguments) async{
  final logger = LogService();
  await logger.initLogFile(); // Initialize log file
  ChatAPI api = ChatAPI();
  Future.wait([api.populateArrays()]).then((value) => {runApp(api)});
}

final logger = LogService();

void clearCLI() {
  print("\x1B[2J\x1B[H"); // Clear the terminal
}

void printWelcomeText() {
  const String reset = '\x1B[0m'; // Reset text style
  const String cyan = '\x1B[96m'; // Bright cyan
  const String yellow = '\x1B[93m'; // Bright yellow
  const String green = '\x1B[92m'; // Bright green


  print(
      '$cyan Welcome to $yellow prompt_chat! $reset'); // Highlight app name in yellow
  print(
      '$green Read the documentation to get started on using the interface.$reset');
  print(
      '$cyan Type "exit" to close the application.$reset');
}
void runApp(ChatAPI api) async {
  String? currUsername;
  String? currentCommand;
  currUsername = api.getCurrentLoggedIn();
clearCLI();
  printWelcomeText();
  loop:
  while (true) {
    try {
      currentCommand = await getUserInputWithTimeout();

      if (currentCommand == null) {
        api.logoutUser(currUsername);
        throw TimedoutLogoutException();
      }
      var ccs = currentCommand.split(" ");
      switch (ccs[0]) {
        case "register":
          {
            var username = getFlagValue("--username", currentCommand);
            var password = getFlagValue("--password", currentCommand);
            await api.registerUser(username, password);
            print("Registration successful!");
            logger.info("User registered", ccs[1]);
            break;
          }
        case "login":
          {
            var username = getFlagValue("--username", currentCommand);
            var password = getFlagValue("--password", currentCommand);
            await api.loginUser(username, password);
            currUsername = username;
            print("\x1B[92m✔️  Login Successful!\n✨ Welcome, \x1B[96m$currUsername!\x1B[0m 🚀");
            logger.info("User logged in", ccs[1]);
            break;
          }
        case "logout":
          {
            await api.logoutUser(currUsername);
            logger.info("User logged out", currUsername as String);
            currUsername = null;
            print("Successfully logged out, see you again!");
            break;
          }
        case "update-username":
          {
            await api.updateUsername(ccs[1], ccs[2]);
            currUsername = ccs[1];
            print("Successfully updated username!");
            break;
          }
        case "update-password":
          {
            await api.updatePassword(ccs[1], ccs[2]);
            print("Successfully updated password!");
            break;
          }
        case 'current-session':
          {
            print("$currUsername is logged in");
            break;
          }
        case "create-server":
          {
            var serverName = getFlagValue("--name", currentCommand);
            var joinPermission =
                getFlagValue("--permission", currentCommand);
            await api.createServer(serverName, currUsername, joinPermission);
            logger.info("Created new server $serverName", currUsername as String);
            print("Created server successfully");
            break;
          }
        case "add-member":
          {
            var serverName = getFlagValue("--server", currentCommand);
            var memberName = getFlagValue("--member", currentCommand);
            await api.addMemberToServer(serverName, memberName, currUsername);
            logger.info("Added member $memberName to server $serverName", currUsername as String);
            print("Added member successfully");
            break;
          }
        case "add-category":
          {
            var serverName = getFlagValue("--server", currentCommand);
            var categoryName = getFlagValue("--category", currentCommand);
            await api.addCategoryToServer(
                serverName, categoryName, currUsername);
            logger.info("Added category $categoryName to server $serverName", currUsername as String);
            print("Added category successfully");
            break;
          }
        case "add-channel":
          {
            var serverName = getFlagValue("--server", currentCommand);
            var channelName = getFlagValue("--channel", currentCommand);
            var channelPerms =
                getFlagValue("--permissions", currentCommand);
            var channelType = getFlagValue("--type", currentCommand);
            var parentCategory = getFlagValue("--category", currentCommand);
            await api.addChannelToServer(serverName, channelName, channelPerms,
                channelType, parentCategory, currUsername);
            logger.info("Added channel $channelName to server $serverName", currUsername as String);
            print("Added channel successfully");
            break;
          }
        case "send-msg":
          {
            var serverName = getFlagValue("--server", currentCommand);
            var channelName = getFlagValue("--channel", currentCommand);
            print("Enter the text message to be sent");
            var message = stdin.readLineSync();
            await api.sendMessageInServer(
                serverName, currUsername, channelName, message);
            logger.info("Sent message in server '$serverName' channel '$channelName'", currUsername as String);
            print('Message sent successfully');
            break;
          }
        case "display-messages":
          {
            var serverName = getFlagValue("--server", currentCommand);
            api.displayMessages(serverName);
            break;
          }
        case "display-users":
          {
            api.displayUsers();
            break;
          }
        case "search-users":
          {
            api.searchUsers(ccs[1]);
            break;
          }
        case "search-servers":
          {
            api.searchServers(ccs[1]);
            break;
          }
        case "display-channels":
          {
            api.displayChannels();
            break;
          }
        case "display-my-servers":
          {
            api.displayUserServers();
            break;
          }
        case "create-role":
          {
            var serverName = getFlagValue("--server", currentCommand);
            var roleName = getFlagValue("--role", currentCommand);
            var permission =
                getFlagValue("--permission", currentCommand);
            await api.createRole(
                serverName, roleName, permission, currUsername);
            logger.info("Created role $roleName in server $serverName", currUsername as String);
            print("Role created successfully");
            break;
          }
        case "assign-role":
          {
            var serverName = getFlagValue("--server", currentCommand);
            var roleName = getFlagValue("--role", currentCommand);
            var memberName = getFlagValue("--member", currentCommand);
            await api.addRoleToUser(
                serverName, roleName, memberName, currUsername);
            logger.info("Assigned role $roleName to user $memberName in server $serverName", currUsername as String);
            print("Role assigned successfully");
            break;
          }
        case "channel-to-cat":
          {
            var serverName = getFlagValue("--server", currentCommand);
            var channelName = getFlagValue("--channel", currentCommand);
            var categoryName = getFlagValue("--category", currentCommand);
            await api.addChannelToCategory(
                serverName, channelName, categoryName, currUsername);
             logger.info("Added channel $channelName to category $categoryName", currUsername as String);
            print("Channel added to category");
            break;
          }
        case "change-perm":
          {
            var serverName = getFlagValue("--server", currentCommand);
            var channelName = getFlagValue("--channel", currentCommand);
            var newPerm = getFlagValue("--permission", currentCommand);
            await api.changePermission(
                serverName, channelName, newPerm, currUsername);
            logger.info("Changed permission $newPerm in server $serverName", currUsername as String);
            print("Permission changed successfully.");
            break;
          }
        case "change-ownership":
          {
            var serverName = getFlagValue("--server", currentCommand);
            var newOwner = getFlagValue("--owner", currentCommand);
            await api.changeOwnership(serverName, currUsername, newOwner);
            logger.info("Changed ownership in server $serverName to $newOwner", currUsername as String);
            break;
          }
        case "leave-server":
          {
            var serverName = getFlagValue("--server", currentCommand);
            print("Are you sure you want to proceed? (y/n)");
            var confirm = stdin.readLineSync();
            if (confirm == null) {
              break;
            }
            confirm = confirm.toLowerCase();
            if (confirm == "y" || confirm == "yes") {
              await api.leaveServer(serverName, currUsername);
              print("Member deleted");
            logger.info("Left server $ccs[1]", currUsername as String);
            }
            break;
          }
        case "kickout-member":
          {
            var serverName = getFlagValue("--server", currentCommand);
            var memberName = getFlagValue("--member", currentCommand);
            print("Are you sure you want to proceed? (y/n)");
            var confirm = stdin.readLineSync();
            if (confirm == null) {
              break;
            }
            confirm = confirm.toLowerCase();
            if (confirm == "y" || confirm == "yes") {
              await api.kickoutFromServer(serverName, memberName, currUsername);
              logger.info("Kicked out member $memberName from server $serverName", currUsername as String);
              print("Member kicked out");
            }
            break;
          }
        case 'join-server':
          {
            var serverName = getFlagValue("--server", currentCommand);
            await api.joinServer(serverName, currUsername);
            logger.info("Joined server $serverName", currUsername as String);
            print("Server joined successfully.");
            break;
          }
        case "create-invite-code":
        {
          if (currUsername == null) {
            throw Exception("Please login to create an invite code.");
          }
          var code = await api.createInviteCode(ccs[1], currUsername);
          print("Invite code created successfully. \n Use code: $code");
          break;
        }
        case"join-server-with-code":
        {
          if (currUsername == null) {
            throw Exception("Please login to create an invite code.");
          }
          await api.joinServerWithCode(ccs[1], currUsername);
          print("Server joined successfully.");
          break;
        }
        case 'clear-screen':
          {
            print("\x1B[2J\x1B[H");
            break;
          }
        case "exit":
          {
            print("See you soon!");
            break loop;
          }
          case "display-logs":
          {
            print(await logger.getLogs());
            break;
          }
        case "help":
          {
            print(helpText);
          }
        case "send-dm":
          {
            if (currUsername == null) {
              print("Please login to send a direct message.");
              break;
            }
          print("Enter the message:");
          var message = stdin.readLineSync();
          if (message == null) {
            print("Please enter a message.");
            break;
          }
          api.sendDm(ccs[1], message,currUsername);
        }
        case "display-dms":
          {
            if (currUsername == null) {
              print("Please login to view direct messages.");
              break;
            }
            List<String> messages = await api.getRecievedDms(currUsername);
            for (var element in messages) {
              print(element);
            }
            break;
          }
        case "display-sent-dms":
        {
          if (currUsername == null) {
            print("Please login to view direct messages.");
            break;
          }
          List<String> messages = await api.getSentDms(currUsername);
          for (var element in messages) {
            print(element);
          }
          break;
        }
        case "delete-user":
          {
            if (currUsername == null) {
              print("Please login first.");
              break;
            }
            await api.logoutUser(currUsername);
            currUsername = null;
            api.deleteUser(currUsername);
            print("User deleted successfully.");
          }
        default:
          {
            print("Please enter a valid command.");
          }
      }
    } on TimedoutLogoutException {
      print("User has been logged out due to inactivity.");
      break loop;
    } on Exception catch (e) {
      print("$e");
    }
  }
}
