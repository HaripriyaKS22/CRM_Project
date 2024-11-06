  import 'dart:convert';
  import 'package:beposoft/pages/ACCOUNTS/customer.dart';
  import 'package:beposoft/pages/ACCOUNTS/dashboard.dart';
  import 'package:beposoft/pages/ACCOUNTS/dorwer.dart';
  import 'package:beposoft/pages/ACCOUNTS/methods.dart';
  import 'package:beposoft/pages/api.dart';
  import 'package:flutter/material.dart';
  import 'package:shared_preferences/shared_preferences.dart';
  import 'package:http/http.dart' as http;

  class OrderReview extends StatefulWidget {
    final  id;
    const OrderReview({super.key, required this.id});

    @override
    State<OrderReview> createState() => _OrderReviewState();
  }

  class _OrderReviewState extends State<OrderReview> {
    Drawer d = Drawer();
    var ord;
    List<Map<String, dynamic>> items = [];

    @override
    void initState() {
      super.initState();
      initData();
    }

    Future<void> initData() async {
      await fetchOrderItems();
    }

    Future<String?> getTokenFromPrefs() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString('token');
    }

    Future<void> fetchOrderItems() async {
      try {
        final token = await getTokenFromPrefs();
        var response = await http.get(
          Uri.parse('$api/api/order/${widget.id}/items/'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final parsed = jsonDecode(response.body);
          ord = parsed['order'];
          List<dynamic> itemsData = parsed['items'];

          List<Map<String, dynamic>> orderList = [];
          for (var item in itemsData) {
            orderList.add({
              'id': item['id'],
              'name': item['name'],
              'quantity': item['quantity'],
              'rate': item['rate'],
              'tax': item['tax'],
              'discount': item['discount'],
              'actual_price': item['actual_price'],
              'exclude_price': item['exclude_price'],
              'images': item['images'],
            });
          }

          setState(() {
            items = orderList;
            print("itemmmmmmmmmmmmmmmmmm$items");
          });
        } else {
          print("Failed to fetch data. Status Code: ${response.statusCode}");
        }
      } catch (error) {
        print("Error: $error");
      }
    }

   @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
    body: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 255, 255),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            height: 140,
            child: Column(
              children: [
                SizedBox(height: 50),
                Row(
                  children: [
                    SizedBox(width: 13),
                    Container(
                      height: 70,
                      width: 70,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 220, 220, 220),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.local_shipping, size: 40, color: Colors.blue),
                    ),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ord != null ? ord['invoice'] ?? 'Invoice Number' : 'Loading...',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                        Text(
                          ord != null ? ord["company"] ?? 'Company' : '',
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              color: Colors.white,
              elevation: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15.0),
                        topRight: Radius.circular(15.0),
                      ),
                    ),
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          ord != null ? ord['manage_staff'] ?? 'manage_staff' : 'Loading...',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          ord != null ? ord["order_date"] ?? 'Date Not Available' : '',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: .0),
                        Row(
                          children: [
                            Text(
                              'Status: ',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            Spacer(),
                            Text(
                              ord != null ? '${ord["status"]}' : 'Loading...',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Family',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            Spacer(),
                            Text(
                              ord != null ? '${ord["family"]}' : 'Loading...',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.0),
                         SizedBox(height: 4.0),
              if (ord != null && ord['shipping_mode'] != null)
                Row(
                  children: [
                    Text(
                      'Shipping Mode',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    Spacer(),
                    Text(
                      '${ord['shipping_mode']}',
                      style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0), fontSize: 12),
                    ),
                  ],
                ),
                        
                        if (ord != null && ord['code_charge'] != null && ord['code_charge'] != 0)
                         SizedBox(height: 4.0),
                        if (ord != null && ord['code_charge'] != null && ord['code_charge'] != 0)
                         Row(
                          children: [
                            Text(
                              'Code Charge',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            Spacer(),
                            
                            Text(
                              ' ${ord['code_charge']}',
                              style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0), fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
         Padding(
  padding: const EdgeInsets.only(left: 20),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Billing Address',
        style: TextStyle(
          color: Color.fromARGB(255, 0, 0, 0),
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: 4),
      Text(
        ord != null ? '${ord["customer"]["name"]}' : 'Loading...',
        style: TextStyle(
          color: const Color.fromARGB(255, 0, 0, 0),
          fontSize: 13,
        ),
      ),
      Text(
        ord != null
            ? '${ord["customer"]["address"]}, ${ord["customer"]["city"]}, ${ord["customer"]["state"]}, ${ord["customer"]["zip_code"]}'
            : 'Loading...',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
      Text(
        ord != null ? 'Phone: ${ord["customer"]["phone"]}' : 'Loading...',
        style: TextStyle(
          color: Colors.grey,
          fontSize: 12,
        ),
      ),
      Text(
        ord != null ? 'Email: ${ord["customer"]["email"]}' : 'Loading...',
        style: TextStyle(
          color: Colors.grey,
          fontSize: 12,
        ),
      ),
    ],
  ),
),
Padding(
  padding: const EdgeInsets.only(right: 15, left: 15),
  child: Divider(),
),
Padding(
  padding: const EdgeInsets.only(left: 20),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Shipping Address',
        style: TextStyle(
          color: Color.fromARGB(255, 0, 0, 0),
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: 4),
      Text(
        ord != null ? '${ord["billing_address"]["name"]}' : 'Loading...',
        style: TextStyle(
          color: const Color.fromARGB(255, 0, 0, 0),
          fontSize: 13,
        ),
      ),
      Text(
        ord != null
            ? '${ord["billing_address"]["address"]}, ${ord["billing_address"]["city"]}, ${ord["billing_address"]["state"]}, ${ord["billing_address"]["zipcode"]}'
            : 'Loading...',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
      Text(
        ord != null ? 'Phone: ${ord["billing_address"]["phone"]}' : 'Loading...',
        style: TextStyle(
          color: Colors.grey,
          fontSize: 12,
        ),
      ),
      Text(
        ord != null ? 'Email: ${ord["billing_address"]["email"]}' : 'Loading...',
        style: TextStyle(
          color: Colors.grey,
          fontSize: 12,
        ),
      ),
    ],
  ),
),
Padding(
  padding: const EdgeInsets.only(left: 20, top: 10),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Products',
        style: TextStyle(
          color: Color.fromARGB(255, 0, 0, 0),
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: 10),
      // Display each item in the list within a card
      for (var item in items)
        Card(
          margin: const EdgeInsets.only(bottom: 8.0, right: 20), // Card margin
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4, // Add shadow to the card
          child: Padding(
            padding: const EdgeInsets.all(12.0), // Padding inside the card
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Display the first image in a small container
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage('$api${item["images"][0]}'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                // Display product details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['name'],
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Quantity: ${item["quantity"]}, Rate: ${item["rate"]}',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        'Total: ${item["actual_price"] * item["quantity"]}',
                        style: TextStyle(fontSize: 12, color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
