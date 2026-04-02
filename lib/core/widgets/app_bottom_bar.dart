import 'package:flutter/material.dart';

/// A reusable bottom navigation bar widget for the application.
///
/// This widget provides a consistent navigation UI across the app
/// and allows switching between different screens using a bottom bar.
///
/// Why use this?
/// - Ensures consistent navigation design across screens
/// - Reduces duplication of BottomNavigationBar code
/// - Makes navigation logic centralized and easier to manage
///
/// Parameters:
/// - [currentIndex]: The currently selected tab index
/// - [onTap]: Callback triggered when a tab is tapped
///
/// Example usage:
/// ```dart
/// AppBottomBar(
///   currentIndex: _selectedIndex,
///   onTap: (index) {
///     setState(() => _selectedIndex = index);
///   },
/// )
/// ```
///
/// Notes:
/// - The parent widget is responsible for handling navigation logic
/// - This widget only handles UI rendering
class AppBottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AppBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.list),
          label: 'list',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.check_circle),
          label: 'bookmarks',
        ),
      ],
    );
  }
}