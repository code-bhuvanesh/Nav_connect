import 'package:flutter/material.dart';
import 'package:sist_nav_connect/utils/helpers.dart';

import '../../utils/widgets/rectagle.dart';

class MapBottomSheet extends StatefulWidget {
  const MapBottomSheet({
    super.key,
    this.busDistance,
  });

  final double? busDistance;

  @override
  State<MapBottomSheet> createState() => _MapBottomSheetState();
}

class _MapBottomSheetState extends State<MapBottomSheet> {
  var sheetheight = 180.0;

  Container bottomSheet(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: sheetheight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            spreadRadius: 4,
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          sheetHandler(
            maxHeight: MediaQuery.of(context).size.height / 1.3,
            stopers: [sheetheight, 400, 800],
          ),
          (widget.busDistance != null)
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 15,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Bus no 26",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                        width: double.infinity,
                      ),
                      RichText(
                        text: TextSpan(
                          text: convertMeters(widget.busDistance!),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                          children: const [
                            TextSpan(
                              text: ' away',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          text: "will arrive in ",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 20.0,
                            fontWeight: FontWeight.normal,
                          ),
                          children: [
                            TextSpan(
                              text: convertMetersTime(widget.busDistance!),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : Container(
                  padding: const EdgeInsets.all(50),
                  child: const Text(
                    "Bus has not yet started",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget sheetHandler({
    required double maxHeight,
    double minHeight = 180.0,
    List<double> stopers = const [],
  }) {
    double? oldPostion;
    return GestureDetector(
      onTap: () => print("haodl"),
      onVerticalDragUpdate: (dragupdate) {
        // dragupdate.localPosition
        // print("pos : ${dragupdate.globalPosition.dy}");
        oldPostion ??= dragupdate.globalPosition.dy;
        // print("change : ${oldPostion! - dragupdate.globalPosition.dy}");
        var newsheetheight =
            sheetheight + oldPostion! - dragupdate.globalPosition.dy;
        setState(
          () {
            if (newsheetheight <= maxHeight && newsheetheight >= minHeight) {
              sheetheight = newsheetheight;
            }
          },
        );
        oldPostion = dragupdate.globalPosition.dy;
      },
      onVerticalDragEnd: (dragupdate) {
        if (stopers.isEmpty) return;
        var dif = double.infinity;
        // oldPostion = dragupdate..dy;
        var newsheetheight = sheetheight;
        stopers.forEach((element) {
          var newDif = (sheetheight - element).abs();
          print("dif : $newDif");
          if (newDif < dif) {
            newsheetheight = element;
            dif = newDif;
          }
        });

        setState(
          () {
            if (newsheetheight <= maxHeight && newsheetheight >= minHeight) {
              sheetheight = newsheetheight;
            }
          },
        );
      },
      child: Container(
        color: Colors.transparent,
        height: 20,
        width: 100,
        child: Center(
          child: CustomPaint(
            painter: DrawRectagle(-30, 4, 30, -4),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return bottomSheet(context);
  }
}
