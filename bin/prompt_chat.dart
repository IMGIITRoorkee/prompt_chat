import 'package:prompt_chat/prompt_chat.dart';
import 'dart:io';

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
            await api.registerUser(ccs[1], ccs[2]);
            print("Registration successful!");
            break;
          }
        case "login":
          {
            await api.loginUser(ccs[1], ccs[2]);
            currUsername = ccs[1];
            print("Login successful!");
            break;
          }
        case "logout":
          {
            await api.logoutUser(currUsername);
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
            print("Created server succesfully");
            break;
          }
        case "add-member":
          {
            await api.addMemberToServer(ccs[1], ccs[2], currUsername);
            print("Added member successfully");
            break;
          }
        case "add-category":
          {
            await api.addCategoryToServer(ccs[1], ccs[2], currUsername);
            print("Added category successfully");
            break;
          }
        case "add-channel":
          {
            await api.addChannelToServer(
                ccs[1], ccs[2], ccs[3], ccs[4], ccs[5], currUsername);
            print("Added channel successfully");
            break;
          }
        case "send-msg":
          {
            print("Enter the text message to be sent");
            var message = stdin.readLineSync();
            await api.sendMessageInServer(
                ccs[1], currUsername, ccs[2], message);
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
        case "display-channels":
          {
            api.displayChannels();
            break;
          }
        case "create-role":
          {
            await api.createRole(ccs[1], ccs[2], ccs[3], currUsername);
            print("Role created successfully");
            break;
          }
        case "assign-role":
          {
            await api.addRoleToUser(ccs[1], ccs[2], ccs[3], currUsername);
            print("Role assigned successfully");
            break;
          }
        case "channel-to-cat":
          {
            await api.addChannelToCategory(
                ccs[1], ccs[2], ccs[3], currUsername);
            print("Channel added to category");
            break;
          }
        case "change-perm":
          {
            await api.changePermission(ccs[1], ccs[2], ccs[3], currUsername);
            print("Permission changed successfully.");
            break;
          }
        case "change-ownership":
          {
            await api.changeOwnership(ccs[1], currUsername, ccs[2]);
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
              print("Member kicked out");
            }
            break;
          }
        case 'join-server':
          {
            await api.joinServer(ccs[1], currUsername);
            print("Server joined successfully.");
          }
        case "exit":
          {
            print("See you soon!");
            break loop;
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
