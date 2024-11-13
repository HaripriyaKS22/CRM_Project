import 'dart:convert';
import 'dart:io';
import 'package:beposoft/pages/api.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart'; // For formatting dates

class CustomerLedger extends StatefulWidget {
  final int customerid;
  const CustomerLedger({Key? key, required this.customerid}) : super(key: key);

  @override
  State<CustomerLedger> createState() => _CustomerLedgerState();
}

class _CustomerLedgerState extends State<CustomerLedger> {
  List<Map<String, dynamic>> ledgerEntries = [];
  List<Map<String, dynamic>> filteredEntries = [];
  double totalDebit = 0.0;
  double totalCredit = 0.0;
  final List<String> companies = [
    'BEPOSITIVERACING PVT LTD',
    'MICHEAL IMPORT EXPORT PVT LTD'
  ];
  DateTime? startDate;
  DateTime? endDate;

  String? selectedCompany;

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
            'company': entry['company'],
            'particular': 'Goods Sale',
            'debit': debitAmount,
            'credit': null,
            'isFirstOfOrder': true,
          });

          for (var receipt in entry['payment_receipts']) {
            double creditAmount = double.parse(receipt['amount']);
            creditSum += creditAmount;

            entries.add({
              'date': receipt['received_at'],
              'invoice': '${entry['invoice']}/${entry['company']}',
              'company': entry['company'],
              'particular': 'Payment received',
              'debit': null,
              'credit': creditAmount,
              'isFirstOfOrder': false,
            });
          }
        }

        setState(() {
          ledgerEntries = entries;
          filteredEntries = entries;
          totalDebit = debitSum;
          totalCredit = creditSum;
        });
      }
    } catch (error) {
      print("Error fetching ledger data: $error");
    }
  }

void filterEntriesByCompanyAndDate() {
  double debitSum = 0.0;
  double creditSum = 0.0;

  setState(() {
    // Step 1: Filter by date (either by specific date or by date range)
    filteredEntries = ledgerEntries.where((entry) {
      final entryDate = DateTime.parse(entry['date']);

      // Check if entry is on the selected date or within the date range
      final isOnSelectedDate = startDate != null && endDate == null &&
          entryDate.year == startDate!.year &&
          entryDate.month == startDate!.month &&
          entryDate.day == startDate!.day;

      final isWithinDateRange = startDate != null && endDate != null &&
          entryDate.isAfter(startDate!.subtract(Duration(days: 1))) &&
          entryDate.isBefore(endDate!.add(Duration(days: 1)));

      // Return true if entry meets the date condition
      return isOnSelectedDate || isWithinDateRange;
    }).toList();

    // Step 2: Filter by company if a specific company is selected
    if (selectedCompany != null && selectedCompany!.isNotEmpty) {
      filteredEntries = filteredEntries.where((entry) => entry['company'] == selectedCompany).toList();
    }

    // Step 3: Recalculate debit and credit sums for the filtered entries
    for (var entry in filteredEntries) {
      debitSum += entry['debit'] ?? 0.0;
      creditSum += entry['credit'] ?? 0.0;
    }

    // Update the total debit and credit for the filtered entries
    totalDebit = debitSum;
    totalCredit = creditSum;
  });
}

 Future<void> pickDateRange() async {
  final picked = await showDateRangePicker(
    context: context,
    firstDate: DateTime(2000),
    lastDate: DateTime.now(),
  );

  if (picked != null) {
    setState(() {
      startDate = picked.start;
      endDate = picked.start == picked.end ? null : picked.end;
      filterEntriesByCompanyAndDate();
    });
  }
}



  Future<void> downloadPDF() async {
    // Request storage permission
    if (await Permission.storage.request().isGranted) {
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              children: [
                pw.Text("Customer Ledger", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 20),
                pw.Table.fromTextArray(
                  headers: ["#", "Date", "Invoice", "Particular", "Debit (₹)", "Credit (₹)"],
                  data: [
                    for (var i = 0; i < filteredEntries.length; i++) [
                      "${i + 1}",
                      filteredEntries[i]['date'] ?? '',
                      filteredEntries[i]['invoice'] ?? '',
                      filteredEntries[i]['particular'] ?? '',
                      filteredEntries[i]['debit'] != null ? filteredEntries[i]['debit'].toString() : '',
                      filteredEntries[i]['credit'] != null ? filteredEntries[i]['credit'].toString() : '',
                    ]
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Text("Grand Total Debit: ₹${totalDebit.toStringAsFixed(2)}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(width: 10),
                    pw.Text("Grand Total Credit: ₹${totalCredit.toStringAsFixed(2)}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Text("Closing Balance: ₹${(totalDebit - totalCredit).toStringAsFixed(2)}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.red)),
                  ],
                ),
              ],
            );
          },
        ),
      );

      // Save to Downloads directory
      final directory = await getExternalStorageDirectory();
      final path = "${directory!.path}/Download/ledger.pdf";
      final file = File(path);
      await file.writeAsBytes(await pdf.save());

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("PDF downloaded to Downloads folder: ledger.pdf"),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Storage permission denied."),
      ));
    }
  }

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Customer Ledger")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedCompany,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedCompany = newValue;
                        filterEntriesByCompanyAndDate();
                      });
                    },
                    items: [
                      DropdownMenuItem<String>(
                        value: null,
                        child: Text("All Companies"),
                      ),
                      ...companies.map<DropdownMenuItem<String>>((String company) {
                        return DropdownMenuItem<String>(
                          value: company,
                          child: Text(company),
                        );
                      }).toList(),
                    ],
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                    dropdownColor: Colors.white,
                    isExpanded: true,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: pickDateRange,
                  tooltip: "Select Date Range",
                ),
                IconButton(
                  icon: Icon(Icons.picture_as_pdf),
                  onPressed: downloadPDF,
                  tooltip: "Download PDF",
                ),
              ],
            ),
          ),
         if (startDate != null)
  Padding(
    padding: const EdgeInsets.all(8.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          endDate == null
              ? 'Selected Date: ${DateFormat('yyyy-MM-dd').format(startDate!)}'
              : 'Selected Date Range: ${DateFormat('yyyy-MM-dd').format(startDate!)} - ${DateFormat('yyyy-MM-dd').format(endDate!)}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    ),
  ),

          Expanded(
            child: filteredEntries.isEmpty
                ? Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Column(
                        children: [
                      DataTable(
  headingRowColor: MaterialStateColor.resolveWith((states) => Colors.blue.shade100),
  dataRowColor: MaterialStateColor.resolveWith((states) {
    return states.contains(MaterialState.selected) ? Colors.blue.shade50 : Colors.grey.shade200;
  }),
  columnSpacing: 20,
  columns: const [
    DataColumn(label: Text('#', style: TextStyle(fontWeight: FontWeight.bold))),
    DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
    DataColumn(label: Text('Invoice', style: TextStyle(fontWeight: FontWeight.bold))),
    DataColumn(label: Text('Particular', style: TextStyle(fontWeight: FontWeight.bold))),
    DataColumn(label: Text('Debit (₹)', style: TextStyle(fontWeight: FontWeight.bold))),
    DataColumn(label: Text('Credit (₹)', style: TextStyle(fontWeight: FontWeight.bold))),
  ],
  rows: () {
    int mainOrderCounter = 1;  // Main order numbering
    String? previousInvoice;   // To track invoice and display only on the first entry of each order

    return List.generate(filteredEntries.length + 2, (index) {
      if (index < filteredEntries.length) {
        final entry = filteredEntries[index];
        final currentInvoice = entry['invoice'];

        bool isMainOrder = entry['isFirstOfOrder'] == true;
        String displayNumber;

        // Determine the display number based on if it's the main order or a receipt
        if (isMainOrder) {
          displayNumber = mainOrderCounter.toString();
          mainOrderCounter++;  // Increment main order counter for the next main order
          previousInvoice = currentInvoice;  // Update invoice to track consecutive entries
        } else {
          // For receipts, use sub-numbering (e.g., 1.1, 1.2, ...)
          int subOrderCounter = 1;
          displayNumber = "${mainOrderCounter - 1}.$subOrderCounter";
          subOrderCounter++;  // Increment sub-counter within the same order
        }

        return DataRow(cells: [
          DataCell(Text(displayNumber)),  // Display the custom numbering
          DataCell(Text(entry['date'] ?? '')),
          DataCell(Text(isMainOrder ? currentInvoice : '', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold))),
          DataCell(Text(entry['particular'] ?? '', style: TextStyle(color: entry['particular'] == 'Goods Sale' ? Colors.red : Colors.green, fontWeight: FontWeight.bold))),
          DataCell(Text(entry['debit']?.toString() ?? '')),
          DataCell(Text(entry['credit']?.toString() ?? '')),
        ]);
      } else if (index == filteredEntries.length) {
        // Grand Total Row
        return DataRow(cells: [
          DataCell(Text('Grand Total', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
          DataCell(Text('')),
          DataCell(Text('')),
          DataCell(Text('')),
          DataCell(Text(totalDebit.toStringAsFixed(2), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade800))),
          DataCell(Text(totalCredit.toStringAsFixed(2), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade800))),
        ]);
      } else {
        // Closing Balance Row
        return DataRow(cells: [
          DataCell(Text('Closing Balance', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrangeAccent))),
          DataCell(Text('')),
          DataCell(Text('')),
          DataCell(Text('')),
          DataCell(Text((totalDebit - totalCredit).toStringAsFixed(2), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrangeAccent))),
          DataCell(Text('')),
        ]);
      }
    });
  }(),
)



                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
