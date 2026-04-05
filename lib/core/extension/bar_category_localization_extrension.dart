import 'package:ay_bay_app/features/common/models/category_model.dart';
import 'package:get/get.dart';

extension CategoryLocalization on CategoryModel {
  String localizedName() {
    final key = 'category_${name.toLowerCase().replaceAll(' ', '_')}';
    return key.tr; // GetX translation
  }
}