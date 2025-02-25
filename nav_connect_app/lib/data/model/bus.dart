// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:latlong2/latlong.dart';

import 'route.dart';

class Bus {
  final int busid;
  final int busNo;
  final int driverID;
  final String driverName;
  final LatLng currentLocation;
  final List<Route> routes;

  Bus({
    required this.busid,
    required this.busNo,
    required this.driverID,
    required this.driverName,
    required this.currentLocation,
    required this.routes,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'bus_id': busid,
      'bus_no': busNo,
      'driver_id': driverID,
      'driver_name': driverName,
      'bus_lat': currentLocation.latitude,
      'bus_lang': currentLocation.longitude,
      'routes': routes.map((x) => x.toMap()).toList(),
    };
  }

  factory Bus.fromMap(Map<String, dynamic> map) {
    return Bus(
      busid: map['bus_id'] as int,
      busNo: map['bus_no'] as int,
      driverID: map['driver_id'] as int,
      driverName: map['driver_name'] as String,
      currentLocation:
          LatLng(map['bus_lat'] as double, map['bus_lang'] as double),
      routes: (map['routes'] as List).map((e) => Route.fromMap(e)).toList(),
    );
  }

  String toJson() => json.encode(toMap());

  factory Bus.fromJson(String source) => Bus.fromMap(
        json.decode(source) as Map<String, dynamic>,
      );
}
