import 'package:flutter/material.dart';

class SafeText extends StatelessWidget {
  /// Accepts anything safely (String, int, null, etc.)
  final dynamic value;

  /// Optional text style
  final TextStyle? style;

  /// Optional max lines
  final int? maxLines;

  /// Optional overflow
  final TextOverflow? overflow;

  /// Optional alignment
  final TextAlign? textAlign;

  /// Optional formatter (highest priority)
  final String Function(String)? formatter;

  /// Convert text to normalized title (Basic Wash)
  final bool titleCase;

  const SafeText(
    this.value, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.formatter,
    this.titleCase = false,
  });

  @override
  Widget build(BuildContext context) {
    String text = value?.toString() ?? '';

    // 🔹 Custom formatter (highest priority)
    if (formatter != null) {
      text = formatter!(text);
    }
    // 🔹 Normalize wash types
    else {
      text = _normalizeWashType(text);
    }

    return Text(
      text,
      style: style,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
    );
  }

  /// 🔹 Converts any wash variant to correct display
  /// basic → Basic Wash
  /// deep → Deep Wash
  /// full → Full Wash
  String _normalizeWashType(String text) {
    final normalized = text.trim().toLowerCase();

    switch (normalized) {
      case 'basic':
      case 'basic wash':
        return 'Basic Wash';

      case 'full':
      case 'full wash':
        return 'Full Wash';

      case 'deep':
      case 'deep wash':
        return 'Deep Wash';

      default:
        return titleCase ? _toTitleCase(text) : text;
    }
  }

  /// Converts "basic wash" → "Basic Wash"
  String _toTitleCase(String text) {
    if (text.isEmpty) return text;

    return text
        .split(' ')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1)}'
            : word)
        .join(' ');
  }
}