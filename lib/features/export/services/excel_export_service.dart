import 'dart:io';

import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../bills/models/bill_model.dart';
import '../../expenses/models/expense_model.dart';

class ExcelExportService {
  Future<void> export({
    required List<ExpenseModel> expenses,
    required List<BillModel> bills,
    required String flatName,
    required List<Map<String, dynamic>> members,
  }) async {
    final excel = Excel.createExcel();

    //------------------------
    // MEMBER MAP
    //------------------------

    final memberNames = <String, String>{};

    for (final member in members) {
      memberNames[member['id']] =
          member['name']?.toString() ?? 'Unknown';
    }

    //------------------------
    // SUMMARY
    //------------------------

    final summary = excel['Summary'];

    final totalExpense = expenses.fold<double>(
      0,
      (sum, e) => sum + e.amount,
    );

    final pendingBills =
        bills.where((e) => !e.isPaid).toList();

    final pendingAmount =
        pendingBills.fold<double>(
      0,
      (sum, e) => sum + e.amount,
    );

    summary.appendRow([
      TextCellValue('Flat Name'),
      TextCellValue(flatName),
    ]);

    summary.appendRow([
      TextCellValue('Members'),
      IntCellValue(members.length),
    ]);

    summary.appendRow([
      TextCellValue('Total Expenses'),
      DoubleCellValue(totalExpense),
    ]);

    summary.appendRow([
      TextCellValue('Pending Bills'),
      DoubleCellValue(pendingAmount),
    ]);

    summary.appendRow([
      TextCellValue('Generated'),
      TextCellValue(DateTime.now().toString()),
    ]);

    //------------------------
    // EXPENSE SHEET
    //------------------------

    final expenseSheet = excel['Expenses'];

    expenseSheet.appendRow([
      TextCellValue('Title'),
      TextCellValue('Category'),
      TextCellValue('Paid By'),
      TextCellValue('Amount'),
    ]);

    for (final expense in expenses) {
      expenseSheet.appendRow([
        TextCellValue(expense.title),
        TextCellValue(expense.category),
        TextCellValue(
          memberNames[expense.paidBy] ??
              expense.paidBy,
        ),
        DoubleCellValue(expense.amount),
      ]);
    }

    //------------------------
    // BILL SHEET
    //------------------------

    final billSheet = excel['Bills'];

    billSheet.appendRow([
      TextCellValue('Title'),
      TextCellValue('Category'),
      TextCellValue('Due Date'),
      TextCellValue('Status'),
      TextCellValue('Amount'),
    ]);
        for (final bill in bills) {
      billSheet.appendRow([
        TextCellValue(bill.title),
        TextCellValue(bill.category),
        TextCellValue(
          bill.dueDate.toString().split(' ').first,
        ),
        TextCellValue(
          bill.isPaid ? 'Paid' : 'Pending',
        ),
        DoubleCellValue(bill.amount),
      ]);
    }

    //------------------------
    // SAVE FILE
    //------------------------

    final directory =
        await getTemporaryDirectory();

    final file = File(
      '${directory.path}/FlatFlow_Report.xlsx',
    );

    final bytes = excel.encode();

    if (bytes != null) {
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [
          XFile(file.path),
        ],
        text: 'FlatFlow Report',
      );
    }
  }
} 