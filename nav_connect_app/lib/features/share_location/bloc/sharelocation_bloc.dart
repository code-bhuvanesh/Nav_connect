import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:meta/meta.dart';

import '../../../data/respository/location_socket.dart';
import '../../../data/respository/open_map_api.dart';
import '../../../utils/helpers.dart';

part 'sharelocation_event.dart';
part 'sharelocation_state.dart';

class SharelocationBloc extends Bloc<SharelocationEvent, SharelocationState> {
  var openMapApi = OpenMapApi();

  SharelocationBloc() : super(SharelocationInitial()) {
    on<GetMapPolylinePoints>(onGetMapPolylinePoints);
    on<ListenBusLocationEvent>(onListenBusLocationEvent);
    on<AddBusLocationEvent>(onAddBusLocationEvent);
    on<UpdateCurrentLocation>(onUpdateCurrentLocation);
    on<LocationState>(onLocationState);
  }

  FutureOr<void> onGetMapPolylinePoints(
    GetMapPolylinePoints event,
    Emitter<SharelocationState> emit,
  ) async {
    var polylinepoints =
        await openMapApi.getInbetweenPoints(latLanPoints: event.points);
    emit(MapsPolyLineCordinates(points: polylinepoints));
  }

  FutureOr<void> onListenBusLocationEvent(
    ListenBusLocationEvent event,
    Emitter<SharelocationState> emit,
  ) async {
    var locationSocket = LocationSocket();
    await locationSocket.start();
    locationSocket.ws.stream.listen((event) {
      var data = jsonDecode(event) as Map<String, dynamic>;
      // print(
      // "bus location event : ${(jsonDecode(event) as Map<String, dynamic>).runtimeType}");
      print("bus location event : ${data["current_lat"]}");
      var newLatLng = LatLng(
        data["current_lat"] as double,
        data["current_lang"] as double,
      );
      //cannot emit state create a new event add instead of emit
      add(AddBusLocationEvent(location: newLatLng));
    });
  }

  FutureOr<void> onAddBusLocationEvent(
    AddBusLocationEvent event,
    Emitter<SharelocationState> emit,
  ) {
    emit(CurrentBusLocationState(newLocation: event.location));
  }

  FutureOr<void> onUpdateCurrentLocation(
    UpdateCurrentLocation event,
    Emitter<SharelocationState> emit,
  ) async {
    Location location = Location();
    var permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        showToast("grant location permission");
        return;
      }
    }
    var locationEnabled = await location.serviceEnabled();
    if (!locationEnabled) {
      locationEnabled = await location.requestService();
      if (!locationEnabled) {
        return;
      }
    }
    locationEnabled = await location.serviceEnabled();
    var currentLocation = await location.getLocation();
    print("current location : $currentLocation");
    try {
      var loc = LatLng(currentLocation.latitude!, currentLocation.longitude!);
      var locationSocket = LocationSocket();
      await locationSocket.start();
      var locData = {"lat": loc.latitude, "lang": loc.longitude};
      locationSocket.sendMsg(jsonEncode(locData));
      // add(LocationState(location: loc));
      emit(CurrentLocationState(location: loc));

      late StreamSubscription<dynamic> locStreamSubscription;
      locStreamSubscription = locationSocket.ws.stream.listen((event) async {
        print("new loc : $event");
        var currentLocation = await location.getLocation();
        if (currentLocation.latitude != null ||
            currentLocation.longitude != null) {
          if (!isClosed) {
            add(AddBusLocationEvent(
                location: LatLng(
              currentLocation.latitude!,
              currentLocation.longitude!,
            )));
          } else {
            locStreamSubscription.cancel();
          }

          locData = {
            "lat": currentLocation.latitude!,
            "lang": currentLocation.longitude!
          };
          locationSocket.sendMsg(jsonEncode(locData));
        }
      });
    } catch (e) {
      print(e);
    }

    // location.onLocationChanged.listen((LocationData currentLocation) {
    //   emit(CurrentLocation(locationData: currentLocation));
    // });
  }

  FutureOr<void> onLocationState(
    LocationState event,
    Emitter<SharelocationState> emit,
  ) {
    emit(CurrentLocationState(location: event.location));
  }
}
