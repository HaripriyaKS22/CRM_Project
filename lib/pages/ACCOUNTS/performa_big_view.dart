import 'dart:convert';
import 'dart:io';

import 'package:beposoft/loginpage.dart';
import 'package:beposoft/pages/ACCOUNTS/add_attribute.dart';
import 'package:beposoft/pages/ACCOUNTS/add_bank.dart';
import 'package:beposoft/pages/ACCOUNTS/add_company.dart';
import 'package:beposoft/pages/ACCOUNTS/add_department.dart';
import 'package:beposoft/pages/ACCOUNTS/add_family.dart';
import 'package:beposoft/pages/ACCOUNTS/add_services.dart';
import 'package:beposoft/pages/ACCOUNTS/add_state.dart';
import 'package:beposoft/pages/ACCOUNTS/add_supervisor.dart';
import 'package:beposoft/pages/ACCOUNTS/customer.dart';
import 'package:beposoft/pages/ACCOUNTS/dashboard.dart';
import 'package:beposoft/pages/ACCOUNTS/dorwer.dart';
import 'package:beposoft/pages/ACCOUNTS/methods.dart';
import 'package:beposoft/pages/WAREHOUSE/warehouse_order_view.dart';
import 'package:beposoft/pages/api.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';

class PerformaInvoice_BigView_List extends StatefulWidget {
  final String invoice;
  const PerformaInvoice_BigView_List({super.key, required this.invoice});

  @override
  State<PerformaInvoice_BigView_List> createState() =>
      _PerformaInvoice_BigView_ListState();
}

class _PerformaInvoice_BigView_ListState
    extends State<PerformaInvoice_BigView_List> {
  drower d = drower();
  List<Map<String, dynamic>> orders = [];
    List<Map<String, dynamic>> stat = [];


  @override
  void initState() {
    super.initState();
    fetchperformalistData();
    getstate();

    print(widget.invoice);

  }
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

Future<pw.Document> createInvoice() async {
  final pdf = pw.Document();

  for (var order in orders) {
    final items = order['perfoma_items'] as List<dynamic>;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header section
                pw.Container(
                  color: PdfColors.blue800,
                  padding: const pw.EdgeInsets.all(16),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('INVOICE',
                              style: pw.TextStyle(
                                  color: PdfColors.white,
                                  fontSize: 30,
                                  fontWeight: pw.FontWeight.bold)),
                          pw.Text('Bepositive Racing Pvt Ltd',
                              style: pw.TextStyle(
                                  color: PdfColors.white, fontSize: 12)),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text('Invoice No: #${order['invoice'].toString()}',
                              style: pw.TextStyle(
                                  color: PdfColors.white, fontSize: 12)),
                          pw.Text('Date: ${order['order_date'].toString()}',
                              style: pw.TextStyle(
                                  color: PdfColors.white, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                // Customer Information
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Invoice To:',
                            style: pw.TextStyle(
                                fontSize: 16, fontWeight: pw.FontWeight.bold)),
                        pw.Text(order['customer_name'].toString()),
                        pw.Text(order['address'].toString()),
                        pw.Text(order['state'].toString()),
                      ],
                    ),
                    pw.SizedBox(width: 20),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Payment Details:',
                            style: pw.TextStyle(
                                fontSize: 16, fontWeight: pw.FontWeight.bold)),
                        pw.Text('Bank Code: ${order['bank'].toString()}'),
                        pw.Text('Payment Method: ${order['payment_method'].toString()}'),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),

                // Items Table
                pw.Container(
                  color: PdfColors.grey300,
                  padding: const pw.EdgeInsets.symmetric(vertical: 5),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(
                          child: pw.Text('Description',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold))),
                      pw.Text('Qty',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('Cost',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('Subtotal',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                ),
                pw.Divider(thickness: 1),

                // Loop to Display Items
                for (var item in items)
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(child: pw.Text(item['name'].toString())),
                      pw.Text(item['quantity'].toString()),
                      pw.Text('\$${item['actual_price'].toString()}'),
                      pw.Text(
                          '\$${(item['quantity'] * item['actual_price']).toStringAsFixed(2)}'),
                    ],
                  ),
                pw.Divider(thickness: 1),

                // Total Amount Section
                pw.SizedBox(height: 20),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Row(
                          children: [
                            pw.Text('Subtotal: ',
                                style: pw.TextStyle(
                                    fontSize: 12,
                                    fontWeight: pw.FontWeight.bold)),
                            pw.Text('\$${order['total_amount'].toString()}'),
                          ],
                        ),
                        pw.Row(
                          children: [
                            pw.Text('Tax: ',
                                style: pw.TextStyle(
                                    fontSize: 12,
                                    fontWeight: pw.FontWeight.bold)),
                            pw.Text('\$250.00'), // Example Tax value
                          ],
                        ),
                        pw.Row(
                          children: [
                            pw.Text('Total: ',
                                style: pw.TextStyle(
                                    fontSize: 14,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.blue800)),
                            pw.Text(
                                '\$${(order['total_amount'] + 250).toStringAsFixed(2)}',
                                style: pw.TextStyle(
                                    fontSize: 14,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.blue800)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),

                // Footer
                pw.Text('Thank You!',
                    style: pw.TextStyle(
                        fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.Text(
                    'Please contact us if you have any questions about this invoice.',
                    style: pw.TextStyle(fontSize: 12)),
                pw.SizedBox(height: 10),
                pw.Text('Contact Us:',
                    style: pw.TextStyle(
                        fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.Row(
                  children: [
                    pw.Text('+123-456-7890  |  '),
                    pw.Text('contact@bepositive.com  |  '),
                    pw.Text('123 Main St, Kochi, Kerala, India'),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  return pdf;
}
void logout() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('userId');
  await prefs.remove('token');

  // Use a post-frame callback to show the SnackBar after the current frame
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (ScaffoldMessenger.of(context).mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logged out successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  });

  // Wait for the SnackBar to disappear before navigating
  await Future.delayed(Duration(seconds: 2));

  // Navigate to the HomePage after the snackbar is shown
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => login()),
  );
}


// Function to save and download the PDF
  Future<void> downloadInvoice() async {
    final pdf = await createInvoice();

    // Save PDF to temporary directory
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/invoice.pdf");
    await file.writeAsBytes(await pdf.save());

    // Share or download PDF
    await Printing.sharePdf(bytes: await pdf.save(), filename: 'invoice.pdf');
  }

  Future<String?> getTokenFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> getstate() async {
  try {
    final token = await getTokenFromPrefs();
    var response = await http.get(
      Uri.parse('$api/api/states/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final parsed = jsonDecode(response.body);
      var productsData = parsed['data'];

      List<Map<String, dynamic>> statelist = productsData
          .map<Map<String, dynamic>>((productData) => {
                'id': productData['id'],
                'name': productData['name'],
              })
          .toList();

      setState(() {
        stat = statelist;
      });
    }
  } catch (error) {
    print("Error: $error");
  }
}
String getStateNameById(int stateId) {
  final state = stat.firstWhere(
    (element) => element['id'] == stateId,
    orElse: () => {'name': 'Unknown'}, // Return a Map with a default 'name'
  );
  return state['name'];
}


// Fetch performa list data and map state ID to state name
Future<void> fetchperformalistData() async {
  try {
    final token = await getTokenFromPrefs();
    final response = await http.get(
      Uri.parse('$api/api/perfoma/${widget.invoice}/invoice/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final parsed = jsonDecode(response.body);

      List<Map<String, dynamic>> performaInvoiceList = [];

      List<Map<String, dynamic>> perfomaItemsWithImages =
          (parsed['perfoma_items'] as List<dynamic>).map((item) {
        return {
          'id': item['id'],
          'name': item['name'],
          'quantity': item['quantity'],
          'actual_price': item['actual_price'],
          'first_image': item['images'] != null && item['images'].isNotEmpty
              ? '$api/${item['images'][0]}'
              : null,
        };
      }).toList();

      // Get state name from ID
      final stateName = getStateNameById(parsed['state']);

      performaInvoiceList.add({
        'id': parsed['id'],
        'invoice': parsed['invoice'],
        'manage_staff': parsed['manage_staff'],
        'company': parsed['company'],
        'customer_name': parsed['customer']['name'],
        'family': parsed['family'],
        'state': stateName, // Use state name instead of ID
        'address': parsed['billing_address']['address'],
        'payment_status': parsed['payment_status'],
        'bank': parsed['bank']['name'],
        'payment_method': parsed['payment_method'],
        'status': parsed['status'],
        'total_amount': parsed['total_amount'],
        'order_date': parsed['order_date'],
        'created_at': parsed['customer']['created_at'],
        'perfoma_items': perfomaItemsWithImages,
      });

      setState(() {
        orders = performaInvoiceList;
      });
    } else {
      print("Error fetching data: ${response.statusCode}");
    }
  } catch (error) {
    print("Error: $error");
  }
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text(
        'Performa Invoice List',
        style: TextStyle(fontSize: 14, color: Colors.grey),
      ),
      centerTitle: true,
    ),
         drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "lib/assets/logo.png",
                        width: 150, // Change width to desired size
                        height: 150, // Change height to desired size
                        fit: BoxFit
                            .contain, // Use BoxFit.contain to maintain aspect ratio
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
                title: Text('Company'),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => add_company()));
                  // Navigate to the Settings page or perform any other action
                },
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Departments'),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => add_department()));
                  // Navigate to the Settings page or perform any other action
                },
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Supervisors'),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => add_supervisor()));
                  // Navigate to the Settings page or perform any other action
                },
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Family'),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => add_family()));
                  // Navigate to the Settings page or perform any other action
                },
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Bank'),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => add_bank()));
                  // Navigate to the Settings page or perform any other action
                },
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text('States'),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => add_state()));
                  // Navigate to the Settings page or perform any other action
                },
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Attributes'),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => add_attribute()));
                  // Navigate to the Settings page or perform any other action
                },
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Services'),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CourierServices()));
                  // Navigate to the Settings page or perform any other action
                },
              ),
               ListTile(
                leading: Icon(Icons.person),
                title: Text('Delivery Notes'),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => WarehouseOrderView(status: null,)));
                  // Navigate to the Settings page or perform any other action
                },
              ),
              Divider(),
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
              _buildDropdownTile(context, 'Customers', [
                'Add Customer',
                'Customers',
              ]),
              _buildDropdownTile(context, 'Staff', [
                'Add Staff',
                'Staff',
              ]),
              _buildDropdownTile(context, 'Credit Note', [
                'Add Credit Note',
                'Credit Note List',
              ]),
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
                'Product Add',
                'Stock',
              ]),
              _buildDropdownTile(context, 'Expence', [
                'Add Expence',
                'Expence List',
              ]),
              _buildDropdownTile(
                  context, 'GRV', ['Create New GRV', 'GRVs List']),
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
                  logout();
                },
              ),
            ],
          ),
        ),
    body: Column(
      children: [
        Expanded(
          child: orders.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: orders.length,
                  padding: const EdgeInsets.all(16.0),
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    final items = order['perfoma_items'] as List<dynamic>;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        elevation: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Invoice header
                            Container(
                              padding: const EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(15.0)),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Invoice No: #${order['invoice']}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Date: ${order['order_date']}',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                            // Invoice details
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Customer Name: ${order['customer_name']}',
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    'Company: ${order['company']}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    'Managed By: ${order['manage_staff']}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    'Family: ${order['family']}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    'State: ${order['state']}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    'Billing Address: ${order['address']}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    'Payment Status: ${order['payment_status']}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    'Bank: ${order['bank']}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    'Payment Method: ${order['payment_method']}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    'Order Status: ${order['status']}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                
                                  const SizedBox(height: 10),
                                  Text(
                                    'Items:',
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  // List of Items in the Invoice
                                  for (var item in items)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4.0),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Display the first image of each item
                                          if (item['first_image'] != null)
                                            Flexible(
                                              flex: 1,
                                              child:  Image.network(
                                                    "${item['first_image']}",
                                                    width: 80,
                                                    height: 80,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context,
                                                        error, stackTrace) {
                                                      return Icon(Icons
                                                          .image_not_supported); // Fallback image or icon
                                                    },
                                                  ),
                                            ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            flex: 2,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Item Name: ${item['name']}',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                                Text(
                                                  'Quantity: ${item['quantity']}',
                                                  style:
                                                      const TextStyle(fontSize: 14),
                                                ),
                                                Text(
                                                  'Unit Price: \$${item['actual_price']}',
                                                  style:
                                                      const TextStyle(fontSize: 14),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                      Text(
                                    'Total Amount: \$${order['total_amount']}',
                                    style: const TextStyle(
                                      fontSize: 16,
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
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: downloadInvoice,
            child: const Text('Download Invoice'),
          ),
        ),
      ],
    ),
  );
}



}
