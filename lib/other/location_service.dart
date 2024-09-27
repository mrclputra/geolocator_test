import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationService {
  final LatLng _defaultPosition = const LatLng(3.1575, 101.7116); // custom default user position

  LatLng? _currentPosition;
  String _message = 'No Location Detected';

  get currentPosition => _currentPosition ?? _defaultPosition;
  get message => _message;

  Future<void> updateLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _message = 'Location services are disabled';
        return;
      }

      // Request permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _message = 'Location permissions are denied';
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _message = 'Location permissions are denied forever. Please configure in settings.';
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        // ignore: deprecated_member_use
        desiredAccuracy: LocationAccuracy.best,
      );
      _currentPosition = LatLng(position.latitude, position.longitude);
      _message = 'Location Detected';
    } catch (e) {
      _message = e.toString();
    }
  }

  // Future<Position> getLocation() async {
  //   bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //     return Future.error('Location services are disabled');
  //   }

  //   LocationPermission permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.denied) {
  //       return Future.error('Location permissions are denied');
  //     }
  //   }

  //   if (permission == LocationPermission.deniedForever) {
  //     return Future.error('Location permissions are denied externally, please configure in settings.');
  //   }

  //   return await Geolocator.getCurrentPosition(
  //     // ignore: deprecated_member_use
  //     desiredAccuracy: LocationAccuracy.best,
  //   ).timeout(const Duration(seconds: 20));
  // }
}
