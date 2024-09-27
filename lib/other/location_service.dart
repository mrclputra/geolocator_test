import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:flutter_excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;

  // constructor
  LocationService._internal();

  final LatLng _defaultPosition = const LatLng(3.1575, 101.7116); // custom default user position

  LatLng? _currentPosition;

  String message = 'No Location Detected';
  bool hasLocationUpdated = false; // flag to track location update status

  get currentPosition => _currentPosition ?? _defaultPosition;

  // update current location
  Future<void> updateLocation() async {
    try {
      // check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        message = 'Location services are disabled';
        return;
      }

      //request permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          message = 'Location permissions are denied';
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        message = 'Location permissions are denied forever. Please configure in settings.';
        return;
      }

      // get current position
      Position position = await Geolocator.getCurrentPosition(
        // ignore: deprecated_member_use
        desiredAccuracy: LocationAccuracy.best,
      );
      _currentPosition = LatLng(position.latitude, position.longitude);
      message = 'Location Detected';
      hasLocationUpdated = true;
    } catch (e) {
      message = e.toString();
    }
  }

  Future<void> saveLocationData() async {
    final file = await _getExcelFile();
    var excel = Excel.createExcel();

    if (await file.exists()) {
      final bytes = await file.readAsBytes();
      excel = Excel.decodeBytes(bytes);
    }

    final sheet = excel['Sheet1'];
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

    final newRow = [
      formattedDate, // timestamp
      _currentPosition?.latitude ?? 'N/A', // latitude
      _currentPosition?.longitude ?? 'N/A' // longitude
    ];

    sheet.appendRow(newRow);
    await file.writeAsBytes(excel.save()!);
  }

  Future<File> _getExcelFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/location_data.xlsx';
    return File(path);
  }
}
