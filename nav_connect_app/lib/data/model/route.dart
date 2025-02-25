// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:latlong2/latlong.dart';

class Route {
  final String routename;
  final int order;
  final LatLng location;

  Route({
    required this.routename,
    required this.order,
    required this.location,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'route_name': routename,
      'order': order,
      'lat': location.latitude,
      'lang': location.longitude,
    };
  }

  factory Route.fromMap(Map<String, dynamic> map) {
    print("route map : $map");
    return Route(
      routename: map['route_name'] as String,
      order: map['order'] as int,
      location: LatLng(map['lat'] as double, map['lang'] as double),
    );
  }

  String toJson() => json.encode(toMap());

  factory Route.fromJson(String source) =>
      Route.fromMap(json.decode(source) as Map<String, dynamic>);
}
