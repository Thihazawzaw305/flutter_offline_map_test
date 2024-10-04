import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class MapDownloadController extends GetxController {
  var filePath = "File status will be displayed here".obs;
  var isDownloading = false.obs;
  var downloadProgress = 0.0.obs;
  var totalSize = 0.obs;
  var downloadedSize = 0.obs;
  var downloadCompleted = false.obs;
  var fileExists = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkFileExists();
  }

  Future<void> checkFileExists() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String filePathValue = '${directory.path}/myanmar.map';
    File file = File(filePathValue);

    if (await file.exists()) {
      filePath.value = "Map File already exists.";
      fileExists.value = true;
      downloadCompleted.value = true;
    } else {
      filePath.value = "Map File not found. Please download.";
      fileExists.value = false;
    }
  }

  Future<void> requestPermissionAndDownload() async {
    PermissionStatus permission = await Permission.storage.request();

    if (permission.isGranted) {
      downloadFile();
    } else {
      filePath.value = "Storage permission denied!";
    }
  }

  Future<void> downloadFile() async {
    const url = 'https://next-innovations.ltd/map/myanmar.map';
    int retryCount = 0; // Initialize retry count
    const int maxRetries = 3; // Maximum number of retries

    while (retryCount < maxRetries) {
      try {
        isDownloading.value = true;

        Directory directory = await getApplicationDocumentsDirectory();
        String filePathValue = '${directory.path}/myanmar.map';

        http.Client client = http.Client();
        http.Request request = http.Request('GET', Uri.parse(url));
        http.StreamedResponse response = await client.send(request);

        if (response.statusCode == 200) {
          totalSize.value = response.contentLength ?? 0;

          File file = File(filePathValue);
          var sink = file.openWrite();
          downloadedSize.value = 0; // Reset downloaded size

          response.stream.listen((data) {
            sink.add(data);
            downloadedSize.value += data.length;
            downloadProgress.value = downloadedSize.value / totalSize.value;
          }, onDone: () async {
            await sink.close();
            isDownloading.value = false;
            // Check if the file was completely downloaded
            if (downloadedSize.value == totalSize.value) {
              downloadCompleted.value = true;
              fileExists.value = true;
              filePath.value = "Download completed.";
            } else {
              downloadCompleted.value = false;
              filePath.value = "Download incomplete. Please try again.";
            }
          }, onError: (error) async {
            await sink.close(); // Close the sink on error
            throw error; // Rethrow error for retry logic
          });
          break; // Exit loop on successful download
        } else {
          isDownloading.value = false;
          filePath.value = "Failed to download file. Status code: ${response.statusCode}";
          break; // Exit loop if the response is not OK
        }
      } catch (e) {
        isDownloading.value = false;
        retryCount++;
        filePath.value = "Network error: $e. Retrying... ($retryCount/$maxRetries)";
        await Future.delayed(Duration(seconds: 2)); // Wait before retrying
        if (retryCount >= maxRetries) {
          filePath.value = "Failed to download after $maxRetries attempts.";
        }
      }
    }
  }
}
