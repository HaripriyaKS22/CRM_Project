import 'dart:convert';
import 'package:beposoft/pages/ACCOUNTS/order.review.dart';
import 'package:beposoft/pages/api.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class OrderList extends StatefulWidget {
  const OrderList({super.key});

  @override
  State<OrderList> createState() => _OrderListState();
}

class _OrderListState extends State<OrderList> {
  List<Map<String, dynamic>> orders = [];

  @override
  void initState() {
    super.initState();
    fetchOrderData();
  }

  Future<String?> getTokenFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> fetchOrderData() async {
    try {
      final token = await getTokenFromPrefs();
      var response = await http.get(
        Uri.parse('$api/api/orders/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print("AAAAAAAA================${response.body}");

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        var productsData = parsed; 
        List<Map<String, dynamic>> orderList = [];

        for (var productData in productsData) {
          orderList.add({
            'id':productData['id'],
            'invoice': productData['invoice'],
            'manage_staff': productData['manage_staff'],
            'customer_name': productData['customer']['name'],
            'status': productData['status'],
            'total_amount': productData['total_amount'],
            'order_date': productData['order_date'],
          });
        }

        setState(() {
          orders = orderList;
        });
      }
    } catch (error) {
      print("Error: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order List'),
      ),
      body: orders.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return GestureDetector(
                  onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>OrderReview(id:order['id'])));

                  },
                  child: Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Invoice: ${order['invoice']}', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.blue)),
                          Text('${order['manage_staff']}',style: TextStyle(fontWeight: FontWeight.bold),),
                          Text('Customer: ${order['customer_name']}'),
                            Text(
                              'Status: ${order['status']}',
                              style: TextStyle(
                                color: order['status'] == 'Pending' ? Colors.red : Colors.green,
                              ),
                            ),
                          Text('Total Amount: ₹${order['total_amount']}',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.green)),
                            Text(
                              'Order Date: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(order['order_date']))}',
                            ),                      ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}