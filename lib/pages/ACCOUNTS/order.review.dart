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
 bool showAllProducts = false;
    Future<String?> getTokenFromPrefs() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString('token');
    }
double netAmountBeforeTax = 0.0; // Define at the class level
double totalTaxAmount = 0.0; // Define at the class level
double payableAmount = 0.0; // Define at the class level
double totalDiscount = 0.0; // Define at the class level

Future<void> fetchOrderItems() async {
  try {
    print('$api/api/order/${widget.id}/items/');
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
      double calculatedNetAmount = 0.0;
      double calculatedTotalTax = 0.0;
      double calculatedPayableAmount = 0.0;
      double calculatedTotalDiscount = 0.0;

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

        // Convert values to double for safe calculation
        double excludePrice = (item['exclude_price'] ?? 0).toDouble();
        double actualPrice = (item['actual_price'] ?? 0).toDouble();
        double discount = (item['discount'] ?? 0).toDouble();
        int quantity = item['quantity'] ?? 1;

        // Add the exclude_price to net amount
        calculatedNetAmount += excludePrice;

        // Calculate and add the tax amount for each product
        double taxAmountForItem = actualPrice - excludePrice;
        calculatedTotalTax += taxAmountForItem;

        // Add discount amount for each product
        calculatedTotalDiscount += discount * quantity;

        // Calculate payable amount after subtracting discount
        double payableForItem = (actualPrice - discount) * quantity;
        calculatedPayableAmount += payableForItem;
      }

      setState(() {
        items = orderList;
        netAmountBeforeTax = calculatedNetAmount;
        totalTaxAmount = calculatedTotalTax;
        payableAmount = calculatedPayableAmount;
        totalDiscount = calculatedTotalDiscount;
        print("Net Amount Before Tax: $netAmountBeforeTax");
        print("Total Tax Amount: $totalTaxAmount");
        print("Payable Amount: $payableAmount");
        print("Total Discount: $totalDiscount");
      });
    } else {
      print("Failed to fetch data. Status Code: ${response.statusCode}");
    }
  } catch (error) {
    print("Error: $error");
  }
}


    Future<void> removeproduct(int Id) async {
    final token = await getTokenFromPrefs();

    try {
      final response = await http.delete(
        Uri.parse('$api/api/remove/order/$Id/item/'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
    print(response.statusCode);
    if(response.statusCode == 200){
         ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Color.fromARGB(255, 49, 212, 4),
          content: Text('Deleted sucessfully'),
        ),
      );
      // Navigator.push(context, MaterialPageRoute(builder: (context)=>OrderReview(id:widget.id)));
       await fetchOrderItems();
    }

      if (response.statusCode == 204) {
      } else {
        throw Exception('Failed to delete wishlist ID: $Id');
      }
    } catch (error) {
    }
  }

  void removeProductindex(int index) {
    setState(() {
      items.removeAt(index);
    });
  }


 void showPopupDialog(BuildContext context, Map<String, dynamic> item) {
    
    TextEditingController quantityController =
        TextEditingController(text: item['quantity']?.toString() ?? '');
    TextEditingController discountController =
        TextEditingController(text: item['discount']?.toString() ?? '');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Edit Item Details',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
             
              TextField(
                controller: quantityController,
                decoration: InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: discountController,
                decoration: InputDecoration(labelText: 'Discount (in Rs for each product)'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
               
                final quantity = int.tryParse(quantityController.text) ?? item['quantity'];
                final discount = double.tryParse(discountController.text) ?? item['discount'];

                updatedetails(item['id'], quantity, discount);
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }
Future<void> updatedetails(
      int id, int quantity,double discount) async {
    try {
      final token = await getTokenFromPrefs();
      final response = await http.put(
        Uri.parse('$api/api/remove/order/$id/item/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'quantity': quantity,
          'discount': discount,
        }),
      );

      print("Response from update: ${response.body}");

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cart item updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
         await fetchOrderItems();
        // Navigator.push(context, MaterialPageRoute(builder: (context)=>OrderReview(id: widget.id)));
      } else {
        throw Exception('Failed to update cart item');
      }
    } catch (error) {
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update cart item'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

   @override
Widget build(BuildContext context) {
   final visibleItems = showAllProducts ? items : items.take(2).toList();
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
      padding: const EdgeInsets.only( top: 10,right: 15,left: 15),
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

          // Display each item in the visibleItems list within a card
          for (var item in visibleItems )
            GestureDetector(
              onTap: () {
                showPopupDialog(context, item);
              },
              child: Card(
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
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
                            Row(
                              children: [
                                Text(
                                  'Excluded price: ${item["exclude_price"]}',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                SizedBox(width: 4,),
                                
                                if(item["tax"]!=0)
                                 Text('Tax: ${item["tax"]}',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),)
                              ],
                            ),
                            Text('Tax Amount: ${item["rate"] - item["exclude_price"]}', style: TextStyle(fontSize: 12, color: Colors.grey),),
                            Row(
                              children: [
                                Text(
                                  'Total: ${item["actual_price"] * item["quantity"]}',
                                  style: TextStyle(fontSize: 12, color: Colors.black),
                                ),
                                Spacer(),
                                GestureDetector(
                                  onTap: () {
                                    removeproduct(item["id"]);
                                   
                                  },
                                  child: Image.asset(
                                    height: 25,
                                    width: 25,
                                    "lib/assets/delete.png"
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // "See More" or "See Less" Button
          if (items.length > 3) // Show button only if there are more than 3 items
            TextButton(
              onPressed: () {
                setState(() {
                  showAllProducts = !showAllProducts; // Toggle the visibility
                });
              },
              child: Text(showAllProducts ? 'See Less' : 'See More',style: TextStyle(color: Colors.blue),),
            ),
        ],
      ),
    ),

    Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 2, 65, 96),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 3,
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Bank Details',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Icon(
                          Icons.credit_card,
                          color: Colors.white,
                          size: 24,
                        ),
                      ],
                    ),
                    
                    Row(
                      children: [
                        Text(
                          ord != null ? ord["bank"]["name"] : 'Loading...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            letterSpacing: 2,
                          ),
                        ),
                        Spacer(),
                        Image.asset(
                          height: 40,
                          width: 40,
                          'lib/assets/money.png'
                        )
                      ],
                    ),
                    SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Account Holder',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              ord != null
                                  ? ord["customer"]["name"]
                                  : 'Loading...',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Account No: ',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  ord != null
                                      ? ord["bank"]["account_number"]
                                      : 'Loading...',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  'IFSC CODE: ',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  ord != null
                                      ? ord["bank"]["ifsc_code"]
                                      : 'Loading...',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  'Branch: ',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  ord != null
                                      ? ord["bank"]["branch"]
                                      : 'Loading...',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  'Open Balance: ',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  ord != null
                                      ? ord["bank"]["open_balance"]
                                          .toStringAsFixed(
                                              2) // Formats to 2 decimal places
                                      : 'Loading...',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
SizedBox(height: 10,),
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  child: Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5),
          spreadRadius: 3,
          blurRadius: 10,
          offset: Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Billing Summary',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Net Amount Before Tax',
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 14,
              ),
            ),
            Text(
              '\$${netAmountBeforeTax.toStringAsFixed(2)}', // Format to 2 decimal places
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
        SizedBox(height: 4,),
         Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total Discount',
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 14,
              ),
            ),
            Text(
              '\$${totalDiscount.toStringAsFixed(2)}', // Format to 2 decimal places
              style: TextStyle(
                color: const Color.fromARGB(255, 3, 3, 3),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
        SizedBox(height: 4,),
         Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total Tax Amount',
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 14,
              ),
            ),
            Text(
              '\$${totalTaxAmount.toStringAsFixed(2)}', // Format to 2 decimal places
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
         SizedBox(height: 4,),
         Divider(),
         Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total Payable Amount ',
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 14,
              ),
            ),
            Text(
              '\$${payableAmount.toStringAsFixed(2)}', // Format to 2 decimal places
              style: TextStyle(
                color: const Color.fromARGB(255, 1, 155, 24),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    ),
  ),
),
  SizedBox(height: 14,),


        ],
      ),
    ),
  );
}
}
