import 'package:flutter/material.dart';

import 'package:flutter_excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<List<dynamic>> _locationData = [];

  @override
  void initState() {
    super.initState();
    _loadLocationData();
  }

  // load location history from excel file
  Future<void> _loadLocationData() async {
    final file = await _getExcelFile();
    final excel = Excel.decodeBytes(file.readAsBytesSync());
    Sheet sheetObject = excel['Sheet1'];

    List<List<dynamic>> data = [];
    for (var row in sheetObject.rows.reversed) { // times are read bottom up
      data.add(row.map((cell) => cell?.value ?? '').toList());
    }

    setState(() {
      _locationData = data; // store loaded data
    });
  }

  // get excel file object
  Future<File> _getExcelFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/location_data.xlsx';
    return File(path);
  }

  // clear location data and excel file
  Future<void> _clearLocationData() async {
    // clear list in memory
    setState(() {
      _locationData.clear();
    });

    // clear excel file
    final file = await _getExcelFile();
    if (await file.exists()) {
      // create new excel file
      var excel = Excel.createExcel();
      // Sheet sheetObject = excel['Sheet1'];
      await file.writeAsBytes(excel.save()!);
    }
  }

  // User Interface here
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(left: 10),
          child: Text('Report History'),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                // implement delete here
                _clearLocationData();
              },
            ),
          )
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return ListView(
                children: <Widget>[
                  _locationData.isEmpty
                      ? const Text(
                          'No Data', // Display when there are no records
                          style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                        )
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minWidth: constraints.maxWidth),
                            child: DataTable(
                              columns: const [
                                DataColumn(
                                  label: Expanded(
                                    child: Text(
                                      'Timestamp',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Expanded(
                                    child: Text(
                                      'Latitude',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Expanded(
                                    child: Text(
                                      'Longitude',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                              rows: _locationData
                                  .map((row) => DataRow(
                                        cells: row.map((cell) => DataCell(Text(cell.toString()))).toList(),
                                      ))
                                  .toList(),
                            ),
                          ),
                        ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
