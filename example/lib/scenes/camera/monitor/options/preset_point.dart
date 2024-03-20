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

                        if (_isValidEnteredValue(enteredRange)) {
                          final data = await _domCameraPlugin
                              .turnToPreset(int.parse(enteredRange));

                          if (data["isError"]) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(data['message'])),
                              );
                            }
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Command successful"),
                                ),
                              );
                            }
                          }
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Invalid value"),
                              ),
                            );
                          }
                        }
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
                        if (_isValidEnteredValue(enteredValue)) {
                          final data = await _domCameraPlugin
                              .addPresetPoint(int.parse(enteredValue));

                          if (data["isError"]) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(data['message'])),
                              );
                            }
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Preset set successfully"),
                                ),
                              );
                            }
                          }
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Invalid value"),
                              ),
                            );
                          }
                        }
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

  bool _isValidEnteredValue(String value) {
    try {
      int parsedValue = int.parse(value);
      return parsedValue >= 1 && parsedValue <= 255;
    } catch (e) {
      return false;
    }
  }
}
