import 'dart:convert';
import 'dart:io';
import 'package:ay_bay_app/app/app_colors.dart';
import 'package:ay_bay_app/core/extension/localization_extension.dart';
import 'package:ay_bay_app/core/extension/transaction_category_localization.dart';
import 'package:ay_bay_app/core/profile/controllers/saving_controller.dart';
import 'package:ay_bay_app/core/profile/models/saving_model.dart';
import 'package:ay_bay_app/core/settings/controllers/settings_controller.dart';
import 'package:ay_bay_app/core/utils/number_util.dart';
import 'package:ay_bay_app/features/common/data/category_data.dart';
import 'package:ay_bay_app/features/common/models/category_model.dart';
import 'package:ay_bay_app/features/common/models/transaction_type_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ay_bay_app/features/home/controllers/home_controller.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:ay_bay_app/core/profile/controllers/user_controller.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

class ProfileScreen extends StatelessWidget {
  final double radius;

  ProfileScreen({super.key, this.radius = 60});

  final HomeController homeController = Get.find<HomeController>();
  final UserController userController = Get.find<UserController>();

  String localizedMonthName(String? monthName) {
    if (monthName == null || monthName.isEmpty) return '';
    try {
      final monthNumber = DateFormat('MMMM', 'en').parse(monthName).month;
      final date = DateTime(DateTime.now().year, monthNumber);
      return DateFormat.MMMM(Get.locale?.languageCode ?? 'en').format(date);
    } catch (e) {
      return monthName; // fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final _ = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.localization.profile,
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: AppColors.loginTextButtonColor,
      ),
      body: Obx(() {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildProfileHeader(context, size),
              SizedBox(height: size.height * 0.01),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        title: context.localization.transactions,
                        value: localizedNumber(
                          homeController.allTransactions.length,
                        ),
                        icon: Icons.swap_horiz,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        title: context.localization.income,
                        value: localizedNumber(homeController.income.value),
                        icon: Icons.trending_up,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        title: context.localization.expense,
                        value: localizedNumber(homeController.expense.value),
                        icon: Icons.trending_down,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: size.height * 0.01),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: _premiumCard(
                  child: ListTile(
                    leading: Icon(Icons.download, color: Colors.orangeAccent),
                    title: Text(context.localization.downloadPDF),
                    trailing: Icon(Icons.arrow_forward_ios, size: 18),
                    onTap: () => _showDownloadPdfDialog(context),
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: _premiumCard(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              context.localization.savingsGoals,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () {
                                _showAddGoalDialog(context);
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 4),

                        /// Goals List
                        Obx(() {
                          final controller = Get.find<SavingsGoalController>();

                          if (controller.goals.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(context.localization.noGoalsYet),
                            );
                          }

                          return Column(
                            children: controller.goals
                                .map((goal) => savingsGoalCard(context,goal))
                                .toList(),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.015),
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  context.localization.incomeSummary,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              _buildMonthList(),
              SizedBox(height: size.height * 0.03),
              _buildCategoryColorLegend(),
              SizedBox(height: size.height * 0.03),
              _buildIncomeBarChart(context, size),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProfileHeader(BuildContext context, Size size) {
    DateTime? firstTransactionDate;
    if (homeController.allTransactions.isNotEmpty) {
      firstTransactionDate = homeController.allTransactions
          .map((e) => e.date) // ধরছি transaction এ date ফিল্ড আছে
          .reduce((a, b) => a.isBefore(b) ? a : b);
    }

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: size.height * 0.025,
        horizontal: size.width * 0.04,
      ),
      decoration: const BoxDecoration(
        color: AppColors.loginTextButtonColor,
        boxShadow: [
          BoxShadow(
            color: AppColors.categoryShadowColor,
            offset: Offset(0, 3),
            blurRadius: 24,
            blurStyle: BlurStyle.inner,
          ),
        ],
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                width: radius * 1.4,
                height: radius * 1.4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white30, // border color
                    width: 3, // border width
                  ),
                ),
                child: CircleAvatar(
                  radius: radius,
                  backgroundColor: Colors.blueGrey.withAlpha(80),
                  backgroundImage: userController.avatarBase64.value.isNotEmpty
                      ? MemoryImage(
                          base64Decode(userController.avatarBase64.value),
                        )
                      : null,
                  child: userController.avatarBase64.value.isEmpty
                      ? Text(
                          userController.fullName.value.isNotEmpty
                              ? userController.fullName.value[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: radius * 0.85,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
              ),

              // Edit icon overlay
              Positioned(
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    userController.updateProfileImage();
                  },
                  child: CircleAvatar(
                    radius: radius * 0.22,
                    backgroundColor: Colors.grey,
                    child: Icon(
                      Icons.camera_alt,
                      size: radius * 0.25,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(width: size.width * 0.04),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        userController.fullName.value.isNotEmpty
                            ? userController.fullName.value
                            : 'Your Name',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: size.width * 0.06,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    SizedBox(width: 6),

                    Icon(
                      Icons.workspace_premium,
                      color: Colors.amber,
                      size: 22,
                    ),
                  ],
                ),

                SizedBox(height: size.height * 0.005),

                // Phone
                Text(
                  userController.phoneNumber.value.isNotEmpty
                      ? userController.phoneNumber.value
                      : 'Phone Number',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: size.width * 0.040,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: size.height * 0.005),

                // Member Since (সব ইউজারের জন্য)
                if (userController.createdAt.value != null)
                  Text(
                    '${context.localization.accountOpen} ${localizedNumber(userController.createdAt.value!.day)}/${localizedNumber(userController.createdAt.value!.month)}/${localizedNumber(userController.createdAt.value!.year)}',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: size.width * 0.035,
                    ),
                  ),

                // Transactions Since (শুধু প্রিমিয়ামের জন্য)
                if (userController.isPremium.value &&
                    firstTransactionDate != null)
                  Text(
                    '${context.localization.accountOpen} ${localizedNumber(userController.createdAt.value!.day)}/${localizedNumber(userController.createdAt.value!.month)}/${localizedNumber(userController.createdAt.value!.year)}',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: size.width * 0.035,
                    ),
                  ),
              ],
            ),
          ),

          // Edit Button
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              onPressed: () => _showEditProfileDialog(context),
              icon: const Icon(Icons.edit, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final nameController = TextEditingController(
      text: userController.fullName.value,
    );
    final phoneController = TextEditingController(
      text: userController.phoneNumber.value,
    );

    RxBool hasChanged = false.obs;

    // Detect changes
    nameController.addListener(() {
      hasChanged.value =
          nameController.text.trim() != userController.fullName.value ||
          phoneController.text.trim() != userController.phoneNumber.value;
    });
    phoneController.addListener(() {
      hasChanged.value =
          nameController.text.trim() != userController.fullName.value ||
          phoneController.text.trim() != userController.phoneNumber.value;
    });

    Get.dialog(
      Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: Get.width * 0.9,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 🔹 Profile Avatar with Edit Icon
                  Stack(
                    children: [
                      Obx(
                        () => CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.blueGrey.withAlpha(80),
                          backgroundImage:
                              userController.avatarBase64.value.isNotEmpty
                              ? MemoryImage(
                                  base64Decode(
                                    userController.avatarBase64.value,
                                  ),
                                )
                              : null,
                          child: userController.avatarBase64.value.isEmpty
                              ? Text(
                                  userController.fullName.value.isNotEmpty
                                      ? userController.fullName.value[0]
                                      .toUpperCase() : '?',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () async {
                            await userController.updateProfileImage();
                          },
                          child: CircleAvatar(
                            radius: 15,
                            backgroundColor: Colors.grey[700],
                            child: const Icon(
                              Icons.camera_alt,
                              size: 16,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 🔹 Name Field
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.person,
                          color: Colors.blueAccent,
                        ),
                        labelText: context.localization.readFullName,
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.blueAccent,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 🔹 Phone Field
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.phone,
                          color: Colors.green,
                        ),
                        labelText: context.localization.readPhoneNumber,
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.green,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // 🔹 Buttons
                  Obx(
                    () => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Cancel
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Get.back(),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: Colors.red,
                                width: 1.5,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              context.localization.cancel,
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Save
                        Expanded(
                          child: ElevatedButton(
                            onPressed: hasChanged.value
                                ? () async {
                                    final newName = nameController.text.trim();
                                    final newPhone = phoneController.text
                                        .trim();

                                    if (newName.isEmpty || newPhone.isEmpty) {
                                      Get.snackbar(
                                        context.localization.error,
                                        context.localization.namePhoneCannotBeEmpty,
                                        snackPosition: SnackPosition.BOTTOM,
                                        barBlur: 0,
                                      );
                                      return;
                                    }

                                    try {
                                      await userController.updateProfile(
                                        name: newName,
                                        phone: newPhone,
                                      );
                                      if (Get.isDialogOpen!) Get.back();
                                    } catch (e) {
                                      Get.snackbar(
                                        context.localization.error,
                                        e.toString(),
                                        snackPosition: SnackPosition.BOTTOM,
                                        barBlur: 0,
                                      );
                                    }
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 3,
                            ),
                            child: Text(
                              context.localization.save,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Widget _premiumCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black26.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  void _showDownloadPdfDialog(BuildContext context) {
    Get.dialog(
      Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: Get.width * 0.9,
            height: Get.height * 0.6,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Text(
                  context.localization.downloadMonthlyPDF,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Obx(() {
                    return ListView.builder(
                      itemCount: homeController.months.length,
                      itemBuilder: (context, index) {
                        final month = homeController.months[index];
                        final monthName = localizedMonthName(month['month']);
                        final monthId = month['id'];

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          color: Colors.white,
                          child: ListTile(
                            title: Text(monthName),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              // Row shrink-wrap হোক
                              children: [
                                // Download Icon
                                IconButton(
                                  icon: Icon(
                                    Icons.download_for_offline_outlined,
                                    color: Colors.blueAccent,
                                  ),
                                  tooltip: context.localization.downloadPDF,
                                  onPressed: () async {
                                    await _generateMonthPdf(
                                      context,
                                      monthId,
                                      monthName,
                                    ); // Local download
                                    Get.snackbar(
                                      context.localization.success,
                                      '$monthName ${context.localization.pdfDownloaded}',
                                      snackPosition: SnackPosition.BOTTOM,
                                      barBlur: 0,
                                      backgroundColor: Colors.transparent,
                                    );
                                  },
                                ),

                                // Share Icon
                                IconButton(
                                  icon: const Icon(
                                    Icons.folder_shared_outlined,
                                    color: Colors.orange,
                                  ),
                                  tooltip: context.localization.sharePDF,
                                  onPressed: () async {
                                    final file = await _generateMonthPdfFile(
                                      monthId,
                                      monthName,
                                    );

                                    // Share the PDF file
                                    await SharePlus.instance.share(
                                      ShareParams(
                                        text: '${context.localization.hereIsThePDFFor} $monthName',
                                        // Optional text
                                        files: [
                                          XFile(file.path),
                                        ], // List of files to share
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _generateMonthPdf(
      BuildContext context,
      String monthId,
      String monthName,
      ) async {
    final controller = Get.find<HomeController>();
    final settingsController = Get.find<SettingsController>();

    await controller.fetchTransactions(monthId);
    final list = controller.transactions;

    if (list.isEmpty) {
      Get.snackbar(
        context.localization.noTransactions,
        '${context.localization.noTransactionFoundFor} $monthName',
      );
      return;
    }

    double totalIncome = list
        .where((trx) => trx.type == TransactionType.income)
        .fold(0.0, (sum, trx) => sum + trx.amount);

    double totalExpense = list
        .where((trx) => trx.type == TransactionType.expense)
        .fold(0.0, (sum, trx) => sum + trx.amount);

    double balance = controller.balance.toDouble();

    final pdf = pw.Document();

    final summaries = [
      {
        'title': context.localization.totalBudget,
        'value': controller.totalBalance.value,
        'color': PdfColors.green,
      },
      {
        'title': context.localization.income,
        'value': totalIncome,
        'color': PdfColors.green800,
      },
      {
        'title': context.localization.expense,
        'value': totalExpense,
        'color': PdfColors.red,
      },
      {
        'title': context.localization.balance,
        'value': balance,
        'color': PdfColors.blue,
      },
    ];

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),

        build: (pw.Context pdfContext) => [

          pw.Center(
            child: pw.Text(
              '$monthName ${context.localization.transactionReport}',
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),

          pw.SizedBox(height: 20),

          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: summaries.map((s) {
              return _pdfSummary(
                s['title'] as String,
                s['value'] as double,
                s['color'] as PdfColor,
              );
            }).toList(),
          ),

          pw.Divider(height: 32, color: PdfColors.grey400),

          pw.TableHelper.fromTextArray(
            headers: [
              context.localization.date,
              context.localization.type,
              context.localization.category,
              context.localization.amount,
            ],
            data: list.map((trx) {
              return [
                DateFormat('dd MMM yyyy').format(trx.date),
                trx.type == TransactionType.income
                    ? context.localization.income
                    : context.localization.expense,
                trx.category,
                '${settingsController.defaultCurrency.value} ${trx.amount.toInt()}',
              ];
            }).toList(),
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
              fontSize: 12,
            ),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey800),
            cellAlignment: pw.Alignment.centerLeft,
            cellStyle: const pw.TextStyle(fontSize: 12),
            columnWidths: {
              0: const pw.FixedColumnWidth(90),
              1: const pw.FixedColumnWidth(80),
              2: const pw.FlexColumnWidth(),
              3: const pw.FixedColumnWidth(80),
            },
          ),

          pw.SizedBox(height: 20),

          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              context.localization.generatedByApp,
              style: const pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey,
              ),
            ),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  pw.Widget _pdfSummary(String title, double amount, PdfColor color) {
    final SettingsController settingsController =
        Get.find<SettingsController>();
    return pw.Column(
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
        ),
        pw.SizedBox(height: 6),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: pw.BoxDecoration(
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
          ),
          child: pw.Text(
            '${amount.toInt()} ${settingsController.defaultCurrency.value}',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: color,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Future<File> _generateMonthPdfFile(String monthId, String monthName) async {
    // ১. PDF ডকুমেন্ট তৈরি
    final pdf = pw.Document();
    final ttfRegular = pw.Font.ttf(
      await rootBundle.load('assets/fonts/NotoSansBengali-Regular.ttf'),
    );

    // ২. Sample Content, তোমার ডাটা অনুযায়ী পরিবর্তন করো
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  'Month: $monthName',
                  style: pw.TextStyle(
                    font: ttfRegular,
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Here is your PDF content for month ID: $monthId',
                  style: pw.TextStyle(font: ttfRegular, fontSize: 16),
                ),
              ],
            ),
          );
        },
      ),
    );

    // ৩. টেম্পোরারি ডিরেক্টরিতে ফাইল সেভ করা
    final directory = await getTemporaryDirectory(); // temp folder
    final filePath = '${directory.path}/$monthName.pdf';
    final file = File(filePath);

    await file.writeAsBytes(await pdf.save());

    return file; // শেয়ারের জন্য রিটার্ন
  }

  Widget savingsGoalCard(BuildContext context, SavingsGoal goal) {
    final controller = Get.find<SavingsGoalController>();
    final settingsController = Get.find<SettingsController>();

    final percent =
    (goal.progress * 100).clamp(0, 100);

    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 8,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black12
                .withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [

          /// Header
          Row(
            children: [
              Container(
                padding:
                const EdgeInsets.all(8),
                decoration:
                BoxDecoration(
                  color: Colors.deepPurple.withValues(alpha: 0.1),
                  borderRadius:
                  BorderRadius
                      .circular(10),
                ),
                child: Icon(
                  Icons.flag,
                  color:
                  Colors.deepPurple,
                  size: 20,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  goal.title,
                  style:
                  const TextStyle(
                    fontSize: 16,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ),

              /// Delete button
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                ),
                tooltip: "Delete Goal",
                onPressed: () {
                  controller.deleteGoal(
                    goal.id,
                  );

                  Get.snackbar(
                    "",
                    context.localization.goalRemoved,
                    snackPosition:
                    SnackPosition
                        .BOTTOM,
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// Amount Row
          Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${settingsController.defaultCurrency.value} ${localizedNumber(goal.savedAmount)}",
                style:
                const TextStyle(
                  fontSize: 16,
                  fontWeight:
                  FontWeight.bold,
                  color:
                  Colors.green,
                ),
              ),
              Text(
                "${context.localization.target} ${settingsController.defaultCurrency.value} ${localizedNumber(goal.targetAmount)}",
                style:
                const TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          /// Progress Bar
          ClipRRect(
            borderRadius:
            BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: goal.progress,
              minHeight: 8,
              backgroundColor:
              Colors.grey
                  .shade200,
              valueColor:
              const AlwaysStoppedAnimation(
                Colors.deepPurple,
              ),
            ),
          ),

          const SizedBox(height: 6),

          /// Percentage
          Align(
            alignment:
            Alignment.centerRight,
            child: Text(
              "${localizedNumber(percent)}%",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
          ),

          const SizedBox(height: 14),

          /// Add Savings Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                showAddMoneyDialog(context, goal.id);
              },
              style:
              ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              label: Text(
                context.localization.addSavings,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showAddMoneyDialog(BuildContext context, String goalId) {
    final controller = Get.find<SavingsGoalController>();
    final amountController = TextEditingController();

    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              /// Title
              Row(
                children: [
                  Icon(
                    Icons.savings_outlined,
                    color: Colors.green,
                    size: 28,
                  ),
                  SizedBox(width: 10),
                  Text(
                    context.localization.addSavings,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// Amount Field
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: context.localization.money,
                  hintStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.attach_money),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              /// Buttons
              Row(
                children: [

                  /// Cancel Button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(context.localization.cancel,style: TextStyle(color: Colors.red),),
                    ),
                  ),

                  const SizedBox(width: 12),

                  /// Save Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final amount =
                        double.tryParse(amountController.text);

                        if (amount == null || amount <= 0) {
                          Get.snackbar(
                            context.localization.invalidAmount,
                            "",
                            snackPosition: SnackPosition.BOTTOM,
                          );
                          return;
                        }

                        controller.addSavings(goalId, amount);

                        Get.back();

                        Get.snackbar(
                          context.localization.success,
                          "",
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        context.localization.save,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddGoalDialog(BuildContext context) {
    final controller = Get.find<SavingsGoalController>();

    final titleController = TextEditingController();

    final amountController = TextEditingController();

    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Header
              Row(
                children: [
                  Icon(Icons.flag, color: Colors.deepPurple, size: 26),
                  SizedBox(width: 10),
                  Text(
                    context.localization.createSavingsGoal,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// Goal Title
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: context.localization.goalTitle,
                  hintText: context.localization.buyBike,
                  hintStyle: TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.title),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// Target Amount
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: context.localization.target,
                  hintText: context.localization.money,
                  hintStyle: TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.attach_money),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              /// Buttons
              Row(
                children: [
                  /// Cancel
                  Expanded(
                    child: OutlinedButton(
                      onPressed: Get.back,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        side: BorderSide(color: Colors.white)),
                      child: Text(context.localization.cancel, style: TextStyle(color: Colors.white),),
                    ),
                  ),

                  const SizedBox(width: 12),

                  /// Save
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final title = titleController.text;

                        final amount = double.tryParse(amountController.text);

                        if (title.isEmpty || amount == null) {
                          Get.snackbar(
                            context.localization.error,
                            "",
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.transparent,
                            barBlur: 0,
                            colorText: Colors.red,
                          );
                          return;
                        }

                        controller.addGoal(title: title, targetAmount: amount);

                        Get.back();

                        Get.snackbar(
                          context.localization.success,
                          "",
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.transparent,
                          barBlur: 0,
                          colorText: Colors.green,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        context.localization.saveGoal,
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white,),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthList() {
    return SizedBox(
      height: 50,
      child: Obx(() {
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: homeController.months.length,
          itemBuilder: (context, index) {
            final month = homeController.months[index];
            final isSelected =
                month['id'] == homeController.selectedMonthId.value;

            return GestureDetector(
              onTap: () => homeController.selectMonth(month),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: EdgeInsets.only(
                  left: index == 0 ? 16 : 10, // প্রথম বাটনের জন্য বাম margin
                  right: 10, // বাকি বাটনের জন্য right margin
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [Color(0xFF42A5F5), Color(0xFF1E88E5)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : LinearGradient(
                          colors: [Colors.grey.shade200, Colors.grey.shade300],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.blueAccent.withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Center(
                  child: Text(
                    localizedMonthName(month['month']),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildIncomeBarChart(BuildContext context, Size size) {
    if (homeController.allTransactions.isEmpty) {
      return SizedBox(
        height: size.height * 0.4,
        child: Center(
          child: Text(
            context.localization.noTransactionThisMonth,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      );
    }

    /// 🔹 Category-wise Income
    final Map<String, double> categoryIncome = {};

    for (var trx in homeController.allTransactions) {
      if (trx.type == TransactionType.income) {
        categoryIncome[trx.category] =
            (categoryIncome[trx.category] ?? 0) + trx.amount;
      }
    }

    if (categoryIncome.isEmpty) {
      return const SizedBox.shrink();
    }

    final categories = categoryIncome.keys.toList();
    final amounts = categoryIncome.values.toList();
    final maxY = amounts.reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: size.height * 0.4,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 5,
        shadowColor: Colors.grey.withValues(alpha: 0.3),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: BarChart(
            BarChartData(
              maxY: maxY * 1.2,
              alignment: BarChartAlignment.spaceAround,
              borderData: FlBorderData(show: false),

              /// 🔹 Grid
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: maxY / 4,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.grey.withValues(alpha: 0.2),
                  strokeWidth: 1,
                ),
              ),

              /// 🔹 Titles
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: maxY / 4,
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),

                /// 🔻 Bottom: ONLY COLOR DOT
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 26,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= categories.length) {
                        return const SizedBox.shrink();
                      }

                      final category = categories[value.toInt()];
                      final color = getCategoryColor(category);

                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              /// 🔹 Bars
              barGroups: categoryIncome.entries.toList().asMap().entries.map((
                entry,
              ) {
                final index = entry.key;
                final data = entry.value;
                final barColor = getCategoryColor(data.key);

                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: data.value,
                      width: 22,
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [barColor.withValues(alpha: 0.4), barColor],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ],
                );
              }).toList(),

              /// 🔹 Tooltip (name থাকবে)
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final category = categories[group.x.toInt()];
                    final amount = categoryIncome[category]!.toInt();

                    return BarTooltipItem(
                      '$category\n+$amount ৳',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color getCategoryColor(String name) {
    final allCategories = [...incomeCategories, ...expenseCategories];
    return allCategories
        .firstWhere(
          (cat) => cat.name == name,
          orElse: () =>
              CategoryModel(name: name, iconId: 0, color: Colors.grey),
        )
        .color;
  }

  Widget _buildCategoryColorLegend() {
    final allCategories = [...incomeCategories];

    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: allCategories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final category = allCategories[index];

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: category.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: category.color.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🔵 Color Dot
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: category.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),

                // 📝 Category Name
                Text(
                  category.name.localizedName(),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: category.color,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    final isPressed = false.obs;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        // Responsive sizing
        final iconSize = width * 0.22; // ~28–32
        final valueSize = width * 0.18; // ~16–18
        final titleSize = width * 0.13; // ~12–14

        return Obx(() {
          return GestureDetector(
            onTapDown: (_) => isPressed.value = true,
            onTapUp: (_) => isPressed.value = false,
            onTapCancel: () => isPressed.value = false,
            child: AnimatedScale(
              scale: isPressed.value ? 0.96 : 1,
              duration: const Duration(milliseconds: 120),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.blue.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: isPressed.value ? 8 : 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(width * 0.08),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: Colors.white, size: iconSize),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      value,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: valueSize,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: titleSize,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

}
