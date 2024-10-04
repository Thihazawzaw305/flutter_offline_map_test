import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_offline_map_test/PinScreen/pin_location_screen.dart';
import 'package:get/get.dart';
import 'package:mapsforge_flutter/core.dart';
import 'package:mapsforge_flutter/maps.dart';
import 'package:mapsforge_flutter/marker.dart';
import 'package:path_provider/path_provider.dart';
import 'map_display_controller.dart';

class MapDisplayScreen extends StatefulWidget {
  const MapDisplayScreen({Key? key}) : super(key: key);

  @override
  State<MapDisplayScreen> createState() => _MapDisplayScreenState();
}

class _MapDisplayScreenState extends State<MapDisplayScreen> {
  final MapDisplayController controller = Get.put(MapDisplayController()); // Instantiate the controller

  // Declare the required variables
  late final DisplayModel displayModel;
  late final SymbolCache symbolCache;
  late final MarkerDataStore markerDataStore;

  @override
  void initState() {
    super.initState();
    displayModel = DisplayModel(deviceScaleFactor: 2);
    symbolCache = FileSymbolCache();
    markerDataStore = MarkerDataStore();
  }

  Future<MapModel> _createMapModel() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String filePath = '${directory.path}/myanmar.map';
    final mapFile = await MapFile.from(filePath, null, null);
    final renderTheme = await RenderThemeBuilder.create(
      displayModel,
      'assets/render_themes/defaultrender.xml',
    );

    MapDataStoreRenderer jobRenderer = MapDataStoreRenderer(mapFile, renderTheme, symbolCache, true);

    MapModel mapModel = MapModel(
      displayModel: displayModel,
      renderer: jobRenderer,
    );

    mapModel.markerDataStores.add(markerDataStore);
    return mapModel;
  }

  Future<ViewModel> _createViewModel() async {
    ViewModel viewModel = ViewModel(displayModel: displayModel);
    viewModel.setMapViewPosition(17.011, 95.50);
    viewModel.setZoomLevel(8);

    viewModel.addOverlay(_MarkerOverlay(
      viewModel: viewModel,
      markerDataStore: markerDataStore,
      symbolCache: symbolCache,
      displayModel: displayModel,
      onMarkerUpdated: (latLong) {
        controller.updateMarkerPosition(latLong); // Update last marker position in controller
      },
    ));

    return viewModel;
  }

  void _navigateToPinScreen() {
    Get.to(PinLocationScreen(
      latLong: controller.lastLatLong.value, // Pass the last marker position from the controller
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text("Map Screen")),
      body: Stack(
        children: [
          MapviewWidget(
            displayModel: displayModel,
            createMapModel: _createMapModel,
            createViewModel: _createViewModel,
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: _navigateToPinScreen,
              child: const Icon(Icons.pin_drop),
            ),
          ),
        ],
      ),
    );
  }
}

class _MarkerOverlay extends StatefulWidget {
  final MarkerDataStore markerDataStore;
  final ViewModel viewModel;
  final SymbolCache symbolCache;
  final DisplayModel displayModel;
  final Function(LatLong) onMarkerUpdated;

  const _MarkerOverlay({
    required this.viewModel,
    required this.markerDataStore,
    required this.symbolCache,
    required this.displayModel,
    required this.onMarkerUpdated,
  });

  @override
  State<StatefulWidget> createState() {
    return _MarkerOverlayState();
  }
}

class _MarkerOverlayState extends State<_MarkerOverlay> {
  PoiMarker? _marker;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TapEvent>(
      stream: widget.viewModel.observeTap,
      builder: (BuildContext context, AsyncSnapshot<TapEvent> snapshot) {
        if (snapshot.data == null) return const SizedBox();

        // Remove the previous marker if it exists
        if (_marker != null) {
          widget.markerDataStore.removeMarker(_marker!);
        }

        // Create the marker using latitude and longitude from TapEvent
        _marker = PoiMarker(
          displayModel: widget.displayModel,
          src: 'assets/icons/marker.svg',
          height: 64,
          width: 48,
          latLong: LatLong(snapshot.data!.latitude, snapshot.data!.longitude),
          position: Position.ABOVE,
        );

        // Initialize resources and add marker
        _marker!.initResources(widget.symbolCache).then((value) {
          widget.markerDataStore.addMarker(_marker!);
          widget.markerDataStore.setRepaint();

          // Pass the LatLong to the callback
          widget.onMarkerUpdated(LatLong(snapshot.data!.latitude, snapshot.data!.longitude));
        });

        return const SizedBox();
      },
    );
  }
}
