
import 'package:flutter/material.dart';
import 'package:flutter_offline_map_test/MapDisplayScreen/map_display_screen.dart';
import 'package:get/get.dart';
import 'map_download_controller.dart'; // Import the controller


class MapDownloadScreen extends StatelessWidget {
  final MapDownloadController controller = Get.put(MapDownloadController());

  // Navigate using Navigator.push
  void _navigateToMapDisplayScreen() {
    Get.to(MapDisplayScreen());
  }

  // Convert bytes to MB with two decimal points
  String _bytesToMB(int bytes) {
    return (bytes / (1024 * 1024)).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Map Download Screen'),
      ),
      body: Center(
        child: Obx(() { // Use Obx to listen for changes
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(controller.filePath.value),
              SizedBox(height: 20),
              controller.isDownloading.value
                  ? Column(
                children: [
                  Text('File Size: ${_bytesToMB(controller.totalSize.value)} MB'),
                  Text('Downloaded: ${_bytesToMB(controller.downloadedSize.value)} MB'),
                  Text('Progress: ${(controller.downloadProgress.value * 100).toStringAsFixed(2)}%'),
                ],
              )
                  : Container(),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: controller.fileExists.value || controller.isDownloading.value
                    ? null
                    : controller.requestPermissionAndDownload, // Disable if file exists or is downloading
                child: Text('Download Map'),
              ),
              SizedBox(height: 20),
              controller.downloadCompleted.value
                  ? ElevatedButton(
                onPressed: _navigateToMapDisplayScreen,
                child: Text('Go to Map Display'),
              )
                  : Container(),
            ],
          );
        }),
      ),
    );
  }
}
