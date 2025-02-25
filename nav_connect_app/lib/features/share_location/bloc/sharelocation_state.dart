part of 'sharelocation_bloc.dart';

@immutable
sealed class SharelocationState {}

final class SharelocationInitial extends SharelocationState {}

class MapsPolyLineCordinates extends SharelocationState {
  final List<LatLng> points;

  MapsPolyLineCordinates({required this.points});
}

class CurrentBusLocationState extends SharelocationState {
  final LatLng newLocation;

  CurrentBusLocationState({required this.newLocation});
}

class CurrentLocationState extends SharelocationState {
  final LatLng location;

  CurrentLocationState({required this.location});
}
