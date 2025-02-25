import 'dart:convert';
import 'dart:math';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

import '../../utils/helpers.dart';

class OpenMapApi {
  var client = http.Client();

  Future<String?> _getAccessToken(String clientId, String clientSecret) async {
    final url = Uri.parse(
        'https://account.olamaps.io/realms/olamaps/protocol/openid-connect/token');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'grant_type': 'client_credentials',
        'scope': 'openid',
        'client_id': clientId,
        'client_secret': clientSecret,
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      _accessToken == responseData['access_token'];
    } else {
      print(
          'Failed to obtain access token. Status code: ${response.statusCode}');
    }
    return null;
  }

  String? _accessToken;
  final _clientId = "9dc520e7-3b24-492b-b8c9-05a9512a6b3d";
  final _clientSecret = "QvTondtIT8GgkifqTP86dDAZfk4KzwxB";
  Future<List<LatLng>> getInbetweenPoints({
    // List<LatLng>? pointsLatLng,
    required List<List<double>> latLanPoints,
  }) async {
    // if (_accessToken == null) _getAccessToken(_clientId, _clientSecret);
    // if (_accessToken == null) return [];
    // var header = {
    //   "Content-Type": "application/json",
    //   "Authorization":
    //       "Bearer $_accessToken",
    // };
    String waypoints = "";
    if (latLanPoints.length > 2) {
      latLanPoints
          .sublist(1, latLanPoints.length - 1)
          .forEach((e) => waypoints += "${e[1]},${e[0]}|");
    }
    waypoints = waypoints.substring(0, waypoints.length - 1);
    var body = {
      "api_key": "TazIAv3R5Xuv1rwwiLCen7MN51yU4sZpQaMWzBoR",
      "origin": "${latLanPoints.first[1]}, ${latLanPoints.first[0]}",
      "destination": "${latLanPoints.last[1]}, ${latLanPoints.last[0]}",
    };

    if (waypoints != "") {
      body['waypoints'] = waypoints;
    }

    // var mapUrl = "https://api.openrouteservice.org/v2/directions/driving-car";
    var mapUrl = "https://api.olamaps.io/routing/v1/directions";

    print(body);
    var response = await client.post(
      Uri.https("api.olamaps.io", "/routing/v1/directions", body),
      // body: jsonEncode(body),
    );
    var data = jsonDecode(response.body) as Map<String, dynamic>;
    print(jsonEncode(body));
    try {
      print(data["routes"][0]["overview_polyline"]);
    }
    // ignore: empty_catches
    on Exception catch (_) {}
    var polyPointEncoded = data["routes"][0]["overview_polyline"];
    print("***********************************");
    // log(polyPointEncoded);
    print(decodePolyline(polyPointEncoded).unpackPolyline());
    return decodePolyline(polyPointEncoded).unpackPolyline();

    // return [];
  }
}
