import 'package:flutter/material.dart';

/// A reusable widget that displays an icon alongside text.
///
/// This widget is useful for compact UI elements such as:
/// - List items
/// - Metadata display (e.g., location, price, rating)
/// - Cards and summaries
///
/// Why use this?
/// - Avoids repeating Row + Icon + Text pattern
/// - Ensures consistent spacing and styling
/// - Handles text overflow automatically
///
/// Parameters:
/// - [icon]: The icon to display
/// - [text]: The text content
/// - [iconColor]: Optional color for the icon (default: grey)
/// - [iconSize]: Size of the icon (default: 15)
/// - [textStyle]: Optional custom text styling
///
/// Example usage:
/// ```dart
/// IconText(
///   icon: Icons.location_on,
///   text: 'Kathmandu',
/// )
/// ```
///
/// Notes:
/// - Uses [Expanded] to prevent overflow
/// - Text will truncate with ellipsis if too long
class IconText extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? iconColor;
  final double iconSize;
  final TextStyle? textStyle;

  const IconText({
    super.key,
    required this.icon,
    required this.text,
    this.iconColor,
    this.iconSize = 15,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor ?? Colors.grey, size: iconSize),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: textStyle ?? const TextStyle(fontSize: 13),
          ),
        ),
      ],
    );
  }
}