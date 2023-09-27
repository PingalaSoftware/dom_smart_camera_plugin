import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> showAudioAlertDialog(context) {
  return showCupertinoDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) => CupertinoAlertDialog(
      title: const Text('Permission Denied'),
      content: const Text(
          'DOM Camera requires "Microphone" permission to open audio channel'),
      actions: <CupertinoDialogAction>[
        CupertinoDialogAction(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: () => {openAppSettings(), Navigator.of(context).pop()},
          child: const Text('Settings'),
        ),
      ],
    ),
  );
}

Future<void> textCopyDialog(
    context, String title, String message, String textToCopy) {
  TextEditingController textController = TextEditingController();
  textController.text = textToCopy;

  final localContext = context;

  return showCupertinoDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) => CupertinoAlertDialog(
      title: Text(title),
      content: Column(
        children: [
          const SizedBox(height: 5),
          Text(message),
          const SizedBox(height: 5),
          Material(
            child: Container(
              height: 30,
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).primaryColor),
                borderRadius: BorderRadius.circular(3),
              ),
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextField(
                      readOnly: true,
                      controller: textController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  GestureDetector(
                    onTap: () async {
                      await Clipboard.setData(ClipboardData(text: textToCopy));
                      ScaffoldMessenger.of(localContext).showSnackBar(
                        const SnackBar(content: Text("Copied to clipboard")),
                      );
                    },
                    child: Icon(
                      Icons.copy,
                      size: 20,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      actions: <CupertinoDialogAction>[
        CupertinoDialogAction(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Continue'),
        ),
      ],
    ),
  );
}

Future<void> locationAlertDialog(context) {
  return showCupertinoDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) => CupertinoAlertDialog(
      title: const Text('Permission Denied'),
      content: const Text(
          'Please enable location permission access WiFi information and try again'),
      actions: <CupertinoDialogAction>[
        CupertinoDialogAction(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: () => {openAppSettings(), Navigator.of(context).pop()},
          child: const Text('Settings'),
        ),
      ],
    ),
  );
}

Future<void> showCameraInitAlert(
    BuildContext context, Function onPressed) async {
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) => CupertinoAlertDialog(
      title: const Text('Initialising Camera'),
      content: const Text(
          'Please keep the camera in Connectivity Mode and press okay'),
      actions: <CupertinoDialogAction>[
        CupertinoDialogAction(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        CupertinoDialogAction(
          onPressed: () {
            Navigator.of(context).pop();
            onPressed();
          },
          child: const Text('Okay'),
        ),
      ],
    ),
  );
}

Future<void> showWifiConnectionAlert(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) => CupertinoAlertDialog(
      title: const Text('WiFi connection required'),
      content: const Text(
          'Please connect to the Wi-Fi to which the camera will be initialized and try again'),
      actions: <CupertinoDialogAction>[
        CupertinoDialogAction(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Okay'),
        ),
      ],
    ),
  );
}

Future<void> getWifiPasswordAlert(
  BuildContext context,
  wifiName,
  Function onPasswordEntered,
) async {
  TextEditingController passwordController = TextEditingController();

  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) => CupertinoAlertDialog(
      title: const Text('Enter Wi-Fi Password'),
      content: Column(
        children: <Widget>[
          Text(
              'Please enter the password for $wifiName network to connect with camera.'),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: CupertinoTextField(
              controller: passwordController,
              placeholder: 'Password',
              keyboardType: TextInputType.text,
              obscureText: true,
            ),
          ),
        ],
      ),
      actions: <CupertinoDialogAction>[
        CupertinoDialogAction(
          onPressed: () {
            if (passwordController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Please provide a Password")),
              );
              return;
            }
            if (passwordController.text.length < 8) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Invalid WiFi Password")),
              );
              return;
            }
            onPasswordEntered(passwordController.text);
            Navigator.of(context).pop();
          },
          child: const Text('Add Camera'),
        ),
      ],
    ),
  );
}

Future<void> showDeleteConfirmationDialog(
    BuildContext context, String cameraName, Function onPressed) async {
  return showCupertinoDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: const Text('Confirm Deletion'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('Remove camera id "$cameraName"?'),
            ],
          ),
        ),
        actions: <Widget>[
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          CupertinoDialogAction(
            child: const Text('Agree'),
            onPressed: () {
              onPressed();
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
