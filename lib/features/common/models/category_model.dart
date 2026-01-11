import 'package:flutter/material.dart';

class CategoryModel {
  final String name;
  final IconData icon;

  const CategoryModel({
    required this.name,
    required this.icon,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CategoryModel &&
        other.name == name &&
        other.icon.codePoint == icon.codePoint;
  }

  @override
  int get hashCode => name.hashCode ^ icon.codePoint.hashCode;
}
