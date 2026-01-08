import 'package:flutter/material.dart';

Widget searchHighlightText(
  String text,
  String query, {
  Color highlightColor = Colors.blue,
  FontWeight fontWeight = FontWeight.bold,
}) {
  if (query.isEmpty) {
    return Text(text);
  }

  final lowerText = text.toLowerCase();
  final lowerQuery = query.toLowerCase();

  if (!lowerText.contains(lowerQuery)) {
    return Text(text);
  }

  final start = lowerText.indexOf(lowerQuery);
  final end = start + query.length;

  return RichText(
    text: TextSpan(
      children: [
        TextSpan(
          text: text.substring(0, start),
          style: const TextStyle(color: Colors.black),
        ),
        TextSpan(
          text: text.substring(start, end),
          style: TextStyle(color: highlightColor, fontWeight: fontWeight),
        ),
        TextSpan(
          text: text.substring(end),
          style: const TextStyle(color: Colors.black),
        ),
      ],
    ),
  );
}
