import 'package:dom_camera_example/scenes/camera/home_screen.dart';
import 'package:dom_camera_example/scenes/camera/monitor/camera_full_screen.dart';
import 'package:dom_camera_example/scenes/camera/monitor/camera_home_screen.dart';
import 'package:dom_camera_example/scenes/camera/monitor/monitor_home_screen.dart';
import 'package:dom_camera_example/scenes/camera/monitor/playback/picture_list.dart';
import 'package:dom_camera_example/scenes/camera/monitor/playback/video_playback.dart';
import 'package:dom_camera_example/scenes/camera/monitor/settings/setting_page.dart';
import 'package:dom_camera_example/utils/constants.dart';
import 'package:dom_camera_example/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case ScreenRoutes.homeScreen:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case ScreenRoutes.monitorHome:
        return MaterialPageRoute(builder: (_) => const MonitorHomeScreen());

      case ScreenRoutes.cameraHome:
        final args = settings.arguments as Map<String, dynamic>;

        return MaterialPageRoute(
            builder: (_) => CameraHomeScreen(cameraId: args["cameraId"]));

      case ScreenRoutes.videoPlayback:
        final args = settings.arguments as Map<String, dynamic>;

        return MaterialPageRoute(
            builder: (_) => VideoPlayback(cameraId: args["cameraId"]));

      case ScreenRoutes.pictureList:
        final args = settings.arguments as Map<String, dynamic>;

        return MaterialPageRoute(
            builder: (_) => PictureList(cameraId: args["cameraId"]));

      case ScreenRoutes.settingsPage:
        final args = settings.arguments as Map<String, dynamic>;

        return MaterialPageRoute(
            builder: (_) => SettingsPage(cameraId: args["cameraId"]));

      case ScreenRoutes.cameraFullScreen:
        return MaterialPageRoute(builder: (_) => const CameraFullScreen());

      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return const Scaffold(
        appBar: CustomAppBar(
          centerTitle: true,
          title: 'Error',
        ),
        body: Center(
          child: Text('#404'),
        ),
      );
    });
  }
}
