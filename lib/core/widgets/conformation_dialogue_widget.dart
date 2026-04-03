import 'package:flutter/material.dart';

/// Displays a reusable confirmation dialog.
///
/// This dialog is used to confirm user actions such as:
/// - Booking confirmation
/// - Deletion actions
/// - Critical operations
///
/// Why use this?
/// - Avoids repeating AlertDialog code
/// - Ensures consistent dialog UI across the app
/// - Centralizes dialog behavior
///
/// Parameters:
/// - [context]: BuildContext required to show the dialog
/// - [title]: Title displayed at the top of the dialog
/// - [content]: Description/message shown inside the dialog
/// - [confirmText]: Text for the confirmation button
///
/// Returns:
/// - `true` → if user confirms
/// - `false` → if user cancels
/// - `null` → if dialog is dismissed
///
/// Example usage:
/// ```dart
/// final result = await conformationDialog(
///   context: context,
///   title: 'Confirm Booking',
///   content: 'Are you sure?',
///   confirmText: 'Book',
/// );
///
/// if (result == true) {
///   // proceed with action
/// }
/// ```
///
/// Note:
/// - This function uses [showDialog] internally
/// - Caller must handle the result asynchronously
Future<bool?> conformationDialog({
  required BuildContext context,
  required String title,
  required String content,
  required String confirmText,
}) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      );
    },
  );
}