import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sist_nav_connect/features/map_view/map_view.dart';

import '../../animations/mapAnimations.dart';
import 'bloc/mapbloc_bloc.dart';
import '../mainbloc/main_bloc.dart';

class MapViewPage extends StatefulWidget {
  static const routename = '/mapview';
  const MapViewPage({super.key});

  @override
  State<MapViewPage> createState() => _MapViewPageState();
}

class _MapViewPageState extends State<MapViewPage>
    with TickerProviderStateMixin {
  var mapController = MapController();
  List<LatLng> polyline = [];

  var zoomLevel = 17.0;
  LatLng? currentLocation;

  @override
  void initState() {
    // context.read<MapBloc>().add(GetMapPolylinePoints(points: cordinates));
    context.read<MainBloc>().add(GetCurrentLocation());
    context.read<MapBloc>().add(ListenBusLocationEvent(busId: 4));
    super.initState();
  }

  LatLng? currentBusLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              markersLatLng.removeLast();
            });
            if (markersLatLng.length > 1) {
              context.read<MapBloc>().add(GetMapPolylinePoints(
                  points: markersLatLng
                      .map((e) => [e.longitude, e.latitude])
                      .toList()));
            } else {
              setState(() {
                polyline = [];
              });
            }
          },
          child: Text("-")),
      body: MultiBlocListener(
        listeners: [
          BlocListener<MainBloc, MainState>(
            listener: (context, state) {
              if (state is CurrentLocationState) {
                print(state.location);
                var loc = LatLng(
                  state.location.latitude!,
                  state.location.longitude!,
                );
                animatedMapMove(
                  mapController: mapController,
                  vsync: this,
                  destLocation: loc,
                  destZoom: zoomLevel,
                );
                setState(() {
                  // mapController.move(loc, 17);
                  currentLocation = loc;
                });
              }
            },
          ),
          BlocListener<MapBloc, MapblocState>(
            listener: (context, state) {
              if (state is MapsPolyLineCordinates) {
                setState(() {
                  polyline = state.points;
                });
              }
              if (state is CurrentBusLocationState) {
                setState(() {
                  currentBusLocation = state.newLocation;
                });
              }
            },
          ),
        ],
        child: Stack(
          children: [
            // mapView(),
            MapView(
              showCurrentLocation: true,
              mapController: mapController,
              currentLocation: currentLocation,
              markers: [
                if (currentLocation != null)
                  Marker(
                    point: currentLocation!,
                    child: const Icon(
                      Icons.bus_alert_rounded,
                    ),
                  ),
                ...markersLatLng
                    .map((e) => Marker(
                        point: e,
                        child: const Icon(
                          Icons.pin_drop,
                          size: 50,
                        )))
                    .toList(),
              ],
              polylines: [
                Polyline(
                  points: polyline,
                  // points: cordinates.map((e) => LatLng(e[1], e[0])).toList(),
                  color: Colors.blue,
                  strokeWidth: 10,
                  strokeCap: StrokeCap.round,
                  borderColor: Colors.black,
                  borderStrokeWidth: 2,
                  // borderStrokeWidth: 10,
                ),
              ],
            )
            // Positioned(
            //   bottom: 0,
            //   child:
            //       Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            //     navButton(
            //       icon: const Icon(
            //         Icons.bus_alert,
            //       ),
            //       onTap: () {},
            //     ),
            //     const SizedBox(
            //       height: 20,
            //     ),
            //     navButton(
            //       icon: const Icon(
            //         Icons.gps_fixed,
            //       ),
            //       onTap: () {
            //         if (currentLocation != null) {
            //           _animatedMapMove(currentLocation!, zoomLevel);
            //         }
            //         context.read<MainBloc>().add(GetCurrentLocation());
            //       },
            //     ),
            //     const SizedBox(
            //       height: 30,
            //     ),
            //     const MapBottomSheet(),
            //   ]),
            // ),
          ],
        ),
      ),
    );
  }

  Widget navButton({required Widget icon, required void Function() onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: const Color.fromARGB(255, 221, 240, 255),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: icon,
        ),
      ),
    );
  }

  List<LatLng> markersLatLng = [];
  var distancecal = Distance(roundResult: true);
  Widget mapView() {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
          initialCenter: const LatLng(13.0827, 80.2707),
          initialZoom: 9.2,
          onTap: (_, tapLatLng) {
            print("zoom : ${mapController.camera.zoom}");
            int rmindex = markersLatLng.indexWhere((element) {
              print(
                  "dis : ${distancecal.as(LengthUnit.Meter, element, tapLatLng)}");
              return distancecal.as(LengthUnit.Meter, element, tapLatLng) <=
                  20 * (20 - mapController.camera.zoom);
              // pow(2.5, 20 - mapController.camera.zoom);
            });

            setState(() {
              if (rmindex == -1) {
                markersLatLng.add(tapLatLng);
              } else {
                markersLatLng.removeAt(rmindex);
              }
            });

            if (markersLatLng.length > 1) {
              context.read<MapBloc>().add(GetMapPolylinePoints(
                  points: markersLatLng
                      .map((e) => [e.longitude, e.latitude])
                      .toList()));
            } else {
              setState(() {
                polyline = [];
              });
            }
          }
          // onPositionChanged: (_, __) {
          //   print("pos changed");
          //   setState(() {
          //     // centerLatLng = mapController.camera.center;
          //   });
          // },
          ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.app',
        ),
        PolylineLayer(
          polylines: [
            Polyline(
              points: polyline,
              // points: cordinates.map((e) => LatLng(e[1], e[0])).toList(),
              color: Colors.blue,
              strokeWidth: 10,
              strokeCap: StrokeCap.round,
              borderColor: Colors.black,
              borderStrokeWidth: 2,
              // borderStrokeWidth: 10,
            ),
          ],
        ),
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
            markers: [
              if (currentBusLocation != null)
                Marker(
                  point: currentBusLocation!,
                  child: const Icon(
                    Icons.bus_alert_rounded,
                  ),
                ),
              ...markersLatLng
                  .map((e) => Marker(
                      point: e,
                      child: const Icon(
                        Icons.pin_drop,
                        size: 50,
                      )))
                  .toList(),
            ]),
        CircleLayer(circles: [
          if (currentLocation != null)
            CircleMarker(
              point: currentLocation!,
              radius: 10,
              borderColor: Colors.blue,
              color: const Color.fromARGB(150, 156, 214, 255),
              borderStrokeWidth: 3,
            )
        ])
      ],
    );
  }

  Marker customMarker(LatLng startLocation) {
    var pos = startLocation;
    return Marker(
      rotate: true,
      point: pos,
      child: GestureDetector(
        onTap: () {
          print("marker is clicked");
        },
        onVerticalDragUpdate: (drag) {
          setState(() {
            pos = mapController.camera
                .pointToLatLng(drag.globalPosition.toPoint());
          });
        },
        onHorizontalDragUpdate: (drag) {
          setState(() {
            pos = mapController.camera
                .pointToLatLng(drag.globalPosition.toPoint());
          });
        },
        child: const Icon(
          Icons.pin_drop,
          size: 150,
        ),
      ),
    );
  }
}
