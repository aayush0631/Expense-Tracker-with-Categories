import 'package:sqflite/sqflite.dart';

class ErrorHandler {
  static String getMessage(dynamic error) {
    if (error is DatabaseException) {
      return "Database error occurred";
    }

    if (error.toString().contains("no such table")) {
      return "Local database is corrupted";
    }

    if (error.toString().contains("invalid")) {
      return "Invalid data format";
    }

    return "went wrong";
  }
}