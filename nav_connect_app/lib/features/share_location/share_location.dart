import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sist_nav_connect/features/map_view/map_view.dart';
import 'package:sist_nav_connect/features/share_location/bloc/sharelocation_bloc.dart';
import 'package:sist_nav_connect/utils/constants.dart';

import '../mainbloc/main_bloc.dart' as main_bloc;
import '../map_view_page/mapBottomSheet.dart';

class ShareLocation extends StatefulWidget {
  static const routename = "sharelocation";
  const ShareLocation({super.key});

  @override
  State<ShareLocation> createState() => _ShareLocationState();
}

class _ShareLocationState extends State<ShareLocation>
    with TickerProviderStateMixin {
  var mapController = MapController();
  List<LatLng> polyline = [];

  static const _startedId = 'AnimatedMapController#MoveStarted';
  static const _inProgressId = 'AnimatedMapController#MoveInProgress';
  static const _finishedId = 'AnimatedMapController#MoveFinished';

  var zoomLevel = 17.0;
  LatLng? currentLocation;

  @override
  void initState() {
    // context.read<MapBloc>().add(GetMapPolylinePoints(points: cordinates));
    if (markersLatLng.length > 1) {
      context.read<SharelocationBloc>().add(GetMapPolylinePoints(
          points:
              markersLatLng.map((e) => [e.longitude, e.latitude]).toList()));
    }
    context.read<SharelocationBloc>().add(UpdateCurrentLocation(busID: 4));
    super.initState();
  }

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    final camera = mapController.camera;
    final latTween = Tween<double>(
        begin: camera.center.latitude, end: destLocation.latitude);
    final lngTween = Tween<double>(
        begin: camera.center.longitude, end: destLocation.longitude);
    final zoomTween = Tween<double>(begin: camera.zoom, end: destZoom);
    final controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    final Animation<double> animation =
        CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);
    final startIdWithTarget =
        '$_startedId#${destLocation.latitude},${destLocation.longitude},$destZoom';
    bool hasTriggeredMove = false;

    controller.addListener(() {
      final String id;
      if (animation.value == 1.0) {
        id = _finishedId;
      } else if (!hasTriggeredMove) {
        id = startIdWithTarget;
      } else {
        id = _inProgressId;
      }

      hasTriggeredMove |= mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
        id: id,
      );
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  LatLng? currentBusLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // floatingActionButton: FloatingActionButton(
      //     onPressed: () {
      //       setState(() {
      //         markersLatLng.removeLast();
      //       });
      //       if (markersLatLng.length > 1) {
      //         context.read<SharelocationBloc>().add(GetMapPolylinePoints(
      //             points: markersLatLng
      //                 .map((e) => [e.longitude, e.latitude])
      //                 .toList()));
      //       } else {
      //         setState(() {
      //           polyline = [];
      //         });
      //       }
      //     },
      //     child: Text("-")),
      body: MultiBlocListener(
        listeners: [
          BlocListener<main_bloc.MainBloc, main_bloc.MainState>(
            listener: (context, state) {},
          ),
          BlocListener<SharelocationBloc, SharelocationState>(
            listener: (context, state) {
              if (state is MapsPolyLineCordinates) {
                setState(() {
                  polyline = state.points;
                });
              }
              if (state is CurrentBusLocationState) {
                setState(() {
                  currentLocation = state.newLocation;
                });
              }
              if (state is CurrentLocationState) {
                print(state.location);
                var loc = LatLng(
                  state.location.latitude,
                  state.location.longitude,
                );
                _animatedMapMove(loc, zoomLevel);
                setState(() {
                  // mapController.move(loc, 17);
                  currentLocation = loc;
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
                if (currentBusLocation != null)
                  Marker(
                    point: currentBusLocation!,
                    child: const Icon(
                      Icons.bus_alert_rounded,
                    ),
                  ),
                // ...markersLatLng
                //     .map((e) => Marker(
                //         point: e,
                //         child: const Icon(
                //           Icons.pin_drop,
                //           size: 50,
                //         )))
                //     .toList(),
                Marker(
                  point: markersLatLng[0],
                  child: const Icon(
                    Icons.pin_drop,
                    size: 50,
                  ),
                ),
                Marker(
                  point: markersLatLng.last,
                  child: const Icon(
                    Icons.pin_drop,
                    size: 50,
                  ),
                )
              ],
              polylines: [
                Polyline(
                  points: polyline,
                  // points: cordinates.map((e) => LatLng(e[1], e[0])).toList(),
                  color: Colors.black,
                  strokeWidth: 7,
                  strokeCap: StrokeCap.round,
                  borderColor: Colors.black,
                  borderStrokeWidth: 2,
                  // borderStrokeWidth: 10,
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              child:
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                navButton(
                  icon: const Icon(
                    Icons.bus_alert,
                  ),
                  onTap: () {},
                ),
                const SizedBox(
                  height: 20,
                ),
                navButton(
                  icon: const Icon(
                    Icons.gps_fixed,
                  ),
                  onTap: () {
                    if (currentLocation != null) {
                      _animatedMapMove(currentLocation!, zoomLevel);
                    }
                    context.read<main_bloc.MainBloc>().add(main_bloc.GetCurrentLocation());
                  },
                ),
                const SizedBox(
                  height: 30,
                ),
                const MapBottomSheet(),
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
      child: Card(
        color: const Color.fromARGB(255, 221, 240, 255),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: icon,
        ),
      ),
    );
  }

  // List<LatLng> markersLatLng = [];
  List<LatLng> markersLatLng = ponamalle_cordinates
      .map(
        (e) => LatLng(e[1], e[0]),
      )
      .toList();

  var distancecal = Distance(roundResult: true);

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
