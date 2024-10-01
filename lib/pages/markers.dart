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

  void _loadPlaceholderMarkers() async {
    _locationService.deleteAllMarkers();

    final markerData = [
      {'position': const LatLng(2.98868537940847, 101.797900666648), 'name': 'Point1'},
      {'position': const LatLng(2.989244413402585, 101.798532386788), 'name': 'Point2'},
      {'position': const LatLng(2.990033366473916, 101.7992203640038), 'name': 'Point3'},
      {'position': const LatLng(2.990693376988884, 101.7998528986079), 'name': 'Point4'},
      {'position': const LatLng(2.991000600300543, 101.7994319101828), 'name': 'Point5'},
      {'position': const LatLng(2.991183359339283, 101.7991375626299), 'name': 'Point6'},
      {'position': const LatLng(2.991274168478034, 101.7990393874386), 'name': 'Point7'},
      {'position': const LatLng(2.991459196578864, 101.7990096733906), 'name': 'Point8'},
      {'position': const LatLng(2.991595308080111, 101.7993332308529), 'name': 'Point9'},
      {'position': const LatLng(2.991796846335147, 101.7999538794936), 'name': 'Point10'},
      {'position': const LatLng(2.992068945072041, 101.8006967136011), 'name': 'Point11'},
      {'position': const LatLng(2.992232580409363, 101.8013141468541), 'name': 'Point12'},
      {'position': const LatLng(2.992287199282622, 101.8019154540598), 'name': 'Point13'},
      {'position': const LatLng(2.992245838393786, 101.8023254031128), 'name': 'Point14'},
      {'position': const LatLng(2.992120704542342, 101.8028650186327), 'name': 'Point15'},
      {'position': const LatLng(2.992102013457163, 101.8028982936435), 'name': 'Point16'},
      {'position': const LatLng(2.992633673121985, 101.8031629498947), 'name': 'Point17'},
      {'position': const LatLng(2.992763972446477, 101.8031904578254), 'name': 'Point18'},
      {'position': const LatLng(2.99464656257988, 101.8027092595519), 'name': 'Point19'},
      {'position': const LatLng(2.994751238107307, 101.8030916538442), 'name': 'Point20'},
      {'position': const LatLng(2.994972827645898, 101.8029886791101), 'name': 'Point21'},
      {'position': const LatLng(2.995632011314621, 101.8029304572101), 'name': 'Point22'},
      {'position': const LatLng(2.996467781200925, 101.8028909097834), 'name': 'Point23'},
      {'position': const LatLng(2.997295857294304, 101.8027997294445), 'name': 'Point24'},
      {'position': const LatLng(2.997095632111799, 101.8017599383495), 'name': 'Point25'},
      {'position': const LatLng(2.996881125760533, 101.8008371099352), 'name': 'Point26'},
      {'position': const LatLng(2.996904451522328, 101.8005968320921), 'name': 'Point27'},
      {'position': const LatLng(2.996992184098294, 101.8004923529445), 'name': 'Point28'},
      {'position': const LatLng(2.997088815271175, 101.799618825858), 'name': 'Point29'},
      {'position': const LatLng(2.997184074399046, 101.7995369555329), 'name': 'Point30'},
      {'position': const LatLng(2.997858984062179, 101.799581144598), 'name': 'Point31'},
      {'position': const LatLng(2.99793504362245, 101.7987814808774), 'name': 'Point32'},
    ];

    // add markers with a loop
    for (var marker in markerData) {
      _locationService.addMarker(marker['position'] as LatLng, marker['name'] as String); // type cast
    }

    setState(() {}); // refresh UI
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
                    _loadPlaceholderMarkers();

                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Loaded Test Markers')));
                  },
                ),
                // IconButton(
                //   icon: const Icon(Icons.download_rounded),
                //   onPressed: () {
                //     // implement download markers excel here
                //     // _downloadExcelFile();
                //   },
                // ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    // implement confirmation screen
                    // implement clear screen here
                    _locationService.deleteAllMarkers();
                    setState(() {}); // refresh UI

                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Deleted Markers')));
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
                final name = _nameController.text.trim().replaceAll(' ', '_'); // remove spaces
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
