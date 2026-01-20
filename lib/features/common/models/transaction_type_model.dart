import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum TransactionType { income, expense }

class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final String category;
  final int categoryIcon; // ✅ নতুন field
  final DateTime date;
  final bool isMonthly;
  final String monthId;
  final String monthName;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.categoryIcon, // constructor update
    required this.date,
    required this.isMonthly,
    required this.monthId,
    required this.monthName,
  });

  factory TransactionModel.fromJson(String id, Map<String, dynamic> json) {
    return TransactionModel(
      id: id,
      title: json['title'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      type: _parseType(json['type']),
      category: json['category'] ?? '',
      categoryIcon: json['categoryIcon'] ?? 0, // default icon
      date: json['date'] is Timestamp
          ? (json['date'] as Timestamp).toDate()
          : DateTime.now(),
      isMonthly: json['isMonthly'] ?? false,
      monthId: '',
      monthName: '',
    );
  }

  TransactionModel copyWith({
    String? monthId,
    String? monthName,
    bool? isMonthly,
  }) {
    return TransactionModel(
      id: id,
      title: title,
      amount: amount,
      type: type,
      category: category,
      categoryIcon: categoryIcon, // copyWith এ থাকছে
      date: date,
      isMonthly: isMonthly ?? this.isMonthly,
      monthId: monthId ?? this.monthId,
      monthName: monthName ?? this.monthName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'amount': amount,
      'type': type == TransactionType.income ? 'income' : 'expense',
      'category': category,
      'categoryIcon': categoryIcon, // ✅ save করবো Firestore-এ
      'date': Timestamp.fromDate(date),
      'isMonthly': isMonthly,
    };
  }

  static TransactionType _parseType(String? type) {
    switch (type) {
      case 'income':
        return TransactionType.income;
      case 'expense':
        return TransactionType.expense;
      default:
        return TransactionType.expense;
    }
  }
}
