import 'package:call_log/call_log.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';

class Index extends StatefulWidget {
  const Index({Key? key}) : super(key: key);

  @override
  State<Index> createState() => _IndexState();
}

void generateCSV() async {
  try {
    final Iterable<CallLogEntry> cLog = await CallLog.get();
    List<List<dynamic>> csvData = [
      [
        'Formatted Number',
        'Cached Matched Number',
        'Number',
        'Name',
        'Call Type',
        'Duration',
        'Account ID',
        'SIM Name'
      ]
    ];

    Set<String> uniqueNumbers = Set<String>();

    for (CallLogEntry entry in cLog) {
      if (entry.callType == CallType.missed && !uniqueNumbers.contains(entry.number)) {
        uniqueNumbers.add(entry.number.toString());
        List<dynamic> row = [
          entry.formattedNumber,
          entry.cachedMatchedNumber,
          entry.number,
          entry.name,
          entry.callType.toString(),
          entry.duration,
          entry.phoneAccountId,
          entry.simDisplayName
        ];
        csvData.add(row);
      }
    }

    String csv = const ListToCsvConverter().convert(csvData);

    final String dir = (await getExternalStorageDirectory())!.path;
    final String path = '$dir/call_log.csv';
    final File file = File(path);

    await file.writeAsString(csv);
    print('CSV file generated at $path');
  } on PlatformException catch (e, s) {
    print(e);
    print(s);
  }
}

class _IndexState extends State<Index> {
  @override
  void initState() {
    generateCSV();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final String dir = (await getExternalStorageDirectory())!.path;
            final String path = '$dir/call_log.csv';
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('CSV file downloaded at $path'),
            ));
            _openFile(path);
          },
          child: Text('Download CSV'),
        ),
      ),
    );
  }

  Future<void> _openFile(String filePath) async {
    try {
      final result = await OpenFile.open(filePath);
      print('Open file: $result');
    } catch (e) {
      print('Error opening file: $e');
    }
  }
}

void main() {
  runApp(MaterialApp(
    home: Index(),
  ));
}
