import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:geolocator_test/other/location_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final LocationService _locationService = LocationService();
  final LatLng _mapCenter = const LatLng(3.1575, 101.7116); // custom coordinates
  final List<BarChartGroupData> barChartData = [];
  final List<PieChartSectionData> pieChartData = [];

  @override
  void initState() {
    super.initState();

    // initialize bar chart (Manhours per Month)
    for (int i = 1; i <= 12; i++) {
      barChartData.add(
        BarChartGroupData(x: i, barRods: [
          BarChartRodData(toY: (i * 5).toDouble(), color: Colors.blue),
        ]),
      );
    }

    // initialize pie chart data with empty titles for inner labels
    pieChartData.addAll([
      PieChartSectionData(value: 40, title: '', color: const Color(0xff22272d)),
      PieChartSectionData(value: 30, title: '', color: const Color(0xff343c45)),
      PieChartSectionData(value: 20, title: '', color: const Color(0xff47525f)),
      PieChartSectionData(value: 10, title: '', color: const Color(0xff5a6a7a)),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 42),

              // Map Section
              Container(
                height: 400,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.withOpacity(0.5), blurRadius: 5, spreadRadius: 2),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: GoogleMap(
                    mapType: MapType.hybrid,
                    initialCameraPosition: CameraPosition(
                      target: _locationService.currentPosition, // change center point here as needed (multiple projects?)
                      zoom: 10,
                    ),
                    markers: _locationService.markers.toSet(),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Progress Bar
              const Text('Progress', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      blurRadius: 5,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10), // round corners
                  child: LinearProgressIndicator(
                    value: 0.7, // progress variable here (70%)
                    minHeight: 20,
                    color: const Color.fromARGB(255, 52, 52, 52),
                    backgroundColor: Colors.grey[300],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Pie Chart
              const Text('Activity Distribution', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Pie Chart
                  SizedBox(
                    height: 180,
                    width: 200, // Set a fixed width for the pie chart
                    child: PieChart(
                      PieChartData(
                        sections: pieChartData,
                        centerSpaceRadius: 40,
                      ),
                    ),
                  ),

                  // Labels Column
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _buildCustomLabel(const Color(0xff22272d), 'Balanced'),
                      _buildCustomLabel(const Color(0xff343c45), 'Current'),
                      _buildCustomLabel(const Color(0xff47525f), 'Plan'),
                      _buildCustomLabel(const Color(0xff5a6a7a), 'Other'),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomLabel(Color color, String label) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
    );
  }
}
