import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

const _startedId = 'AnimatedMapController#MoveStarted';
const _inProgressId = 'AnimatedMapController#MoveInProgress';
const _finishedId = 'AnimatedMapController#MoveFinished';

void animatedMapMove({
  required MapController mapController,
  required TickerProvider vsync,
  required LatLng destLocation,
  required double destZoom,
}) {
  final camera = mapController.camera;
  final latTween =
      Tween<double>(begin: camera.center.latitude, end: destLocation.latitude);
  final lngTween = Tween<double>(
      begin: camera.center.longitude, end: destLocation.longitude);
  final zoomTween = Tween<double>(begin: camera.zoom, end: destZoom);
  final controller = AnimationController(
      duration: const Duration(milliseconds: 500), vsync: vsync);
  final Animation<double> animation =
      CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);
  final startIdWithTarget =
      '$_startedId#${destLocation.latitude},${destLocation.longitude},$destZoom';
  bool hasTriggeredMove = false;

  controller.addListener(() {
    final String id;
    if (animation.value == 1.0) {
      id = _finishedId;
    } else if (!hasTriggeredMove) {
      id = startIdWithTarget;
    } else {
      id = _inProgressId;
    }

    hasTriggeredMove |= mapController.move(
      LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
      zoomTween.evaluate(animation),
      id: id,
    );
  });

  animation.addStatusListener((status) {
    if (status == AnimationStatus.completed) {
      controller.dispose();
    } else if (status == AnimationStatus.dismissed) {
      controller.dispose();
    }
  });

  controller.forward();
}
