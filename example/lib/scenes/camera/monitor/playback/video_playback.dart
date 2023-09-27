import 'package:dom_camera/dom_camera.dart';
import 'package:dom_camera_example/scenes/camera/monitor/options/playback_time_widget.dart';
import 'package:dom_camera_example/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

class VideoPlayback extends StatefulWidget {
  final String cameraId;

  const VideoPlayback({required this.cameraId, Key? key}) : super(key: key);

  @override
  State<VideoPlayback> createState() => _VideoPlaybackState();
}

class _VideoPlaybackState extends State<VideoPlayback> {
  final _domCameraPlugin = DomCamera();

  late String cameraId;
  List<List<String>> dataList = [];
  bool isLoading = true;
  String startTime = "";
  String endTime = "";
  bool isPlaying = false;
  bool isMuted = true;

  @override
  void initState() {
    super.initState();

    cameraId = widget.cameraId;

    getPlayBackList();
  }

  getPlayBackList() async {
    final result = await _domCameraPlugin.playbackList();

    if (result["isError"]) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
      }
      return;
    }

    if (result["dataList"] != null) {
      List<dynamic> tempList1 = result["dataList"];
      List<List<String>> stringList = tempList1
          .map((item) => item.toString().split("__").toList())
          .toList();

      setState(() {
        dataList = stringList;
        isLoading = false;
        startTime = dataList[0][0];
        endTime = dataList[stringList.length - 1][1];
      });
    }
  }

  Duration calculateTimeDifference(String startTime, String endTime) {
    final startDateTime = DateTime.parse(startTime);
    final endDateTime = DateTime.parse(endTime);
    return endDateTime.difference(startDateTime);
  }

  void onItemClick(List<String> item, int index) {
    final result = _domCameraPlugin.playFromPosition(index);

    if (result["isError"]) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
      }
      return;
    }

    setState(() {
      isPlaying = true;
    });
  }

  Widget playBackListWidget() {
    return Expanded(
      child: ListView.builder(
        itemCount: dataList.length,
        itemBuilder: (context, index) {
          List<String> item = dataList[index];
          final timeDifference = calculateTimeDifference(item[0], item[1]);

          return ListTile(
            leading: const Icon(Icons.video_camera_back_rounded),
            title: Text(item[0].toString()),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("${timeDifference.inMinutes} min"),
                const SizedBox(width: 4),
                SizedBox(
                  width: 40,
                  child: TextButton(
                    onPressed: () async {
                      await _domCameraPlugin.downloadFromPosition(index);

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Download Completed!")),
                        );
                      }
                    },
                    child: const Icon(Icons.download),
                  ),
                ),
              ],
            ),
            subtitle: Text("To: ${item[1]}"),
            onTap: () {
              onItemClick(item, index);
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Playback: $cameraId',
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 240,
              child: DecoratedBox(
                decoration: const BoxDecoration(color: Colors.black),
                child: _domCameraPlugin.videoPlaybackWidget(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                    onPressed: () {
                      if (isPlaying) {
                        _domCameraPlugin.pausePlayBack();
                        setState(() {
                          isPlaying = false;
                        });
                      } else {
                        _domCameraPlugin.rePlayPlayBack();
                        setState(() {
                          isPlaying = true;
                        });
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(isMuted ? Icons.volume_off : Icons.volume_up),
                    onPressed: () {
                      if (isPlaying) {
                        if (isMuted) {
                          _domCameraPlugin.openAudioPlayBack();
                          setState(() {
                            isMuted = false;
                          });
                        } else {
                          _domCameraPlugin.closeAudioPlayBack();
                          setState(() {
                            isMuted = true;
                          });
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("No playback is running")),
                        );
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.camera_alt),
                    onPressed: () {
                      if (isPlaying) {
                        _domCameraPlugin.captureImageFromPlayBack();
                        const SnackBar(
                          content: Text("Snapshot saved to your Camera folder"),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("No playback is running"),
                          ),
                        );
                      }
                    },
                  ),
                  const Expanded(child: PlaybackTimeWidget())
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Text("List"),
            isLoading
                ? const Text("Empty list")
                : Text("Start Time: $startTime, End Time: $endTime"),
            isLoading
                ? const CircularProgressIndicator()
                : dataList.isEmpty
                    ? const Text("No Playbacks Found")
                    : playBackListWidget(),
          ],
        ),
      ),
    );
  }
}
