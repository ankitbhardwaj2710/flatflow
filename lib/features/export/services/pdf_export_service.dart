import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../expenses/models/expense_model.dart';
import '../../bills/models/bill_model.dart';

class PdfExportService {
  Future<pw.Document> generateReport({
  required List<ExpenseModel> expenses,
  required List<BillModel> bills,
  required String flatName,
  required List<Map<String, dynamic>> members,
}) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              'FlatFlow Report',
              style: pw.TextStyle(
                fontSize: 28,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),

          pw.SizedBox(height: 20),

          pw.Text('Monthly Expense: ₹0'),
          pw.Text('Pending Bills: ₹0'),
          pw.Text('Grocery Items: 0'),

          pw.Divider(),

          pw.Text(
            'Expenses',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),

          pw.SizedBox(height: 10),

          pw.Text('No expenses available.'),
        ],
      ),
    );

    return pdf;
  }
}