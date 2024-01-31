import 'package:dom_camera/dom_camera.dart';
import 'package:flutter/material.dart';

class NameChange extends StatefulWidget {
  final String cameraId;

  const NameChange({required this.cameraId, Key? key}) : super(key: key);

  @override
  State<NameChange> createState() => _NameChangeState();
}

class _NameChangeState extends State<NameChange> {
  late String cameraId;
  final _domCameraPlugin = DomCamera();

  bool isInitLoading = false;
  bool isSubmitting = false;
  String currentName = "";
  bool isEditing = false;

  final TextEditingController _newNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    cameraId = widget.cameraId;

    newData();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isEditing)
            Text('Current Camera Name: $currentName')
          else
            TextFormField(
              controller: _newNameController,
              decoration: const InputDecoration(labelText: 'New Camera Name'),
            ),
          const SizedBox(height: 16),
          if (!isEditing)
            ElevatedButton(
              onPressed: startEditing,
              child: const Text('Edit Camera Name'),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: cancelEditing,
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: submitNewName,
                  child: isSubmitting
                      ? const CircularProgressIndicator()
                      : const Text('Submit'),
                ),
              ],
            ),
        ],
      ),
    );
  }

  void startEditing() {
    setState(() {
      isEditing = true;
    });
  }

  void cancelEditing() {
    setState(() {
      isEditing = false;
    });
  }

  void submitNewName() async {
    setState(() {
      isSubmitting = true;
    });

    await _domCameraPlugin.setCameraName(_newNameController.text);

    cancelEditing();
    setState(() {
      currentName = _newNameController.text;
      isSubmitting = false;
      isInitLoading = false;
    });
  }

  void newData() async {
    setState(() {
      isInitLoading = true;
    });

    final data = await _domCameraPlugin.getCameraName();

    setState(() {
      currentName = data["details"];
      isInitLoading = false;
    });
  }

  @override
  void dispose() {
    _newNameController.dispose();
    super.dispose();
  }
}
