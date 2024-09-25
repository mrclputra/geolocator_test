import 'package:flutter/material.dart';
import 'package:geolocator_test/pages/history_page.dart';
import 'package:geolocator_test/pages/map_page.dart';
import 'package:geolocator_test/pages/markers_page.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // keep track of current page
  int _selectedIndex = 0;

  String? lat;
  String? long;

  // shared map markers list
  final List<Marker> _markers = [];

  // update location
  void updateLocation(String latitude, String longitude) {
    setState(() {
      lat = latitude;
      long = longitude;
    });
  }

  // add marker
  void addMarker(Marker marker) {
    setState(() {
      _markers.add(marker);
    });
  }

  // delete marker
  void deleteMarker(Marker marker) {
    setState(() {
      _markers.remove(marker);
    });
  }

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages.add(MapPage(
      updateLocation: updateLocation,
      lat: lat,
      long: long,
      markers: _markers,
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
