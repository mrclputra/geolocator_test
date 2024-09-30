import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:flutter_excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'dart:ui' as ui;
import 'package:flutter/services.dart';

/**
 * This class is persistent and runs in the background
 * Contains all background processes
 * Implement persistent variables here
 */

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;

  // constructor
  LocationService._internal() {
    // on program start
    _loadCustomMarkerIcon();
    _loadMarkersFromFile();
  }

  final LatLng _defaultPosition = const LatLng(3.1575, 101.7116); // custom default user position
  get currentPosition => _currentPosition ?? _defaultPosition;

  LatLng? _currentPosition;
  BitmapDescriptor? _customWaypointMarker;
  BitmapDescriptor? get customWaypointMarker => _customWaypointMarker;

  String message = 'No Location Detected';
  bool hasLocationUpdated = false; // flag to track location update status
  List<Marker> markers = [];

  // convert img asset to raw data
  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path); // load image from assets
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width); // resize image
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  // load custom marker icon
  Future<void> _loadCustomMarkerIcon() async {
    final Uint8List markerIcon = await getBytesFromAsset('lib/assets/waypoint.png', 56); // set custom waypoint icon size here
    // ignore: deprecated_member_use
    _customWaypointMarker = BitmapDescriptor.fromBytes(markerIcon);
  }

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

  // save location history to excel
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

  // get directory of excel file
  Future<File> _getExcelFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/location_data.xlsx';
    return File(path);
  }

  // save markers to persistent file
  Future<void> _saveMarkersToFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/markers.txt'); // probably encrypt this in the future

    List<String> markerList = markers.map((marker) {
      return jsonEncode({
        'id': marker.markerId.value,
        'lat': marker.position.latitude,
        'long': marker.position.longitude,
      });
    }).toList();

    await file.writeAsString(markerList.join('\n'));
  }

  // load markers form persistent file
  Future<void> _loadMarkersFromFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/markers.txt');

    if (await file.exists()) {
      List<String> markerList = await file.readAsLines();
      markers.clear(); // Clear existing markers

      // Load markers from file
      for (String markerString in markerList) {
        Map<String, dynamic> markerData = jsonDecode(markerString);
        markers.add(
          Marker(
            markerId: MarkerId(markerData['id']),
            position: LatLng(markerData['lat'], markerData['long']),
            infoWindow: const InfoWindow(title: 'Custom Marker'),
          ),
        );
      }
    }
  }

  // add a map marker
  void addMarker(LatLng position) async {
    final icon = _customWaypointMarker ?? BitmapDescriptor.defaultMarker;
    markers.add(
      Marker(
        markerId: MarkerId('${markers.length + 1}'),
        position: position,
        infoWindow: InfoWindow(title: 'Marker ${markers.length + 1}'),
        icon: icon,
      ),
    );

    _saveMarkersToFile();
  }

  // delete map marker
  void deleteMarker(Marker marker) {
    markers.remove(marker);
  }
}
