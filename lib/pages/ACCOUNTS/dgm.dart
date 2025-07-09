import 'dart:convert';
import 'package:beposoft/pages/api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class Dgm extends StatefulWidget {
  final String shipped_date;
  const Dgm({super.key, required this.shipped_date});

  @override
  State<Dgm> createState() => _DgmState();
}

class _DgmState extends State<Dgm> {
  List<Map<String, dynamic>> courierdata = [];
  Map<String, List<dynamic>> tableDataByFamily = {};
  Map<String, Map<String, Map<String, int>>> parcelServiceCountsByFamily = {};
  Map<String, int> totalOrdersByFamily = {}; // New map to store total orders by family
  Map<String, int> totalBoxesByFamily = {}; // New map to store total boxes by family
int totalRowsCount = 0;

  @override
  void initState() {
    super.initState();
    fetchdgmData();
    getcourierservices();
  }

  Future<String?> gettokenFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
Set<String> selectedRowKeys = {}; // to store selected rows by unique key

  Future<void> updatecheckedby() async {
    try {
      ;
      final token = await gettokenFromPrefs();
      final jwt = JWT.decode(token!);
      var id = jwt.payload['id']; // Expected to be an int
      var response = await http.put(
        Uri.parse('$api/warehouse/update-checked-by/${widget.shipped_date}/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
          {
            'checked_by': id,
          },
        ),
      );
      ;
      ;
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Shipping charge updated successfully'),
            duration: Duration(seconds: 2),
          ),
        );
            fetchdgmData();

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update shipping charge'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (error) {
      ;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating shipping charge'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> getcourierservices() async {
    try {
      final token = await gettokenFromPrefs();
      var response = await http.get(
        Uri.parse('$api/api/parcal/service/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      ;
      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        if (parsed.containsKey('data')) {
          setState(() {
            courierdata = List<Map<String, dynamic>>.from(parsed['data'].map((service) => {
                  'id': service['id'],
                  'name': service['name'],
                }));
          });

          ;
        }
      }
    } catch (error) {
    }
  }

  var checked;
  Future<void> fetchdgmData() async {
    try {
      final token = await gettokenFromPrefs();
      final response = await http.get(
        Uri.parse('$api/api/warehousesdataget/${widget.shipped_date}/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
   
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        Map<String, List<dynamic>> resultsByFamily = {};
        Map<String, Map<String, Map<String, int>>> parcelServiceCounts = {};
        Map<String, int> totalOrdersByFamily = {};
        Map<String, int> totalBoxesByFamily = {};

        
        for (var family in data['results']) {
          for (var order in family['orders']) {
            for (var warehouse in order['warehouses']) {
              checked = warehouse['checked_by'];
              break; // Assuming you only need the first checked_by value
            }
            if (checked != null) break;
          }
          if (checked != null) break;
        }
        if (data.containsKey('results')) {
          for (var family in data['results']) {
            String familyName = family['family'];
            resultsByFamily.putIfAbsent(familyName, () => []);
            parcelServiceCounts.putIfAbsent(familyName, () => {});
            totalOrdersByFamily.putIfAbsent(familyName, () => 0);
            totalBoxesByFamily.putIfAbsent(familyName, () => 0);

            for (var order in family['orders']) {
              totalOrdersByFamily[familyName] = totalOrdersByFamily[familyName]! + 1;
              int orderBoxesCount = order['warehouses'].length;
              totalBoxesByFamily[familyName] = totalBoxesByFamily[familyName]! + orderBoxesCount;

              for (var warehouse in order['warehouses']) {
                ;

                // Initialize parcel service counts for the order
                Map<String, int> parcelServiceCountForOrder = {};

                String parcelService = warehouse['parcel_service'] ?? '';
                if (parcelService.isNotEmpty) {
                  // Set 1 for the corresponding parcel service, 0 for others
                  for (var courier in courierdata) {
                    String courierName = courier['name'];
                    parcelServiceCountForOrder[courierName] = (courierName == parcelService) ? 1 : 0;
                  }
                }

 double height = double.tryParse(warehouse['height']?.toString() ?? '0') ?? 0;
  double length = double.tryParse(warehouse['length']?.toString() ?? '0') ?? 0;
  double breadth = double.tryParse(warehouse['breadth']?.toString() ?? '0') ?? 0;
  double volume = height * length * breadth;
               resultsByFamily[familyName]!.add({
  'invoice_no': warehouse['invoice'] ?? '-',
  'verified_by': warehouse['verified_by'] ?? '-',
  'cod': warehouse['cod_amount']?.toString() ?? '-',
  'phone': warehouse['phone'] ?? '-',
  'customer': warehouse['customer'] ?? '-',
  'zip_code': warehouse['zip_code'] ?? '-',
  'height': warehouse['height']?.toString() ?? '-',
  'length': warehouse['length']?.toString() ?? '-',
  'breadth': warehouse['breadth']?.toString() ?? '-',
  'boxes': orderBoxesCount.toString(),
  'aw_kg': warehouse['actual_weight']?.toString() ?? '-',
  'tracking_id': warehouse['tracking_id'] ?? '-',
  'parcel_service_counts': parcelServiceCountForOrder,
  'volume': volume,
});

parcelServiceCounts[familyName]![order['invoice']?.toString() ?? ''] = parcelServiceCountForOrder;              }
            }
          }
        }
        

int rowCount = 0;
for (var family in resultsByFamily.values) {
  rowCount += family.length;
}

        setState(() {
          tableDataByFamily = resultsByFamily;
          parcelServiceCountsByFamily = parcelServiceCounts;
          this.totalOrdersByFamily = totalOrdersByFamily;
          this.totalBoxesByFamily = totalBoxesByFamily;
         totalRowsCount = rowCount;
        });
      }
    } catch (e) {
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate total boxes by service across all families
    Map<String, int> totalBoxesByServiceAcrossAllFamilies = {};
    tableDataByFamily.forEach((familyName, tableData) {
      for (var row in tableData) {
        Map<String, int> parcelServiceCounts = row['parcel_service_counts'] ?? {};
        for (var service in parcelServiceCounts.keys) {
          totalBoxesByServiceAcrossAllFamilies[service] = (totalBoxesByServiceAcrossAllFamilies[service] ?? 0) + parcelServiceCounts[service]!;
        }
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text("Goods Movement (DGM)", style: TextStyle(fontSize: 12))),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            checked != null
    ? RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: "Final Confirmation by: ",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            TextSpan(
              text: "$checked",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
      )
    : selectedRowKeys.length == totalRowsCount && totalRowsCount > 0
        ? ElevatedButton(
            onPressed: () {
              updatecheckedby();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
            child: Text("CHECK HERE", style: TextStyle(color: Colors.white)),
          )
        : Container(), // Empty if not all selected

            SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: tableDataByFamily.entries.map((entry) {
                  String familyName = entry.key;
                  List<dynamic> tableData = entry.value;
                  int totalOrders = totalOrdersByFamily[familyName] ?? 0; // Get total orders for the family
                  int totalBoxes = totalBoxesByFamily[familyName] ?? 0; // Get total boxes for the family

                  // Calculate total boxes and total aw_kg for each parcel service
                  Map<String, int> totalBoxesByService = {};
                  double totalAwKg = 0.0;
                  for (var row in tableData) {
                    Map<String, int> parcelServiceCounts = row['parcel_service_counts'] ?? {};
                    for (var service in parcelServiceCounts.keys) {
                      totalBoxesByService[service] = (totalBoxesByService[service] ?? 0) + parcelServiceCounts[service]!;
                    }
                    totalAwKg += double.tryParse(row['aw_kg'].toString()) ?? 0.0;
                  }

                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "$familyName (Total Orders: $totalOrders, Total Boxes: $totalBoxes)", // Display family name with total orders and total boxes
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingRowColor: MaterialStateColor.resolveWith((states) => const Color.fromARGB(255, 1, 133, 190)),
                              columns: [
                                const DataColumn(label: Text("Sl No", style: TextStyle(color: Colors.white))),
                                const DataColumn(label: Text("Invoice No", style: TextStyle(color: Colors.white))),
                                const DataColumn(label: Text("Phone", style: TextStyle(color: Colors.white))),
                                const DataColumn(label: Text("Customer", style: TextStyle(color: Colors.white))),
                                const DataColumn(label: Text("Verified by", style: TextStyle(color: Colors.white))),
                                const DataColumn(label: Text("COD", style: TextStyle(color: Colors.white))),

                                const DataColumn(label: Text("Boxes", style: TextStyle(color: Colors.white))),
                                ...courierdata.map((courier) {
                                  return DataColumn(
                                    label: Text(courier['name'], style: TextStyle(color: Colors.white)),
                                  );
                                }),
                                const DataColumn(label: Text("AW (KG)", style: TextStyle(color: Colors.white))),
                                const DataColumn(label: Text("Volume", style: TextStyle(color: Colors.white))),
                                const DataColumn(label: Text("Tracking Id", style: TextStyle(color: Colors.white))),
                              ],
                              rows: [
                                ...List<DataRow>.generate(tableData.length, (index) {
  var row = tableData[index];
  String rowKey = row["invoice_no"] ?? index.toString(); // Use invoice_no as unique key
  Map<String, int> parcelServiceCounts = row['parcel_service_counts'] ?? {};
  bool isSelected = selectedRowKeys.contains(rowKey);

  return DataRow(
    selected: isSelected,
    color: MaterialStateColor.resolveWith((states) {
      return isSelected ? const Color.fromARGB(255, 218, 248, 255) : Colors.transparent;
    }),
    onSelectChanged: (selected) {
      setState(() {
        if (selected == true) {
          selectedRowKeys.add(rowKey);
        } else {
          selectedRowKeys.remove(rowKey);
        }
      });
    },
    cells: [
      DataCell(Text((index + 1).toString())),
      DataCell(Text(row["invoice_no"] ?? '-')),
      DataCell(Text(row["phone"] ?? '-')),
      DataCell(Text(row["customer"] ?? '-')),
      DataCell(Text(row["verified_by"] ?? '-')),
      DataCell(Text(row["cod"] ?? '-')),
      DataCell(Text(row["boxes"]?.toString() ?? '-')),
      ...courierdata.map((courier) {
        String serviceName = courier['name'];
        int count = parcelServiceCounts[serviceName] ?? 0;
        return DataCell(Text(count.toString()));
      }).toList(),
      DataCell(Text(row["aw_kg"]?.toString() ?? '-')),
       DataCell(Text(
  (row["volume"] != null)
      ? (row["volume"] is int
          ? (row["volume"] as int).toDouble().toStringAsFixed(2)
          : (row["volume"] is double
              ? (row["volume"] as double).toStringAsFixed(2)
              : row["volume"].toString()))
      : '-'
)), // Display volume
      DataCell(Text(row["tracking_id"] ?? '-')),
    ],
  );
}),

                                // Add a new row for total boxes by service
                                DataRow(
                                  color: MaterialStateColor.resolveWith((states) => const Color.fromARGB(255, 120, 199, 234)!), // Background color for the total row
                                  cells: [
                                    DataCell(Text('')), // Empty cell for Sl No
                                    DataCell(Text('')), // Empty cell for Invoice No
                                    DataCell(Text('')), // Empty cell for Phone
                                    DataCell(Text('')), // Empty cell for Customer
                                    DataCell(Text('')), // Empty cell for Zip Code
                                     DataCell(Text('')),
                                    DataCell(Text('Total Boxes')), // Label for total boxes
                                    ...courierdata.map((courier) {
                                      String serviceName = courier['name'];
                                      int totalBoxes = totalBoxesByService[serviceName] ?? 0;
                                      return DataCell(Text(totalBoxes.toString()));
                                    }).toList(),
                                    DataCell(Text(totalAwKg.toStringAsFixed(2))), // Total AW (KG)
                                    DataCell(Text('')), // Empty cell for Tracking ID
                                     DataCell(Text('')),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            // SizedBox(height: 20),
            // Text(
            //   "Summary",
            //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
            // ),
            // SingleChildScrollView(
            //   scrollDirection: Axis.horizontal,
            //   child: DataTable(
            //     headingRowColor: MaterialStateColor.resolveWith((states) => const Color.fromARGB(255, 1, 133, 190)),
            //     columns: [
            //       const DataColumn(label: Text("Parcel Service", style: TextStyle(color: Colors.white))),
            //       const DataColumn(label: Text("Total Boxes", style: TextStyle(color: Colors.white))),
            //     ],
            //     rows: [
            //       ...courierdata.map((courier) {
            //         String serviceName = courier['name'];
            //         int totalBoxes = totalBoxesByServiceAcrossAllFamilies[serviceName] ?? 0;
            //         return DataRow(cells: [
            //           DataCell(Text(serviceName)),
            //           DataCell(Text(totalBoxes.toString())),
            //         ]);
            //       }).toList(),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}