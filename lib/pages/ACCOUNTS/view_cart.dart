import 'package:beposoft/pages/ACCOUNTS/customer.dart';
import 'package:beposoft/pages/ACCOUNTS/dashboard.dart';
import 'package:beposoft/pages/ACCOUNTS/dorwer.dart';
import 'package:beposoft/pages/ACCOUNTS/methods.dart';
import 'package:beposoft/pages/ACCOUNTS/order_request.dart';
import 'package:beposoft/pages/api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class View_Cart extends StatefulWidget {
  const View_Cart({super.key});

  @override
  State<View_Cart> createState() => _View_CartState();
}

class _View_CartState extends State<View_Cart> {
  List<Map<String, dynamic>> cartdata = [];
  drower d = drower();

  @override
  void initState() {
    super.initState();
    fetchCartData();
  }

  // Fetch token from shared preferences
  Future<String?> getTokenFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Fetch cart data from API
  Future<void> fetchCartData() async {
    try {
      final token = await getTokenFromPrefs();
      final response = await http.get(
        Uri.parse("$api/api/cart/products/"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print("API Response: ${response.body}");

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        final List<dynamic> cartsData = parsed['data'];
        List<Map<String, dynamic>> cartList = [];

        for (var cartData in cartsData) {
          cartList.add({
            'id': cartData['id'],
            'name': cartData['name'],
            'image': cartData['images'][0],
            'slug': cartData['slug'],
            'size': cartData['size'],
            'quantity': cartData['quantity'],
            'price': cartData['price'],
            'note': cartData['note'] ?? '',
            'discount': cartData['discount'] ?? 0.0,
            'tax': cartData['tax']
          });
        }
        setState(() {
          cartdata = cartList;
        });
      } else {
        throw Exception('Failed to load cart data');
      }
    } catch (error) {
      print(error);
    }
  }

  // Calculate total price of cart items
  double calculateTotalPrice() {
    double total = 0;
    for (var item in cartdata) {
      final discountPerQuantity = item['discount'] ?? 0.0;
      final quantity = item['quantity'] ?? 0;
      final price = item['price'] ?? 0.0;
      final totalItemPrice = quantity * price;
      final totalDiscount = quantity * discountPerQuantity;
      total += totalItemPrice - totalDiscount;
    }
    return total;
  }

  Future<void> updatecartdetails(
      int id, int quantity, String description, double discount) async {
    try {
      final token = await getTokenFromPrefs();
      final response = await http.put(
        Uri.parse('$api/api/cart/update/$id/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'quantity': quantity,
          'note': description,
          'discount': discount,
        }),
      );

      print("Response from update: ${response.body}");

      if (response.statusCode == 200) {
        fetchCartData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cart item updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
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

  // Delete cart item from server
  Future<void> deletecartitem(int id) async {
    final token = await getTokenFromPrefs();

    try {
      final response = await http.delete(
        Uri.parse('$api/api/cart/update/$id/'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 204) {
        setState(() {
          cartdata.removeWhere((item) => item['id'] == id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Product deleted from Cart Successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Failed to delete cart ID: $id');
      }
    } catch (error) {
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete item from cart'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Popup dialog to edit cart item details
  void showPopupDialog(BuildContext context, Map<String, dynamic> item) {
    TextEditingController descriptionController =
        TextEditingController(text: item['note'] ?? '');
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
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
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
                final description = descriptionController.text;
                final quantity = int.tryParse(quantityController.text) ?? item['quantity'];
                final discount = double.tryParse(discountController.text) ?? item['discount'];

                updatecartdetails(item['id'], quantity, description, discount);
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Product List",
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ),
      drawer: Drawer(
        // Drawer content here
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            cartdata.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: cartdata.length,
                    itemBuilder: (context, index) {
                      final item = cartdata[index];
                      final discountPerQuantity = item['discount'] ?? 0.0;
                      final quantity = item['quantity'] ?? 0;
                      final price = item['price'] ?? 0.0;
                      final totalItemPrice = quantity * price;
                      final totalDiscount = quantity * discountPerQuantity;
                      final discountedTotalPrice = totalItemPrice - totalDiscount;

                      return InkWell(
                        onTap: () => showPopupDialog(context, item),
                        child: Stack(
                          children: [
                            Card(
                              elevation: 4,
                              color: Colors.white,
                              margin: EdgeInsets.all(10),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Image.network(
                                      "$api${item['image']}",
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['name'],
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text("Size: ${item['size']}"),
                                          Text("Tax: ${item['tax']}"),

                                          if (item['note'] != null && item['note'].isNotEmpty)
                                            Text(
                                              "Description: ${item['note']}",
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(fontSize: 14),
                                            ),
                                          if (quantity > 0)
                                            Text("Quantity: $quantity"),
                                          if (discountPerQuantity > 0)
                                            Text("Discount per item: ₹$discountPerQuantity"),

                                          Text("Price per item: ₹$price"),
                                          Text("Total price: ₹${totalItemPrice.toStringAsFixed(2)}"),
                                          Text(
                                            "Total discount: -₹${totalDiscount.toStringAsFixed(2)}",
                                            style: TextStyle(color: Colors.red),
                                          ),
                                          Text(
                                            "Final price after discount: ₹${discountedTotalPrice.toStringAsFixed(2)}",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 4,
                              right: 4,
                              child: IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  await deletecartitem(item['id']);
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                'Total Price: ₹${calculateTotalPrice().toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
Navigator.push(context, MaterialPageRoute(builder: (context)=>order_request()));                 },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Continue',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}