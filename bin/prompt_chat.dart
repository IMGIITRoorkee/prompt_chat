import 'package:prompt_chat/constants/helpString.dart';
import 'package:prompt_chat/prompt_chat.dart';
import 'dart:io';

void main(List<String> arguments) {
  ChatAPI api = ChatAPI();
  Future.wait([api.populateArrays()]).then((value) => {runApp(api)});
  //rest of the application cannot start until above function completes.
}

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
            await api.registerUser(
                ccs.elementAtOrNull(1), ccs.elementAtOrNull(2));
            print("Registration successful!");
            break;
          }
        case "login":
          {
            await api.loginUser(ccs.elementAtOrNull(1), ccs.elementAtOrNull(2));
            currUsername = ccs.elementAtOrNull(1);
            print(
                "\x1B[92m✔️  Login Successful!\n✨ Welcome, \x1B[96m$currUsername!\x1B[0m 🚀");
            break;
          }
        case "logout":
          {
            await api.logoutUser(currUsername);
            currUsername = null;
            print("Successfully logged out, see you again!");
            break;
          }
        case "update-username":
          {
            await api.updateUsername(
                ccs.elementAtOrNull(1), ccs.elementAtOrNull(2));
            currUsername = ccs.elementAtOrNull(1);
            print("Successfully updated username!");
            break;
          }
        case "update-password":
          {
            await api.updatePassword(
                ccs.elementAtOrNull(1), ccs.elementAtOrNull(2));
            print("Successfully updated password!");
            break;
          }
        case 'current-session':
          {
            print("$currUsername is logged in");
          }
        case "create-server":
          {
            await api.createServer(
                ccs.elementAtOrNull(1), currUsername, ccs.elementAtOrNull(2));
            print("Created server succesfully");
            break;
          }
        case "add-member":
          {
            await api.addMemberToServer(
                ccs.elementAtOrNull(1), ccs.elementAtOrNull(2), currUsername);
            print("Added member successfully");
            break;
          }
        case "add-category":
          {
            await api.addCategoryToServer(
                ccs.elementAtOrNull(1), ccs.elementAtOrNull(2), currUsername);
            print("Added category successfully");
            break;
          }
        case "add-channel":
          {
            await api.addChannelToServer(
                ccs.elementAtOrNull(1),
                ccs.elementAtOrNull(2),
                ccs.elementAtOrNull(3),
                ccs.elementAtOrNull(4),
                ccs.elementAtOrNull(5),
                currUsername);
            print("Added channel successfully");
            break;
          }
        case "send-msg":
          {
            print("Enter the text message to be sent");
            var message = stdin.readLineSync();
            await api.sendMessageInServer(ccs.elementAtOrNull(1), currUsername,
                ccs.elementAtOrNull(2), message);
            print('Message sent succesfully');
            break;
          }
        case "display-messages":
          {
            api.displayMessages(ccs.elementAtOrNull(1));
            break;
          }
        case "display-users":
          {
            api.displayUsers();
            break;
          }
        case "search-users":
          {
            api.searchUsers(ccs.elementAtOrNull(1));
            break;
          }
        case "search-servers":
          {
            api.searchServers(ccs.elementAtOrNull(1));
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
            await api.createRole(ccs.elementAtOrNull(1), ccs.elementAtOrNull(2),
                ccs.elementAtOrNull(3), currUsername);
            print("Role created successfully");
            break;
          }
        case "assign-role":
          {
            await api.addRoleToUser(ccs.elementAtOrNull(1),
                ccs.elementAtOrNull(2), ccs.elementAtOrNull(3), currUsername);
            print("Role assigned successfully");
            break;
          }
        case "channel-to-cat":
          {
            await api.addChannelToCategory(ccs.elementAtOrNull(1),
                ccs.elementAtOrNull(2), ccs.elementAtOrNull(3), currUsername);
            print("Channel added to category");
            break;
          }
        case "change-perm":
          {
            await api.changePermission(ccs.elementAtOrNull(1),
                ccs.elementAtOrNull(2), ccs.elementAtOrNull(3), currUsername);
            print("Permission changed successfully.");
            break;
          }
        case "change-ownership":
          {
            await api.changeOwnership(
                ccs.elementAtOrNull(1), currUsername, ccs.elementAtOrNull(2));
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
              await api.leaveServer(ccs.elementAtOrNull(1), currUsername);
              print("Member deleted");
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
              await api.kickoutFromServer(
                  ccs.elementAtOrNull(1), ccs.elementAtOrNull(2), currUsername);
              print("Member kicked out");
            }
            break;
          }
        case 'join-server':
          {
            await api.joinServer(ccs.elementAtOrNull(1), currUsername);
            print("Server joined successfully.");
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
