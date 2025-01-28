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

Future<void> getFinancialReport() async {
  final token = await getTokenFromPrefs();

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
      double totalBanksToday = 0.0;

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
            .fold<double>(
                0.0,
                (sum, payment) =>
                    sum + (double.tryParse(payment['amount'] ?? '') ?? 0.0)) ??
            0.0;

        // Adjusted opening balance
        double adjustedOpeningBalance = openBalance + totalPaymentsBeforeDate;

        // Calculate today's payments
        double todayPayments = (bankData['payments'] as List<dynamic>?)
            ?.where((payment) {
              final receivedAt = DateTime.tryParse(payment['received_at'] ?? '');
              return receivedAt != null &&
                  receivedAt.year == currentDate.year &&
                  receivedAt.month == currentDate.month &&
                  receivedAt.day == currentDate.day;
            })
            .fold<double>(
                0.0,
                (sum, payment) =>
                    sum + (double.tryParse(payment['amount'] ?? '') ?? 0.0)) ??
            0.0;

        // Handle `banks` if it contains IDs instead of objects
        List<dynamic> banks = bankData['banks'] ?? [];
        double totalBankExpenses = 0.0;
        double todayBanksAmount = 0.0;

        // Add today's bank expenses to the total
        totalBanksToday += todayBanksAmount;

        // Calculate closing balance
        double closingBalance =
            adjustedOpeningBalance + todayPayments - todayBanksAmount;

        // Add to finance list
        financeList.add({
          'Bank Name': bankName,
          'Opening Balance': adjustedOpeningBalance.toStringAsFixed(2),
          'Closing Balance': closingBalance.toStringAsFixed(2),
          'credit': todayPayments.toStringAsFixed(2),
          'debit': todayBanksAmount.toStringAsFixed(2),
        });
      }

      // Log today's total bank expenses
      print("Today's Total Banks Amount: ${totalBanksToday.toStringAsFixed(2)}");

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

      // Ensure startDate is set
      if (startDate == null) {
        print("Start date is not selected");
        return;
      }

      for (var bankData in parsed['data'] ?? []) {
        String bankName = bankData['name'] ?? 'Unknown Bank';

        // Base opening balance
        double openBalance = (bankData['open_balance'] as num?)?.toDouble() ?? 0.0;

        // Calculate total payments until startDate
        double totalPaymentsUntilStartDate = (bankData['payments'] as List<dynamic>?)
            ?.where((payment) {
              final receivedAt = DateTime.tryParse(payment['received_at'] ?? '');
              return receivedAt != null && !receivedAt.isAfter(startDate!);
            })
            .fold<double>(
                0.0,
                (sum, payment) =>
                    sum + (double.tryParse(payment['amount'] ?? '') ?? 0.0)) ??
            0.0;

        // Calculate total bank expenses until startDate
        double totalExpensesUntilStartDate = (bankData['banks'] as List<dynamic>?)
            ?.where((expense) {
              final expenseDate = DateTime.tryParse(expense['expense_date'] ?? '');
              return expenseDate != null && !expenseDate.isAfter(startDate!);
            })
            .fold<double>(
                0.0,
                (sum, expense) =>
                    sum + (double.tryParse(expense['amount'] ?? '') ?? 0.0)) ??
            0.0;

        // Adjusted opening balance
        double adjustedOpeningBalance =
            openBalance + totalPaymentsUntilStartDate - totalExpensesUntilStartDate;

        // Add the calculated data to the finance list
        financeList.add({
          'Bank Name': bankName,
          'Opening Balance': adjustedOpeningBalance.toStringAsFixed(2),
          'Payments Until Start Date': totalPaymentsUntilStartDate.toStringAsFixed(2),
          'Expenses Until Start Date': totalExpensesUntilStartDate.toStringAsFixed(2),
          'Base Opening Balance': openBalance.toStringAsFixed(2),
        });
      }

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
        : ListView.builder(
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
                            '\u{20B9}${item['Opening Balance']}',
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
                            '\u{20B9}${item['credit']}',
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
                            '\u{20B9}${item['debit']}',
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
                            style: const TextStyle(fontSize: 14,color: Colors.green),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
  );
}

}
