import 'package:flutter/material.dart';
import 'package:geolocator_test/other/location_service.dart';
import 'package:geolocator_test/pages/dashboard.dart';
import 'package:geolocator_test/pages/history.dart';
import 'package:geolocator_test/pages/map.dart';
import 'package:geolocator_test/pages/markers.dart';

class PageManager extends StatefulWidget {
  const PageManager({super.key});

  @override
  State<PageManager> createState() => _PageManagerState();
}

class _PageManagerState extends State<PageManager> {
  // keep track of current page
  int _currentPageIndex = 1;
  final List<Widget> _pages = [];

  // navigate pages
  void _navigatePage(int index) {
    setState(() {
      _currentPageIndex = index;
    });
  }

  final LocationService _locationService = LocationService();

  // this runs on initialization
  @override
  void initState() {
    super.initState();

    // add dashboard page
    _pages.add(const DashboardPage());
    // add map page
    _pages.add(const MapPage());
    // add history page
    _pages.add(const HistoryPage());
    // add markers page
    _pages.add(const MarkersPage());
  }

  // UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _locationService.initialize(), // ensure markers are loaded before showing the content
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // show loading indicator in the page body while markers load
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            // display the current page when loading is done
            return _pages[_currentPageIndex];
          }
        },
      ),
      // bottom navigation bar stays visible even during loading
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _currentPageIndex,
        onTap: _navigatePage,
        unselectedItemColor: const Color.fromARGB(255, 84, 84, 84),
        selectedItemColor: const Color.fromARGB(255, 29, 29, 29),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.space_dashboard_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_edu),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Waypoints',
          ),
        ],
      ),
    );
  }
}
