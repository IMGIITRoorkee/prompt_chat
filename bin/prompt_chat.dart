import 'package:prompt_chat/constants/helpString.dart';
import 'package:prompt_chat/prompt_chat.dart';
import 'dart:io';

import 'package:prompt_chat/utils/get_flag.dart';

void main(List<String> arguments) {
  ChatAPI api = ChatAPI();
  Future.wait([api.populateArrays()]).then((value) => {runApp(api)});
  //rest of the application cannot start until above function completes.
}
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
      currentCommand = stdin.readLineSync();
      if (currentCommand == null) {
        throw Exception("Please enter a command");
      }
      var ccs = currentCommand.split(" ");
      switch (ccs[0]) {
        case "register":
          {
            var username = getFlagValue("--username", currentCommand);
            var password = getFlagValue("--password", currentCommand);
            await api.registerUser(username, password);
            print("Registration successful!");
            break;
          }
        case "login":
          {
            var username = getFlagValue("--username", currentCommand);
            var password = getFlagValue("--password", currentCommand);
            await api.loginUser(username, password);
            currUsername = username;
            print("\x1B[92m✔️  Login Successful!\n✨ Welcome, \x1B[96m$currUsername!\x1B[0m 🚀");
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
                getFlagValue("--permission", currentCommand) ?? "open";
            await api.createServer(serverName, currUsername, joinPermission);
            print("Created server successfully");
            break;
          }
        case "add-member":
          {
            var serverName = getFlagValue("--server", currentCommand);
            var memberName = getFlagValue("--member", currentCommand);
            await api.addMemberToServer(serverName, memberName, currUsername);
            print("Added member successfully");
            break;
          }
        case "add-category":
          {
            var serverName = getFlagValue("--server", currentCommand);
            var categoryName = getFlagValue("--category", currentCommand);
            await api.addCategoryToServer(
                serverName, categoryName, currUsername);
            print("Added category successfully");
            break;
          }
        case "add-channel":
          {
            var serverName = getFlagValue("--server", currentCommand);
            var channelName = getFlagValue("--channel", currentCommand);
            var channelPerms =
                getFlagValue("--permissions", currentCommand) ?? "member";
            var channelType = getFlagValue("--type", currentCommand) ?? "text";
            var parentCategory = getFlagValue("--category", currentCommand);
            await api.addChannelToServer(serverName, channelName, channelPerms,
                channelType, parentCategory, currUsername);
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
                getFlagValue("--permission", currentCommand) ?? "member";
            await api.createRole(
                serverName, roleName, permission, currUsername);
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
            print("Permission changed successfully.");
            break;
          }
        case "change-ownership":
          {
            var serverName = getFlagValue("--server", currentCommand);
            var newOwner = getFlagValue("--owner", currentCommand);
            await api.changeOwnership(serverName, currUsername, newOwner);
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
              print("Member kicked out");
            }
            break;
          }
        case 'join-server':
          {
            var serverName = getFlagValue("--server", currentCommand);
            await api.joinServer(serverName, currUsername);
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
    } on Exception catch (e) {
      print("$e");
    }
  }
}
