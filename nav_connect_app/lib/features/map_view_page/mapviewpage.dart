import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sist_nav_connect/features/map_view/map_view.dart';
import 'package:sist_nav_connect/utils/constants.dart';

import '../../animations/mapAnimations.dart';
import '../../data/model/bus.dart';
import '../../utils/helpers.dart';
import 'bloc/mapbloc_bloc.dart';
import '../mainbloc/main_bloc.dart';
import 'mapBottomSheet.dart';

class MapViewPage extends StatefulWidget {
  static const routename = '/mapview';
  final Bus bus;
  const MapViewPage({
    super.key,
    required this.bus,
  });

  @override
  State<MapViewPage> createState() => _MapViewPageState();
}

class _MapViewPageState extends State<MapViewPage>
    with TickerProviderStateMixin {
  var mapController = MapController();
  List<LatLng> polyline = [];
  List<LatLng> mapCordinates = [];
  double? busDistance;

  var zoomLevel = 17.0;
  LatLng? currentLocation;
  bool isToCollege = true;
  bool animateMap = true;

  @override
  void initState() {
    // context.read<MapBloc>().add(GetMapPolylinePoints(points: cordinates));

    context.read<MapBloc>().add(ListenBusLocationEvent(
          busId: widget.bus.busid,
        ));
    context.read<MainBloc>().add(
          GetCurrentLocation(),
        );
    // Timer.periodic(
    //   const Duration(seconds: 5),
    //   (Timer t) => context.read<MainBloc>().add(
    //         GetCurrentLocation(),
    //       ),
    // );

    // isToCollege = DateTime.now().hour < 10;

    super.initState();
  }

  LatLng? currentBusLocation;

  LatLng? closestPoint;

  var mapCordinatesCount = 0;

  List<Marker> testNumber(List<LatLng> cord) {
    var count = 1;
    return cord.map((e) {
      return Marker(
        child: Card(
          color: const Color.fromARGB(132, 255, 255, 255),
          child: Center(child: Text("${count++}")),
        ),
        point: e,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiBlocListener(
        listeners: [
          BlocListener<MainBloc, MainState>(
            listener: (context, state) {
              if (state is CurrentLocationState) {
                print("updated location : ${state.location}");
                var loc = LatLng(
                  state.location.latitude,
                  state.location.longitude,
                );

                setState(() {
                  // mapController.move(loc, 17);
                  currentLocation = loc;
                });

                if (animateMap) {
                  animatedMapMove(
                    mapController: mapController,
                    vsync: this,
                    destLocation: currentLocation!,
                    destZoom: zoomLevel,
                  );
                  animateMap = false;
                }
              }
            },
          ),
          BlocListener<MapBloc, MapblocState>(
            listener: (context, state) {
              if (state is MapsPolyLineCordinates && currentLocation != null) {
                setState(() {
                  polyline = state.points;
                });
                var generatedPoints = findClosestLatLng(
                  polyline,
                  currentLocation!,
                );
                closestPoint = generatedPoints.removeLast();
                generatedPoints = findClosestLatLng(
                  generatedPoints,
                  currentBusLocation!,
                  onlyhalf: true,
                );
                var busd = getDistanceFromList(polyline,
                    end: closestPoint); // calculate bus distance
                generatedPoints.removeLast();
                setState(() {
                  polyline = generatedPoints;
                  busDistance = busd;
                });
                print("my distance from bus $busDistance");
              }
              if (state is CurrentBusLocationState) {
                setState(() {
                  currentBusLocation = state.newLocation;
                });

                if (polyline.isEmpty) {
                  mapCordinates = ponamalle_cordinates
                      .map((e) => LatLng(e[1], e[0]))
                      .toList();
                  if (!isToCollege) {
                    mapCordinates = mapCordinates.reversed.toList();
                  }

                  context.read<MapBloc>().add(
                        GetMapPolylinePoints(
                            points: mapCordinates
                                .map((e) => [e.longitude, e.latitude])
                                .toList()),
                      );
                } else {
                  var generatedPoints = findClosestLatLng(
                    polyline,
                    currentBusLocation!,
                    onlyhalf: true,
                  );

                  generatedPoints.removeLast();
                  if (closestPoint == null) {
                    generatedPoints =
                        findClosestLatLng(generatedPoints, currentLocation!);
                    closestPoint = generatedPoints.removeLast();
                  }
                  var busd = getDistanceFromList(polyline,
                      end: closestPoint); //bus distance
                  setState(() {
                    polyline = generatedPoints;
                    busDistance = busd;
                  });
                  print("my distance from bus $busDistance");
                }
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
                if (currentBusLocation != null)
                  Marker(
                    point: currentBusLocation!,
                    // child: const Icon(
                    //   Icons.bus_alert_rounded,
                    // ),
                    child: Container(
                      height: 30,
                      width: 30,
                      padding: const EdgeInsets.all(0),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(
                        "assets/icons/bus_logo.png",
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                if (polyline.isNotEmpty)
                  Marker(
                    point: polyline.last,
                    // child: const Icon(
                    //   Icons.bus_alert_rounded,
                    // ),
                    child: Container(
                      height: 60,
                      width: 60,
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: isToCollege
                          ? Image.asset(
                              "assets/icons/sist_logo.png",
                              fit: BoxFit.contain,
                            )
                          : const Icon(Icons.home),
                    ),
                  ),
                // ...testNumber(mapCordinates),
                // ...testNumber(polyline),
                if (closestPoint != null)
                  Marker(
                    point: closestPoint!,
                    child: const Icon(
                      Icons.close,
                      color: Color.fromARGB(126, 255, 255, 255),
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
                  color: Colors.black,
                  strokeWidth: 5,
                  strokeCap: StrokeCap.round,
                  // borderStrokeWidth: 10,
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              child:
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                if (currentBusLocation != null)
                  navButton(
                    // icon: const Icon(
                    //   Icons.bus_alert,
                    // ),
                    icon: Image.asset(
                      "assets/icons/bus_logo.png",
                      fit: BoxFit.contain,
                    ),
                    onTap: () {
                      if (currentBusLocation != null) {
                        animatedMapMove(
                          mapController: mapController,
                          vsync: this,
                          destLocation: currentBusLocation!,
                          destZoom: zoomLevel,
                        );
                      }
                    },
                  ),
                const SizedBox(
                  height: 20,
                ),
                navButton(
                  // icon: const Icon(
                  //   Icons.gps_fixed,
                  // ),
                  icon: Image.asset(
                    "assets/icons/location_logo.png",
                    fit: BoxFit.contain,
                  ),
                  onTap: () {
                    // animateMap = true;
                    animatedMapMove(
                      mapController: mapController,
                      vsync: this,
                      destLocation: currentLocation!,
                      destZoom: zoomLevel,
                    );
                    // context.read<MainBloc>().add(GetCurrentLocation());
                  },
                ),
                const SizedBox(
                  height: 30,
                ),
                MapBottomSheet(
                  busDistance: busDistance,
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget navButton({required Widget icon, required void Function() onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 60,
        width: 60,
        child: Card(
          color: const Color.fromARGB(255, 221, 240, 255),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: icon,
          ),
        ),
      ),
    );
  }

  List<LatLng> markersLatLng = [];
  var distancecal = const Distance(roundResult: true);
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
              if (!isToCollege) markersLatLng = markersLatLng.reversed.toList();
              context.read<MapBloc>().add(
                    GetMapPolylinePoints(
                      points: markersLatLng
                          .map((e) => [e.longitude, e.latitude])
                          .toList(),
                    ),
                  );
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
