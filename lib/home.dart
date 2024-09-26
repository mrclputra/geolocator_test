import 'package:flutter/material.dart';
import 'package:geolocator_test/pages/history_page.dart';
import 'package:geolocator_test/pages/map_page.dart';
import 'package:geolocator_test/pages/markers_page.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

class PageManager extends StatefulWidget {
  const PageManager({super.key});

  @override
  State<PageManager> createState() => _PageManagerState();
}

class _PageManagerState extends State<PageManager> {
  // keep track of current page
  int _selectedIndex = 0;

  String? lat;
  String? long;

  bool isNotNew = false;

  // shared map markers list
  final List<Marker> _markers = [];

  // save markers to persistent file
  Future<void> _saveMarkersToFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/markers.txt');

    List<String> markerList = _markers.map((marker) {
      return jsonEncode({
        'id': marker.markerId.value,
        'lat': marker.position.latitude,
        'long': marker.position.longitude,
      });
    }).toList();

    await file.writeAsString(markerList.join('\n'));
  }

  // load markers from persistent file
  Future<void> _loadMarkersFromFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/markers.txt');

    if (await file.exists()) {
      List<String> markerList = await file.readAsLines();
      setState(() {
        _markers.clear();
        _markers.addAll(markerList.map((markerString) {
          Map<String, dynamic> markerData = jsonDecode(markerString);
          return Marker(
            markerId: MarkerId(markerData['id']),
            position: LatLng(markerData['lat'], markerData['long']),
            infoWindow: const InfoWindow(title: 'Custom Marker'),
          );
        }).toList());
      });
    }
  }

  // add marker
  void addMarker(Marker marker) {
    setState(() {
      _markers.add(marker);
      _saveMarkersToFile();
    });
  }

  // delete marker
  void deleteMarker(Marker marker) {
    setState(() {
      _markers.remove(marker);
      _saveMarkersToFile();
    });
  }

  // update location
  void updateLocation(String latitude, String longitude) {
    setState(() {
      lat = latitude;
      long = longitude;
      isNotNew = true;
      
      // rebuild MapPage immediately with new location
      _pages[0] = MapPage(
        updateLocation: updateLocation,
        lat: lat,
        long: long,
        markers: _markers,
        isNotNew: isNotNew,
      );
    });
  }

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _loadMarkersFromFile();
    _pages.add(MapPage(
      updateLocation: updateLocation,
      lat: lat,
      long: long,
      markers: _markers,
      isNotNew: isNotNew,
    ));
    _pages.add(const HistoryPage());
    _pages.add(MarkersPage(
      markers: _markers, // pass list of markers
      addMarker: addMarker, // pass add markers
      deleteMarker: deleteMarker, // pass delete markers
    ));
  }

  // update selected page
  void _navigateBar(int index) {
    setState(() {
      _selectedIndex = index;
      // re-create MapPage with updated lat/long if coming back
      Marker? currentLocationMarker;
      if (lat != null && long != null) {
        currentLocationMarker = Marker(
          markerId: const MarkerId('selfPosition'),
          position: LatLng(double.parse(lat!), double.parse(long!)),
          infoWindow: const InfoWindow(title: 'My Location'),
          icon: BitmapDescriptor.defaultMarker,
        );
      }

      if (_selectedIndex == 0) {
        _pages[0] = MapPage(
          updateLocation: updateLocation,
          lat: lat,
          long: long,
          markers: List.from(_markers)..addAll(currentLocationMarker != null ? [currentLocationMarker] : []),
          isNotNew: isNotNew
          // markers: _markers,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _navigateBar,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_edu),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.gps_fixed),
            label: 'Markers',
          ),
        ],
      ),
    );
  }
}
