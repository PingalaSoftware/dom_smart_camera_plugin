import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddCameraWithSerialNumber extends StatefulWidget {
  final Function(String cameraId, String cameraType) onSubmit;

  const AddCameraWithSerialNumber({Key? key, required this.onSubmit})
      : super(key: key);

  @override
  State<AddCameraWithSerialNumber> createState() =>
      _AddCameraWithSerialNumberState();
}

class _AddCameraWithSerialNumberState extends State<AddCameraWithSerialNumber> {
  TextEditingController cameraIdController = TextEditingController();
  int selectedSegment = 0;
  final Map<int, String> cameraTypes = {
    0: 'NORMAL_IPC',
    1: 'LOW_POWERED',
  };

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: const Text('Adding Camera with Serial Number'),
      content: Column(
        children: [
          CupertinoTextField(
            placeholder: 'Enter Camera ID',
            controller: cameraIdController,
          ),
          const SizedBox(height: 8),
          CupertinoSlidingSegmentedControl(
            groupValue: selectedSegment,
            children: const {
              0: Text('NORMAL_IPC'),
              1: Text('LOW_POWERED'),
            },
            onValueChanged: (int? value) {
              setState(() {
                selectedSegment = value!;
              });
            },
          ),
        ],
      ),
      actions: [
        CupertinoDialogAction(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        CupertinoDialogAction(
          child: const Text('Submit'),
          onPressed: () {
            if (cameraIdController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Camera ID cannot be empty")),
              );
            } else {
              widget.onSubmit(
                  cameraIdController.text, cameraTypes[selectedSegment]!);
            }

            // widget.onSubmit(
            //     cameraIdController.text, cameraTypes[selectedSegment]!);
          },
        ),
      ],
    );
  }
}
