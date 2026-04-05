import 'package:ay_bay_app/features/common/models/category_model.dart';
import 'package:flutter/material.dart';

final List<CategoryModel> incomeCategories = [
  CategoryModel(name: 'salary', iconId: 0, color: Colors.green),
  CategoryModel(name: 'gift', iconId: 1, color: Colors.blue),
  CategoryModel(name: 'tuition', iconId: 2, color: Colors.purple),
  CategoryModel(name: 'bonus', iconId: 3, color: Colors.orange),
  CategoryModel(name: 'business', iconId: 4, color: Colors.teal),
  CategoryModel(name: 'other', iconId: 5, color: Colors.grey),
];

final List<CategoryModel> expenseCategories = [
  CategoryModel(name: 'food', iconId: 10, color: Colors.red),
  CategoryModel(name: 'transport', iconId: 11, color: Colors.brown),
  CategoryModel(name: 'shopping', iconId: 12, color: Colors.pink),
  CategoryModel(name: 'electric_bill', iconId: 13, color: Colors.yellow),
  CategoryModel(name: 'net_bill', iconId: 14, color: Colors.indigo),
  CategoryModel(name: 'gas_bill', iconId: 15, color: Colors.cyan),
  CategoryModel(name: 'bazaar', iconId: 16, color: Colors.lime),
  CategoryModel(name: 'hospital', iconId: 17, color: Colors.deepOrange),
  CategoryModel(name: 'school', iconId: 18, color: Colors.lightBlue),
  CategoryModel(name: 'other', iconId: 5, color: Colors.grey),
];
