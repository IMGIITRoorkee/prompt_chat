import 'dart:convert';
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

  static Future<Map<String, dynamic>> readJsonFromFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!file.existsSync()) {
        throw Exception('The file does not exist.');
      }

      String content = await file.readAsString();
      Map<String, dynamic> jsonData = jsonDecode(content);

      return jsonData;
    } catch (e) {
      print('Error reading JSON file: $e');
      return {};
    }
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
