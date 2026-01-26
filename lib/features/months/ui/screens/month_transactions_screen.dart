import 'package:ay_bay_app/app/app_colors.dart';
import 'package:ay_bay_app/app/app_routes.dart';
import 'package:ay_bay_app/features/common/models/category_icon.dart';
import 'package:ay_bay_app/features/common/models/transaction_type_model.dart';
import 'package:ay_bay_app/features/home/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class MonthTransactionsScreen extends StatelessWidget {
  final String monthId;
  final String monthName;

  const MonthTransactionsScreen({
    super.key,
    required this.monthId,
    required this.monthName,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    controller.saveLastScreen(AppRoutes.monthTransactionSave);
    controller.fetchTransactions(monthId);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
        title: Text(
          '$monthName মাসের লেনদেন',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actionsPadding: const EdgeInsets.only(right: 12),
        actions: [
          Container(
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.addButtonColor,
                  AppColors.loginTextButtonColor,
                ],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.addButtonColor.withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.download, size: 18, color: Colors.white),
              onPressed: () async {
                await _generatePdf(controller);
              },
            ),
          ),
        ],
      ),


      body: Obx(() {
        final list = controller.transactions;
        if (list.isEmpty) {
          return const Center(child: Text('কোনো ট্রানজ্যাকশন নেই'));
        }

        double totalIncome = 0;
        double totalExpense = 0;
        for (var trx in list) {
          if (trx.type == TransactionType.income) {
            totalIncome += trx.amount;
          } else {
            totalExpense += trx.amount;
          }
        }
        double balance = controller.balance.toDouble();

        return Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.loginTextButtonColor,
                    AppColors.bannerBottomColor,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.loginTextButtonColor.withValues(alpha: 0.4),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: _buildSummarySection(
                  controller,
                  totalIncome,
                  totalExpense,
                  balance,
                ),
              ),
            ),

            SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final trx = list[index];
                  final isIncome = trx.type == TransactionType.income;

                  return _buildCard(trx, isIncome);
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSummarySection(
    HomeController controller,
    double totalIncome,
    double totalExpense,
    double balance,
  ) {
    return Row(
      children: [
        _summaryTile('মোট বাজেট', controller.totalBalance.value, Colors.white),

        Container(
          width: 1,
          height: 60, // responsive height
          color: Colors.white,
          margin: const EdgeInsets.symmetric(horizontal: 8),
        ),

        _summaryTile('আয়', totalIncome, Colors.green),

        Container(
          width: 1,
          height: 60,
          color: Colors.white,
          margin: const EdgeInsets.symmetric(horizontal: 8),
        ),

        _summaryTile('ব্যয়', totalExpense, Colors.red),

        Container(
          width: 1,
          height: 60,
          color: Colors.white,
          margin: const EdgeInsets.symmetric(horizontal: 8),
        ),

        _summaryTile('সঞ্চয় টাকা', balance, Colors.white),
      ],
    );
  }

  Widget _buildCard(TransactionModel trx, bool isIncome) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isIncome
                ? Colors.green.withValues(alpha: 0.12)
                : Colors.red.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            CategoryIcons.fromId(trx.categoryIcon),
            color: isIncome ? Colors.green : Colors.red,
            size: 22,
          ),
        ),
        title: Text(
          trx.category,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            DateFormat('dd MMM yyyy').format(trx.date),
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
        ),
        trailing: Text(
          '${isIncome ? '+' : '-'} ${trx.amount.toInt()} ৳',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: isIncome ? Colors.green : Colors.red,
          ),
        ),
      ),
    );
  }


  Widget _summaryTile(String title, double amount, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.white70,
          ),
        ),
        SizedBox(height: 4),
        Text(
          '${amount.toInt()} ৳',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color,
          ),
        ),
      ],
    );
  }

  Future<void> _generatePdf(HomeController controller) async {
    final list = controller.transactions;

    double totalIncome = list
        .where((trx) => trx.type == TransactionType.income)
        .fold(0.0, (sum, trx) => sum + trx.amount);
    double totalExpense = list
        .where((trx) => trx.type == TransactionType.expense)
        .fold(0.0, (sum, trx) => sum + trx.amount);
    double balance = controller.balance.toDouble();

    final pdf = pw.Document();

    // Summary data
    final summaries = [
      {'title': 'মোট বাজেট', 'value': controller.totalBalance.value, 'color': PdfColors.green},
      {'title': 'আয়', 'value': totalIncome, 'color': PdfColors.green800},
      {'title': 'ব্যয়', 'value': totalExpense, 'color': PdfColors.red},
      {'title': 'ব্যালেন্স', 'value': balance, 'color': PdfColors.blue},
    ];

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => [
          // Header
          pw.Center(
            child: pw.Text(
              '$monthName মাসের লেনদেন রিপোর্ট',
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(height: 20),

          // Summary Row
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: summaries.map((s) {
              return _pdfSummary(s['title'] as String, s['value'] as double, s['color'] as PdfColor);
            }).toList(),
          ),
          pw.Divider(height: 32, color: PdfColors.grey400),

          // Transaction Table
          pw.TableHelper.fromTextArray(
            headers: ['তারিখ', 'টাইপ', 'ক্যাটাগরী', 'পরিমাণ'],
            data: list.map((trx) {
              return [
                DateFormat('dd MMM yyyy').format(trx.date),
                trx.type == TransactionType.income ? 'আয়' : 'ব্যয়',
                trx.category,
                '${trx.amount.toInt()} ৳',
              ];
            }).toList(),
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
              fontSize: 12,
            ),
            headerDecoration: pw.BoxDecoration(color: PdfColors.grey800),
            cellAlignment: pw.Alignment.centerLeft,
            cellStyle: const pw.TextStyle(fontSize: 12),
            columnWidths: {
              0: const pw.FixedColumnWidth(90),
              1: const pw.FixedColumnWidth(50),
              2: const pw.FlexColumnWidth(),
              3: const pw.FixedColumnWidth(80),
            },
          ),
          pw.SizedBox(height: 20),

          // Footer
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              'Generated by AyBay App',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
            ),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  pw.Widget _pdfSummary(String title, double amount, PdfColor color) {
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
            '${amount.toInt()} ৳',
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
}
