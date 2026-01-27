import 'package:ay_bay_app/core/localization/controllers/localization_controller.dart';
import 'package:ay_bay_app/features/common/controller/controller_binding.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ay_bay_app/l10n/app_localizations.dart';


import 'app_colors.dart';
import 'app_routes.dart';

class AyBayApp extends StatefulWidget {
  const AyBayApp({super.key});

  @override
  State<AyBayApp> createState() => _AyBayAppState();
}

class _AyBayAppState extends State<AyBayApp> {
  final localeController = Get.put(LocaleController());


  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      //onGenerateRoute: AppRoutes.onGenerateRoute,
      getPages: AppRoutes.pages,
      theme: ThemeData(
        textTheme: TextTheme(
          titleLarge: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(color: AppColors.textFieldTitleColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppColors.textFieldBorderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppColors.textFieldBorderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppColors.textFieldBorderColor),
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.loginTextButtonColor,
            padding: EdgeInsets.symmetric(horizontal: 60, vertical: 10),
          ),
        ),
      ),
      initialBinding: ControllerBinding(),
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: localeController.initialLocale,
      supportedLocales: [
        Locale('en'), // English
        Locale('bn'), // Bangle
      ],

    );
  }
}