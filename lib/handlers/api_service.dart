import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  final String baseURL = "https://camera.dom4u.in/api/v1";

  Future<Map<String, dynamic>> fetchMasterAccount() async {
    try {
      final response = await http.get(Uri.parse('$baseURL/camera/account'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'isError': false,
          'message': 'Device added successfully.',
          'account': data['account'],
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'isError': true,
          'message': errorData['message'],
        };
      }
    } catch (error) {
      return {
        'isError': true,
        'message': 'An error occurred: $error',
      };
    }
  }

  Future<Map<String, dynamic>> addDeviceToMasterAccount(
      String cameraId, String username) async {
    try {
      final response = await http.get(Uri.parse(
          '$baseURL/camera/add-device?cameraId=$cameraId&username=$username'));

      if (response.statusCode == 200) {
        return {
          'isError': false,
          'message': 'Device added successfully.',
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'isError': true,
          'message': errorData['message'],
        };
      }
    } catch (error) {
      return {
        'isError': true,
        'message': 'An error occurred: $error',
      };
    }
  }

  Future<Map<String, dynamic>> getDeviceMasterAccount(String cameraId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseURL/camera/device-user?cameraId=$cameraId'));

      if (response.statusCode == 200) {
        final details = json.decode(response.body);

        return {
          'isError': false,
          'account': details["account"],
          // 'isOnline': details["isOnline"] ?? false,
          // 'message': details["message"] ?? ""
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'isError': true,
          'message': errorData['message'],
        };
      }
    } catch (error) {
      return {
        'isError': true,
        'message': 'An error occurred: $error',
      };
    }
  }

  Future<Map<String, dynamic>> setDeviceAlarmCallback(
      String cameraId, String callbackUrl) async {
    try {
      final response = await http.get(Uri.parse(
          '$baseURL/camera/device-alarm-callback?cameraId=$cameraId&callbackUrl=$callbackUrl'));

      if (response.statusCode == 200) {
        final details = json.decode(response.body);

        if (details.isError) {
          return {'isError': true, 'message': details["message"]};
        } else {
          return {'isError': false};
        }
      } else {
        final errorData = json.decode(response.body);
        return {
          'isError': true,
          'message': errorData['message'],
        };
      }
    } catch (error) {
      return {
        'isError': true,
        'message': 'An error occurred: $error',
      };
    }
  }
}
