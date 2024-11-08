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
          double? debitAmount = entry['total_amount'];
          debitSum += debitAmount ?? 0.0;

          entries.add({
            'date': entry['order_date'],
            'invoice': '${entry['invoice']}/${entry['company']}',
            'particular': 'Goods Sale',
            'debit': debitAmount,
            'credit': null,
            'isFirstOfOrder': true, // Mark the first entry of an order
          });

          for (var receipt in entry['payment_receipts']) {
            double creditAmount = double.parse(receipt['amount']);
            creditSum += creditAmount;

            entries.add({
              'date': receipt['received_at'],
              'invoice': '${entry['invoice']}/${entry['company']}',
              'particular': 'Payment received',
              'debit': null,
              'credit': creditAmount,
              'isFirstOfOrder': false, // Subsequent entries of the same order
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
    int mainOrderNumber = 1; // Initialize main order number
    int subOrderNumber = 1;  // Initialize sub-order number

    return Scaffold(
      appBar: AppBar(title: Text("Customer Ledger")),
      body: ledgerEntries.isEmpty
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  children: [
                    DataTable(
                      headingRowColor: MaterialStateColor.resolveWith(
                          (states) => Colors.blue.shade100),
                      dataRowColor: MaterialStateColor.resolveWith((states) {
                        return states.contains(MaterialState.selected)
                            ? Colors.blue.shade50
                            : Colors.grey.shade200;
                      }),
                      columnSpacing: 20,
                      columns: const [
                        DataColumn(
                            label: Text('#',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(
                            label: Text('Date',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(
                            label: Text('Invoice',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(
                            label: Text('Particular',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(
                            label: Text('Debit (₹)',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(
                            label: Text('Credit (₹)',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      rows: List.generate(ledgerEntries.length, (index) {
                        final entry = ledgerEntries[index];
                        String displayNumber;

                        // Increment main order number and reset sub-number at each new order
                        if (entry['isFirstOfOrder']) {
                          displayNumber = mainOrderNumber.toString();
                          mainOrderNumber++; // Increment for next main order
                          subOrderNumber = 1; // Reset sub-number for the new main order
                        } else {
                          displayNumber = "${mainOrderNumber - 1}.$subOrderNumber";
                          subOrderNumber++; // Increment sub-number within the same main order
                        }

                        return DataRow(cells: [
                          DataCell(Text(displayNumber)), // Display formatted order number
                          DataCell(Text(entry['date'] ?? '')),
                          DataCell(
                            Text(
                              entry['isFirstOfOrder'] ? entry['invoice'] ?? '' : '',
                              style: TextStyle(
                                color: entry['isFirstOfOrder']
                                    ? Colors.blue
                                    : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              entry['particular'] ?? '',
                              style: TextStyle(
                                color: entry['particular'] == 'Goods Sale'
                                    ? Colors.red
                                    : entry['particular'] == 'Payment received'
                                        ? Colors.green
                                        : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
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
                        headingRowColor: MaterialStateColor.resolveWith(
                            (states) => Colors.blue.shade100),
                        columnSpacing: 20,
                        columns: const [
                          DataColumn(label: Text('')),
                          DataColumn(label: Text('')),
                          DataColumn(label: Text('')),
                          DataColumn(
                              label: Text('Grand Total',
                                  style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('Debit (₹)',
                                  style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('Credit (₹)',
                                  style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: [
                          DataRow(cells: [
                            DataCell(Text('')),
                            DataCell(Text('')),
                            DataCell(Text('')),
                            DataCell(Text('Grand Total',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black))),
                            DataCell(Text(totalDebit.toStringAsFixed(2),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade800,
                                ))),
                            DataCell(Text(totalCredit.toStringAsFixed(2),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade800,
                                ))),
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
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.deepOrangeAccent),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
