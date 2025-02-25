part of 'sharelocation_bloc.dart';

@immutable
sealed class SharelocationEvent {}

class GetMapPolylinePoints extends SharelocationEvent {
  // final List<LatLng> points;
  final List<List<double>> points;

  GetMapPolylinePoints({required this.points});
}

class AddBusLocationEvent extends SharelocationEvent {
  final LatLng location;

  AddBusLocationEvent({required this.location});
}

class ListenBusLocationEvent extends SharelocationEvent {
  final int busId;

  ListenBusLocationEvent({required this.busId});
}

class UpdateCurrentLocation extends SharelocationEvent {
  final int busID;

  UpdateCurrentLocation({required this.busID});
}

class LocationState extends SharelocationEvent{
  final LatLng location;

  LocationState({required this.location});
  
}
