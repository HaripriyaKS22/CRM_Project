import 'dart:convert';
import 'dart:io';
import 'package:beposoft/pages/ACCOUNTS/customer.dart';
import 'package:beposoft/pages/ACCOUNTS/dashboard.dart';
import 'package:beposoft/pages/ACCOUNTS/dorwer.dart';
import 'package:beposoft/pages/ACCOUNTS/methods.dart';
import 'package:beposoft/pages/ACCOUNTS/order.review.dart';
import 'package:beposoft/pages/api.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'package:pdf/pdf.dart';

import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import 'package:open_file/open_file.dart';
class OrderList extends StatefulWidget {
  const OrderList({super.key});

  @override
  State<OrderList> createState() => _OrderListState();
}

class _OrderListState extends State<OrderList> {
  List<Map<String, dynamic>> orders = [];
  List<Map<String, dynamic>> filteredOrders = [];
  String searchQuery = '';

  DateTime? selectedDate; // For single date filter
  DateTime? startDate; // For date range filter
  DateTime? endDate; // For date range filter

    drower d = drower();
  Widget _buildDropdownTile(
      BuildContext context, String title, List<String> options) {
    return ExpansionTile(
      title: Text(title),
      children: options.map((option) {
        return ListTile(
          title: Text(option),
          onTap: () {
            Navigator.pop(context);
            d.navigateToSelectedPage(
                context, option); // Navigate to selected page
          },
        );
      }).toList(),
    );
  }

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

    print("ordersssssssssssss${response.body}");

    if (response.statusCode == 200) {
      final parsed = jsonDecode(response.body);
      var productsData = parsed;
      List<Map<String, dynamic>> orderList = [];

      for (var productData in productsData) {
        // Parse the date
        String rawOrderDate = productData['order_date'];
        String formattedOrderDate = rawOrderDate; // Fallback in case of parsing failure

        try {
          DateTime parsedOrderDate = DateFormat('dd/MM/yy').parse(rawOrderDate);
          formattedOrderDate = DateFormat('yyyy-MM-dd').format(parsedOrderDate); // Convert to desired format
        } catch (e) {
          print("Error parsing date: $rawOrderDate - $e");
        }

        orderList.add({
          'id': productData['id'],
          'invoice': productData['invoice'],
          'manage_staff': productData['manage_staff'],
          'customer': {
            'name': productData['customer']['name'],
            'phone': productData['customer']['phone'],
            'email': productData['customer']['email'],
            'address': productData['customer']['address'],
          },
          'billing_address': {
            'name': productData['billing_address']['name'],
            'email': productData['billing_address']['email'],
            'zipcode': productData['billing_address']['zipcode'],
            'address': productData['billing_address']['address'],
            'phone': productData['billing_address']['phone'],
            'city': productData['billing_address']['city'],
            'state': productData['billing_address']['state'],
          },
          'bank': {
            'name': productData['bank']['name'],
            'account_number': productData['bank']['account_number'],
            'ifsc_code': productData['bank']['ifsc_code'],
            'branch': productData['bank']['branch'],
          },
          'items': productData['items'] != null
              ? productData['items'].map((item) {
                  return {
                    'id': item['id'],
                    'name': item['name'],
                    'quantity': item['quantity'],
                    'price': item['price'],
                    'tax': item['tax'],
                    'discount': item['discount'],
                    'images': item['images'],
                  };
                }).toList()
              : [], // Fallback to empty list
          'status': productData['status'],
          'total_amount': productData['total_amount'],
          'order_date': formattedOrderDate, // Use the formatted string
        });
      }

      setState(() {
        orders = orderList;
        filteredOrders = orderList;
        print("filterrrrrrrrrrrrrrrrrrrrrrrrrr$filteredOrders");
      });
    }
  } catch (error) {
    print("Error: $error");
  }
}

  void _filterOrders(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredOrders = orders;
      } else {
        filteredOrders = orders.where((order) {
          final customerName =
              order['customer_name']?.toString().toLowerCase() ?? '';
          final invoice = order['invoice']?.toString().toLowerCase() ?? '';
          final manageStaff =
              order['manage_staff']?.toString().toLowerCase() ?? '';
          final totalAmount =
              order['total_amount']?.toString().toLowerCase() ?? '';

          return customerName.contains(query.toLowerCase()) ||
              invoice.contains(query.toLowerCase()) ||
              manageStaff.contains(query.toLowerCase()) ||
              totalAmount.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  // Method to filter orders by single date
  void _filterOrdersBySingleDate() {
    if (selectedDate != null) {
      setState(() {
        filteredOrders = orders.where((order) {
          final orderDate = DateTime.parse(order['order_date']);
          return orderDate.year == selectedDate!.year &&
              orderDate.month == selectedDate!.month &&
              orderDate.day == selectedDate!.day;
        }).toList();
      });
    }
  }

  // Method to filter orders between two dates
 // Method to filter orders between two dates, inclusive of start and end dates
void _filterOrdersByDateRange() {
  if (startDate != null && endDate != null) {
    setState(() {
      filteredOrders = orders.where((order) {
        final orderDate = DateTime.parse(order['order_date']);
        return (orderDate.isAtSameMomentAs(startDate!) ||
                orderDate.isAtSameMomentAs(endDate!) ||
                (orderDate.isAfter(startDate!) && orderDate.isBefore(endDate!)));
      }).toList();
    });
  }
}


  Future<void> _selectSingleDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      _filterOrdersBySingleDate();
    }
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
      _filterOrdersByDateRange();
    }
  }
Future<void> exportToExcel() async {
  var excel = Excel.createExcel();
  Sheet sheetObject = excel['Order List'];

  // Add header row
  sheetObject.appendRow([
    'Invoice',
    'Manager',
    'Customer Name',
    'Customer Phone',
    'Customer Email',
    'Customer Address',
    'Billing Name',
    'Billing Email',
    'Billing Phone',
    'Billing Address',
    'Billing City',
    'Billing State',
    'Billing Zipcode',
    'Bank Name',
    'Bank Account Number',
    'Bank IFSC Code',
    'Bank Branch',
    'Item Name',
    'Item Quantity',
    'Item Price',
    'Item Tax',
    'Item Discount',
    'Order Status',
    'Total Amount',
    'Order Date',
  ]);

  // Populate rows with data
  for (var order in filteredOrders) {
    // Iterate through items to create separate rows for each item
    for (var item in order['items']) {
      sheetObject.appendRow([
        order['invoice'] ?? '',
        order['manage_staff'] ?? '',
        order['customer']['name'] ?? '',
        order['customer']['phone'] ?? '',
        order['customer']['email'] ?? '',
        order['customer']['address'] ?? '',
        order['billing_address']['name'] ?? '',
        order['billing_address']['email'] ?? '',
        order['billing_address']['phone'] ?? '',
        order['billing_address']['address'] ?? '',
        order['billing_address']['city'] ?? '',
        order['billing_address']['state'] ?? '',
        order['billing_address']['zipcode'] ?? '',
        order['bank']['name'] ?? '',
        order['bank']['account_number'] ?? '',
        order['bank']['ifsc_code'] ?? '',
        order['bank']['branch'] ?? '',
        item['name'] ?? '',
        item['quantity'] ?? '',
        item['price'] ?? '',
        item['tax'] ?? '',
        item['discount'] ?? '',
        order['status'] ?? '',
        order['total_amount'] ?? '',
        order['order_date'] ?? '',
      ]);
    }
  }

  // Save the Excel file
  final tempDir = await getTemporaryDirectory();
  final tempPath = "${tempDir.path}/order_list.xlsx";
  final tempFile = File(tempPath);
  await tempFile.writeAsBytes(await excel.encode()!);

  // Open the file
  await OpenFile.open(tempPath);
}


 Future<pw.Document> createPdf() async {
  final pdf = pw.Document();

  // Iterate through each order and add a new page for it
  for (var order in filteredOrders) {
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Title Section
                pw.Center(
                  child: pw.Text(
                    'Order Details',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 20),

                // Invoice and Manager
                pw.Text(
                  'Invoice: ${order['invoice']}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Text('Manager: ${order['manage_staff'] ?? ''}'),
                pw.SizedBox(height: 10),

                // Customer Details
                pw.Text(
                  'Customer Details',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Text('Name: ${order['customer']['name'] ?? ''}'),
                pw.Text('Phone: ${order['customer']['phone'] ?? ''}'),
                pw.Text('Email: ${order['customer']['email'] ?? ''}'),
                pw.Text('Address: ${order['customer']['address'] ?? ''}'),
                pw.SizedBox(height: 10),

                // Billing Address
                pw.Text(
                  'Billing Address',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Text('Name: ${order['billing_address']['name'] ?? ''}'),
                pw.Text('Email: ${order['billing_address']['email'] ?? ''}'),
                pw.Text('Phone: ${order['billing_address']['phone'] ?? ''}'),
                pw.Text('Address: ${order['billing_address']['address'] ?? ''}'),
                pw.Text('City: ${order['billing_address']['city'] ?? ''}'),
                pw.Text('State: ${order['billing_address']['state'] ?? ''}'),
                pw.Text('Zipcode: ${order['billing_address']['zipcode'] ?? ''}'),
                pw.SizedBox(height: 10),

                // Bank Details
                pw.Text(
                  'Bank Details',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Text('Name: ${order['bank']['name'] ?? ''}'),
                pw.Text('Account Number: ${order['bank']['account_number'] ?? ''}'),
                pw.Text('IFSC Code: ${order['bank']['ifsc_code'] ?? ''}'),
                pw.Text('Branch: ${order['bank']['branch'] ?? ''}'),
                pw.SizedBox(height: 10),

                // Items Table
                pw.Text(
                  'Items',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Table.fromTextArray(
                  headers: ['Name', 'Quantity', 'Price', 'Tax', 'Discount'],
                  data: [
                    for (var item in order['items'])
                      [
                        item['name'] ?? '',
                        item['quantity'].toString(),
                        item['price'].toString(),
                        item['tax'].toString(),
                        item['discount'].toString(),
                      ],
                  ],
                  headerStyle: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 10,
                  ),
                  cellStyle: pw.TextStyle(
                    fontSize: 8,
                  ),
                  headerDecoration: pw.BoxDecoration(
                    color: PdfColors.grey300,
                  ),
                  rowDecoration: pw.BoxDecoration(
                    border: pw.Border(
                      bottom: pw.BorderSide(color: PdfColors.grey400, width: 0.5),
                    ),
                  ),
                ),
                pw.SizedBox(height: 10),

                // Order Summary
                pw.Text(
                  'Order Summary',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Text('Status: ${order['status'] ?? ''}'),
                pw.Text('Total Amount: ${order['total_amount'].toString()}'),
                pw.Text('Order Date: ${order['order_date'] ?? ''}'),
              ],
            ),
          );
        },
      ),
    );
  }

  return pdf;
}

  Future<void> downloadPdf() async {
    final pdf = await createPdf();
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/order_list.pdf");
    await file.writeAsBytes(await pdf.save());
    await Printing.sharePdf(bytes: await pdf.save(), filename: 'order_list.pdf');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order List',
            style: TextStyle(fontSize: 14, color: Colors.grey)),
        centerTitle: true,
        actions: [
    PopupMenuButton<String>(
      icon: Icon(Icons.more_vert), // 3-dot icon
      onSelected: (value) {
        // Handle menu item selection
        switch (value) {
          case 'Option 1':
           exportToExcel();
            break;
          case 'Option 2':
           downloadPdf();
            break;
         
          default:
            // Handle default case
            break;
        }
      },
      itemBuilder: (BuildContext context) {
        return [
          PopupMenuItem<String>(
            value: 'Option 1',
            child: Text('Export Excel'),
          ),
          PopupMenuItem<String>(
            value: 'Option 2',
            child: Text('Download Pdf'),
          ),
          
        ];
      },
    ),
  ],
      ),

      
     drawer: Drawer( 
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 110, 110, 110),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      "lib/assets/logo-white.png",
                      width: 100, // Change width to desired size
                      height: 100, // Change height to desired size
                      fit: BoxFit
                          .contain, // Use BoxFit.contain to maintain aspect ratio
                    ),
                    SizedBox(
                      width: 70,
                    ),
                    Text(
                      'BepoSoft',
                      style: TextStyle(
                        color: Color.fromARGB(236, 255, 255, 255),
                        fontSize: 20,
                      ),
                    ),
                  ],
                )),
            ListTile(
              leading: Icon(Icons.dashboard),
              title: Text('Dashboard'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => dashboard()));
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Customer'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => customer_list()));
                // Navigate to the Settings page or perform any other action
              },
            ),
            Divider(),
            _buildDropdownTile(context, 'Credit Note', [
              'Add Credit Note',
              'Credit Note List',
            ]),
            _buildDropdownTile(
                context, 'Recipts', ['Add recipts', 'Recipts List']),
            _buildDropdownTile(context, 'Proforma Invoice', [
              'New Proforma Invoice',
              'Proforma Invoice List',
            ]),
            _buildDropdownTile(context, 'Delivery Note',
                ['Delivery Note List', 'Daily Goods Movement']),
            _buildDropdownTile(
                context, 'Orders', ['New Orders', 'Orders List']),
            Divider(),
            Text("Others"),
            Divider(),
            _buildDropdownTile(context, 'Product', [
              'Product List',
              'Stock',
            ]),
            _buildDropdownTile(
                context, 'Purchase', [' New Purchase', 'Purchase List']),
            _buildDropdownTile(context, 'Expence', [
              'Add Expence',
              'Expence List',
            ]),
            _buildDropdownTile(context, 'Reports', [
              'Sales Report',
              'Credit Sales Report',
              'COD Sales Report',
              'Statewise Sales Report',
              'Expence Report',
              'Delivery Report',
              'Product Sale Report',
              'Stock Report',
              'Damaged Stock'
            ]),
            _buildDropdownTile(context, 'GRV', ['Create New GRV', 'GRVs List']),
            _buildDropdownTile(context, 'Banking Module',
                ['Add Bank ', 'List', 'Other Transfer']),
            Divider(),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Methods'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Methods()));
              },
            ),
            ListTile(
              leading: Icon(Icons.chat),
              title: Text('Chat'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Logout'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                // Perform logout action
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide(color: Colors.blue, width: 2.0),
                ),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _filterOrders,
            ),
          ),
          // Date Filters
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
  width: 160,
  child: ElevatedButton(
    onPressed: () => _selectSingleDate(context),
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color.fromARGB(255, 2, 65, 96), // Set button color to grey
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8), // Set the border radius
      ),
    ),
    child: Text(
      'Select Date',
      style: TextStyle(color: Colors.white),
    ),
  ),
),

                SizedBox(width: 10),
              ElevatedButton(
  onPressed: () => _selectDateRange(context),
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color.fromARGB(255, 2, 65, 96), // Set button color to grey
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8), // Set the border radius
      ),
  ),
  child: Text(
    'Select Date Range',
    style: TextStyle(color: Colors.white), // Set text color to white
  ),
),

              ],
            ),
          ),
          // Display Orders
          Expanded(
            child: filteredOrders.isEmpty
                ? Center(
                    child: Text(
                      selectedDate != null ||
                              (startDate != null && endDate != null)
                          ? 'No orders available in this date range'
                          : 'No orders available',
                      style: TextStyle(fontSize: 16, color: const Color.fromARGB(255, 2, 65, 96)),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredOrders.length,
                    padding: const EdgeInsets.only(right: 10,left:10),
                    itemBuilder: (context, index) {
                      final order = filteredOrders[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3.0),
                        child: GestureDetector(
                          onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>OrderReview(id:order['id'])));
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            color: Colors.white,
                            elevation: 4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header section with Invoice and Order Date
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(15.0),
                                      topRight: Radius.circular(15.0),
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '#${order['invoice']}',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ), 
                                      Text(
                                        DateFormat('dd MMM yy').format(
                                            DateTime.parse(order['order_date'])),
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                                // Order details section
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Staff: ${order['manage_staff']}',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      SizedBox(height: 4.0),
                                      Text(
                                        'Customer: ${order['customer']['name']}',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      SizedBox(height: 8.0),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Billing Amount:',
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            '\$${order['total_amount']}',
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green),
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
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
