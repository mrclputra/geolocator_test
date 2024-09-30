import 'package:flutter/material.dart';
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
      // no need to recreate mappage, it should be handled through mappage class init function
    });
  }

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
      body: _pages[_currentPageIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _currentPageIndex,
        onTap: _navigatePage,
        unselectedItemColor: const Color.fromARGB(255, 84, 84, 84),
        selectedItemColor: const Color.fromARGB(255, 29, 29, 29),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
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
            label: 'Markers',
          ),
        ],
      ),
    );
  }
}
