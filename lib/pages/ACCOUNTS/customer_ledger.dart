import 'dart:convert';
import 'dart:io';
import 'package:beposoft/pages/api.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';

class CustomerLedger extends StatefulWidget {
  final int customerid;
  const CustomerLedger({Key? key, required this.customerid}) : super(key: key);

  @override
  State<CustomerLedger> createState() => _CustomerLedgerState();
}

class _CustomerLedgerState extends State<CustomerLedger> {
  List<Map<String, dynamic>> ledgerEntries = [];
  List<Map<String, dynamic>> filteredEntries = [];
  List<Map<String, dynamic>> companyList = [];

  double totalDebit = 0.0;
  double totalCredit = 0.0;
  DateTime? startDate;
  DateTime? endDate;

  String? selectedCompany;

  @override
  void initState() {
    super.initState();
    getCompanyList().then((_) {
      fetchCustomerLedgerDetails();
    });
  }

  Future<String?> getTokenFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> getCompanyList() async {
    try {
      final token = await getTokenFromPrefs();
      var response = await http.get(
        Uri.parse('$api/api/company/getadd/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        setState(() {
          companyList = data
              .map((company) => {'id': company['id'], 'name': company['name']})
              .toList();
        });
      } else {
        print("Failed to load companies: ${response.statusCode}");
      }
    } catch (error) {
      print("Error fetching companies: $error");
    }
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

          // Find the company name based on the company ID
          String companyName = companyList.firstWhere(
            (comp) => comp['id'] == entry['company'],
            orElse: () => {'name': 'Unknown Company'},
          )['name'];

          entries.add({
            'date': entry['order_date'],
            'invoice': '${entry['invoice']}/$companyName',
            'company': companyName,
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
              'invoice': '${entry['invoice']}/$companyName',
              'company': companyName,
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
      } else {
        print("Failed to fetch ledger details: ${response.statusCode}");
      }
    } catch (error) {
      print("Error fetching ledger data: $error");
    }
  }

  void filterEntriesByCompanyAndDate() {
    double debitSum = 0.0;
    double creditSum = 0.0;

    setState(() {
      filteredEntries = ledgerEntries.where((entry) {
        final entryDate = DateTime.parse(entry['date']);

        // Date filtering
        final isOnSelectedDate = startDate != null &&
            endDate == null &&
            entryDate.year == startDate!.year &&
            entryDate.month == startDate!.month &&
            entryDate.day == startDate!.day;

        final isWithinDateRange = startDate != null &&
            endDate != null &&
            entryDate.isAfter(startDate!.subtract(Duration(days: 1))) &&
            entryDate.isBefore(endDate!.add(Duration(days: 1)));

        bool dateMatch =
            startDate == null || isOnSelectedDate || isWithinDateRange;

        // Company filtering
        bool companyMatch = selectedCompany == null ||
            selectedCompany == "All Companies" ||
            entry['company'] == selectedCompany;

        return dateMatch && companyMatch;
      }).toList();

      for (var entry in filteredEntries) {
        debitSum += entry['debit'] ?? 0.0;
        creditSum += entry['credit'] ?? 0.0;
      }

      totalDebit = debitSum;
      totalCredit = creditSum;
    });
  }

  Future<void> exportToExcel() async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Customer Ledger'];

    sheetObject.appendRow(
        ['#', 'Date', 'Invoice', 'Particular', 'Debit (₹)', 'Credit (₹)']);

    for (int i = 0; i < filteredEntries.length; i++) {
      final entry = filteredEntries[i];
      sheetObject.appendRow([
        "${i + 1}",
        entry['date'] ?? '',
        entry['invoice'] ?? '',
        entry['particular'] ?? '',
        entry['debit']?.toString() ?? '',
        entry['credit']?.toString() ?? '',
      ]);
    }

    sheetObject.appendRow([]);
    sheetObject.appendRow([
      'Grand Total',
      '',
      '',
      '',
      totalDebit.toStringAsFixed(2),
      totalCredit.toStringAsFixed(2),
    ]);
    sheetObject.appendRow([
      'Closing Balance',
      '',
      '',
      '',
      (totalDebit - totalCredit).toStringAsFixed(2),
      '',
    ]);

    final tempDir = await getTemporaryDirectory();
    final tempPath = "${tempDir.path}/customer_ledger_preview.xlsx";
    final tempFile = File(tempPath);
    await tempFile.writeAsBytes(await excel.encode()!);

    await OpenFile.open(tempPath);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Save File"),
          content:
              Text("Do you want to save this file to your Downloads folder?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                saveExcelToDownloads(tempPath);
              },
              child: Text("Yes"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text("File not saved to Downloads."),
                ));
              },
              child: Text("No"),
            ),
          ],
        );
      },
    );
  }

  Future<void> saveExcelToDownloads(String tempPath) async {
    final directory = await getExternalStorageDirectory();
    final downloadPath = "${directory!.path}/Download/customer_ledger.xlsx";
    final file = File(tempPath);

    await file.copy(downloadPath);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content:
          Text("Excel file saved to Downloads folder: customer_ledger.xlsx"),
    ));
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
    if (await Permission.storage.request().isGranted) {
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              children: [
                pw.Text("Customer Ledger",
                    style: pw.TextStyle(
                        fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 20),
                pw.Table.fromTextArray(
                  headers: [
                    "#",
                    "Date",
                    "Invoice",
                    "Particular",
                    "Debit (₹)",
                    "Credit (₹)"
                  ],
                  data: [
                    for (var i = 0; i < filteredEntries.length; i++)
                      [
                        "${i + 1}",
                        filteredEntries[i]['date'] ?? '',
                        filteredEntries[i]['invoice'] ?? '',
                        filteredEntries[i]['particular'] ?? '',
                        filteredEntries[i]['debit'] != null
                            ? filteredEntries[i]['debit'].toString()
                            : '',
                        filteredEntries[i]['credit'] != null
                            ? filteredEntries[i]['credit'].toString()
                            : '',
                      ]
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Text(
                        "Grand Total Debit: ₹${totalDebit.toStringAsFixed(2)}",
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(width: 10),
                    pw.Text(
                        "Grand Total Credit: ₹${totalCredit.toStringAsFixed(2)}",
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Text(
                        "Closing Balance: ₹${(totalDebit - totalCredit).toStringAsFixed(2)}",
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.red)),
                  ],
                ),
              ],
            );
          },
        ),
      );

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
                        value: "All Companies",
                        child: Text("All Companies"),
                      ),
                      ...companyList
                          .map<DropdownMenuItem<String>>((companyItem) {
                        return DropdownMenuItem<String>(
                          value: companyItem['name'],
                          child: Text(companyItem['name'] ?? ''),
                        );
                      }).toList(),
                    ],
                    decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                IconButton(
                  icon: Icon(Icons.picture_as_pdf),
                  onPressed: exportToExcel,
                  tooltip: "Export to Excel",
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
                ? Center(
                    child: Text(
                      "No Orders Available",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Column(
                        children: [
                          DataTable(
                            headingRowColor: MaterialStateColor.resolveWith(
                                (states) => Colors.blue.shade100),
                            dataRowColor:
                                MaterialStateColor.resolveWith((states) {
                              return states.contains(MaterialState.selected)
                                  ? Colors.blue.shade50
                                  : Colors.grey.shade200;
                            }),
                            columnSpacing: 20,
                            columns: const [
                              DataColumn(
                                  label: Text('#',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))),
                              DataColumn(
                                  label: Text('Date',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))),
                              DataColumn(
                                  label: Text('Invoice',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))),
                              DataColumn(
                                  label: Text('Particular',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))),
                              DataColumn(
                                  label: Text('Debit (₹)',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))),
                              DataColumn(
                                  label: Text('Credit (₹)',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))),
                            ],
                            rows: () {
                              int mainOrderCounter = 1;
                              String? previousInvoice;

                              return List.generate(filteredEntries.length + 2,
                                  (index) {
                                if (index < filteredEntries.length) {
                                  final entry = filteredEntries[index];
                                  final currentInvoice = entry['invoice'];
                                  bool isMainOrder =
                                      entry['isFirstOfOrder'] == true;
                                  String displayNumber;

                                  if (isMainOrder) {
                                    displayNumber = mainOrderCounter.toString();
                                    mainOrderCounter++;
                                    previousInvoice = currentInvoice;
                                  } else {
                                    int subOrderCounter = 1;
                                    displayNumber =
                                        "${mainOrderCounter - 1}.$subOrderCounter";
                                    subOrderCounter++;
                                  }

                                  return DataRow(cells: [
                                    DataCell(Text(displayNumber)),
                                    DataCell(Text(entry['date'] ?? '')),
                                    DataCell(Text(
                                        isMainOrder ? currentInvoice : '',
                                        style: TextStyle(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.bold))),
                                    DataCell(Text(entry['particular'] ?? '',
                                        style: TextStyle(
                                            color: entry['particular'] ==
                                                    'Goods Sale'
                                                ? Colors.red
                                                : Colors.green,
                                            fontWeight: FontWeight.bold))),
                                    DataCell(
                                        Text(entry['debit']?.toString() ?? '')),
                                    DataCell(Text(
                                        entry['credit']?.toString() ?? '')),
                                  ]);
                                } else if (index == filteredEntries.length) {
                                  return DataRow(cells: [
                                    DataCell(Text('Grand Total',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black))),
                                    DataCell(Text('')),
                                    DataCell(Text('')),
                                    DataCell(Text('')),
                                    DataCell(Text(totalDebit.toStringAsFixed(2),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue.shade800))),
                                    DataCell(Text(
                                        totalCredit.toStringAsFixed(2),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green.shade800))),
                                  ]);
                                } else {
                                  return DataRow(cells: [
                                    DataCell(Text('Closing Balance',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.deepOrangeAccent))),
                                    DataCell(Text('')),
                                    DataCell(Text('')),
                                    DataCell(Text('')),
                                    DataCell(Text(
                                        (totalDebit - totalCredit)
                                            .toStringAsFixed(2),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.deepOrangeAccent))),
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              icon: Icon(Icons.download),
              label: Text("Export to Excel"),
              onPressed: exportToExcel,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
