import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkersPage extends StatefulWidget {
  final List<Marker> markers;
  final Function(Marker) addMarker;
  final Function(Marker) deleteMarker;

  const MarkersPage({
    super.key,
    required this.markers,
    required this.addMarker,
    required this.deleteMarker,
  });

  @override
  State<MarkersPage> createState() => _MarkersPageState();
}

class _MarkersPageState extends State<MarkersPage> {
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _longController = TextEditingController();

  // function add new marker
  void _addMarker() async {
    final double? lat = double.tryParse(_latController.text);
    final double? long = double.tryParse(_longController.text);
    if (lat != null && long != null) {
      final marker = Marker(
        markerId: MarkerId('${widget.markers.length + 1}'),
        position: LatLng(lat, long),
        infoWindow: const InfoWindow(title: 'Custom Marker'),
      );
      widget.addMarker(marker);

      setState(() {
        _latController.clear();
        _longController.clear();
      });
    } else {
      // Show error if coordinates are invalid
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid coordinates')),
      );
    }
  }

  // UI starts here
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: widget.markers.length,
                itemBuilder: (context, index) {
                  final marker = widget.markers[index];
                  return ListTile(
                    title: Text('Marker ${index + 1}'),
                    subtitle: Text('Lat: ${marker.position.latitude}, Long: ${marker.position.longitude}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        // call delete markers function here
                        setState(() {
                          widget.deleteMarker(marker);
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
              onPressed: _addMarker,
              child: const Text('Add Marker'),
            ),
          ],
        ),
      ),
    );
  }
}
