part of 'mapbloc_bloc.dart';

@immutable
sealed class MapblocState {}

final class MapblocInitial extends MapblocState {}

class MapsPolyLineCordinates extends MapblocState {
  final List<LatLng> points;
  

  MapsPolyLineCordinates({required this.points});
}

class CurrentBusLocationState extends MapblocState{
  final LatLng newLocation;

  CurrentBusLocationState({required this.newLocation});
}