import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../bills/models/bill_model.dart';
import '../../expenses/models/expense_model.dart';

class PdfExportService {
  Future<pw.Document> generateReport({
    required List<ExpenseModel> expenses,
    required List<BillModel> bills,
    required String flatName,
    required List<Map<String, dynamic>> members,
  }) async {
    final pdf = pw.Document();

    //------------------------
    // MEMBER MAP
    //------------------------

    final memberNames = <String, String>{};

    for (final member in members) {
      memberNames[member['id']] =
          member['name']?.toString() ?? 'Unknown';
    }

    final totalExpense = expenses.fold<double>(
      0,
      (sum, expense) => sum + expense.amount,
    );

    final pendingBills =
        bills.where((bill) => !bill.isPaid).toList();

    final pendingAmount =
        pendingBills.fold<double>(
      0,
      (sum, bill) => sum + bill.amount,
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              'FlatFlow Report',
              style: pw.TextStyle(
                fontSize: 26,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),

          pw.Text('Flat : $flatName'),
          pw.Text('Members : ${members.length}'),
          pw.Text('Generated : ${DateTime.now()}'),

          pw.SizedBox(height: 20),

          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(),
            ),
            child: pw.Column(
              crossAxisAlignment:
                  pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Total Expenses : ₹${totalExpense.toStringAsFixed(2)}',
                ),
                pw.Text(
                  'Total Bills : ${bills.length}',
                ),
                pw.Text(
                  'Pending Bills Amount : ₹${pendingAmount.toStringAsFixed(2)}',
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 20),

          pw.Text(
            'Expenses',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),

          pw.SizedBox(height: 10),
                    if (expenses.isEmpty)
            pw.Text('No expenses found.')
          else
            pw.TableHelper.fromTextArray(
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
              ),
              headers: const [
                'Title',
                'Category',
                'Paid By',
                'Amount',
              ],
              data: expenses
                  .map(
                    (expense) => [
                      expense.title,
                      expense.category,
                      memberNames[expense.paidBy] ??
                          expense.paidBy,
                      '₹${expense.amount.toStringAsFixed(2)}',
                    ],
                  )
                  .toList(),
            ),

          pw.SizedBox(height: 20),

          pw.Text(
            'Bills',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),

          pw.SizedBox(height: 10),

          if (bills.isEmpty)
            pw.Text('No bills found.')
          else
            pw.TableHelper.fromTextArray(
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
              ),
              headers: const [
                'Title',
                'Category',
                'Due Date',
                'Status',
                'Amount',
              ],
              data: bills
                  .map(
                    (bill) => [
                      bill.title,
                      bill.category,
                      bill.dueDate
                          .toString()
                          .split(' ')
                          .first,
                      bill.isPaid
                          ? 'Paid'
                          : 'Pending',
                      '₹${bill.amount.toStringAsFixed(2)}',
                    ],
                  )
                  .toList(),
            ),
        ],
      ),
    );

    return pdf;
  }
}