import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:meta/meta.dart';
import 'package:sist_nav_connect/utils/helpers.dart';
import 'package:geolocator_platform_interface/src/enums/location_accuracy.dart'
    as ls; //location settings

part 'main_event.dart';
part 'main_state.dart';

class MainBloc extends Bloc<MainEvent, MainState> {
  Location location = Location();
  MainBloc() : super(MainInitial()) {
    on<GetLocationPermission>(onGetLocationPermission);
    on<GetCurrentLocation>(onGetCurrentLocation);
  }

  FutureOr<void> onGetLocationPermission(
    GetLocationPermission event,
    Emitter<MainState> emit,
  ) async {
    var permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        showToast("grant location permission");
        return;
      }
    }
  }

  FutureOr<void> onGetCurrentLocation(
    GetCurrentLocation event,
    Emitter<MainState> emit,
  ) async {
    add(GetLocationPermission());
    var locationEnabled = await location.serviceEnabled();
    if (!locationEnabled) {
      locationEnabled = await location.requestService();
      if (!locationEnabled) {
        return;
      }
    }
    locationEnabled = await location.serviceEnabled();
    // var currentLocation = await location.getLocation();
    // print("current location : $currentLocation");
    // if (currentLocation.latitude != null) {
    //   // emit(CurrentLocationState(
    //   //   location: LatLng(
    //   //     currentLocation.latitude!,
    //   //     currentLocation.longitude!,
    //   //   ),
    //   // ));
    // }
    if (locationEnabled) {
      const locationSettings = LocationSettings(
        accuracy: ls.LocationAccuracy.bestForNavigation,
      );
      await Geolocator.getPositionStream(locationSettings: locationSettings)
          .listen((Position position) {
        emit(CurrentLocationState(
          location: LatLng(
            position.latitude,
            position.longitude,
          ),
        ));
      }).asFuture();
    }
    // location.onLocationChanged.listen((LocationData currentLocation) {
    //   emit(CurrentLocation(locationData: currentLocation));
    // });
  }
}
