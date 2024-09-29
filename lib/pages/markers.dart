import 'package:flutter/material.dart';
import 'package:geolocator_test/other/location_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkersPage extends StatefulWidget {
  const MarkersPage({super.key});

  @override
  State<MarkersPage> createState() => _MarkersPageState();
}

class _MarkersPageState extends State<MarkersPage> {
  final LocationService _locationService = LocationService();
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _longController = TextEditingController();

  // UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                  itemCount: _locationService.markers.length,
                  itemBuilder: (context, index) {
                    final marker = _locationService.markers[index];
                    return ListTile(
                      title: Text('Marker ${index + 1}'),
                      subtitle: Text('Lat: ${marker.position.latitude}, Long: ${marker.position.longitude}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          // call delete markers function here
                          setState(() {
                            _locationService.deleteMarker(marker);
                          });
                        },
                      ),
                    );
                },
              ),
            ),
            TextField(
              controller: _latController,
              decoration: const InputDecoration(labelText: 'Latitude'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            TextField(
              controller: _longController,
              decoration: const InputDecoration(labelText: 'Longitude'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            ElevatedButton(
              onPressed: () {
                final lat = double.tryParse(_latController.text);
                final long = double.tryParse(_longController.text);
                if (lat != null && long != null) {
                  setState(() {
                    _locationService.addMarker(LatLng(lat, long)); // Add marker
                  });
                  _latController.clear();
                  _longController.clear();
                }
              },
              child: const Text('Add Marker'),
            ),
          ],
        ),
      ),
    );
  }
}
