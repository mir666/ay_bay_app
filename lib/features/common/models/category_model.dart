import 'package:flutter/material.dart';

class CategoryModel {
  final String name;
  final int iconId;
  final Color color; // নতুন ফিল্ড

  const CategoryModel({
    required this.name,
    required this.iconId,
    required this.color, // constructor-এ যোগ
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CategoryModel &&
        other.name == name &&
        other.iconId == iconId &&
        other.color == color; // color এর তুলনা
  }

  @override
  int get hashCode => name.hashCode ^ iconId.hashCode ^ color.hashCode;
}