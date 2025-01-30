import 'dart:convert';
import 'package:beposoft/pages/ACCOUNTS/dashboard.dart';
import 'package:beposoft/pages/BDM/bdm_dshboard.dart';
import 'package:beposoft/pages/BDO/bdo_dashboard.dart';
import 'package:beposoft/pages/api.dart';
import 'package:intl/intl.dart';  // For date formatting
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FinancialReport extends StatefulWidget {
  const FinancialReport({super.key});

  @override
  State<FinancialReport> createState() => _FinancialReportState();
}

class _FinancialReportState extends State<FinancialReport> {
  List<Map<String, dynamic>> Finance = [];

  DateTime? selectedDate; // For single date filter
  DateTime? startDate; // For date range filter
  DateTime? endDate; // For date range filter
  @override
  void initState() {
    super.initState();
    getFinancialReport();
  }
    double totalAdjustedOpeningBalance = 0.0;
      double totalClosingBalance = 0.0;
      double totalTodayPayments = 0.0;
      double totalTodayBanksAmount = 0.0;

Future<void> getFinancialReport() async {
  final token = await getTokenFromPrefs();
 totalAdjustedOpeningBalance = 0.0;
  totalClosingBalance = 0.0;
  totalTodayPayments = 0.0;
  totalTodayBanksAmount = 0.0;
  try {
    final response = await http.get(
      Uri.parse('$api/api/finance-report/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print("response.body${response.body}");

    if (response.statusCode == 200) {
      final parsed = jsonDecode(response.body);
      final currentDate = DateTime.now();

      List<Map<String, dynamic>> financeList = [];
  
      for (var bankData in parsed['data'] ?? []) {
        String bankName = bankData['name'] ?? 'Unknown Bank';

        // Base opening balance
        double openBalance = (bankData['open_balance'] as num?)?.toDouble() ?? 0.0;

        // Calculate total payments before today
        double totalPaymentsBeforeDate = (bankData['payments'] as List<dynamic>?)
            ?.where((payment) {
              final receivedAt = DateTime.tryParse(payment['received_at'] ?? '');
              return receivedAt != null &&
                  receivedAt.isBefore(currentDate) &&
                  receivedAt.day != currentDate.day;
            })
            .fold<double>(0.0, (sum, payment) {
              return sum + (double.tryParse(payment['amount'] ?? '') ?? 0.0);
            }) ??
            0.0;
double totalBankExpensesBeforeDate = (bankData['banks'] as List<dynamic>?)
    ?.where((bank) {
      final expenseDate = DateTime.tryParse(bank['expense_date'] ?? '');
      return expenseDate != null &&
          expenseDate.isBefore(currentDate) &&
          expenseDate.day != currentDate.day;
    })
    .fold<double>(0.0, (sum, bank) {
      return sum + (double.tryParse(bank['amount'] ?? '') ?? 0.0);
    }) ?? 0.0;
        // Adjusted opening balance
        double adjustedOpeningBalance = openBalance + totalPaymentsBeforeDate-totalBankExpensesBeforeDate;
        totalAdjustedOpeningBalance += adjustedOpeningBalance;

        // Calculate today's payments
        double todayPayments = (bankData['payments'] as List<dynamic>?)
            ?.where((payment) {
              final receivedAt = DateTime.tryParse(payment['received_at'] ?? '');
              return receivedAt != null &&
                  receivedAt.year == currentDate.year &&
                  receivedAt.month == currentDate.month &&
                  receivedAt.day == currentDate.day;
            })
            .fold<double>(0.0, (sum, payment) {
              return sum + (double.tryParse(payment['amount'] ?? '') ?? 0.0);
            }) ??
            0.0;

        totalTodayPayments += todayPayments;

        // Handle `banks` for today's expenses
        List<dynamic> banks = bankData['banks'] ?? [];
        double todayBanksAmount = banks
            .where((bank) {
              final expenseDate = DateTime.tryParse(bank['expense_date'] ?? '');
              return expenseDate != null &&
                  expenseDate.year == currentDate.year &&
                  expenseDate.month == currentDate.month &&
                  expenseDate.day == currentDate.day;
            })
            .fold<double>(0.0, (sum, bank) {
              return sum + (double.tryParse(bank['amount'] ?? '') ?? 0.0);
            });

        totalTodayBanksAmount += todayBanksAmount;

        // Calculate closing balance
        double closingBalance =
            adjustedOpeningBalance + todayPayments - todayBanksAmount;
        totalClosingBalance += closingBalance;

        // Add to finance list
        financeList.add({
          'Bank Name': bankName,
          'Opening Balance': adjustedOpeningBalance.toStringAsFixed(2),
          'Closing Balance': closingBalance.toStringAsFixed(2),
          'Credit': todayPayments.toStringAsFixed(2),
          'Debit': todayBanksAmount.toStringAsFixed(2),
        });
      }

      // Log totals
      print("Total Adjusted Opening Balance: ${totalAdjustedOpeningBalance.toStringAsFixed(2)}");
      print("Total Closing Balance: ${totalClosingBalance.toStringAsFixed(2)}");
      print("Total Today's Payments: ${totalTodayPayments.toStringAsFixed(2)}");
      print("Total Today's Bank Expenses: ${totalTodayBanksAmount.toStringAsFixed(2)}");

      // Update state to reflect the finance list in UI
      setState(() {
        Finance = financeList;
        print("Filtered Finance Data: $Finance");
      });
    }
  } catch (e) {
    print("Error: $e");
  }
}


  Future<String?> getTokenFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<String?> getdepFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('department');
  } 

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      initialDateRange: startDate != null && endDate != null
          ? DateTimeRange(start: startDate!, end: endDate!)
          : null,
    );
    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;

      });
getFinancialReport2();
    }
  }


Future<void> getFinancialReport2() async {
  final token = await getTokenFromPrefs();
 totalAdjustedOpeningBalance = 0.0;
  totalClosingBalance = 0.0;
  totalTodayPayments = 0.0;
  totalTodayBanksAmount = 0.0;
  try {
    final response = await http.get(
      Uri.parse('$api/api/finance-report/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final parsed = jsonDecode(response.body);
      List<Map<String, dynamic>> financeList = [];

     

      // Ensure startDate and endDate are set
      if (startDate == null || endDate == null) {
        print("Start date or End date is not selected");
        return;
      }

      for (var bankData in parsed['data'] ?? []) {
        String bankName = bankData['name'] ?? 'Unknown Bank';

        // Base opening balance
        double openBalance = (bankData['open_balance'] as num?)?.toDouble() ?? 0.0;

        // Calculate total payments before startDate
        double totalPaymentsBeforeStartDate = (bankData['payments'] as List<dynamic>?)
            ?.where((payment) {
              final receivedAt = DateTime.tryParse(payment['received_at'] ?? '');
              return receivedAt != null && receivedAt.isBefore(startDate!);
            })
            .fold<double>(
                0.0,
                (sum, payment) =>
                    sum + (double.tryParse(payment['amount'] ?? '') ?? 0.0)) ?? 
            0.0;

        // Calculate total expenses before startDate
        double totalExpensesBeforeStartDate = (bankData['banks'] as List<dynamic>?)
            ?.where((expense) {
              final expenseDate = DateTime.tryParse(expense['expense_date'] ?? '');
              return expenseDate != null && expenseDate.isBefore(startDate!);
            })
            .fold<double>(
                0.0,
                (sum, expense) =>
                    sum + (double.tryParse(expense['amount'] ?? '') ?? 0.0)) ?? 
            0.0;

        // Adjusted opening balance
        double adjustedOpeningBalance = openBalance + totalPaymentsBeforeStartDate - totalExpensesBeforeStartDate;

        // Calculate total payments until endDate
        double totalPaymentsUntilEndDate = (bankData['payments'] as List<dynamic>?)
            ?.where((payment) {
              final receivedAt = DateTime.tryParse(payment['received_at'] ?? '');
              return receivedAt != null && !receivedAt.isAfter(endDate!);
            })
            .fold<double>(
                0.0,
                (sum, payment) =>
                    sum + (double.tryParse(payment['amount'] ?? '') ?? 0.0)) ?? 
            0.0;

        // Calculate total expenses until endDate
        double totalExpensesUntilEndDate = (bankData['banks'] as List<dynamic>?)
            ?.where((expense) {
              final expenseDate = DateTime.tryParse(expense['expense_date'] ?? '');
              return expenseDate != null && !expenseDate.isAfter(endDate!);
            })
            .fold<double>(
                0.0,
                (sum, expense) =>
                    sum + (double.tryParse(expense['amount'] ?? '') ?? 0.0)) ?? 
            0.0;

        // Calculate payments between startDate and endDate
        double totalPaymentsBetween = (bankData['payments'] as List<dynamic>?)
            ?.where((payment) {
              final receivedAt = DateTime.tryParse(payment['received_at'] ?? '');
              return receivedAt != null &&
                  !receivedAt.isBefore(startDate!) &&
                  !receivedAt.isAfter(endDate!);
            })
            .fold<double>(
                0.0,
                (sum, payment) =>
                    sum + (double.tryParse(payment['amount'] ?? '') ?? 0.0)) ?? 
            0.0;

        // Calculate expenses between startDate and endDate
        double totalExpensesBetween = (bankData['banks'] as List<dynamic>?)
            ?.where((expense) {
              final expenseDate = DateTime.tryParse(expense['expense_date'] ?? '');
              return expenseDate != null &&
                  !expenseDate.isBefore(startDate!) &&
                  !expenseDate.isAfter(endDate!);
            })
            .fold<double>(
                0.0,
                (sum, expense) =>
                    sum + (double.tryParse(expense['amount'] ?? '') ?? 0.0)) ?? 
            0.0;

        // Calculate closing balance
        double closingBalance =
            openBalance + totalPaymentsUntilEndDate - totalExpensesUntilEndDate;

        // Update totals
        totalAdjustedOpeningBalance += adjustedOpeningBalance;
        totalClosingBalance += closingBalance;
        totalTodayPayments += totalPaymentsBetween;
        totalTodayBanksAmount += totalExpensesBetween;

        // Add the calculated data to the finance list
        financeList.add({
          'Bank Name': bankName,
          'Base Opening Balance': openBalance.toStringAsFixed(2),
          'Opening Balance': adjustedOpeningBalance.toStringAsFixed(2),
          'Credit Until End Date': totalPaymentsUntilEndDate.toStringAsFixed(2),
          'Debit Until End Date': totalExpensesUntilEndDate.toStringAsFixed(2),
          'credit': totalPaymentsBetween.toStringAsFixed(2),
          'debit': totalExpensesBetween.toStringAsFixed(2),
          'Closing Balance': closingBalance.toStringAsFixed(2),
        });
      }

      // Print totals
      print('Total Adjusted Opening Balance: $totalAdjustedOpeningBalance');
      print('Total Closing Balance: $totalClosingBalance');
      print('Total Payments Between: $totalTodayPayments');
      print('Total Expenses Between: $totalTodayBanksAmount');

      // Update the state with the calculated finance list
      setState(() {
        Finance = financeList;
        print("Filtered Finance Data: $Finance");
      });
    } else {
      print("Failed to fetch data. Status code: ${response.statusCode}");
    }
  } catch (e) {
    print("Error: $e");
  }
}



  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text(
        'Financial Report',
        style: TextStyle(color: Color.fromARGB(255, 3, 3, 3), fontSize: 16),
      ),
       leading: IconButton(
          icon: const Icon(Icons.arrow_back), // Custom back arrow
          onPressed: () async{
                    final dep= await getdepFromPrefs();
if(dep=="BDO" ){
   Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => bdo_dashbord()), // Replace AnotherPage with your target page
            );

}
else if(dep=="BDM" ){
   Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => bdm_dashbord()), // Replace AnotherPage with your target page
            );
}
else {
    Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => dashboard()), // Replace AnotherPage with your target page
            );

}
           
          },
        ),
         actions: [
          IconButton(
            icon: Image.asset('lib/assets/profile.png'),
            onPressed: () {},
          ),
          // IconButton(
          //   icon: Icon(Icons.calendar_today),
          //   onPressed: () => _selectSingleDate(context),
          // ),
          IconButton(
            icon: Icon(Icons.date_range),
            onPressed: () => _selectDateRange(context),
          ),
        ],


    ),
   body: Finance.isEmpty
    ? const Center(child: CircularProgressIndicator()) // Show loader while data is being fetched
    : Stack(
        children: [
          ListView.builder(
            padding: const EdgeInsets.only(bottom: 160), // Add padding to avoid overlapping
            itemCount: Finance.length,
            itemBuilder: (context, index) {
              final item = Finance[index]; // Current bank data
              return Card(
                color: Colors.white,
                margin: const EdgeInsets.all(8.0),
                elevation: 4.0,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['Bank Name'] ?? 'Unknown Bank',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Opening Balance:',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '\u{20B9}${item['Opening Balance'] }',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Today Credit:',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          Text(
  '\u{20B9}${item['credit'] ?? '0.0'}',
  style: const TextStyle(fontSize: 14, color: Colors.blue),
),

                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Today Debit:',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '\u{20B9}${item['debit']  ?? '0.0'}',
                            style: const TextStyle(fontSize: 14, color: Colors.red),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Closing Balance:',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '\u{20B9}${item['Closing Balance']}',
                            style: const TextStyle(fontSize: 14, color: Colors.green),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Material(
              elevation: 12,
              color: const Color.fromARGB(255, 12, 80, 163),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  color: Color.fromARGB(255, 12, 80, 163),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Report Summary',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Divider(
                      color: Colors.white.withOpacity(0.5),
                      thickness: 1,
                      indent: 0,
                      endIndent: 0,
                    ),
                    _buildRowWithTwoColumns('Total Opening Blance:', totalAdjustedOpeningBalance,
                        'Total Closing Balance:', totalClosingBalance),
                    _buildRowWithTwoColumns('Credits', totalTodayPayments,
                        'Debit', totalTodayBanksAmount),
                   
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

  );
}
 Widget _buildRowWithTwoColumns(
      String label1, dynamic value1, String label2, dynamic value2) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label1,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
                Text(
                  value1.toString(),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label2,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
                Text(
                  value2.toString(),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
