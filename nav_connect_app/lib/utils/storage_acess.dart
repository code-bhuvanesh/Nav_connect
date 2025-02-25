import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageAcess {
  SharedPreferences? _prefs;
  Future<void> init() async {
    _prefs = _prefs ?? await SharedPreferences.getInstance();
  }

  StorageAcess() {
    init();
  }

  Future<void> setPickupLocation(LatLng loc) async {
    await init();
    _prefs!.setDouble("pickupLat", loc.latitude);
    _prefs!.setDouble("pickupLng", loc.longitude);
  }

  Future<LatLng?> getPickupLocation() async {
    await init();
    var lat = _prefs!.getDouble("pickupLat");
    var lng = _prefs!.getDouble("pickupLng");
    if (lat != null && lng != null) {
      return LatLng(lat, lng);
    }
    return null;
  } 
}

// // Save an integer value to 'counter' key.
// await prefs.setInt('counter', 10);
// // Save an boolean value to 'repeat' key.
// await prefs.setBool('repeat', true);
// // Save an double value to 'decimal' key.
// await prefs.setDouble('decimal', 1.5);
// // Save an String value to 'action' key.
// await prefs.setString('action', 'Start');
// // Save an list of strings to 'items' key.
// await prefs.setStringList('items', <String>['Earth', 'Moon', 'Sun']);