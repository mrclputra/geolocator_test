import 'package:flutter/material.dart';

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../other/location_service.dart';

import 'package:shared_preferences/shared_preferences.dart';

class MapPage extends StatefulWidget {
  // final List<Marker> markers;

  const MapPage({
    super.key,
    // required this.markers,
  });

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  String message = 'No Location Detected';
  bool _isLoading = false;

  final LocationService _locationService = LocationService(); // custom location service object
  LatLng? _currentPosition; // current position on map
  GoogleMapController? _mapController; // camera control
  Marker? _selfMarker; // store self marker separately

  // this runs on page initialize
  @override
  void initState() {
    super.initState();

    // SharedPreferences.getInstance().then((prefs) {
    //   double? savedLat = prefs.getDouble('latitude');
    //   double? savedLng = prefs.getDouble('longitude');

    //   setState(() {
    //     if (savedLat != null && savedLng != null) {
    //       _currentPosition = LatLng(savedLat, savedLng);
    //     } else {
    //       _currentPosition = const LatLng(3.1575, 101.7116); // default starter location
    //       message = 'No Saved Location';
    //     }

    //     // update the self marker
    //     _selfMarker = Marker(
    //       markerId: const MarkerId('self'),
    //       position: _currentPosition!,
    //       infoWindow: const InfoWindow(title: 'My Position'),
    //       icon: BitmapDescriptor.defaultMarker,
    //     );
    //   });
    // });
  }

  // function to update current position
  void _updateLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      Position position = await _locationService.getLocation();

      // save location in shared preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('latitude', position.latitude);
      await prefs.setDouble('longitude', position.longitude);

      setState(() {
        // is able to get latitude and longitude
        message = 'Location Detected';
        _currentPosition = LatLng(position.latitude, position.longitude);

        _selfMarker = Marker(
          markerId: const MarkerId('self'),
          position: _currentPosition!,
          infoWindow: const InfoWindow(title: 'My Position'),
          icon: BitmapDescriptor.defaultMarker,
        );
      });

      // move camera to new position
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
      _isLoading = false; // finished loading
    }
  }

  Future<void> _loadSavedPosition() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    double? savedLat = prefs.getDouble('latitude');
    double? savedLng = prefs.getDouble('longitude');

    if (savedLat != null && savedLng != null) {
      _currentPosition = LatLng(savedLat, savedLng);
      message = 'Loaded saved location';
    } else {
      _currentPosition = const LatLng(3.1575, 101.7116); // default location
      message = 'No saved location';
    }

    _selfMarker = Marker(
      markerId: const MarkerId('self'),
      position: _currentPosition!,
      infoWindow: const InfoWindow(title: 'My Position'),
      icon: BitmapDescriptor.defaultMarker,
    );
  }

  // UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _loadSavedPosition(),
        builder: (context, snapshot) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // map widget here
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.25), spreadRadius: 3, blurRadius: 10, offset: const Offset(0, 5) // shadow offset
                            )
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
                      // markers: Set.from(widget.markers)..addAll(_selfMarker != null ? [_selfMarker!] : []),
                    ),
                  ),
                ),
                // indicator text
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
                                  onPressed: _updateLocation, // update location function here
                                  child: const Text(
                                    'Track',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                                const SizedBox(width: 20), // row padding
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
                                  onPressed: () {}, // save to excel function here
                                  child: const Text(
                                    'Save',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                )
                              ],
                            )),
                )
              ],
            ),
          );
        }
      ),
    );
  }
}
