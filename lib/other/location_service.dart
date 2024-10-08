import 'dart:convert';

import 'package:flutter/material.dart';
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
    // on program start, place init functions here
    _loadCustomMarkerIcon();
  }

  // initialize function to be called after creating the instance
  Future<void> initialize() async {
    await loadMarkersFromFile();
    // do other async tasks here like updating the location
  }

  final LatLng _defaultPosition = const LatLng(3.1575, 101.7116); // custom default user position
  get currentPosition => _currentPosition ?? _defaultPosition;

  LatLng? _currentPosition;
  String message = 'No Location Detected';
  bool hasLocationUpdated = false; // flag to track location update status

  BitmapDescriptor? _customWaypointMarker;
  BitmapDescriptor? get customWaypointMarker => _customWaypointMarker;

  Map<PolylineId, Polyline> polyLines = {};
  List<Marker> markers = [];

  // add polyline
  void updatePolylines() {
    const PolylineId polylineId = PolylineId('polyline_id');

    // create a list of points from  markers' positions
    List<LatLng> points = markers.map((marker) => marker.position).toList();

    // create a polyline said points
    final Polyline polyline = Polyline(
      polylineId: polylineId,
      // color: const ui.Color.fromARGB(255, 14, 97, 165), // set polyline color here
      color: Colors.red,
      points: points,
      width: 6,
    );

    // update the polyLines map
    polyLines[polylineId] = polyline;
  }

  // convert img asset to raw data
  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path); // load image from assets
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width); // resize image
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  // load custom marker icon
  Future<void> _loadCustomMarkerIcon() async {
    final Uint8List markerIcon = await getBytesFromAsset('lib/assets/waypoint.png', 54); // set custom waypoint icon size here
    // ignore: deprecated_member_use
    _customWaypointMarker = BitmapDescriptor.fromBytes(markerIcon);
  }

  // update current map location
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

  // save location history to device '/downloads'
  Future<void> downloadLocationDataToDevice() async {
    final file = await _getLocationDataLocalPath();
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

  // get directory of local location data excel file
  Future<File> _getLocationDataLocalPath() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/location_data.xlsx';
    return File(path);
  }

  // Future<void> uploadLocationDataToFirebase() async {
  //   try {
  //     final file = await _getLocationDataLocalPath();

  //     if(!await file.exists()) {
  //       print('File does not exist');
  //       return;
  //     }

  //     // upload to firebase storage
  //     final storageRef = FirebaseStorage.instance.ref().child('location_data/location_data.xlsx');
  //     await storageRef.putFile(file);
  //   } catch(e) {
  //     print('Failed to upload file: $e');
  //   }
  // }

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
  Future<void> loadMarkersFromFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/markers.txt');

    if (await file.exists()) {
      List<String> markerList = await file.readAsLines();
      markers.clear(); // precautionary

      // Load markers from file
      for (String markerString in markerList) {
        Map<String, dynamic> markerData = jsonDecode(markerString);
        String markerName = markerData['id'];
        LatLng position = LatLng(markerData['lat'], markerData['long']);

        addMarker(position, markerName);
      }
    }
  }

  // add a map marker
  void addMarker(LatLng position, String name) async {
    // check for duplicate marker names and modify the name if needed
    String newName = name;
    int count = 1; // define filename postfix
    while (markers.any((marker) => marker.markerId.value == newName)) {
      newName = '$name' '_' '$count';
      count++;
    }

    final icon = _customWaypointMarker!;
    markers.add(
      Marker(
        markerId: MarkerId(newName),
        position: position,
        infoWindow: InfoWindow(
          title: newName,
          snippet: 'Lat: ${position.latitude}, Long: ${position.longitude}',
        ),
        icon: icon,
        anchor: const Offset(0.5, 0.8), // center the icon
      ),
    );

    _saveMarkersToFile(); // save full list
    updatePolylines();
  }

  // delete map marker
  void deleteMarker(Marker marker) {
    markers.remove(marker);
    _saveMarkersToFile();
    updatePolylines();
  }

  // clear all markers
  void deleteAllMarkers() {
    markers.clear();
    _saveMarkersToFile();
    updatePolylines();
  }

  // Find the closest marker and update the message
  void findClosestMarker() {
    if (markers.isEmpty) {
      message = 'No Markers';
      return;
    } else if (_currentPosition == null) {
      message = 'Current Position Unknown';
      return;
    }

    Marker? closestMarker; // Change to nullable
    double closestDistance = double.infinity;

    for (Marker marker in markers) {
      double distance = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        marker.position.latitude,
        marker.position.longitude,
      );

      if (distance < closestDistance) {
        closestDistance = distance;
        closestMarker = marker; // Assign marker to nullable variable
      }
    }

    // Check if a closest marker was found
    if (closestMarker != null) {
      message = 'Closest Marker: ${closestMarker.markerId.value}, Distance: ${closestDistance.toStringAsFixed(2)} meters';
    } else {
      message = 'No markers found.';
    }
  }
}
