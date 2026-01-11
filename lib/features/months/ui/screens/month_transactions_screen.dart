import 'package:ay_bay_app/app/app_colors.dart';
import 'package:ay_bay_app/app/app_routes.dart';
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
        title: Text('$monthName মাসের লেনদেন', style: TextStyle(fontSize: 18)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              await _generatePdf(controller);
            },
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
            Card(
              color: AppColors.textFieldBorderColor,
              elevation: 4,
              shadowColor: Colors.black26,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  // যদি বেশি Column থাকে তাহলে scrollable হবে
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _summaryTile(
                        'মোট বাজেট',
                        controller.totalBalance.value,
                        Colors.white,
                      ),

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
                  ),
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

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    child: ListTile(
                      leading: Icon(
                        IconData(trx.categoryIcon, fontFamily: 'MaterialIcons'),
                        color: Colors.blue,
                        size: 28,
                      ),
                      title: Text(
                        trx.category,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        DateFormat('dd MMM yyyy').format(trx.date),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${isIncome ? '+' : '-'} ৳ ${trx.amount}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isIncome ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
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
            color: Colors.white,
          ),
        ),
        SizedBox(height: 4),
        Text(
          '৳ $amount',
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

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text(
            '$monthName মাসের লেনদেন রিপোর্ট',
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 16),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _pdfSummary(
                'মোট বাজেট',
                controller.totalBalance.value,
                PdfColors.green,
              ),
              _pdfSummary('আয়', totalIncome, PdfColors.green),
              _pdfSummary('ব্যয়', totalExpense, PdfColors.red),
              _pdfSummary('ব্যালেন্স', balance, PdfColors.blue),
            ],
          ),
          pw.SizedBox(height: 16),
          pw.TableHelper.fromTextArray(
            headers: ['তারিখ', 'টাইপ', 'ক্যাটাগরী', 'পরিমাণ'],
            data: list.map((trx) {
              return [
                DateFormat('dd MMM yyyy').format(trx.date), // তারিখ
                trx.type == TransactionType.income ? 'আয়' : 'ব্যয়', // টাইপ
                trx.category, // ক্যাটাগরী
                '৳ ${trx.amount}', // পরিমাণ
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
              0: const pw.FixedColumnWidth(70), // তারিখ → fixed
              1: const pw.FixedColumnWidth(50), // টাইপ → fixed
              2: const pw.FlexColumnWidth(3), // ক্যাটাগরী → বড় জায়গা
              3: const pw.FixedColumnWidth(50), // পরিমাণ → ছোট
            },
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  pw.Widget _pdfSummary(String title, double amount, PdfColor color) {
    return pw.Column(
      children: [
        pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        pw.Text(
          '৳ $amount',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: color),
        ),
      ],
    );
  }
}
