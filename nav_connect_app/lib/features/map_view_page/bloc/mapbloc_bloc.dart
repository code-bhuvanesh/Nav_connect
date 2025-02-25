import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:meta/meta.dart';
import 'package:sist_nav_connect/data/respository/location_socket.dart';
import 'package:sist_nav_connect/data/respository/open_map_api.dart';

part 'mapbloc_event.dart';
part 'mapbloc_state.dart';

class MapBloc extends Bloc<MapblocEvent, MapblocState> {
  var openMapApi = OpenMapApi();

  MapBloc() : super(MapblocInitial()) {
    on<GetMapPolylinePoints>(onGetMapPolylinePoints);
    on<ListenBusLocationEvent>(onListenBusLocationEvent);
    on<AddBusLocationEvent>(onAddBusLocationEvent);
  }

  FutureOr<void> onGetMapPolylinePoints(
    GetMapPolylinePoints event,
    Emitter<MapblocState> emit,
  ) async {
    var polylinepoints =
        await openMapApi.getInbetweenPoints(latLanPoints: event.points);
    emit(MapsPolyLineCordinates(points: polylinepoints));
  }

  FutureOr<void> onListenBusLocationEvent(
    ListenBusLocationEvent event,
    Emitter<MapblocState> emit,
  ) async {
    var locationSocket = LocationSocket();
    await locationSocket.start();
    late StreamSubscription<dynamic> locStreamSubscription;
    locStreamSubscription = locationSocket.ws.stream.listen((event) {
      var data = jsonDecode(event) as Map<String, dynamic>;
      // print(
      // "bus location event : ${(jsonDecode(event) as Map<String, dynamic>).runtimeType}");
      print("bus location event : ${data["current_lat"]}");
      var newLatLng = LatLng(
        data["current_lat"] as double,
        data["current_lang"] as double,
      );
      //cannot emit state create a new event add instead of emit
      if (!isClosed) {
        add(AddBusLocationEvent(location: newLatLng));
      } else {
        locStreamSubscription.cancel();
      }
    });
  }

  FutureOr<void> onAddBusLocationEvent(
    AddBusLocationEvent event,
    Emitter<MapblocState> emit,
  ) {
    emit(CurrentBusLocationState(newLocation: event.location));
  }
}
