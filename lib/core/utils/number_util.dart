import 'package:get/get.dart';

String localizedNumber(num value) {
  final str = value.toStringAsFixed(0);

  if (Get.locale?.languageCode != 'bn') return str;

  const english = ['0','1','2','3','4','5','6','7','8','9'];
  const bangla  = ['০','১','২','৩','৪','৫','৬','৭','৮','৯'];

  String result = str;
  for (int i = 0; i < english.length; i++) {
    result = result.replaceAll(english[i], bangla[i]);
  }
  return result;
}
