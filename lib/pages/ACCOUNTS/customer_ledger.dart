import 'dart:convert';
import 'package:beposoft/pages/api.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CustomerLedger extends StatefulWidget {
  final int customerid;
  const CustomerLedger({Key? key, required this.customerid}) : super(key: key);

  @override
  State<CustomerLedger> createState() => _CustomerLedgerState();
}

class _CustomerLedgerState extends State<CustomerLedger> {
  List<Map<String, dynamic>> ledgerEntries = [];
  double totalDebit = 0.0;
  double totalCredit = 0.0;

  @override
  void initState() {
    super.initState();
    fetchCustomerLedgerDetails();
  }

  Future<String?> getTokenFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> fetchCustomerLedgerDetails() async {
    try {
      final token = await getTokenFromPrefs();
      final response = await http.get(
        Uri.parse('$api/api/customer/${widget.customerid}/ledger/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        final data = parsed['data'] as List;

        List<Map<String, dynamic>> entries = [];
        double debitSum = 0.0;
        double creditSum = 0.0;

        for (var entry in data) {
          // Add main sale entry
          double? debitAmount = entry['total_amount'];
          debitSum += debitAmount ?? 0.0;

          entries.add({
            'date': entry['order_date'],
            'invoice': '${entry['invoice']}/${entry['company']}',
            'particular': 'Goods Sale',
            'debit': debitAmount,
            'credit': null,
          });

          // Add payment receipts
          for (var receipt in entry['payment_receipts']) {
            double creditAmount = double.parse(receipt['amount']);
            creditSum += creditAmount;

            entries.add({
              'date': receipt['received_at'],
              'invoice': '${entry['invoice']}/${entry['company']}',
              'particular': 'Payment received',
              'debit': null,
              'credit': creditAmount,
            });
          }
        }

        setState(() {
          ledgerEntries = entries;
          totalDebit = debitSum;
          totalCredit = creditSum;
        });
      }
    } catch (error) {
      print("Error fetching ledger data: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Customer Ledger")),
      body: ledgerEntries.isEmpty
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                children: [
                  DataTable(
                    columns: const [
                      DataColumn(label: Text('#')),
                      DataColumn(label: Text('Date')),
                      DataColumn(label: Text('Invoice')),
                      DataColumn(label: Text('Particular')),
                      DataColumn(label: Text('Debit (₹)')),
                      DataColumn(label: Text('Credit (₹)')),
                    ],
                    rows: List.generate(ledgerEntries.length, (index) {
                      final entry = ledgerEntries[index];
                      return DataRow(cells: [
                        DataCell(Text((index + 1).toString())),
                        DataCell(Text(entry['date'] ?? '')),
                        DataCell(Text(entry['invoice'] ?? '')),
                        DataCell(Text(entry['particular'] ?? '')),
                        DataCell(Text(entry['debit'] != null
                            ? entry['debit'].toString()
                            : '')),
                        DataCell(Text(entry['credit'] != null
                            ? entry['credit'].toString()
                            : '')),
                      ]);
                    }),
                  ),
                  // Footer row for totals
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('')),
                        DataColumn(label: Text('')),
                        DataColumn(label: Text('')),
                        DataColumn(label: Text('Grand Total')),
                        DataColumn(label: Text('Debit (₹)')),
                        DataColumn(label: Text('Credit (₹)')),
                      ],
                      rows: [
                        DataRow(cells: [
                          DataCell(Text('')),
                          DataCell(Text('')),
                          DataCell(Text('')),
                          DataCell(Text('Grand Total')),
                          DataCell(Text(totalDebit.toStringAsFixed(2),
                              style: TextStyle(fontWeight: FontWeight.bold))),
                          DataCell(Text(totalCredit.toStringAsFixed(2),
                              style: TextStyle(fontWeight: FontWeight.bold))),
                        ]),
                      ],
                    ),
                  ),
                  // Closing Balance
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "Closing Balance (₹): ${(totalDebit - totalCredit).toStringAsFixed(2)}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
