import 'package:dom_camera/dom_camera.dart';
import 'package:dom_camera_example/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

class PictureList extends StatefulWidget {
  final String cameraId;

  const PictureList({required this.cameraId, Key? key}) : super(key: key);

  @override
  State<PictureList> createState() => _PictureListState();
}

class _PictureListState extends State<PictureList> {
  final _domCameraPlugin = DomCamera();

  late String cameraId;
  late List<Map<String, dynamic>> dataList;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    cameraId = widget.cameraId;

    getPlayBackList();
  }

  getPlayBackList() async {
    final result = await _domCameraPlugin.imageListInCamera();

    if (result["isError"]) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
      }

      setState(() {
        dataList = [];
        isLoading = false;
      });
      return;
    }

    if (result["dataList"] != null) {
      List<String> tempList1 = result["dataList"];

      List<Map<String, dynamic>> tempData = [];
      for (String element in tempList1) {
        tempData.add({'name': element, 'isDownloaded': false});
      }

      setState(() {
        dataList = tempData;
        isLoading = false;
      });
    } else {
      setState(() {
        dataList = [];
        isLoading = false;
      });
    }
  }

  Duration calculateTimeDifference(String startTime, String endTime) {
    final startDateTime = DateTime.parse(startTime);
    final endDateTime = DateTime.parse(endTime);
    return endDateTime.difference(startDateTime);
  }

  Widget playBackListWidget() {
    return Expanded(
      child: ListView.builder(
        itemCount: dataList.length,
        itemBuilder: (context, index) {
          Map<String, dynamic> item = dataList[index];
          return ListTile(
            leading: const Icon(Icons.photo),
            title: Text(item['name']),
            trailing: item['isDownloaded']
                ? null
                : IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: () async {
                      await _domCameraPlugin.imageDownloadFromCamera(index);

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Download Completed!")),
                        );
                      }
                    },
                  ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Images in: $cameraId',
        actions: [
          CustomAppBarAction(
            icon: Icons.refresh,
            callback: () => getPlayBackList(),
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 10),
            isLoading
                ? const Text("No Images Found")
                : const Text("Images List"),
            const SizedBox(height: 10),
            isLoading
                ? const CircularProgressIndicator()
                : dataList.isEmpty
                    ? const Text("No Images Found")
                    : playBackListWidget(),
          ],
        ),
      ),
    );
  }
}
