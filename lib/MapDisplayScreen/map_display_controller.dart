import 'package:get/get.dart';
import 'package:mapsforge_flutter/core.dart';

class MapDisplayController extends GetxController {
  var lastLatLong = LatLong(0, 0).obs; // Observable for storing the last marker position
  void updateMarkerPosition(LatLong latLong) {
    lastLatLong.value = latLong; // Update the last marker position
  }
}
