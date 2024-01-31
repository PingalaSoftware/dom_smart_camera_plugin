import 'package:dom_camera/dom_camera.dart';
import 'package:dom_camera_example/components/button.dart';
import 'package:flutter/material.dart';

class PresetPoint extends StatefulWidget {
  const PresetPoint({Key? key}) : super(key: key);

  @override
  State<PresetPoint> createState() => _PresetPointState();
}

class _PresetPointState extends State<PresetPoint> {
  final _domCameraPlugin = DomCamera();
  TextEditingController presetRangeController = TextEditingController();
  TextEditingController enteredValueController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showPresetPointDialog(context);
      },
      child: OptionsButton(
        borderRadios: 12,
        text: "Preset point",
        backgroundColor: Theme.of(context).primaryColor,
        size: 50,
      ),
    );
  }

  void _showPresetPointDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Preset Point"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: presetRangeController,
                      decoration: const InputDecoration(
                        hintText: "Preset point [1-255]",
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: GestureDetector(
                      onTap: () async {
                        String enteredRange = presetRangeController.text;
                        print("Preset: 000 $enteredRange");
                        final result = await _domCameraPlugin
                            .turnToPreset(int.parse(enteredRange));
                        print("_domCameraPlugin result $result");
                      },
                      child: OptionsButton(
                        text: "Call",
                        size: 50,
                        textColor: Theme.of(context).primaryColor,
                        backgroundColor: Theme.of(context).secondaryHeaderColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              TextField(
                controller: enteredValueController,
                decoration: const InputDecoration(
                  hintText: "Enter value [1-255]",
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        String enteredValue = enteredValueController.text;
                        // if (_isValidEnteredValue(enteredValue)) {
                        //   // Perform actions for a valid entered value
                        // } else {
                        //   // Handle invalid entered value
                        // }

                        print("Preset: 000 $enteredValue");
                        final result = await _domCameraPlugin
                            .addPresetPoint(int.parse(enteredValue));
                        print("_domCameraPlugin add result $result");
                      },
                      child: const Text("Setup"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  bool _isValidPresetRange(String range) {
    return true;
  }

  bool _isValidEnteredValue(String value) {
    return true;
  }
}
