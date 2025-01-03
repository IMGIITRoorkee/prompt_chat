import 'dart:io';

class LogService {
  static final LogService _instance = LogService._internal();
  factory LogService() => _instance;

  late File _logFile;

  LogService._internal();

  /// Initialize log file
  Future<void> initLogFile() async {
    final directory = Directory.current.path; // Use current working directory
    _logFile = File('$directory/app_logs.log');
    if (!(await _logFile.exists())) {
      await _logFile.create(); // Create the file if it doesn't exist
    }
  }

  /// Write logs to file
  Future<void> logToFile(String message, String user) async {
    final time = DateTime.now().toIso8601String();
    final logMessage = '[$time] $user: $message\n';
    await _logFile.writeAsString(logMessage, mode: FileMode.append);
  }

  /// Log an info message
  void info(String message, String user) {
    logToFile('[INFO] $message', user);
  }


  /// Log an error message
  void error(String message, String user) {
    logToFile('[ERROR] $message',user);
  }

  /// Fetch the contents of the log file as a string
  Future<String> getLogs() async {
    try {
      if (await _logFile.exists()) {
        return await _logFile.readAsString(); // Read and return logs
      } else {
        return 'No logs available.';
      }
    } catch (e) {
      return 'Error reading logs: $e';
    }
  }
}
