import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapView extends StatefulWidget {
  final LatLng initialPostion;
  final LatLng? currentLocation;
  final List<Marker> markers;
  final List<Polyline> polylines;
  final bool showCurrentLocation;
  final MapController mapController;
  final void Function(TapPosition, LatLng)? onMapTap;
  const MapView({
    super.key,
    this.initialPostion = const LatLng(13.0827, 80.2707),
    this.showCurrentLocation = false,
    this.markers = const [],
    this.polylines = const [],
    this.currentLocation,
    this.onMapTap,
    required this.mapController,
  });

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  var distancecal = const Distance(roundResult: true);
  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: widget.mapController,
      options: MapOptions(
        initialCenter: const LatLng(13.0827, 80.2707),
        initialZoom: 9.2,
        onTap: widget.onMapTap,
      ),
      children: [
        TileLayer(
          additionalOptions: const {
            'lat': "{lat}", // Placeholder for latitude
            'lon': "{lon}", // Placeholder for longitude
          },
          // tileProvider: OlaMapTileProvider(),
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          // urlTemplate:
          //     'https://api.maptiler.com/maps/streets-v2/{z}/{x}/{y}@2x.png?key=7mohzoiadIawWMBoamrR',
          // urlTemplate:
          //     'https://api.olamaps.io/tiles/v1/styles/default-light-standard/static/{lon},{lat},{z}/800x600.png?api_key=TazIAv3R5Xuv1rwwiLCen7MN51yU4sZpQaMWzBoR',
          tileUpdateTransformer:
              StreamTransformer<TileUpdateEvent, TileUpdateEvent>(
            (stream, cancelOnError) => stream.listen(
              (tile) => print("tile event : ${tile.center}"),
            ),
          ),

          userAgentPackageName: 'com.example.app',
        ),
        PolylineLayer(polylines: widget.polylines),
        MarkerLayer(
          rotate: true,
          // markers: [
          //   // if (currentLocation != null)
          //   //   Marker(
          //   //     rotate: true,
          //   //     point: centerLatLng,
          //   //     child: const Icon(
          //   //       Icons.pin_drop,
          //   //       size: 50,
          //   //     ),
          //   //   )

          // ],
          markers: widget.markers,
        ),
        // if (widget.showCurrentLocation)
        CircleLayer(circles: [
          if (widget.currentLocation != null)
            CircleMarker(
              point: widget.currentLocation!,
              radius: 10,
              borderColor: Colors.blue,
              color: const Color.fromARGB(150, 156, 214, 255),
              borderStrokeWidth: 3,
            )
        ])
      ],
    );
  }
}

class OlaMapTileProvider extends TileProvider {
  @override
  ImageProvider getImage(TileCoordinates coords, TileLayer options) {
    final lat = tile2lat(coords.y.toInt(), coords.z.toInt());
    final lon = tile2lon(coords.x.toInt(), coords.z.toInt());

    // Create the URL using lat/lon instead of x/y/z
    String url = options.urlTemplate!;
    print("map cor : $lat $lon");
    url = url.replaceAll('{lat}', lat.toString());
    url = url.replaceAll('{lon}', lon.toString());
    url = url.replaceAll('{z}', coords.z.toString());

    // Return a NetworkImage as the ImageProvider
    return NetworkImage(url);
  }

  double tile2lat(int y, int z) {
    final n = math.pi - 2.0 * math.pi * y / math.pow(2.0, z);
    return (180.0 / math.pi * math.atan(sinh(n)));
  }

  double tile2lon(int x, int z) {
    return (x / math.pow(2.0, z) * 360.0 - 180.0);
  }

  double sinh(double x) {
    return (math.exp(x) - math.exp(-x)) / 2;
  }
}
