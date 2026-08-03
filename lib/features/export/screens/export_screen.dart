import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import '../../bills/providers/bill_provider.dart';
import '../../expenses/providers/expense_provider.dart';
import '../../home/providers/home_provider.dart';

import '../services/excel_export_service.dart';
import '../services/pdf_export_service.dart';

class ExportScreen extends ConsumerWidget {
  const ExportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Export Reports',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Choose Report',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 24),

          //==========================
          // PDF
          //==========================

          FilledButton.icon(
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Export PDF'),
            onPressed: () async {
              final expenses =
                  ref.read(expensesProvider).value ?? [];

              final bills =
                  ref.read(billsProvider).value ?? [];

              final flat =
                  ref.read(currentFlatProvider).value;

              final members =
                  ref.read(currentFlatMembersProvider).value ?? [];

              if (flat == null) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('No Flat Found'),
                    ),
                  );
                }
                return;
              }

              final pdf =
                  await PdfExportService().generateReport(
                expenses: expenses,
                bills: bills,
                flatName: flat.name,
                members: members,
              );

              await Printing.layoutPdf(
                onLayout: (_) async => pdf.save(),
              );
            },
          ),

          const SizedBox(height: 16),

          //==========================
          // EXCEL
          //==========================

          FilledButton.icon(
            icon: const Icon(Icons.table_chart),
            label: const Text('Export Excel'),
            onPressed: () async {
              final expenses =
                  ref.read(expensesProvider).value ?? [];

              final bills =
                  ref.read(billsProvider).value ?? [];

              final flat =
                  ref.read(currentFlatProvider).value;

              final members =
                  ref.read(currentFlatMembersProvider).value ?? [];

              if (flat == null) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('No Flat Found'),
                    ),
                  );
                }
                return;
              }

              await ExcelExportService().export(
                expenses: expenses,
                bills: bills,
                flatName: flat.name,
                members: members,
              );
            },
          ),
        ],
      ),
    );
  }
}