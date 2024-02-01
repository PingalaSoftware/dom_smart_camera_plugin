import 'package:dom_camera/dom_camera.dart';
import 'package:dom_camera_example/components/button.dart';
import 'package:dom_camera_example/scenes/camera/monitor/options/playback_time_widget.dart';
import 'package:dom_camera_example/scenes/camera/monitor/playback/time_range_seekbar.dart';
import 'package:dom_camera_example/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class VideoPlayback extends StatefulWidget {
  final String cameraId;

  const VideoPlayback({required this.cameraId, Key? key}) : super(key: key);

  @override
  State<VideoPlayback> createState() => _VideoPlaybackState();
}

class _VideoPlaybackState extends State<VideoPlayback> {
  final _domCameraPlugin = DomCamera();
  DateTime selectedDateFrom = DateTime.now();
  DateTime selectedDateTo = DateTime.now();

  late String cameraId;
  List<List<String>> dataList = [];
  bool isListLoading = true;
  String startTime = "";
  String endTime = "";
  bool isPlaying = false;
  bool isMuted = true;

  bool isMainPlaybackLoading = false;

  bool isPlaybackLoading = false;

  @override
  void initState() {
    super.initState();

    cameraId = widget.cameraId;

    String formattedDateFrom = DateFormat('dd').format(selectedDateFrom);
    String formattedMonthFrom = DateFormat('MM').format(selectedDateFrom);
    String formattedYearFrom = DateFormat('yyyy').format(selectedDateFrom);

    String formattedDateTo = DateFormat('dd').format(selectedDateTo);
    String formattedMonthTo = DateFormat('MM').format(selectedDateTo);
    String formattedYearTo = DateFormat('yyyy').format(selectedDateTo);

    getPlayBackList(
      formattedDateFrom,
      formattedMonthFrom,
      formattedYearFrom,
      formattedDateTo,
      formattedMonthTo,
      formattedYearTo,
    );
  }

  getPlayBackList(String dateFrom, String monthFrom, String yearFrom,
      String dateTo, String monthTo, String yearTo) async {
    final result = await _domCameraPlugin.playbackList(
        dateFrom, monthFrom, yearFrom, dateTo, monthTo, yearTo);

    if (result["isError"]) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
      }
      setState(() {
        dataList = [];
        isListLoading = false;
      });
      return;
    }

    if (result["dataList"] != null) {
      List<dynamic> tempList1 = result["dataList"];
      List<List<String>> stringList = tempList1
          .map((item) => item.toString().split("__").toList())
          .toList();

      setState(() {
        dataList = stringList;
        isListLoading = false;
        startTime = dataList[0][0];
        endTime = dataList[stringList.length - 1][1];
      });
    } else {
      setState(() {
        dataList = [];
        isListLoading = false;
      });
    }
  }

  Future<void> _selectDateFrom(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDateFrom,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDateFrom) {
      setState(() {
        selectedDateFrom = picked;
      });
    }
  }

  Future<void> _selectDateTo(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDateTo,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDateTo) {
      setState(() {
        selectedDateFrom = picked;
      });
    }
  }

  void getListBasedOnDate() async {
    String formattedDateFrom = DateFormat('dd').format(selectedDateFrom);
    String formattedMonthFrom = DateFormat('MM').format(selectedDateFrom);
    String formattedYearFrom = DateFormat('yyyy').format(selectedDateFrom);

    String formattedDateTo = DateFormat('dd').format(selectedDateTo);
    String formattedMonthTo = DateFormat('MM').format(selectedDateTo);
    String formattedYearTo = DateFormat('yyyy').format(selectedDateTo);

    getPlayBackList(formattedDateFrom, formattedMonthFrom, formattedYearFrom,
        formattedDateTo, formattedMonthTo, formattedYearTo);
  }

  Duration calculateTimeDifference(String startTime, String endTime) {
    final startDateTime = DateTime.parse(startTime);
    final endDateTime = DateTime.parse(endTime);
    return endDateTime.difference(startDateTime);
  }

  void onItemClick(List<String> item, int index) async {
    setState(() {
      isPlaybackLoading = true;
      startTime = item[0];
      endTime = item[1];
    });
    final result = await _domCameraPlugin.playFromPosition(index);
    setState(() {
      isPlaybackLoading = false;
    });
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
    String formattedDateFrom =
        DateFormat('dd-MM-yyyy').format(selectedDateFrom);
    String formattedDateTo = DateFormat('dd-MM-yyyy').format(selectedDateTo);

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
                decoration: const BoxDecoration(color: Colors.redAccent),
                child: _domCameraPlugin.videoPlaybackWidget(),
              ),
            ),
            const SizedBox(height: 20),
            const TimeRangeSeekBar(),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Row(
                children: [
                  if (isPlaybackLoading) const CircularProgressIndicator(),
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
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).primaryColor),
                borderRadius: BorderRadius.circular(3),
              ),
              padding:
                  const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
              child: Column(
                children: [
                  const Text("Select from and to date"),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                          onTap: () => _selectDateFrom(context),
                          child: Text(
                            formattedDateFrom,
                            style: const TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Text("  -  "),
                        InkWell(
                          onTap: () => _selectDateTo(context),
                          child: Text(
                            formattedDateTo,
                            style: const TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        InkWell(
                          onTap: () => getListBasedOnDate(),
                          child: const OptionsButton(
                            text: "Go",
                            size: 50,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            isListLoading
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
