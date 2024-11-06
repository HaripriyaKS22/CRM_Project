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
                        if(ord['shipping_mode']!=null)
                        Row(
                          children: [
                            Text(
                              'Shipping Mode',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            Spacer(),
                            Text(
                              ord != null ? ' ${ord['shipping_mode']}' : 'Loading...',
                              style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0), fontSize: 12),
                            ),
                          ],
                        ),
                        
                        if(ord['code_charge']!=0)
                         SizedBox(height: 4.0),
                        if(ord['code_charge']!=0)
                         Row(
                          children: [
                            Text(
                              'Code Charge',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            Spacer(),
                            
                            Text(
                              ord != null ? ' ${ord['code_charge']}' : 'Loading...',
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

        ],
      ),
    ),
  );
}
}

  //   Widget _buildPackageHeader() {
  //     return Container(
      
  //       decoration: BoxDecoration(
  //         color: Colors.blue,
  //         borderRadius: BorderRadius.circular(10),
  //       ),
  //       child: Row(
  //         children: [
  //           Icon(Icons.local_shipping, size: 40, color: Colors.white),
  //           SizedBox(width: 10),
  //           Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(
  //                 ord["invoice"] ?? 'Invoice Number',
  //                 style: TextStyle(
  //                   fontSize: 18,
  //                   fontWeight: FontWeight.bold,
  //                   color: Colors.black,
  //                 ),
  //               ),
  //               Text(
  //                 'Package Delivered',
  //                 style: TextStyle(color: Colors.black),
  //               ),
  //             ],
  //           ),
  //         ],
  //       ),
  //     );
  //   }

  //   Widget _buildDeliveryInfo() {
  //     return Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           'Picked on ${ord["order_date"] ?? 'Date Not Available'}',
  //           style: TextStyle(color: Colors.grey),
  //         ),
  //         Text(
  //           '${ord["customer"]["address"]}, ${ord["customer"]["city"]}',
  //           style: TextStyle(fontWeight: FontWeight.bold),
  //         ),
  //         Divider(),
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             Text('Delivery Charges', style: TextStyle(color: Colors.grey)),
  //             Text('₹${ord["code_charge"]}', style: TextStyle(fontWeight: FontWeight.bold)),
  //           ],
  //         ),
  //         Divider(),
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             Text('Package Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
  //             Text('₹${ord["total_amount"]}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
  //           ],
  //         ),
  //       ],
  //     );
  //   }

  //  Widget _buildPackageDetails() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         'Package Details',
  //         style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  //       ),
  //       SizedBox(height: 10),
  //       Text('Invoice Number'),
  //       Text(ord["invoice"] ?? '', style: TextStyle(fontWeight: FontWeight.bold)),
  //       SizedBox(height: 5),
  //       Text('Package Items'),
  //       if (ord["items"] != null && ord["items"].isNotEmpty) ...ord["items"].map<Widget>((item) {
  //         return Padding(
  //           padding: const EdgeInsets.symmetric(vertical: 4.0),
  //           child: Text(
  //             '${item["name"]} - ₹${item["rate"]} x ${item["quantity"]}',
  //             style: TextStyle(fontWeight: FontWeight.bold),
  //           ),
  //         );
  //       }).toList() else
  //         Text('No items available', style: TextStyle(color: Colors.grey)),
  //       SizedBox(height: 5),
  //       Text('Delivery Type'),
  //       Text(ord["shipping_mode"] ?? '', style: TextStyle(fontWeight: FontWeight.bold)),
  //       SizedBox(height: 5),
  //       Text('Date'),
  //       Text(ord["order_date"] ?? '', style: TextStyle(fontWeight: FontWeight.bold)),
  //     ],
  //   );
  // }

  //   Widget _buildFooterButtons() {
  //     return ButtonBar(
  //       alignment: MainAxisAlignment.spaceEvenly,
  //       children: [
  //         ElevatedButton.icon(
  //           onPressed: () {},
  //           icon: Icon(Icons.email),
  //           label: Text("Email Invoice"),
  //           style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow),
  //         ),
  //         ElevatedButton.icon(
  //           onPressed: () {},
  //           icon: Icon(Icons.help),
  //           label: Text("Need help?"),
  //           style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow),
  //         ),
  //       ],
  //     );
  //   }
  // }