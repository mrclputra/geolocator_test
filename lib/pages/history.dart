// ignore_for_file: use_build_context_synchronously

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
  List<List<dynamic>> _locationData = []; // 2d data list

  @override
  void initState() {
    super.initState();
    _loadExcelFile();
  }

  Future<File> _getExcelFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/location_data.xlsx';
    return File(path);
  }

  Future<void> _loadExcelFile() async {
    final file = await _getExcelFile();
    if (await file.exists()) {
      final excel = Excel.decodeBytes(file.readAsBytesSync());
      Sheet sheetObject = excel['Sheet1'];

      List<List<dynamic>> data = [];
      for (var row in sheetObject.rows.reversed) {
        data.add(row.map((cell) => cell?.value ?? '').toList());
      }

      setState(() {
        _locationData = data;
      });
    }
  }

  Future<void> _clearExcelFile() async {
    setState(() {
      _locationData.clear();
    });

    final file = await _getExcelFile();
    if (await file.exists()) {
      var excel = Excel.createExcel();
      await file.writeAsBytes(excel.save()!);
    }
  }

  Future<void> _downloadExcelFile() async {
    final file = await _getExcelFile();

    if (!await file.exists()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File does not exist.')),
      );
      return;
    }

    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Download Excel'),
        content: const Text('Do you want to download the Excel file?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Download'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preparing to download...')),
      );

      final downloadDirectory = Directory('/storage/emulated/0/Download'); // Adjust as necessary
      if (await downloadDirectory.exists()) {
        String newFilePath = '${downloadDirectory.path}/location_data.xlsx';
        int counter = 1;

        // Check for duplicate files and rename if necessary
        while (await File(newFilePath).exists()) {
          newFilePath = '${downloadDirectory.path}/location_data($counter).xlsx';
          counter++;
        }

        try {
          await file.copy(newFilePath);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('File downloaded to Downloads folder.')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error downloading file: $e')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Download directory not found.')),
        );
      }
    }
  }

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
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.download_rounded),
                  onPressed: () {
                    _downloadExcelFile();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    _clearExcelFile();
                  },
                ),
              ],
            ),
          ),
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
                          'No Data',
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
