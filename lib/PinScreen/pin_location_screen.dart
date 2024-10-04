import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mapsforge_flutter/core.dart';

class PinLocationScreen extends StatelessWidget {
  final LatLong latLong;

  const PinLocationScreen({Key? key, required this.latLong}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Pin Location"),
      ),
      body: Center(
        child: latLong.latitude == 0 && latLong.longitude == 0
            ? const Text("There is no pin place")
            : Text("Latitude: ${latLong.latitude}, Longitude: ${latLong.longitude}"),
      ),
    );
  }
}
