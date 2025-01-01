import 'package:prompt_chat/cli/logsysten/logger_service.dart';
import 'package:prompt_chat/constants/helpString.dart';
import 'package:prompt_chat/prompt_chat.dart';
import 'dart:io';

void main(List<String> arguments) async{
  final logger = LogService();
  await logger.initLogFile(); // Initialize log file
  ChatAPI api = ChatAPI();
  Future.wait([api.populateArrays()]).then((value) => {runApp(api)});
  //rest of the application cannot start until above function completes.
}
final logger = LogService();

void runApp(ChatAPI api) async {
  String? currUsername;
  String? currentCommand;
  currUsername = api.getCurrentLoggedIn();
  print(
      "Welcome to prompt_chat! Read the documentation to get started on using the interface. Type \"exit\" to close the application.Type \"help\" for a list of commands.");
  loop:
  while (true) {
    try {
      currentCommand = stdin.readLineSync();
      if (currentCommand == null) {
        throw Exception("Please enter a command");
      }
      var ccs = currentCommand.split(" ");
      switch (ccs[0]) {
        case "register":
          {
            await api.registerUser(ccs[1], ccs[2]);
            print("Registration successful!");
            logger.info("User registered", ccs[1]);
            break;
          }
        case "login":
          {
            await api.loginUser(ccs[1], ccs[2]);
            currUsername = ccs[1];
            print("Login successful!");
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
        case 'current-session':
          {
            print("$currUsername is logged in");
          }
        case "create-server":
          {
            await api.createServer(ccs[1], currUsername, ccs[2]);
            logger.info("Created new server $ccs[1]", currUsername as String);
            print("Created server succesfully");
            break;
          }
        case "add-member":
          {
            await api.addMemberToServer(ccs[1], ccs[2], currUsername);
            logger.info("Added member $ccs[2] to server $ccs[1]", currUsername as String);
            print("Added member successfully");
            break;
          }
        case "add-category":
          {
            await api.addCategoryToServer(ccs[1], ccs[2], currUsername);
            logger.info("Added category $ccs[2] to server $ccs[1]", currUsername as String);
            print("Added category successfully");
            break;
          }
        case "add-channel":
          {
            await api.addChannelToServer(
                ccs[1], ccs[2], ccs[3], ccs[4], ccs[5], currUsername);
            logger.info("Added channel $ccs[2] to server $ccs[1]", currUsername as String);
            print("Added channel successfully");
            break;
          }
        case "send-msg":
          {
            print("Enter the text message to be sent");
            var message = stdin.readLineSync();
            await api.sendMessageInServer(
                ccs[1], currUsername, ccs[2], message);
            logger.info("Sent message in server '$ccs[1]' channel '$ccs[2]'", currUsername as String);
            print('Message sent succesfully');
            break;
          }
        case "display-messages":
          {
            api.displayMessages(ccs[1]);
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
            await api.createRole(ccs[1], ccs[2], ccs[3], currUsername);
            logger.info("Created role $ccs[2] in server $ccs[1]", currUsername as String);
            print("Role created successfully");
            break;
          }
        case "assign-role":
          {
            await api.addRoleToUser(ccs[1], ccs[2], ccs[3], currUsername);
            logger.info("Assigned role $ccs[2] to user $ccs[3] in server $ccs[1]", currUsername as String);
            print("Role assigned successfully");
            break;
          }
        case "channel-to-cat":
          {
            await api.addChannelToCategory(
                ccs[1], ccs[2], ccs[3], currUsername);
            logger.info("Added channel $ccs[3] to category $ccs[2]", currUsername as String);
            print("Channel added to category");
            break;
          }
        case "change-perm":
          {
            await api.changePermission(ccs[1], ccs[2], ccs[3], currUsername);
            logger.info("Changed permission $ccs[3] in server $ccs[1]", currUsername as String);
            print("Permission changed successfully.");
            break;
          }
        case "change-ownership":
          {
            await api.changeOwnership(ccs[1], currUsername, ccs[2]);
            logger.info("Changed ownership in server $ccs[1] to $ccs[2]", currUsername as String);
            break;
          }
        case "leave-server":
          {
            print("Are you sure you want to proceed? (y/n)");
            var confirm = stdin.readLineSync();
            if (confirm == null) {
              break;
            }
            confirm = confirm.toLowerCase();
            if (confirm == "y" || confirm == "yes") {
              await api.leaveServer(ccs[1], currUsername);
              print("Member deleted");
            logger.info("Left server $ccs[1]", currUsername as String);
            }
            break;
          }
        case "kickout-member":
          {
            print("Are you sure you want to proceed? (y/n)");
            var confirm = stdin.readLineSync();
            if (confirm == null) {
              break;
            }
            confirm = confirm.toLowerCase();
            if (confirm == "y" || confirm == "yes") {
              await api.kickoutFromServer(ccs[1], ccs[2], currUsername);
            logger.info("Kicked out member $ccs[2] from server $ccs[1]", currUsername as String);
              print("Member kicked out");
            }
            break;
          }
        case 'join-server':
          {
            await api.joinServer(ccs[1], currUsername);
            logger.info("Joined server $ccs[1]", currUsername as String);
            print("Server joined successfully.");
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
        case "help":
          {
            print(helpText);
          }
        default:
          {
            print("Please enter a valid command.");
          }
      }
    } on Exception catch (e) {
      print("$e");
    }
  }
}
