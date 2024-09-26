import 'package:flutter/material.dart';

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../other/location_service.dart';

import 'package:flutter_excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class MapPage extends StatefulWidget {
  final Function(String, String) updateLocation;
  final String? lat;
  final String? long;
  final List<Marker> markers;
  final bool isNotNew;

  const MapPage({
    super.key,
    required this.updateLocation, // function to get lat and long
    this.lat,
    this.long,
    required this.markers,
    required this.isNotNew
  });

  @override
  State<MapPage> createState() => _MapPageState();
}

/**
 * this class acts as the main page for the application
 * contains geolocator, google maps, and excel functions
 */

class _MapPageState extends State<MapPage> {
  String message = 'No Location Detected';
  LatLng? _currentPosition = const LatLng(3.1575, 101.7116); // current position on map
  bool _isLoading = false; // track loading state
  GoogleMapController? _mapController; // camera control

  final LocationService _locationService = LocationService();
  Marker? _selfMarker; // store self marker separately

  @override
  void initState() {
    super.initState();
    // set initial position from passed lat/long
    if (widget.lat != null && widget.long != null) {
      // if position has been determined before
      _currentPosition = LatLng(double.parse(widget.lat!), double.parse(widget.long!));
      message = 'Location Detected';
    } else {
      // else go to default position (no cache)
      _currentPosition = const LatLng(3.1575, 101.7116);
    }
  }

  // get excel file path
  Future<File> _getExcelFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/location_data.xlsx';
    final file = File(path);

    // check if file exists. if not, create with headers
    if (!await file.exists()) {
      var excel = Excel.createExcel();
      // Sheet sheetObject = excel['Sheet1'];
      file.writeAsBytesSync(excel.save()!);
    }

    return file;
  }

  // update or read geolocation
  void _updateLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      Position position = await _locationService.getLocation();
      setState(() {
        // is able to get latitude and longitude
        String lat = '${position.latitude}';
        String long = '${position.longitude}';
        message = 'Location Detected';
        _currentPosition = LatLng(position.latitude, position.longitude);
        widget.updateLocation(lat, long);

        _selfMarker = Marker(
          markerId: const MarkerId('selfPosition'),
          position: _currentPosition!,
          infoWindow: const InfoWindow(title: 'My Location'),
          icon: BitmapDescriptor.defaultMarker,
        );
      });

      // move camera to new location
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(_currentPosition!),
        );
      }
    } catch (e) {
      setState(() {
        // failed to get latitude and longitude
        message = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false; // finished loading
      });
    }
  }

  void _saveToExcel() async {
    if (widget.isNotNew) {
      try {
        final file = await _getExcelFile();
        final excel = Excel.decodeBytes(file.readAsBytesSync());
        Sheet sheetObject = excel['Sheet1'];

        String timestamp = DateFormat('HH:mm').format(DateTime.now());
        sheetObject.appendRow([timestamp, _currentPosition!.latitude, _currentPosition!.longitude]);
        file.writeAsBytesSync(excel.save()!);

        setState(() {
          message = 'Location Saved';
        });
      } catch (e) {
        setState(() {
          message = 'Failed to save Location: $e';
        });
      }
    } else {
      setState(() {
        message = 'No location tracked to save';
      });
    }
  }

  // UI starts here
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // map here
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      spreadRadius: 3,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition!,
                    zoom: 18.0,
                  ),
                  mapType: MapType.satellite,
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                  },
                  markers: Set.from(widget.markers)..addAll(_selfMarker != null ? [_selfMarker!] : []),
                ),
              ),
            ),
            // Location Indicated Text
            Padding(
              padding: const EdgeInsets.only(top: 25, bottom: 10),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'Latitude: ${_currentPosition?.latitude ?? 'N/A'}',
                style: const TextStyle(fontSize: 18),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                'Longitude: ${_currentPosition?.longitude ?? 'N/A'}',
                style: const TextStyle(fontSize: 18),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: SizedBox(
                height: 60,
                child: _isLoading
                    ? const Center(
                        child: SizedBox(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: const Color.fromARGB(255, 34, 34, 34),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              minimumSize: const Size(150, 45),
                            ),
                            onPressed: _updateLocation,
                            child: const Text(
                              'Track',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          const SizedBox(width: 20),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: const Color.fromARGB(255, 34, 34, 34),
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: const BorderSide(color: Color.fromARGB(255, 34, 34, 34), width: 2),
                              ),
                              minimumSize: const Size(80, 45),
                            ),
                            onPressed: _saveToExcel,
                            child: const Text(
                              'Save',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
