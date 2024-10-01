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

  final TextEditingController _nameController = TextEditingController(); // waypoint name
  final TextEditingController _latController = TextEditingController(); // waypoint latitude
  final TextEditingController _longController = TextEditingController(); // waypoint longitude

  // reorder markers in list
  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final marker = _locationService.markers.removeAt(oldIndex);
      _locationService.markers.insert(newIndex, marker);

      // update map
      _locationService.updatePolylines();
    });
  }

  // UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(left: 10),
          child: Text(
            'Waypoints',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.library_add_rounded),
                  onPressed: () {
                    // call waypoint excel import
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.download_rounded),
                  onPressed: () {
                    // implement download markers excel here
                    // _downloadExcelFile();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    // implement confirmation screen
                    // implement clear screen here
                  },
                )
              ],
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: ReorderableListView.builder(
                itemCount: _locationService.markers.length,
                onReorder: _onReorder,
                itemBuilder: (context, index) {
                  final marker = _locationService.markers[index];
                  return ListTile(
                    key: ValueKey(marker.markerId), // unique key for each marker
                    title: Text(marker.markerId.value),
                    subtitle: Text('Lat: ${marker.position.latitude}, Long: ${marker.position.longitude}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                            size: 23,
                          ),
                          onPressed: () {
                            setState(() {
                              _locationService.deleteMarker(marker);
                            });
                          },
                        ),
                        const Icon(
                          Icons.drag_handle,
                          size: 26,
                        ), // drag icon to reorder
                      ],
                    ),
                  );
                },
              ),
            ),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Waypoint Name',
                isDense: false,
                contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 12.0),
              ),
            ),
            TextField(
              controller: _latController,
              decoration: const InputDecoration(
                labelText: 'Latitude',
                isDense: false,
                contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 12.0),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            TextField(
              controller: _longController,
              decoration: const InputDecoration(
                labelText: 'Longitude',
                isDense: false,
                contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 12.0),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color.fromARGB(255, 34, 34, 34),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                minimumSize: const Size(140, 40),
              ),
              onPressed: () {
                final name = _nameController.text;
                final lat = double.tryParse(_latController.text);
                final long = double.tryParse(_longController.text);

                if (lat != null && long != null && name.isNotEmpty) {
                  setState(() {
                    _locationService.addMarker(LatLng(lat, long), name); // add marker
                  });
                  // _nameController.clear();
                  _latController.clear();
                  _longController.clear();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all Fields.')));
                }
              },
              child: const Text('Add Marker'),
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}
