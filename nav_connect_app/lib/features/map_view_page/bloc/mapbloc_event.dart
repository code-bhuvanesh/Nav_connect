part of 'mapbloc_bloc.dart';

@immutable
sealed class MapblocEvent {}

class GetMapPolylinePoints extends MapblocEvent {
  // final List<LatLng> points;
  final List<List<double>> points;
  

  GetMapPolylinePoints({required this.points});
  
}

class AddBusLocationEvent extends  MapblocEvent{
  final LatLng location;

  AddBusLocationEvent({required this.location});
}

class ListenBusLocationEvent extends MapblocEvent{
  final int busId;

  ListenBusLocationEvent({required this.busId});
}
