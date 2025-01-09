import 'dart:io';

class FileUtils {
  static Future<void> writeJsonToFile(
      String jsonString, String filePath) async {
    final file = File(filePath);
    Directory dir = file.parent;

    File out = File('${dir.path}/prompt_chat.json');
    await out.writeAsString(jsonString);

    print('JSON file saved at ${dir.path}/prompt_chat.json');
  }

  static bool isValidPath(String path) {
    try {
      File file = File(path);

      Directory dir = file.parent;
      if (!dir.existsSync()) {
        return false;
      }

      File tempFile = File('${dir.path}/temp_file.tmp');
      tempFile.createSync();
      tempFile.deleteSync();

      return true;
    } catch (e) {
      return false;
    }
  }
}
