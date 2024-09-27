// ignore_for_file: avoid_print

import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../other/location_service.dart';

class MapPage extends StatefulWidget {
  const MapPage({
    super.key,
  });

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final LocationService _locationService = LocationService();
  GoogleMapController? _mapController;

  bool _isLoading = false; // initialize page by loading

  // loading indicator
  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  // refresh location and UI, called on track button press
  void _refreshLocation() async {
    setState(() {
      // show loading indicator
      _isLoading = true;
    });

    await _locationService.updateLocation();

    if (_locationService.currentPosition != null && _mapController != null) {
      // move camera to new position
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(_locationService.currentPosition!),
      );
    }

    setState(() {
      // hide loading indicator
      _isLoading = false;
    });
  }

  // placeholder for the save function
  void _saveLocation() {
    // Logic to save the location (e.g., to a file or database)
    print("Saving location: ${_locationService.currentPosition}");
    // Show confirmation or feedback to the user here
  }

  // this runs on page initialization
  @override
  void initState() {
    super.initState();
    // initialize camera position if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(_locationService.currentPosition),
      );
    });
  }

  // UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // map widget here
            Expanded(
              flex: 2,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _locationService.currentPosition,
                  zoom: 18.0,
                ),
                mapType: MapType.satellite,
                onMapCreated: (GoogleMapController controller) {
                  _mapController = controller;
                },
                markers: _locationService.currentPosition != null
                    ? {
                        Marker(
                          markerId: const MarkerId('self'),
                          position: _locationService.currentPosition!,
                          infoWindow: const InfoWindow(title: 'My Position'),
                          icon: BitmapDescriptor.defaultMarker,
                        ),
                      }
                    : {},
              ),
            ),
            // Indicator text
            Padding(
              padding: const EdgeInsets.only(top: 25, bottom: 10),
              child: Text(
                _locationService.message,
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
                'Latitude: ${_locationService.currentPosition?.latitude ?? 'N/A'}',
                style: const TextStyle(fontSize: 18),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                'Longitude: ${_locationService.currentPosition?.longitude ?? 'N/A'}',
                style: const TextStyle(fontSize: 18),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: SizedBox(
                height: 60,
                child: _isLoading
                    ? _buildLoadingIndicator()
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
                            onPressed: _refreshLocation, // update location function
                            child: const Text(
                              'Track',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          const SizedBox(width: 20), // Row padding
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
                            onPressed: _saveLocation, // Save to storage function
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
