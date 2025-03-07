import 'dart:convert';
import 'package:beposoft/pages/api.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class EmiReport extends StatefulWidget {
  final int emid;
  const EmiReport({super.key, required this.emid});

  @override
  State<EmiReport> createState() => _EmiReportState();
}

class _EmiReportState extends State<EmiReport> {
  Map<String, dynamic>? emiData;
  List<Map<String, dynamic>> emiPayments = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    getEmiReport();
  }

  Future<String?> getToken() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString('token');
  }

  Future<void> getEmiReport() async {
    final token = await getToken();
    try {
      final response = await http.get(
        Uri.parse('$api/apis/emiexpense/${widget.emid}/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);

        List<Map<String, dynamic>> payments =
            List<Map<String, dynamic>>.from(parsed['emidata']);

        // Process EMI data and identify missing months
        List<Map<String, dynamic>> processedPayments =
            _generateMonthlyPayments(payments);

        setState(() {
          emiData = {
            'emi_name': parsed['emi_name'],
            'principal': parsed['principal'],
            'tenure_months': parsed['tenure_months'],
            'annual_interest_rate': parsed['annual_interest_rate'],
            'down_payment': parsed['down_payment'],
            'total_amount_paid': parsed['total_amount_paid'],
            'emi_amount': parsed['emi_amount'],
            'total_interest': parsed['total_interest'],
            'total_payment': parsed['total_payment'],
          };
          emiPayments = processedPayments;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load data';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred: $e';
        isLoading = false;
      });
    }
  }

  /// Function to generate monthly payment history including missing months
  List<Map<String, dynamic>> _generateMonthlyPayments(
      List<Map<String, dynamic>> payments) {
    if (payments.isEmpty) return [];

    // Sort payments by date
    payments.sort((a, b) => a['date'].compareTo(b['date']));

    // Get the start and end months from payments
    DateTime startDate = DateTime.parse(payments.first['date']);
    DateTime endDate = DateTime.parse(payments.last['date']);

    Map<String, double> paymentMap = {
      for (var payment in payments)
        DateFormat('yyyy-MM').format(DateTime.parse(payment['date'])):
            payment['amount']
    };

    List<Map<String, dynamic>> completePayments = [];
    DateTime currentDate = startDate;

    while (currentDate.isBefore(endDate.add(Duration(days: 1)))) {
      String monthKey = DateFormat('yyyy-MM').format(currentDate);

      completePayments.add({
        'date': DateFormat('MMM yyyy').format(currentDate),
        'amount': paymentMap[monthKey] ?? 0.0,
      });

      // Move to next month
      currentDate = DateTime(currentDate.year, currentDate.month + 1, 1);
    }

    return completePayments;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('EMI Report')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Text(errorMessage!,
                      style: const TextStyle(color: Colors.red)),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildEmiDetailsCard(),
                      const SizedBox(height: 20),
                      _buildEmiPaymentsCard(),
                    ],
                  ),
                ),
    );
  }

  /// EMI Details Card
  Widget _buildEmiDetailsCard() {
    double totalPayment = emiData!['total_payment'];
    double totalAmountPaid = emiData!['total_amount_paid'];
    double totalPaymentPending = totalPayment - totalAmountPaid;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('EMI Details', style: Theme.of(context).textTheme.titleMedium),
            const Divider(),
            _buildDetailRow('EMI Name', emiData!['emi_name']),
            _buildDetailRow('Principal Amount', emiData!['principal']),
            _buildDetailRow('Tenure (Months)', emiData!['tenure_months']),
            _buildDetailRow(
                'Annual Interest Rate', emiData!['annual_interest_rate']),
            _buildDetailRow('Down Payment', emiData!['down_payment']),
            _buildDetailRow('Total Amount Paid', emiData!['total_amount_paid']),
            _buildDetailRow('EMI Amount Per Month', emiData!['emi_amount'],
                valueColor: Colors.red),
            _buildDetailRow('Total Interest', emiData!['total_interest']),
            _buildDetailRow('Total Payment', emiData!['total_payment']),
            _buildDetailRow('Total Payment Pending', totalPaymentPending,
                valueColor: Colors.red),
          ],
        ),
      ),
    );
  }

  /// EMI Payments Card
  Widget _buildEmiPaymentsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('EMI Payments',
                style: Theme.of(context).textTheme.titleMedium),
            const Divider(),
            ...emiPayments.map((payment) {
              return Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      payment['amount'] > 0 ? Icons.payment : Icons.warning,
                      color: payment['amount'] > 0 ? Colors.green : Colors.red,
                    ),
                    title: Text(
                      'Month: ${payment['date']}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      payment['amount'] > 0
                          ? 'Amount Paid: ₹${payment['amount']}'
                          : 'Pending',
                      style: TextStyle(
                          color: payment['amount'] > 0
                              ? Colors.green
                              : Colors.red),
                    ),
                  ),
                  const Divider(),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, dynamic value,
      {Color valueColor = Colors.black}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(
            value.toString(),
            style: TextStyle(color: valueColor, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
