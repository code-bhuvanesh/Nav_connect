import 'dart:math' as math;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:latlong2/latlong.dart';
export 'package:google_polyline_algorithm/google_polyline_algorithm.dart'
    show decodePolyline;

void showToast(String text) {
  Fluttertoast.cancel();
  Fluttertoast.showToast(msg: text);
}

extension PolylineExt on List<List<num>> {
  List<LatLng> unpackPolyline() =>
      map((p) => LatLng(p[0].toDouble(), p[1].toDouble())).toList();
}

double getDistance(LatLng point1, LatLng point2) {
  const double earthRadius = 6371000.0; // in meters

  double lat1 = point1.latitude * (3.141592653589793 / 180.0);
  double lon1 = point1.longitude * (3.141592653589793 / 180.0);
  double lat2 = point2.latitude * (3.141592653589793 / 180.0);
  double lon2 = point2.longitude * (3.141592653589793 / 180.0);

  double dLat = lat2 - lat1;
  double dLon = lon2 - lon1;

  double a = (math.sin(dLat / 2) * math.sin(dLat / 2)) +
      (math.cos(lat1) *
          math.cos(lat2) *
          math.sin(dLon / 2) *
          math.sin(dLon / 2));

  double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

  return earthRadius * c;
}

double getDistanceFromList(List<LatLng> points, {LatLng? end}) {
  double totalDistance = 0;
  if (end == null) {
    for (int i = 0; i < points.length - 1; i++) {
      LatLng point1 = points[i];
      LatLng point2 = points[i++];
      totalDistance += getDistance(point1, point2);
    }

    return totalDistance;
  } else {
    // for (var p in points) {
    //   print("point is true : ${p == end}");
    // }
    for (int i = 0; i < points.length - 1; i++) {
      LatLng point1 = points[i];
      LatLng point2 = points[i + 1];
      // print("distance from ${getDistance(point1, point2)}");
      totalDistance += getDistance(point1, point2);
      // print(
      //     "is same : ${point2.latitude == end.latitude && point2.longitude == end.longitude}");
      if (point2.latitude == end.latitude &&
          point2.longitude == end.longitude) {
        break;
      }
    }

    return totalDistance;
  }
}

List<LatLng> generatePoints(
    {required List<LatLng> points, double minDis = 100}) {
  List<LatLng> generatedPoints = [];

  // Calculate the distance between the two points
  int c = 0;
  while (c < points.length - 1) {
    double dis = getDistance(points[c], points[c + 1]);
    generatedPoints.add(points[c]);
    if (dis > minDis) {
      print("points :  ${points[c]}, ${points[c + 1]}");
      print("num points : ${dis ~/ minDis}");

      var gp = generateinBetweenPoints(points[c], points[c + 1], dis ~/ minDis);

      generatedPoints.addAll(gp);
      // generatedPoints.add(points[c + 1]);
    }
    c++;
  }
  print(" check ${points.last}, ${generatedPoints.last}");
  generatedPoints.add(points.last);
  return generatedPoints;
}

List<LatLng> generateinBetweenPoints(
    LatLng point1, LatLng point2, int numPoints) {
  List<LatLng> generatedPoints = [];

  // Calculate the distance between the two points
  // double totalDistance = getDistance(point1, point2);

  // Calculate the distance between each generated point
  // double intervalDistance = totalDistance / (numPoints + 1);

  // Generate points
  for (int i = 1; i <= numPoints; i++) {
    double ratio = i / (numPoints + 1);
    double intermediateLatitude =
        point1.latitude + ratio * (point2.latitude - point1.latitude);
    double intermediateLongitude =
        point1.longitude + ratio * (point2.longitude - point1.longitude);

    LatLng intermediatePoint =
        LatLng(intermediateLatitude, intermediateLongitude);
    generatedPoints.add(intermediatePoint);
  }

  return generatedPoints;
}

List<LatLng> findClosestLatLng(List<LatLng> points, LatLng targetLatLng,
    {bool onlyhalf = false}) {
  List<LatLng> generatedPoints = [];

  double minDistance = double.infinity;
  late int closestLatLng2 = 0;
  late int closestLatLng = 0;
  late LatLng closestPoint;
  for (var i = 0; i < points.length; i++) {
    double distance = getDistance(targetLatLng, points[i]);
    if (distance < minDistance) {
      minDistance = distance;
      closestLatLng = i;
      closestPoint = points[i];
    }
  }
  if (closestLatLng != 0) closestLatLng--;
  if (closestLatLng + 2 < points.length) {
    closestLatLng2 = closestLatLng + 2;
  } else {
    closestLatLng2 = closestLatLng + 1;
  }

  var dis = getDistance(points[closestLatLng], points[closestLatLng2]);
  var gp = generateinBetweenPoints(
      points[closestLatLng], points[closestLatLng2], dis ~/ 50);

  for (var i = 0; i < gp.length; i++) {
    double distance = getDistance(targetLatLng, gp[i]);
    if (distance < minDistance) {
      minDistance = distance;
      closestPoint = gp[i];
    }
  }
  if (!onlyhalf) {
    generatedPoints.addAll(points.sublist(0, closestLatLng + 1));
    generatedPoints.addAll(gp);
  }
  generatedPoints.add(closestPoint);
  generatedPoints.addAll(points.sublist(closestLatLng + 1));
  generatedPoints.add(closestPoint);

  return generatedPoints;
}

int compareDistances(LatLng reference, LatLng a, LatLng b) {
  double distanceA = getDistance(reference, a);
  double distanceB = getDistance(reference, b);

  return distanceA.compareTo(distanceB);
}

String convertMeters(double meters) {
  var m = meters;
  if (m > 999) {
    return "${(m / 1000).toStringAsFixed(1)} KM";
  }
  return "${m.toStringAsFixed(0)} M";
}

String convertMetersTime(double meters) {
  var time = (((meters / 1000) / 30)); //30 is speed of the bus
  if (time < 1.0) {
    return "${(time * 60).toStringAsFixed(0)} Min";
  }
  var hr = time.floorToDouble().toInt();
  var min = ((time - hr) * 60).toStringAsFixed(0);
  return "$hr Hr $min min";
}



final _random = math.Random();

int nextRandomInt(int min, int max) => min + _random.nextInt(max - min);