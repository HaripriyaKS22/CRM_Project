import 'dart:convert';
import 'package:beposoft/pages/api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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

  @override
  void initState() {
    super.initState();
    getcourierservices();
    fetchdgmData();
  }

  Future<String?> gettokenFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
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

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        if (parsed.containsKey('data')) {
          setState(() {
            courierdata = List<Map<String, dynamic>>.from(parsed['data'].map((service) => {
                  'id': service['id'],
                  'name': service['name'],
                }));
          });
        }
      }
    } catch (error) {
      debugPrint("Error fetching courier services: $error");
    }
  }

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

        if (data.containsKey('results')) {
          for (var family in data['results']) {
            String familyName = family['family'];
            resultsByFamily.putIfAbsent(familyName, () => []);
            parcelServiceCounts.putIfAbsent(familyName, () => {});

            for (var order in family['orders']) {
              Map<String, int> parcelServiceCountForOrder = {};
              for (var warehouse in order['warehouses']) {
                String parcelService = warehouse['parcel_service'];
                parcelServiceCountForOrder.update(parcelService, (val) => val + 1, ifAbsent: () => 1);
                resultsByFamily[familyName]!.add({
                  'invoice_no': warehouse['invoice'],
                  'phone': warehouse['phone'],
                  'customer': warehouse['customer'],
                  'zip_code': warehouse['zip_code'],
                  'boxes': order['warehouses'].length,
                  'aw_kg': warehouse['actual_weight'],
                  'tracking_id': warehouse['tracking_id'],
                  'parcel_service_counts': parcelServiceCountForOrder,
                });
              }
              parcelServiceCounts[familyName]![order['invoice']] = parcelServiceCountForOrder;
            }
          }
        }

        setState(() {
          tableDataByFamily = resultsByFamily;
          parcelServiceCountsByFamily = parcelServiceCounts;
        });
      }
    } catch (e) {
      debugPrint("Error fetching parcel data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Goods Movement (DGM)")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: tableDataByFamily.entries.map((entry) {
            String familyName = entry.key;
            List<dynamic> tableData = entry.value;

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
                      familyName,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: MaterialStateColor.resolveWith((states) => Colors.blueGrey.shade100),
                        columns: [
                          const DataColumn(label: Text("Sl No")),
                          const DataColumn(label: Text("Invoice No")),
                          const DataColumn(label: Text("Phone")),
                          const DataColumn(label: Text("Customer")),
                          const DataColumn(label: Text("Zip Code")),
                          const DataColumn(label: Text("Boxes")),
                          ...courierdata.map((courier) => DataColumn(label: Text(courier['name']))),
                          const DataColumn(label: Text("AW (KG)")),
                          const DataColumn(label: Text("Tracking Id")),
                        ],
                        rows: List<DataRow>.generate(tableData.length, (index) {
                          var row = tableData[index];
                          Map<String, int> parcelServiceCounts = row['parcel_service_counts'] ?? {};
                          return DataRow(cells: [
                            DataCell(Text((index + 1).toString())),
                            DataCell(Text(row["invoice_no"] ?? '-')),
                            DataCell(Text(row["phone"] ?? '-')),
                            DataCell(Text(row["customer"] ?? '-')),
                            DataCell(Text(row["zip_code"] ?? '-')),
                            DataCell(Text(row["boxes"]?.toString() ?? '-')),
                            ...courierdata.map((courier) {
                              int count = parcelServiceCounts.containsKey(courier['name']) ? 1 : 0;
                              return DataCell(Text(count.toString()));
                            }),
                            DataCell(Text(row["aw_kg"]?.toString() ?? '-')),
                            DataCell(Text(row["tracking_id"] ?? '-')),
                          ]);
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}