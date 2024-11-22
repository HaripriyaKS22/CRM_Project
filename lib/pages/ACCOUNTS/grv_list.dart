import 'dart:convert';
import 'package:beposoft/pages/api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class GrvList extends StatefulWidget {
  const GrvList({super.key});

  @override
  State<GrvList> createState() => _GrvListState();
}

class _GrvListState extends State<GrvList> {
  List<Map<String, dynamic>> grvlist = [];
  List<String> remarkOptions = ["return", "refund"];
  List<String> statusOptions = ["pending", "approved", "rejected"];
  List<Map<String, dynamic>> filteredProducts = [];
  TextEditingController searchController = TextEditingController();
  String selectedStatus = ""; // Default selected status

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getGrvList();
  }

  // Get token from SharedPreferences
  Future<String?> getTokenFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Fetch GRV list data from the API
  Future<void> getGrvList() async {
    setState(() {
      isLoading = true;
    });
    try {
      final token = await getTokenFromPrefs();

      var response = await http.get(
        Uri.parse('$api/api/grvget/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        var productsData = parsed['data'];

        List<Map<String, dynamic>> grvDataList = [];
        for (var productData in productsData) {
          grvDataList.add({
            'id': productData['id'],
            'product': productData['product'],
            'returnreason': productData['returnreason'],
            'invoice': productData['invoice'],
            'customer': productData['customer'],
            'staff': productData['staff'],
            'remark': productData['remark'],
            'status': productData['status'] ?? statusOptions[0],
            'order_date': productData['order_date'],
          });
        }
        setState(() {
          grvlist = grvDataList;
          filteredProducts = grvDataList; // Initially show all items
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to fetch GRV data'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error fetching GRV data'),
          duration: Duration(seconds: 2),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Update GRV item data
  Future<void> updateGrvItem(int id, String status, String remark) async {
    try {
      final token = await getTokenFromPrefs();

      // Get current time and format it correctly
      String formattedTime = DateFormat("HH:mm").format(DateTime.now());

      var response = await http.put(
        Uri.parse('$api/api/grvupdate/$id/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'status': status,
          'remark': remark,
          'date': DateTime.now().toIso8601String().split('T')[0],
          'time': formattedTime,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          grvlist = grvlist.map((item) {
            if (item['id'] == id) {
              item['status'] = status;
              item['remark'] = remark;
            }
            return item;
          }).toList();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('GRV updated successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update GRV'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error updating GRV'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Filter GRV list based on status and search query
  void _filterProducts(String query) {
    setState(() {
      filteredProducts = grvlist.where((product) {
        final matchesStatus =
            selectedStatus.isEmpty || product['status'] == selectedStatus;
        final matchesSearch = query.isEmpty ||
            product['product'].toLowerCase().contains(query.toLowerCase()) ||
            product['invoice'].toLowerCase().contains(query.toLowerCase()) ||
            product['customer'].toLowerCase().contains(query.toLowerCase()) ||
            product['staff'].toLowerCase().contains(query.toLowerCase());

        return matchesStatus && matchesSearch; // Both filters must match
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(242, 255, 255, 255),
      appBar: AppBar(
        title: const Text("GRV List"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Image.asset('lib/assets/profile.png'),
            onPressed: () {},
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: "Search GRV...",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide(
                          color: Colors.blue,
                          width: 2.0,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide(
                          color: Colors.blue,
                          width: 2.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide(
                          color: Colors.blueAccent,
                          width: 2.0,
                        ),
                      ),
                    ),
                    onChanged: (query) =>
                        _filterProducts(query), // Pass the query here
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButton<String>(
                    value: selectedStatus.isEmpty ? null : selectedStatus,
                    items: statusOptions.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedStatus = newValue;
                        });
                        _filterProducts(searchController
                            .text); // Re-filter based on the selected status
                      }
                    },
                    isExpanded: true,
                    hint: const Text("Search by Status"),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final item = filteredProducts[index];

                      return Card(
                        elevation: 4,
                        color: Colors.white,
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Product: ${item['product']}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text("Invoice: ${item['invoice']}"),
                              Text("Customer: ${item['customer']}"),
                              Text("Staff: ${item['staff']}"),
                              const Divider(color: Colors.blue, thickness: 1),
                              Text("Return Reason: ${item['returnreason']}"),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Remark:"),
                                  DropdownButton<String>(
                                    key: Key(
                                        "remark-${item['id']}"), // Unique key for dropdown
                                    value: item['remark'],
                                    hint: const Text(
                                        "Select Remark"), // Display hint when null
                                    items: remarkOptions.map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                    onChanged: (newValue) {
                                      if (newValue != null) {
                                        setState(() {
                                          item['remark'] = newValue;
                                        });
                                        updateGrvItem(item['id'],
                                            item['status'], newValue);
                                      }
                                    },
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Status:"),
                                  DropdownButton<String>(
                                    key: Key(
                                        "status-${item['id']}"), // Unique key for status dropdown
                                    value: item['status'],
                                    items: statusOptions.map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                    onChanged: (newValue) {
                                      if (newValue != null) {
                                        setState(() {
                                          item['status'] = newValue;
                                        });
                                        updateGrvItem(item['id'], newValue,
                                            item['remark'] ?? "");
                                      }
                                    },
                                  ),
                                ],
                              ),
                              const Divider(color: Colors.blue, thickness: 1),
                              Text("Created At: ${item['order_date']}"),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
