import 'package:get/get.dart';

extension StringCategoryLocalization on String {
  String localizedName() {
    final lang = Get.locale?.languageCode ?? 'en';
    switch (toLowerCase()) {
      case 'salary': return lang == 'bn' ? 'বেতন' : 'Salary';
      case 'gift': return lang == 'bn' ? 'উপহার' : 'Gift';
      case 'tuition': return lang == 'bn' ? 'টিউশন' : 'Tuition';
      case 'bonus': return lang == 'bn' ? 'বোনাস' : 'Bonus';
      case 'business': return lang == 'bn' ? 'ব্যবসা' : 'Business';
      case 'food': return lang == 'bn' ? 'খাবার' : 'Food';
      case 'transport': return lang == 'bn' ? 'পরিবহন' : 'Transport';
      case 'shopping': return lang == 'bn' ? 'শপিং' : 'Shopping';
      case 'electric_bill': return lang == 'bn' ? 'বিদ্যুৎ বিল' : 'Electric Bill';
      case 'net_bill': return lang == 'bn' ? 'নেট বিল' : 'Net Bill';
      case 'gas_bill': return lang == 'bn' ? 'গ্যাস বিল' : 'Gas Bill';
      case 'bazaar': return lang == 'bn' ? 'বাজার' : 'Bazaar';
      case 'hospital': return lang == 'bn' ? 'হাসপাতাল' : 'Hospital';
      case 'school': return lang == 'bn' ? 'বিদ্যালয়' : 'School';
      case 'other': return lang == 'bn' ? 'অন্যান্য' : 'Other';
      default: return this;
    }
  }
}