import 'package:sqflite/sqflite.dart';

class ErrorHandler {
  static String handle(dynamic error) {
    if (error is DatabaseException) {
      if (error.isNoSuchTableError()) {
        return "Database not initialized";
      }
      return "Database error occurred";
    }

    if (error is FormatException) {
      return "Data parsing error";
    }

    return error.toString();
  }
}