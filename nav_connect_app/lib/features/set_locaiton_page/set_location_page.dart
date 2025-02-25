import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sist_nav_connect/animations/mapAnimations.dart';
import 'package:sist_nav_connect/features/mainbloc/main_bloc.dart';
import 'package:sist_nav_connect/utils/storage_acess.dart';

import '../map_view/map_view.dart';

class SetLocationPage extends StatefulWidget {
  static const routename = "setLocationPage";
  const SetLocationPage({super.key});

  @override
  State<SetLocationPage> createState() => _SetLocationPageState();
}

class _SetLocationPageState extends State<SetLocationPage>
    with TickerProviderStateMixin {
  @override
  void initState() {
    context.read<MainBloc>().add(GetCurrentLocation());
    super.initState();
  }

  var mapController = MapController();
  LatLng? currentLocation;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<MainBloc, MainState>(
        listener: (context, state) {
          if (state is CurrentLocationState) {
            setState(() {
              currentLocation = state.location;
              animatedMapMove(
                mapController: mapController,
                vsync: this,
                destLocation: currentLocation!,
                destZoom: 19,
              );
            });
          }
        },
        child: Stack(
          children: [
            MapView(
              showCurrentLocation: true,
              currentLocation: currentLocation,
              mapController: mapController,
            ),
            Positioned.fill(
              bottom: 50,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: GestureDetector(
                  onTap: () async {
                    print("center location : ${mapController.camera.center}");
                    await StorageAcess().setPickupLocation(
                      mapController.camera.center,
                    );
                    if (mounted) Navigator.of(context).pop();
                  },
                  child: SizedBox(
                    height: 50,
                    width: 150,
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                        child: Text("set Location"),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              bottom: 50,
              right: 10,
              child: Align(
                alignment: Alignment.bottomRight,
                child: GestureDetector(
                  onTap: () {
                    context.read<MainBloc>().add(GetCurrentLocation());
                  },
                  child: const SizedBox(
                    height: 50,
                    width: 50,
                    child: Card(
                      elevation: 3,
                      // shape: RoundedRectangleBorder(
                      //   // borderRadius: BorderRadius.circular(20),
                      // ),
                      child: Center(
                          child: Icon(
                        Icons.gps_fixed,
                      )),
                    ),
                  ),
                ),
              ),
            ),
            const Positioned.fill(
              bottom: 50,
              right: 10,
              child: Align(
                alignment: Alignment.center,
                child: SizedBox(
                  height: 50,
                  width: 50,
                  child: Center(
                    child: Icon(
                      Icons.pin_drop,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
