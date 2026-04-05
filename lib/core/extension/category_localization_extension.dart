import 'package:ay_bay_app/features/common/models/category_model.dart';
import 'package:flutter/material.dart';

import 'localization_extension.dart';

extension CategoryLocalization on CategoryModel {
  String localizedName(BuildContext context) {
    final categoryLocalization = context.localization;

    switch (name) { // 🔴 key না, name
      case 'salary':
        return categoryLocalization.category_salary;
      case 'gift':
        return categoryLocalization.category_gift;
      case 'tuition':
        return categoryLocalization.category_tuition;
      case 'bonus':
        return categoryLocalization.category_bonus;
      case 'business':
        return categoryLocalization.category_business;

      case 'food':
        return categoryLocalization.category_food;
      case 'transport':
        return categoryLocalization.category_transport;
      case 'shopping':
        return categoryLocalization.category_shopping;
      case 'electric_bill':
        return categoryLocalization.category_electric_bill;
      case 'net_bill':
        return categoryLocalization.category_net_bill;
      case 'gas_bill':
        return categoryLocalization.category_gas_bill;
      case 'bazaar':
        return categoryLocalization.category_bazaar;
      case 'hospital':
        return categoryLocalization.category_hospital;
      case 'school':
        return categoryLocalization.category_school;

      default:
        return categoryLocalization.category_other;
    }
  }
}
